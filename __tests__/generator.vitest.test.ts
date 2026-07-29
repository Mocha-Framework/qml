import { describe, expect, it } from "vitest";
import { QMLTemplateParser } from "../src/qml-parser.js";
import { TypeGenerator } from "../src/generator.js";

const parser = new QMLTemplateParser();
const gen = new TypeGenerator();

function nl(qml: string) {
  return qml.replace(/\s+/g, " ").trim();
}

describe("TypeGenerator", () => {
  it("generates interface from simple parse result", () => {
    // Properties on separate lines (parser limitation)
    const doc = parser.parse(["Text {", "  text: controller.name", "}"].join("\n"));
    const output = gen.generateFromQML(doc, "MyApp");

    expect(output).toContain("export interface MyAppQML");
    expect(output).toContain('import { Signal, QProperty } from "@mocha/core"');
    expect(output).toContain("declare global");
    expect(output).toContain("namespace Mocha");
  });

  it("generates controller interface with signal handlers", () => {
    const doc = parser.parse(["Button {", '  onClicked: controller.handleClick()', "}"].join("\n"));
    const output = gen.generateFromQML(doc, "MyApp");

    expect(output).toContain("export interface MyAppController");
    expect(output).toContain("ButtonClicked");
  });

  it("includes property types based on inferred values", () => {
    const doc = parser.parse(["Item {", "  visible: true", "  opacity: 0.5", '  title: "Hello"', "}"].join("\n"));
    const output = gen.generateFromQML(doc, "MyApp");

    expect(output).toContain("visible");
    expect(output).toContain("opacity");
    expect(output).toContain("title");
  });

  it("prefixes signals with 'readonly'", () => {
    const doc = parser.parse(["Button {", "  onClicked: controller.go()", "}"].join("\n"));
    const output = gen.generateFromQML(doc, "MyApp");

    expect(output).toContain("Signal");
    expect(output).toContain("ButtonClicked");
  });

  it("generates DTS from widget map", () => {
    const output = gen.generateDTSFromWidgets({ MyButton: "QQuickItem" });
    expect(output).toContain("declare module");
    expect(output).toContain("@mocha/qml/widget-types");
    expect(output).toContain("interface MyButton extends QQuickItem");
  });

  it("generates project types from multiple components", () => {
    const doc1 = parser.parse(["Text {", "  text: controller.name", "}"].join("\n"));
    const doc2 = parser.parse(["Button {", "  onClicked: controller.go()", "}"].join("\n"));

    const output = gen.generateProjectTypes([
      { name: "App1", document: doc1 },
      { name: "App2", document: doc2 },
    ]);

    expect(output).toContain("App1QML");
    expect(output).toContain("App2QML");
  });

  it("infers QProperty type for binding expressions", () => {
    const doc = parser.parse(["TextField {", "  text: controller.name", "}"].join("\n"));
    const output = gen.generateFromQML(doc, "MyApp");

    expect(output).toContain("QProperty<any>");
  });
});
