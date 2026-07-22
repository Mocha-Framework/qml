import { Logger } from "@mocha/shared";
import { QObject, QProperty, QComputedProperty, effect, globalContainer, DebugServer } from "@mocha/core";
import { getQMLComponentMetadata, getAllQMLComponents, generateQMLSource, generateInnerQML, type ProxyEntry } from "./qml-component.js";
import { setNativeAppRef, createLazyViewChild, type ViewChildRef } from "./view-child.js";
import * as fs from "node:fs";
import * as path from "node:path";

// ThemeData interface — duck-typed, avoids composit-build import issues with @mocha/tokens
export interface ThemeLike {
  toQMLOverrides(): Record<string, string>;
}

const logger = new Logger("runApp");

let _debugServer: DebugServer | null = null;

let _brandThemeProxyId: number | null = null;
let _brandThemeNativeApp: any = null;

export function switchTheme(theme: ThemeLike): void {
  if (!_brandThemeNativeApp || _brandThemeProxyId === null) {
    logger.warn("[theme] switchTheme called but _brandTheme not initialized");
    return;
  }
  const overrides = theme.toQMLOverrides();
  for (const [key, value] of Object.entries(overrides)) {
    _brandThemeNativeApp.proxySetValue(_brandThemeProxyId, key, value);
  }
  logger.info(`[theme] switchTheme: updated ${Object.keys(overrides).length} overrides`);
}

export function getDebugServer() {
  return _debugServer;
}

export interface RunAppOptions {
  basePath?: string;
  onReady?: () => void;
  devtools?: DevToolsIntegration;
  fallbackMode?: "warn" | "error" | "silent";
  watch?: boolean;
  theme?: ThemeLike;
}

export interface DevToolsIntegration {
  port?: number;
  host?: string;
  autoStart?: boolean;
}

interface AppContext {
  nativeApp: any;
  proxyEntries: ProxyEntry[];
  controller: any;
  meta: any;
  componentClass: any;
  options?: RunAppOptions;
  propsSnapshot: Map<string, unknown>;
  shellLoaded: boolean;
}

let _currentCtx: AppContext | null = null;

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

  if (_currentCtx) {
    logger.info(`[HMR] runApp() called again — reusing existing ctx (shellLoaded=${_currentCtx.shellLoaded})`);
    _currentCtx.componentClass = componentClass;
    if (options) _currentCtx.options = options;
    await bindControllerToQML(_currentCtx);
    return;
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
  // Expose for inspection in dev/test scripts
  (globalThis as any).__mochaNative = nativeApp;

  const ctx: AppContext = {
    nativeApp,
    proxyEntries: [],
    controller: null,
    meta,
    componentClass,
    options,
    propsSnapshot: new Map(),
    shellLoaded: false,
  };
  _currentCtx = ctx;

  await bindControllerToQML(ctx);

  try {
    await startDebugServer(ctx);
  } catch (err) {
    logger.warn(`Debug server failed to start (app will run without debugger): ${(err as any)?.message ?? err}`);
  }

  if (options?.watch || process.env.MOCHA_ENV === "development") {
    startWatchMode(ctx);
  }

  await runEventLoop(nativeApp, ctx.proxyEntries);

  if (_debugServer) {
    try { await _debugServer.stop(); } catch {}
  }
}

