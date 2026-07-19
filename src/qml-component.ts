import { QObject, QProperty } from "@mocha/core";
import { Logger } from "@mocha/shared";
import { QMLTemplateParser, type ParsedQMLDocument, type QMLBindingMap } from "./qml-parser.js";
import { BindingEngine } from "./binding.js";

const logger = new Logger("QMLComponent");
const parser = new QMLTemplateParser();

export interface QMLComponentOptions {
  qml: string;
  imports?: string[];
  autoBind?: boolean;
  hotReload?: boolean;
  providedIn?: "root" | "view";
}

export interface QMLComponentMetadata {
  options: QMLComponentOptions;
  document: ParsedQMLDocument;
  bindings: QMLBindingMap;
  componentName: string;
  providedIn: "root" | "view";
}

const componentRegistry = new Map<Function, QMLComponentMetadata>();

export interface ProxyEntry {
  proxyId: number;
  instance: QObject;
  componentName: string;
}

export function QMLComponent(options: QMLComponentOptions) {
  return function <T extends { new (...args: any[]): any }>(target: T): T {
    const componentName = target.name;
    const document = parser.parse(options.qml);
    const bindings = parser.generateBindings(document, "controller");

    const metadata: QMLComponentMetadata = {
      options,
      document,
      bindings,
      componentName,
      providedIn: options.providedIn || "view",
    };

    componentRegistry.set(target, metadata);
    logger.debug(`Registered QML component: ${componentName}`);

    (target as any).__qmlComponent = metadata;
    (target as any).__qmlTemplate = options.qml;
    (target as any).__qmlDocument = document;
    (target as any).__qmlBindings = bindings;

    return target;
  };
}

export function getQMLComponentMetadata(
  component: Function
): QMLComponentMetadata | undefined {
  return componentRegistry.get(component);
}

export function getAllQMLComponents(): Map<Function, QMLComponentMetadata> {
  return new Map(componentRegistry);
}

export function generateQMLSource(
  component: QObject,
  metadata: QMLComponentMetadata,
  rootProxies?: ProxyEntry[]
): string {
  let qml = metadata.options.qml;

  // Transform controller.xxx bindings via global regex — robust against parser quirks
  qml = qml.replace(/controller\.(\w+)\.value\b/g, 'controller.get("$1")');
  qml = qml.replace(/controller\.(\w+)\s*\(\)/g, 'controller.bridgeCall("$1")');

  // If proxies exist, inject bridgeSeq bridge for reactive dependency
  if (rootProxies && rootProxies.length > 0) {
    for (const proxy of rootProxies) {
      const bridgeExpr = `readonly property int _bridge_${proxy.componentName}: ${proxy.componentName}.bridgeSeq`;
      if (!qml.includes(bridgeExpr)) {
        const braceIdx = qml.indexOf("{");
        if (braceIdx >= 0) {
          const before = qml.slice(0, braceIdx + 1);
          const after = qml.slice(braceIdx + 1);
          qml = `${before}\n    ${bridgeExpr}${after}`;
        }
      }

      // Wrap .get("X") calls with bridge dependency so QML bindings re-evaluate
      // QML only tracks property reads, not Q_INVOKABLE method calls.
      // The comma operator reads bridgeSeq (property → tracked) and returns get().
      const name = proxy.componentName;
      qml = qml.replace(
        new RegExp(name + '\\.get\\("([^"]*)"\\)', 'g'),
        `(${name}.bridgeSeq, ${name}.get("$1"))`
      );
    }
  }

  // Auto-inject Router lifecycle hooks if controller has routeLeave/routeEnter
  const hasLeave = typeof (component as any).routeLeave === "function";
  const hasEnter = typeof (component as any).routeEnter === "function";
  if ((hasLeave || hasEnter) && qml.includes("Router")) {
    let hooks = "";
    if (hasLeave) {
      hooks += `\n        onRouteLeave: (path) => controller.bridgeCall("routeLeave|" + JSON.stringify(path))`;
    }
    if (hasEnter) {
      hooks += `\n        onRouteEnter: (path) => controller.bridgeCall("routeEnter|" + JSON.stringify(path))`;
    }
    qml = qml.replace(/Router\s*\{/, `Router {${hooks}`);
  }

  // AutoBind: scan QML ids matching @qproperty names → inject bridgeCall
  if (metadata.options.autoBind) {
    const qprops = new Set<string>();
    let proto = Object.getPrototypeOf(component);
    while (proto && proto !== Object.prototype) {
      for (const key of Object.getOwnPropertyNames(proto)) {
        if (key.startsWith("__qproperty_")) {
          qprops.add(key.replace("__qproperty_", ""));
        }
      }
      proto = Object.getPrototypeOf(proto);
    }

    const elementBindings: Record<string, { signal: string; prop: string }> = {
      TextField: { signal: "onTextChanged", prop: "text" },
    };

    const lines = qml.split("\n");
    const elemStack: string[] = [];
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const elemMatch = line.match(/^\s*(\w+)\s*\{/);
      if (elemMatch) elemStack.push(elemMatch[1]);
      const closeMatch = line.match(/^\s*\}\s*$/);
      if (closeMatch && elemStack.length > 0) elemStack.pop();

      const idMatch = line.match(/\bid:\s*"(\w+)"|\bid:\s*(\w+)/);
      const idName = idMatch?.[1] ?? idMatch?.[2];
      if (idName && elemStack.length > 0 && qprops.has(idName)) {
        const elemType = elemStack[elemStack.length - 1];
        const binding = elementBindings[elemType];
        if (binding) {
          const indent = (line.match(/^(\s*)/)?.[1] ?? "    ");
          const inject = `${indent}${binding.signal}: controller.bridgeCall("_bind_${idName}|" + JSON.stringify(${binding.prop}))`;
          lines.splice(i + 1, 0, inject);
          i++;
        }
      }
    }
    qml = lines.join("\n");
  }

  return qml;
}

export function generateQMLFile(
  component: QObject,
  metadata: QMLComponentMetadata
): string {
  const header = [
    "import QtQuick 2.15",
    "import QtQuick.Controls 2.15",
    "import QtQuick.Layouts 1.15",
  ].join("\n");

  const body = generateQMLSource(component, metadata);

  return `${header}\n\n${body}`;
}
