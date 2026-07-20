import { Logger } from "@mocha/shared";
import { QObject, QProperty, effect, globalContainer, DebugServer } from "@mocha/core";
import { getQMLComponentMetadata, getAllQMLComponents, generateQMLSource, type ProxyEntry } from "./qml-component.js";
import { setNativeAppRef, createLazyViewChild, type ViewChildRef } from "./view-child.js";

const logger = new Logger("runApp");

let _debugServer: DebugServer | null = null;

export function getDebugServer() {
  return _debugServer;
}

export interface RunAppOptions {
  basePath?: string;
  onReady?: () => void;
  devtools?: DevToolsIntegration;
  fallbackMode?: "warn" | "error" | "silent";
}

export interface DevToolsIntegration {
  port?: number;
  host?: string;
  autoStart?: boolean;
}

export async function runApp<T extends QObject>(
  componentClass: new (...args: any[]) => T,
  options?: RunAppOptions
): Promise<void> {
  const meta = getQMLComponentMetadata(componentClass);
  if (!meta) {
    throw new Error(
      `No QML metadata found for "${componentClass.name}". ` +
      "Did you forget the @QMLComponent decorator?"
    );
  }

  let nativeApp: any = null;
  try {
    const { createNativeApp } = await import("@mocha/native");
    nativeApp = await createNativeApp();
  } catch (err) {
    const fallback = options?.fallbackMode ?? process.env.MOCHA_FALLBACK_MOCK ?? "warn";
    if (fallback === "error") {
      throw new Error(
        "@mocha/native native module not found and MOCHA_FALLBACK_MOCK=error set. " +
        "Run: cd packages/native && npx napi build --platform --release"
      );
    }
    if (fallback !== "silent") {
      logger.warn(
        "@mocha/native not available — using mock backend. " +
        "Properties and QML rendering will be simulated. " +
        "Set MOCHA_FALLBACK_MOCK=silent to suppress this message or MOCHA_FALLBACK_MOCK=error to fail hard."
      );
    }
    nativeApp = createMockNativeApp();
  }
    setNativeAppRef(nativeApp);

  const proxyEntries: ProxyEntry[] = [];

  // ── Root services ──
  const rootServices = scanRootServices();
  for (const service of rootServices) {
    const proxyId = nativeApp.createProxy();
    proxyEntries.push({ proxyId, instance: service.instance, componentName: service.componentName });

    const props = scanProperties(service.instance);
    for (const { name, qp } of props) {
      effect(() => {
        const val = qp.value;
        nativeApp.proxySetValue(proxyId, name, val);
      });
    }
    nativeApp.setContextProperty(service.componentName, proxyId);
  }

  // ── Main controller ──
  const controller = new componentClass();
  const CONTEXT_NAME = "controller";
  const mainProxyId = nativeApp.createProxy();
  proxyEntries.push({ proxyId: mainProxyId, instance: controller, componentName: CONTEXT_NAME });

    const mainProps = scanProperties(controller);
    logger.info(`[scanProperties] found ${mainProps.length} props on ${controller.constructor.name}`);
    for (const p of mainProps) {
      logger.info(`  - ${p.name}: initial=${JSON.stringify(p.qp.value)}`);
    }
    for (const { name, qp } of mainProps) {
      effect(() => {
        const val = qp.value;
        logger.debug(`[effect] ${name} = ${JSON.stringify(val)}`);
        nativeApp.proxySetValue(mainProxyId, name, val);
      });
    }
  nativeApp.setContextProperty(CONTEXT_NAME, mainProxyId);
  logger.info(`[setContextProperty] set ${CONTEXT_NAME} = proxyId ${mainProxyId}`);

  // ── Generate and load QML ──
  const qmlSource = generateQMLSource(controller, meta, proxyEntries);
  const qmlWithImports = [
    "import QtQuick",
    "import QtQuick.Controls",
    "import QtQuick.Layouts",
    "",
    qmlSource,
  ].join("\n");
  logger.info(`[QML generated] ${qmlWithImports.length} bytes, preview: ${qmlWithImports.slice(0, 300).replace(/\n/g, "\\n")}`);
  nativeApp.loadQML(qmlWithImports, options?.basePath || process.cwd());

  resolveViewChildren(controller);

  options?.onReady?.();

  // ── Debug Server ──
  const dt = options?.devtools ?? (process.env.MOCHA_DEVTOOLS ? { autoStart: true } : undefined);
  if (dt) {
    const dtPort = dt.port ?? parseInt(process.env.MOCHA_DEVTOOLS_PORT ?? "9229", 10);
    const dtHost = dt.host ?? process.env.MOCHA_DEVTOOLS_HOST ?? "localhost";
    _debugServer = new DebugServer({ port: dtPort, host: dtHost });
    if (dt.autoStart ?? true) {
      await _debugServer.start();
      _debugServer.attach(controller);
      _debugServer.startConsoleCapture();
      if (meta?.document?.root) {
        _debugServer.setQmlTree([meta.document.root]);
      }
      logger.info(`Debug server available at http://localhost:${_debugServer.port}`);
    }
  }

  // ── Event loop: interleave Qt events + Node.js event loop ──
  await runEventLoop(nativeApp, proxyEntries);

  // Cleanup debug server (frees port)
  if (_debugServer) {
    await _debugServer.stop();
  }
}