async function bindControllerToQML(ctx: AppContext): Promise<void> {
  const { nativeApp } = ctx;
  ctx.proxyEntries.length = 0;

  const rootServices = scanRootServices();
  for (const service of rootServices) {
    const proxyId = nativeApp.createProxy();
    ctx.proxyEntries.push({ proxyId, instance: service.instance, componentName: service.componentName });

    const props = scanProperties(service.instance);
    for (const { name, qp } of props) {
      if (qp instanceof QComputedProperty) {
        qp.changed.connect((val: any) => nativeApp.proxySetValue(proxyId, name, val));
        nativeApp.proxySetValue(proxyId, name, qp.value);
      } else {
        effect(() => {
          const val = qp.value;
          nativeApp.proxySetValue(proxyId, name, val);
        });
      }
    }
    nativeApp.setContextProperty(service.componentName, proxyId);
  }

  const controller = new ctx.componentClass();
  ctx.controller = controller;
  const CONTEXT_NAME = "controller";
  const mainProxyId = nativeApp.createProxy();
  ctx.proxyEntries.push({ proxyId: mainProxyId, instance: controller, componentName: CONTEXT_NAME });

  const mainProps = scanProperties(controller);
  logger.info(`[scanProperties] found ${mainProps.length} props on ${controller.constructor.name}`);
  for (const p of mainProps) {
    logger.info(`  - ${p.name}: initial=${JSON.stringify(p.qp.value)}${p.qp instanceof QComputedProperty ? " [computed]" : ""}`);
    if (ctx.propsSnapshot.has(p.name) && !(p.qp instanceof QComputedProperty)) {
      p.qp.value = ctx.propsSnapshot.get(p.name);
    }
  }
  for (const { name, qp } of mainProps) {
    if (qp instanceof QComputedProperty) {
      qp.changed.connect((val: any) => {
        logger.debug(`[computed] ${name} = ${JSON.stringify(val)}`);
        nativeApp.proxySetValue(mainProxyId, name, val);
      });
      nativeApp.proxySetValue(mainProxyId, name, qp.value);
    } else {
      effect(() => {
        const val = qp.value;
        logger.debug(`[effect] ${name} = ${JSON.stringify(val)}`);
        nativeApp.proxySetValue(mainProxyId, name, val);
      });
    }
  }
  nativeApp.setContextProperty(CONTEXT_NAME, mainProxyId);
  logger.info(`[setContextProperty] set ${CONTEXT_NAME} = proxyId ${mainProxyId}`);

  // Inject brand theme overrides before QML loads
  if (ctx.options?.theme) {
    injectThemeOverrides(nativeApp, ctx.options.theme);
  }

  const newMeta = getQMLComponentMetadata(controller.constructor) || ctx.meta;
  const qmlSource = generateQMLSource(controller, newMeta, ctx.proxyEntries);
  const qmlWithImports = [
    "import QtQuick",
    "import QtQuick.Controls",
    "import QtQuick.Layouts",
    "",
    qmlSource,
  ].join("\n");
  logger.info(`[QML generated] ${qmlWithImports.length} bytes, preview: ${qmlWithImports.slice(0, 300).replace(/\n/g, "\\n")}`);

  const { innerQML: inner, imports: innerImports } = generateInnerQML(qmlSource, newMeta.options.qml);
  const allImports = [...new Set([
    "import QtQuick",
    "import QtQuick.Controls",
    "import QtQuick.Layouts",
    ...innerImports,
    ...(newMeta.options.imports || []),
  ])];
  const innerWithImports = [...allImports, "", inner].join("\n");

  logger.info(`[HMR shell] innerQML=${inner.length}b, imports=[${allImports.join(", ")}], shellLoaded=${ctx.shellLoaded}`);
  logger.info(`[HMR shell] content preview: ${innerWithImports.slice(0, 500).replace(/\n/g, "\\n")}`);

  if (!ctx.shellLoaded) {
    ctx.nativeApp.loadShell(ctx.options?.basePath || process.cwd());
    ctx.shellLoaded = true;
    ctx.nativeApp.setShellSource(innerWithImports);
    extractWindowProps(qmlSource, ctx.nativeApp);
  } else {
    ctx.nativeApp.setShellSource(innerWithImports);
    extractWindowProps(qmlSource, ctx.nativeApp);
  }

  ctx.meta = newMeta;

  applyDarkTitleBar(nativeApp);

  resolveViewChildren(controller);

  ctx.options?.onReady?.();
}

