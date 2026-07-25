import { describe, expect, it } from "vitest";
import { QmlAstParser } from "../src/qml-ast-parser.js";
import { analyzeQmlStructure, extractLatestTaggedQmlTemplate } from "../src/qml-structure.js";

describe("QmlAstParser", () => {
  it("parses nested inline component elements", () => {
    const parser = new QmlAstParser();
    const doc = parser.parse(`
      import QtQuick

      ApplicationWindow {
        title: "Demo"

        Item {
          id: host
          view: Component {
            Column {
              id: content
              Text {
                id: label
                text: "Hello"
              }
            }
          }
        }
      }
    `);

    expect(doc.root?.tag).toBe("ApplicationWindow");
    expect(doc.root?.children[0]?.tag).toBe("Item");
    expect(doc.root?.children[0]?.children[0]?.tag).toBe("Component");
    expect(doc.root?.children[0]?.children[0]?.children[0]?.tag).toBe("Column");
    expect(doc.root?.children[0]?.children[0]?.children[0]?.children[0]?.id).toBe("label");
  });
});

describe("analyzeQmlStructure", () => {
  it("extracts inner qml and window props from a window root", () => {
    const analysis = analyzeQmlStructure(`
      import QtQuick 2.15
      import QtQuick.Controls

      ApplicationWindow {
        title: "Preview"
        width: 960
        height: 640
        color: "black"

        Column {
          id: rootColumn
          Text { text: "Hello" }
        }
      }
    `);

    expect(analysis.rootTag).toBe("ApplicationWindow");
    expect(analysis.windowProps).toEqual({
      title: "Preview",
      width: 960,
      height: 640,
    });
    expect(analysis.innerQML.startsWith("Column {")).toBe(true);
    expect(analysis.imports).toContain("import QtQuick 2.15");
  });
});

describe("extractLatestTaggedQmlTemplate", () => {
  it("returns the last qml tagged template from a source file", () => {
    const source = `
      const helper = qml\`
        Item {}
      \`;

      export const App = qml\`
        ApplicationWindow {
          title: "Final"
          Column {
            Text { text: "Hello" }
          }
        }
      \`;
    `;

    const extracted = extractLatestTaggedQmlTemplate(source);

    expect(extracted.template).toContain('title: "Final"');
    expect(extracted.template).not.toContain("Item {}");
  });

  it("fails clearly for interpolated templates", () => {
    expect(() =>
      extractLatestTaggedQmlTemplate("const x = qml`Text { text: ${label} }`;")
    ).toThrow("Interpolated qml templates are not supported");
  });
});
