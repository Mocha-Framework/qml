import { describe, test, expect, beforeEach } from "vitest";
import { QMLComponent, deriveTagName, getTagRegistry } from "@mocha/qml";
import { findChildComponentUsages, isChildComponentTag } from "@mocha/qml";
import { qml } from "@mocha/qml";
import { QObject } from "@mocha/core";

class ChildController extends QObject {}
class AnotherChildController extends QObject {}

@QMLComponent({
  qml: qml`
    import QtQuick
    Item {
      Text { text: "child" }
    }
  `,
  as: "Child",
})
class CustomChildController extends QObject {}

@QMLComponent({
  qml: qml`
    import QtQuick
    Item { Text { text: "default" } }
  `,
})
class AutoChildController extends QObject {}

describe("deriveTagName", () => {
  test("strips Controller suffix", () => {
    expect(deriveTagName("ChildController")).toBe("Child");
    expect(deriveTagName("HomeController")).toBe("Home");
  });
  test("preserves names without suffix", () => {
    expect(deriveTagName("Child")).toBe("Child");
    expect(deriveTagName("AppRoot")).toBe("AppRoot");
  });
});

describe("tag registry", () => {
  test("explicit `as` option wins", () => {
    const cls = getTagRegistry().get("Child");
    expect(cls).toBe(CustomChildController);
  });

  test("auto derivation from class name", () => {
    const cls = getTagRegistry().get("AutoChild");
    expect(cls).toBe(AutoChildController);
  });
});

describe("isChildComponentTag", () => {
  test("returns true for registered tags", () => {
    expect(isChildComponentTag("Child")).toBe(true);
    expect(isChildComponentTag("AutoChild")).toBe(true);
  });

  test("returns false for built-in QML tags", () => {
    expect(isChildComponentTag("Item")).toBe(false);
    expect(isChildComponentTag("Text")).toBe(false);
    expect(isChildComponentTag("Rectangle")).toBe(false);
  });

  test("returns false for unregistered tags", () => {
    expect(isChildComponentTag("NotRegistered")).toBe(false);
  });

  test("returns false for lowercase tags", () => {
    expect(isChildComponentTag("text")).toBe(false);
  });
});

describe("findChildComponentUsages", () => {
  test("finds simple child component usage", () => {
    const qml = `
      import QtQuick
      ApplicationWindow {
        Child {
          name: "hello"
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages).toHaveLength(1);
    expect(usages[0].tag).toBe("Child");
    expect(usages[0].classCtor).toBe(CustomChildController);
    expect(usages[0].attrs.name).toBe("hello");
  });

  test("ignores built-in QML components", () => {
    const qml = `
      ApplicationWindow {
        Rectangle { width: 100 }
        Text { text: "hi" }
        Column { spacing: 10 }
        Item { anchors.fill: parent }
      }
    `;
    expect(findChildComponentUsages(qml)).toHaveLength(0);
  });

  test("ignores MochaDS components", () => {
    const qml = `
      ApplicationWindow {
        Card { padding: 10 }
        Button { text: "OK" }
      }
    `;
    expect(findChildComponentUsages(qml)).toHaveLength(0);
  });

  test("finds nested child components", () => {
    const qml = `
      ApplicationWindow {
        Column {
          Child { name: "first" }
          Child { name: "second" }
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages).toHaveLength(2);
    expect(usages[0].attrs.name).toBe("first");
    expect(usages[1].attrs.name).toBe("second");
  });

  test("finds deeply nested child components", () => {
    const qml = `
      ApplicationWindow {
        Column {
          Rectangle {
            Column {
              Child { name: "deep" }
            }
          }
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages).toHaveLength(1);
    expect(usages[0].attrs.name).toBe("deep");
  });

  test("captures id attribute", () => {
    const qml = `
      ApplicationWindow {
        Child {
          id: myChild
          name: "x"
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages[0].id).toBe("myChild");
  });

  test("handles multiple attributes", () => {
    const qml = `
      ApplicationWindow {
        Child {
          name: "foo"
          value: 42
          enabled: true
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages[0].attrs).toMatchObject({
      name: "foo",
      value: "42",
      enabled: "true",
    });
  });

  test("returns empty array for QML without child components", () => {
    const qml = `
      ApplicationWindow {
        Text { text: "hello" }
      }
    `;
    expect(findChildComponentUsages(qml)).toEqual([]);
  });

  test("handles attributes with expressions (controller.x)", () => {
    const qml = `
      ApplicationWindow {
        Child {
          name: controller.greeting
          value: controller.count
        }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages[0].attrs.name).toBe("controller.greeting");
    expect(usages[0].attrs.value).toBe("controller.count");
  });

  test("handles multiple child component types", () => {
    const qml = `
      ApplicationWindow {
        Child { name: "a" }
        AutoChild { value: 1 }
      }
    `;
    const usages = findChildComponentUsages(qml);
    expect(usages).toHaveLength(2);
    const tags = usages.map((u) => u.tag).sort();
    expect(tags).toEqual(["AutoChild", "Child"]);
  });
});
