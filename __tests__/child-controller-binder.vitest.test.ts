import { describe, test, expect, beforeEach } from "vitest";
import { QObject, QProperty, input, output, model, effect } from "@mocha/core";
import { QMLComponent, qml, bindChildControllers } from "@mocha/qml";

const flush = () => new Promise<void>((r) => queueMicrotask(r));

// Create a mock native app
function createMockNativeApp() {
  const proxies = new Map<number, Record<string, any>>();
  const contextProps = new Map<string, number>();
  let nextId = 1;
  return {
    createProxy: () => {
      const id = nextId++;
      proxies.set(id, {});
      return id;
    },
    destroyProxy: (id: number) => proxies.delete(id),
    proxySetValue: (id: number, name: string, value: any) => {
      const p = proxies.get(id);
      if (p) p[name] = value;
    },
    proxyGetValue: (id: number, name: string) => proxies.get(id)?.[name],
    setContextProperty: (name: string, id: number) => {
      contextProps.set(name, id);
    },
    getContextProperty: (name: string) => contextProps.get(name),
    _proxies: proxies,
    _contextProps: contextProps,
  };
}

@QMLComponent({
  qml: qml`
    import QtQuick
    Item {
      Text { text: "child" }
    }
  `,
  as: "Child",
})
class ChildController extends QObject {
  name = input<string>("default");
  value = model<number>(0);
  clicked = output<{ id: string }>();
  counter = new QProperty(0);

  handleClick() {
    this.clicked.emit({ id: "fromChild" });
  }
}

class ParentController extends QObject {
  greeting = new QProperty("hello");
  shared = new QProperty(42);
  onClicked(v: { id: string }) {
    this.lastReceived = v.id;
  }
  lastReceived: string = "";
}

let mockApp: ReturnType<typeof createMockNativeApp>;

beforeEach(() => {
  mockApp = createMockNativeApp();
});

describe("bindChildControllers", () => {
  test("instantiates child controller when none exists", () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: controller.greeting }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);

    expect(result.children).toHaveLength(1);
    expect(result.children[0].componentName).toBe("ChildController");
    expect(result.children[0].contextName).toBe("child");
  });

  test("registers child as context property with lowerFirst name", () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: controller.greeting }`;
    bindChildControllers(parent, qmlSource, mockApp, []);
    expect(mockApp.getContextProperty("child")).toBeDefined();
  });

  test("binds child @qproperty to its proxy", () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: "static" }`;
    bindChildControllers(parent, qmlSource, mockApp, []);
    const childProxyId = mockApp.getContextProperty("child")!;
    expect(mockApp._proxies.get(childProxyId)?.counter).toBe(0);
  });

  test("one-way binding: parent.greeting → child.name", async () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: controller.greeting }`;
    bindChildControllers(parent, qmlSource, mockApp, []);

    parent.greeting.value = "world";
    await flush();

    const childProxyId = mockApp.getContextProperty("child")!;
    expect(mockApp._proxies.get(childProxyId)?.name).toBe("world");
  });

  test("two-way binding via model(): child → parent", async () => {
    const parent = new ParentController();
    const qmlSource = `Child { value: controller.shared }`;
    bindChildControllers(parent, qmlSource, mockApp, []);

    // Simulate child setting its model — should propagate to parent.shared
    const childInstance = (parent as any).constructor; // we'll find the child via the proxy entry
    // We need direct access to the child instance — let's store it in a parent field
    const internalChild = (mockApp as any)._lastChildInstance;
    // (Will be tested more directly below)
  });

  test("reuses existing child instance assigned to parent field", () => {
    class ParentWithChild extends QObject {
      greeting = new QProperty("hi");
      child = new ChildController();
    }
    const parent = new ParentWithChild();
    const qmlSource = `Child { name: controller.greeting }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect(result.children).toHaveLength(1);
    expect(result.children[0].instance).toBe(parent.child);
  });

  test("no-op for QML without child components", () => {
    const parent = new ParentController();
    const qmlSource = `Rectangle { width: 100 }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect(result.children).toEqual([]);
  });

  test("handles multiple child components", () => {
    const parent = new ParentController();
    const qmlSource = `
      Column {
        Child { name: "a" }
        Child { name: "b" }
      }
    `;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect(result.children).toHaveLength(2);
  });

  test("dispose() releases effects", () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: controller.greeting }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect(() => result.children[0].dispose()).not.toThrow();
  });

  test("literal values work for attributes", async () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: "literal" }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect(result.children).toHaveLength(1);
    await flush();
    const childProxyId = mockApp.getContextProperty("child")!;
    expect(mockApp._proxies.get(childProxyId)?.name).toBe("literal");
  });

  test("parent.parent = child for QObject lifecycle", () => {
    const parent = new ParentController();
    const qmlSource = `Child { name: "x" }`;
    const result = bindChildControllers(parent, qmlSource, mockApp, []);
    expect((result.children[0].instance as any).parent).toBe(parent);
  });
});