function drainPendingCalls(nativeApp: any, entries: ProxyEntry[]): boolean {
  for (const entry of entries) {
    const calls: string[] = nativeApp.proxyDrainPendingCalls(entry.proxyId);
    if (calls && calls.length > 0) {
      logger.info(`[drain] ${entry.componentName}: ${calls.length} calls`);
      for (const call of calls) {
        const sep = call.indexOf("|");
        const method = sep >= 0 ? call.slice(0, sep) : call;
        const args = sep >= 0 ? call.slice(sep + 1) : "";

        if (method.startsWith("_bind_")) {
          const propName = method.slice(6);
          const qp = (entry.instance as any)[propName];
          if (qp instanceof QProperty) {
            qp.value = args ? JSON.parse(args) : "";
          }
          continue;
        }

        // Check breakpoint BEFORE executing — stop immediately on hit
        if (_debugServer && _debugServer.interruptIfBreakpoint(method)) {
          logger.info(`[debug] Paused at breakpoint: ${method}`);
          return true;
        }

        logger.info(`  → ${method}(${args})`);

        const fn = (entry.instance as any)[method];
        if (typeof fn === "function") {
          if (args) {
            fn.call(entry.instance, JSON.parse(args));
          } else {
            fn.call(entry.instance);
          }
        }
      }
    }
  }
  return false;
}

function runEventLoop(nativeApp: any, entries: ProxyEntry[]): Promise<void> {
  return new Promise((resolve) => {
    let running = true;

    const tick = async () => {
      if (!running) { resolve(); return; }
      try { nativeApp.processEvents(); } catch { running = false; resolve(); return; }
      const breakpointHit = drainPendingCalls(nativeApp, entries);
      if (breakpointHit || (_debugServer && _debugServer.isPaused)) {
        await _debugServer!.waitWhilePaused();
      }
      if (running) setTimeout(tick, 8);
    };

    process.once("SIGINT", () => { running = false; });
    process.once("SIGTERM", () => { running = false; });
    tick();
  });
}

function scanRootServices(): Array<{ instance: QObject; componentName: string }> {
  const results: Array<{ instance: QObject; componentName: string }> = [];
  const all = getAllQMLComponents();
  for (const [cls, meta] of all.entries()) {
    if (meta.providedIn === "root") {
      const name = meta.componentName;
      let instance: QObject;
      if (globalContainer.has(cls as any)) instance = globalContainer.resolve(cls as any);
      else instance = new (cls as any)();
      results.push({ instance, componentName: name });
    }
  }
  return results;
}

function scanProperties(instance: QObject): Array<{ name: string; qp: QProperty }> {
  const props: Array<{ name: string; qp: QProperty }> = [];
  const visited = new Set<string>();

  // Strategy 1: walk prototype chain looking for __qproperty_ metadata (legacy)
  let proto = Object.getPrototypeOf(instance);
  while (proto && proto !== Object.prototype) {
    for (const key of Object.getOwnPropertyNames(proto)) {
      if (key.startsWith("__qproperty_")) {
        const propName = key.replace("__qproperty_", "");
        if (visited.has(propName)) continue;
        visited.add(propName);
        const val = (instance as any)[propName];
        if (val instanceof QProperty) props.push({ name: propName, qp: val });
      }
    }
    proto = Object.getPrototypeOf(proto);
  }

  // Strategy 2: scan instance own properties for QProperty instances (works without decorator metadata)
  for (const key of Object.getOwnPropertyNames(instance)) {
    if (visited.has(key)) continue;
    if (key.startsWith("_")) continue;
    const val = (instance as any)[key];
    if (val instanceof QProperty) {
      visited.add(key);
      props.push({ name: key, qp: val });
    }
  }

  return props;
}

function resolveViewChildren(controller: QObject): void {
  const proto = Object.getPrototypeOf(controller);
  const keys = Object.getOwnPropertyNames(controller).concat(
    ...getAllProtoKeys(controller)
  );
  for (const key of keys) {
    const val = (controller as any)[key];
    if (val && val.__viewChild) {
      (controller as any)[key] = createLazyViewChild(val as ViewChildRef<any>);
    }
  }
}

function getAllProtoKeys(obj: any): string[] {
  const result: string[] = [];
  let proto = Object.getPrototypeOf(obj);
  while (proto && proto !== Object.prototype) {
    result.push(...Object.getOwnPropertyNames(proto));
    proto = Object.getPrototypeOf(proto);
  }
  return result;
}

function createMockNativeApp() {
  return {
    loadQML: () => {}, setProperty: () => {}, getProperty: () => "",
    createProxy: () => 0, proxySetValue: () => {}, proxyGetValue: () => "",
    proxyDrainPendingCalls: () => [], setContextProperty: () => {},
    processEvents: () => {}, exec: () => 0, quit: () => {},
    registerAppObjects: () => {},
    listRootObjects: () => [] as any[],
    listChildren: () => [] as any[],
    getQmlProperty: () => "",
    getQmlProperties: () => [] as any[],
    setQmlProperty: () => {},
  };
}
