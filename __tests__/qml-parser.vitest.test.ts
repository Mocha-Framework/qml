import { describe, expect, it } from "vitest";
import { QMLTemplateParser } from "../src/qml-parser.js";

const parser = new QMLTemplateParser();

describe("QMLTemplateParser.parse", () => {
  it("parses a simple element with properties", () => {
    const doc = parser.parse(`Rectangle {
      width: 200
      height: 100
      color: "#ff0000"
    }`);

    expect(doc.imports).toEqual([]);
    expect(doc.root.type).toBe("Rectangle");
    expect(doc.root.properties).toEqual({
      width: 200,
      height: 100,
      color: "#ff0000",
    });
    expect(doc.root.children).toEqual([]);
    expect(doc.root.signalHandlers).toEqual({});
  });

  it("parses nested children", () => {
    const doc = parser.parse(`Column {
      Button {
        text: "Click"
      }
      Text {
        text: "Hello"
      }
    }`);

    expect(doc.root.type).toBe("Column");
    expect(doc.root.children).toHaveLength(2);
    expect(doc.root.children[0].type).toBe("Button");
    expect(doc.root.children[0].properties).toEqual({ text: "Click" });
    expect(doc.root.children[1].type).toBe("Text");
    expect(doc.root.children[1].properties).toEqual({ text: "Hello" });
  });

  it("extracts single import with semicolon", () => {
    const doc = parser.parse("import QtQuick;\nItem {}");
    expect(doc.imports).toEqual(["QtQuick"]);
  });

  it("extracts import with version number", () => {
    const doc = parser.parse("import QtQuick 2.15;\nItem {}");
    expect(doc.imports).toEqual(["QtQuick 2.15"]);
  });

  it("includes semicolons in import extraction result", () => {
    const doc = parser.parse("import QtQuick;\nItem {}");
    expect(doc.imports[0]).toBe("QtQuick");
  });

  it("parses signal handlers", () => {
    const doc = parser.parse(`Button {
      text: "Click"
      onClicked: controller.handleClick()
      onTextChanged: controller.handleChange(text)
    }`);

    expect(doc.root.signalHandlers).toEqual({
      onClicked: "controller.handleClick()",
      onTextChanged: "controller.handleChange(text)",
    });
  });

  it("parses binding expressions", () => {
    const doc = parser.parse(`TextField {
      text: controller.name
    }`);

    expect(doc.root.properties.text).toEqual({
      type: "binding",
      expression: "controller.name",
    });
  });

  it("parses binding with .value() accessor", () => {
    const doc = parser.parse(`Text {
      text: controller.name.value()
    }`);

    expect(doc.root.properties.text).toEqual({
      type: "binding",
      expression: "controller.name.value()",
    });
  });

  it("parses binding with .get() accessor", () => {
    const doc = parser.parse(`Text {
      text: controller.name.get()
    }`);

    expect(doc.root.properties.text).toEqual({
      type: "binding",
      expression: "controller.name.get()",
    });
  });

  it("coerces boolean property values", () => {
    const doc = parser.parse(`Item {
      visible: true
      enabled: false
    }`);

    expect(doc.root.properties.visible).toBe(true);
    expect(doc.root.properties.enabled).toBe(false);
  });

  it("coerces null and numeric values", () => {
    const doc = parser.parse(`Item {
      opacity: 0.5
      z: null
    }`);

    expect(doc.root.properties.opacity).toBe(0.5);
    expect(doc.root.properties.z).toBeNull();
  });

  it("handles string values with quotes", () => {
    const doc = parser.parse(`Item {
      title: "Hello World"
      subtitle: 'Single quoted'
    }`);

    expect(doc.root.properties.title).toBe("Hello World");
    expect(doc.root.properties.subtitle).toBe("Single quoted");
  });

  it("extracts element id", () => {
    const doc = parser.parse(`TextField {
      id: myInput
      text: "hello"
    }`);

    expect(doc.root.id).toBe("myInput");
  });

  it("does not extract id with quoted value (parser only supports unquoted)", () => {
    const doc = parser.parse(`TextField {
      id: "myInput"
      text: "hello"
    }`);

    expect(doc.root.id).toBeUndefined();
  });

  it("returns Item as default type for empty input", () => {
    const doc = parser.parse("  ");
    expect(doc.root.type).toBe("Item");
    expect(doc.root.properties).toEqual({});
    expect(doc.root.children).toEqual([]);
  });

  it("parses children on separate lines", () => {
    const doc = parser.parse(`Column {
        Text {
          text: "A"
        }
        Text {
          text: "B"
        }
    }`);

    expect(doc.root.children).toHaveLength(2);
    expect(doc.root.children[0].properties.text).toBe("A");
    expect(doc.root.children[1].properties.text).toBe("B");
  });

  it("handles properties with colon in string values", () => {
    const doc = parser.parse(`Item {
      text: "time: 12:30"
    }`);

    expect(doc.root.properties.text).toBe("time: 12:30");
  });
});

describe("QMLTemplateParser.generateBindings", () => {
  it("extracts bindings from root node", () => {
    const doc = parser.parse(`TextField {
      text: controller.name
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    expect(Object.keys(bindings)).toHaveLength(1);
    const key = Object.keys(bindings)[0];
    expect(bindings[key].expression).toBe("controller.name");
    expect(bindings[key].property).toBe("text");
  });

  it("extracts bindings from nested children", () => {
    const doc = parser.parse(`Column {
        TextField {
          text: controller.name
        }
        Slider {
          value: controller.level
        }
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    const keys = Object.keys(bindings);
    expect(keys).toHaveLength(2);
  });

  it("returns empty map when no bindings exist", () => {
    const doc = parser.parse(`Item {
      visible: true
      width: 100
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    expect(Object.keys(bindings)).toHaveLength(0);
  });

  it("includes node id in binding key", () => {
    const doc = parser.parse(`TextField {
      id: nameField
      text: controller.name
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    const key = Object.keys(bindings)[0];
    expect(key).toContain("nameField");
  });

  it("handles multiple bindings on same node", () => {
    const doc = parser.parse(`TextField {
      text: controller.name
      color: controller.textColor
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    expect(Object.keys(bindings)).toHaveLength(2);
  });

  it("binds with .value() accessor syntax", () => {
    const doc = parser.parse(`Text {
      text: controller.title.value()
    }`);
    const bindings = parser.generateBindings(doc, "controller");

    const key = Object.keys(bindings)[0];
    expect(bindings[key].expression).toBe("controller.title.value()");
  });
});