function startWatchMode(ctx: AppContext): void {
  const basePath = process.env.MOCHA_ENTRY_DIR || ctx.options?.basePath || process.cwd();

  let srcDir = path.join(basePath, "src");
  if (!fs.existsSync(srcDir)) {
    srcDir = basePath;
  }

  if (!fs.existsSync(srcDir)) {
    logger.warn(`Watch directory not found: ${srcDir} — watch mode disabled`);
    return;
  }

  let reloadTimer: ReturnType<typeof setTimeout> | null = null;

  const handleFileChange = async (filename: string) => {
    if (!filename || !filename.endsWith(".qml.ts")) return;

    if (reloadTimer) clearTimeout(reloadTimer);

    reloadTimer = setTimeout(async () => {
      const changedPath = path.resolve(srcDir, filename);
      logger.info(`[HMR] File changed: ${filename}`);

      const snapshot = captureState(ctx.controller);
      ctx.propsSnapshot = snapshot;

      try {
        const ts = Date.now();
        const newMod = await import(`${changedPath}?t=${ts}`);
        const NewClass = findComponentClass(newMod);

        if (NewClass && NewClass !== ctx.componentClass) {
          ctx.componentClass = NewClass;
          logger.info(`[HMR] New component class: ${NewClass.name}`);
        }

        await bindControllerToQML(ctx);
        const elapsed = Date.now() - ts;
        logger.info(`[HMR] Reloaded in ${elapsed}ms`);
      } catch (err) {
        logger.error(`[HMR] Reload failed: ${filename}`, err);
      }
    }, 100);
  };

  // Primary: fs.watch (event-driven, instant)
  try {
    const watcher = fs.watch(srcDir, { recursive: true }, (_event, filename) => {
      if (filename) handleFileChange(filename);
    });
    watcher.on("error", (err) => {
      logger.warn(`[HMR] fs.watch error: ${(err as any)?.message ?? err} — falling back to polling`);
      startPollingFallback(srcDir, handleFileChange);
    });
    logger.info(`[HMR] Watching ${srcDir} for .qml.ts changes (fs.watch)...`);
  } catch (err) {
    logger.warn(`[HMR] fs.watch failed: ${(err as any)?.message ?? err} — using polling`);
    startPollingFallback(srcDir, handleFileChange);
  }
}

function startPollingFallback(srcDir: string, onChange: (filename: string) => void): void {
  // Poll all .qml.ts files in the directory using fs.watchFile (stat-based)
  const files: string[] = [];
  try {
    for (const entry of fs.readdirSync(srcDir, { recursive: true })) {
      const name = String(entry);
      if (name.endsWith(".qml.ts")) {
        files.push(name);
        const fullPath = path.join(srcDir, name);
        fs.watchFile(fullPath, { interval: 500 }, (curr, prev) => {
          if (curr.mtimeMs !== prev.mtimeMs) {
            onChange(name);
          }
        });
      }
    }
    logger.info(`[HMR] Polling ${files.length} .qml.ts files in ${srcDir}...`);
  } catch (err) {
    logger.error(`[HMR] Polling setup failed: ${(err as any)?.message ?? err}`);
  }
}

function findComponentClass(mod: any): any | null {
  for (const key of Object.keys(mod)) {
    const exported = mod[key];
    if (typeof exported === "function" && exported.prototype instanceof QObject) {
      return exported;
    }
  }
  return null;
}

function captureState(controller: any): Map<string, unknown> {
  const state = new Map<string, unknown>();
  if (!controller) return state;
  for (const key of Object.keys(controller)) {
    const value = (controller as any)[key];
    if (value instanceof QProperty) {
      state.set(key, value.value);
    }
  }
  return state;
}

