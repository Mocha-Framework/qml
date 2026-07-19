import { QObject, QProperty, effect, globalContainer } from "@mocha/core";
import { getQMLComponentMetadata, getAllQMLComponents, generateQMLSource, type ProxyEntry } from "./qml-component.js";
import { setNativeAppRef, createLazyViewChild, type ViewChildRef } from "./view-child.js";

export interface RunAppOptions {
  basePath?: string;
  onReady?: () => void;
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
    } catch {
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
    for (const { name, qp } of mainProps) {
      effect(() => {
        const val = qp.value;
        nativeApp.proxySetValue(mainProxyId, name, val);
      });
    }
  nativeApp.setContextProperty(CONTEXT_NAME, mainProxyId);

  // ── Generate and load QML ──
  const qmlSource = generateQMLSource(controller, meta, proxyEntries);
  nativeApp.loadQML(qmlSource, options?.basePath || process.cwd());

  resolveViewChildren(controller);

  options?.onReady?.();

  // ── Event loop: interleave Qt events + Node.js event loop ──
  await runEventLoop(nativeApp, proxyEntries);
}

function drainPendingCalls(nativeApp: any, entries: ProxyEntry[]): void {
  for (const entry of entries) {
    const calls: string[] = nativeApp.proxyDrainPendingCalls(entry.proxyId);
    if (calls && calls.length > 0) {
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
}

function runEventLoop(nativeApp: any, entries: ProxyEntry[]): Promise<void> {
  return new Promise((resolve) => {
    let running = true;

    const tick = () => {
      if (!running) { resolve(); return; }
      try { nativeApp.processEvents(); } catch { running = false; resolve(); return; }
      drainPendingCalls(nativeApp, entries);
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
  };
}
