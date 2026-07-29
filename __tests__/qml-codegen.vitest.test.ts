import { describe, expect, it } from "vitest";
import { QObject, QProperty } from "@mocha/core";
import {
  generateInnerQML,
  generateQMLSource,
  applyInjections,
  generateQMLFile,
  QMLComponent,
  getQMLComponentMetadata,
} from "../src/qml-component.js";
import { QMLTemplateParser } from "../src/qml-parser.js";

const parser = new QMLTemplateParser();

// ── Helpers ──

function makeController() {
  class TestController extends QObject {
    count = new QProperty(0);
    name = new QProperty("");
  }
  return new TestController();
}

function makeMetadata(qml: string, opts?: Partial<{ autoBind: boolean }>) {
  const doc = parser.parse(qml);
  const bindings = parser.generateBindings(doc, "controller");
  return {
    options: { qml, autoBind: opts?.autoBind ?? false },
    document: doc,
    bindings,
    componentName: "TestController",
    providedIn: "view" as const,
  };
}

// ── generateInnerQML ──

describe("generateInnerQML", () => {
  it("extracts inner QML from ApplicationWindow", () => {
    const qml = [
      "import QtQuick",
      "ApplicationWindow {",
      "  title: \"Test\"",
      "  width: 960",
      "  Column {",
      "    Text { text: \"Hello\" }",
      "  }",
      "}",
    ].join("\n");

    const result = generateInnerQML(qml);
    expect(result.innerQML).toContain("Column {");
    expect(result.innerQML).not.toContain("ApplicationWindow");
    expect(result.innerQML).not.toContain("title:");
    expect(result.imports).toEqual(["import QtQuick"]);
  });

  it("extracts inner QML from Window", () => {
    const qml = [
      "Window {",
      "  visible: true",
      "  Rectangle {",
      "    color: \"red\"",
      "  }",
      "}",
    ].join("\n");

    const result = generateInnerQML(qml);
    expect(result.innerQML).toContain("Rectangle {");
    expect(result.imports).toEqual([]);
  });

  it("returns full QML when no Window root is found", () => {
    const qml = "Rectangle { color: \"blue\" }";
    const result = generateInnerQML(qml);
    expect(result.innerQML).toBe(qml);
  });

  it("extracts imports from the full document", () => {
    const qml = [
      "import QtQuick",
      "import QtQuick.Controls",
      "ApplicationWindow {",
      "  Button { text: \"Click\" }",
      "}",
    ].join("\n");

    const result = generateInnerQML(qml);
    expect(result.imports).toContain("import QtQuick");
    expect(result.imports).toContain("import QtQuick.Controls");
  });
});

// ── generateQMLSource ──

describe("generateQMLSource", () => {
  it("replaces controller.xxx.value with controller.xxx", () => {
    const qml = "Text { text: controller.name.value }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).not.toContain("controller.name.value");
    expect(result).toContain("controller.name");
  });

  it("transforms method calls to bridgeCall", () => {
    const qml = "Button { onClicked: controller.handleClick() }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toContain("controller.bridgeCall(\"handleClick\")");
  });

  it("transforms method calls with arguments", () => {
    const qml = "Button { onClicked: controller.echo(name, 42) }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toContain("JSON.stringify([\"echo\", name, 42])");
  });

  it("does not double-wrap existing bridgeCall", () => {
    const qml = 'Button { onClicked: controller.bridgeCall("handleClick") }';
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toBe(qml);
  });

  it("transforms root proxy method calls", () => {
    const qml = "Button { onClicked: CounterState.increment() }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta, [
      { proxyId: 1, instance: ctrl, componentName: "CounterState" },
    ]);

    expect(result).toContain('CounterState.bridgeCall("increment")');
  });

  it("transforms root proxy .get() calls to direct property access", () => {
    const qml = "Text { text: CounterState.get(\"count\") }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta, [
      { proxyId: 1, instance: ctrl, componentName: "CounterState" },
    ]);

    expect(result).toContain("CounterState.count");
    expect(result).not.toContain(".get(");
  });

  it("handles nested parentheses in method calls", () => {
    const qml = 'Button { onClicked: controller.format("a(b)", 42) }';
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toContain('JSON.stringify(["format", "a(b)", 42])');
  });

  it("handles method calls with no arguments", () => {
    const qml = "Button { onClicked: controller.reset() }";
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toContain('controller.bridgeCall("reset")');
    expect(result).not.toContain("JSON.stringify");
  });

  it("warns on deprecated controller.bridgeCall in template", () => {
    const qml = 'Button { onClicked: controller.bridgeCall("oldWay") }';
    const meta = makeMetadata(qml);
    const ctrl = makeController();

    expect(() => generateQMLSource(ctrl, meta)).not.toThrow();
  });

  it("transforms multiple method calls in the same template", () => {
    const qml = [
      "Column {",
      "  Button { onClicked: controller.inc() }",
      "  Button { onClicked: controller.dec() }",
      "}",
    ].join("\n");
    const meta = makeMetadata(qml);
    const ctrl = makeController();
    const result = generateQMLSource(ctrl, meta);

    expect(result).toContain('controller.bridgeCall("inc")');
    expect(result).toContain('controller.bridgeCall("dec")');
  });
});