async function startDebugServer(ctx: AppContext): Promise<void> {
  const dt = ctx.options?.devtools ?? (process.env.MOCHA_DEVTOOLS ? { autoStart: true } : undefined);
  if (dt) {
    const dtPort = dt.port ?? parseInt(process.env.MOCHA_DEVTOOLS_PORT ?? "9229", 10);
    const dtHost = dt.host ?? process.env.MOCHA_DEVTOOLS_HOST ?? "localhost";
    _debugServer = new DebugServer({ port: dtPort, host: dtHost });
    if (dt.autoStart ?? true) {
      await _debugServer.start();
      _debugServer.attach(ctx.controller);
      _debugServer.startConsoleCapture();
      if (ctx.meta?.document?.root) {
        _debugServer.setQmlTree([ctx.meta.document.root]);
      }
      logger.info(`Debug server available at http://localhost:${_debugServer.port}`);
    }
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

        if (_debugServer && _debugServer.interruptIfBreakpoint(method)) {
          logger.info(`[debug] Paused at breakpoint: ${method}`);
          return true;
        }

        if (method.startsWith("_bind_")) {
          const propName = method.slice(6);
          const qp = (entry.instance as any)[propName];
          if (qp instanceof QProperty) {
            qp.value = args ? JSON.parse(args) : "";
            logger.debug(`[autoBind] ${propName} = ${JSON.stringify(qp.value)}`);
          } else {
            logger.warn(`[autoBind] _bind_ target "${propName}" is not a QProperty on ${entry.componentName}`);
          }
          continue;
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

function scanProperties(instance: QObject): Array<{ name: string; qp: QProperty | QComputedProperty<any> }> {
  const props: Array<{ name: string; qp: QProperty | QComputedProperty<any> }> = [];
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
      if (key.startsWith("__qcomputed_")) {
        const propName = key.replace("__qcomputed_", "");
        if (visited.has(propName)) continue;
        visited.add(propName);
        const val = (instance as any)[propName];
        if (val instanceof QComputedProperty) props.push({ name: propName, qp: val });
      }
    }
    proto = Object.getPrototypeOf(proto);
  }

  for (const key of Object.getOwnPropertyNames(instance)) {
    if (visited.has(key)) continue;
    if (key.startsWith("_")) continue;
    const val = (instance as any)[key];
    if (val instanceof QProperty || val instanceof QComputedProperty) {
      visited.add(key);
      props.push({ name: key, qp: val });
    }
  }

  return props;
}

function extractWindowProps(qml: string, nativeApp: any): void {
  const titleMatch = qml.match(/title:\s*["']([^"']+)["']/);
  const widthMatch = qml.match(/width:\s*(\d+)/);
  const heightMatch = qml.match(/height:\s*(\d+)/);
  nativeApp.setShellWindowProps({
    title: titleMatch?.[1],
    width: widthMatch ? parseInt(widthMatch[1]) : undefined,
    height: heightMatch ? parseInt(heightMatch[1]) : undefined,
  });
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

function applyDarkTitleBar(nativeApp: any): void {
  try {
    const dark = nativeApp.getProperty("darkTitleBar");
    if (dark === "true" || dark === true) {
      nativeApp.setDarkTitleBar(true);
      logger.info("[darkTitleBar] Applied dark native title bar");
    }
  } catch {
    // ApplicationWindow may not be the root object — skip silently
  }
}

function injectThemeOverrides(nativeApp: any, theme: ThemeLike): void {
  const overrides = theme.toQMLOverrides();
  const proxyId = nativeApp.createProxy();
  _brandThemeProxyId = proxyId;
  _brandThemeNativeApp = nativeApp;
  for (const [key, value] of Object.entries(overrides)) {
    nativeApp.proxySetValue(proxyId, key, value);
  }
  nativeApp.setContextProperty("_brandTheme", proxyId);
  logger.info(`[theme] Injected ${Object.keys(overrides).length} brand theme overrides`);
}

function createMockNativeApp() {
  return {
    loadQML: () => {}, reloadQML: () => 0, setProperty: () => {}, getProperty: () => "",
    createProxy: () => 0, proxySetValue: () => {}, proxyGetValue: () => "",
    proxyDrainPendingCalls: () => [], setContextProperty: () => {},
    processEvents: () => {}, exec: () => 0, quit: () => {},
    registerAppObjects: () => {},
    listRootObjects: () => [] as any[],
    listChildren: () => [] as any[],
    getQmlProperty: () => "",
    getQmlProperties: () => [] as any[],
    setQmlProperty: () => {},
    findChild: () => 0,
    getRootObject: () => 0,
    setDarkTitleBar: () => {},
    startSystemMove: () => {},
    loadShell: () => {},
    setShellSource: () => {},
    setShellWindowProps: () => {},
  };
}