// ── applyInjections ──

describe("applyInjections", () => {
  it("injects objectName from id declarations", () => {
    const inner = "TextField { id: myInput }";
    const ctrl = makeController();
    const meta = makeMetadata("Item {}");

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain('objectName: "myInput"');
  });

  it("injects objectName for quoted id declarations", () => {
    const inner = "TextField { id: \"myInput\" }";
    const ctrl = makeController();
    const meta = makeMetadata("Item {}");

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain('objectName: "myInput"');
  });

  it("injects router hooks when component has routeLeave", () => {
    class TestController extends QObject {
      count = new QProperty(0);
      routeLeave(path: string) {}
    }
    const ctrl = new TestController();
    const meta = makeMetadata("Router { }");
    const inner = "Router {\n  // routes\n}";

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain("onRouteLeave");
    expect(result).toContain("controller.bridgeCall");
  });

  it("injects router hooks when component has routeEnter", () => {
    class TestController extends QObject {
      count = new QProperty(0);
      routeEnter(path: string) {}
    }
    const ctrl = new TestController();
    const meta = makeMetadata("Router { }");
    const inner = "Router {\n  // routes\n}";

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain("onRouteEnter");
  });

  it("does not inject router hooks when not needed", () => {
    const ctrl = makeController();
    const meta = makeMetadata("Router { }");
    const inner = "Router {\n  // routes\n}";

    const result = applyInjections(inner, ctrl, meta);
    expect(result).not.toContain("onRouteLeave");
    expect(result).not.toContain("onRouteEnter");
  });

  it("injects autoBind for qproperty-matching TextField ids", () => {
    const inner = [
      "Column {",
      "  TextField {",
      "    id: myInput",
      "  }",
      "}",
    ].join("\n");
    const meta = makeMetadata("Item {}", { autoBind: true });
    const ctrl = makeController();
    // Make 'myInput' look like a qproperty
    Object.defineProperty(Object.getPrototypeOf(ctrl), "__qproperty_myInput", {
      value: true,
      writable: false,
    });

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain("text: controller.myInput");
    expect(result).toContain("onTextChanged");
  });

  it("injects autoBind for Checkbox", () => {
    const inner = [
      "Column {",
      "  Checkbox {",
      "    id: myCheck",
      "  }",
      "}",
    ].join("\n");
    const meta = makeMetadata("Item {}", { autoBind: true });
    const ctrl = makeController();
    Object.defineProperty(Object.getPrototypeOf(ctrl), "__qproperty_myCheck", {
      value: true,
      writable: false,
    });

    const result = applyInjections(inner, ctrl, meta);
    expect(result).toContain("checked: controller.myCheck");
  });
});

// ── generateQMLFile ──

describe("generateQMLFile", () => {
  it("prepends QtQuick imports", () => {
    const ctrl = makeController();
    const meta = makeMetadata("Item {}");
    const result = generateQMLFile(ctrl, meta);

    expect(result).toContain("import QtQuick");
    expect(result).toContain("import QtQuick.Controls");
    expect(result).toContain("import QtQuick.Layouts");
    expect(result).toContain("Item {");
  });
});

// ── QMLComponent decorator ──

describe("QMLComponent decorator", () => {
  it("registers metadata on decorated class", () => {
    const qml = "Text { text: controller.name }";

    @QMLComponent({ qml })
    class MyComponent extends QObject {
      name = new QProperty("world");
    }

    const meta = getQMLComponentMetadata(MyComponent);
    expect(meta).toBeDefined();
    expect(meta!.componentName).toBe("MyComponent");
    expect(meta!.document.root.type).toBe("Text");
    expect(meta!.options.qml).toBe(qml);
  });

  it("stores metadata on class prototype", () => {
    @QMLComponent({ qml: "Item {}" })
    class MyItem extends QObject {}

    expect((MyItem as any).__qmlComponent).toBeDefined();
    expect((MyItem as any).__qmlTemplate).toBe("Item {}");
  });

  it("supports providedIn option", () => {
    @QMLComponent({ qml: "Item {}", providedIn: "root" })
    class RootService extends QObject {}

    const meta = getQMLComponentMetadata(RootService);
    expect(meta!.providedIn).toBe("root");
  });
});
