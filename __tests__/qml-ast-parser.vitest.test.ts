import { describe, expect, it } from "vitest";
import { QmlAstParser } from "../src/qml-ast-parser.js";

const parser = new QmlAstParser();

describe("QmlAstParser.parse", () => {
  it("parses a simple document with one element", () => {
    const doc = parser.parse(`import QtQuick\n\nItem {\n  width: 100\n}`);
    expect(doc.imports).toEqual(["import QtQuick"]);
    expect(doc.root?.tag).toBe("Item");
    expect(doc.root?.attrs?.width).toBe("100");
    expect(doc.root?.id).toBeNull();
  });

  it("parses nested elements", () => {
    const doc = parser.parse(`Column {\n  Button { text: "Click" }\n  Text { text: "Hi" }\n}`);
    expect(doc.root?.tag).toBe("Column");
    expect(doc.root?.children).toHaveLength(2);
    expect(doc.root?.children[0].tag).toBe("Button");
    expect(doc.root?.children[1].tag).toBe("Text");
  });

  it("extracts element ids", () => {
    const doc = parser.parse(`Item {\n  id: myRoot\n  Text { id: myLabel; text: "Hi" }\n}`);
    expect(doc.root?.id).toBe("myRoot");
    expect(doc.root?.children[0].id).toBe("myLabel");
  });

  it("handles inline Component elements", () => {
    const doc = parser.parse(`Item {\n  view: Component {\n    Column { Text { text: "Hi" } }\n  }\n}`);
    expect(doc.root?.children[0]?.tag).toBe("Component");
    expect(doc.root?.children[0]?.children[0]?.tag).toBe("Column");
  });

  it("preserves attributes as strings", () => {
    const doc = parser.parse(`Item {\n  width: 100\n  visible: true\n  title: "Hello"\n}`);
    expect(doc.root?.attrs["width"]).toBe("100");
    expect(doc.root?.attrs["visible"]).toBe("true");
    expect(doc.root?.attrs["title"]).toBe("Hello");
  });

  it("handles strings with braces inside", () => {
    const doc = parser.parse(`Item {\n  text: "hello {world}"\n  AnotherItem {}\n}`);
    expect(doc.root?.attrs["text"]).toBe("hello {world}");
    expect(doc.root?.children).toHaveLength(1);
    expect(doc.root?.children[0].tag).toBe("AnotherItem");
  });

  it("skips line comments", () => {
    const doc = parser.parse(`Item {\n  // this is a comment\n  width: 100\n}`);
    expect(doc.root?.attrs["width"]).toBe("100");
    expect(doc.root?.attrs).not.toContain("this is a comment");
  });

  it("skips block comments", () => {
    const doc = parser.parse(`Item {\n  /* block\n  comment */\n  width: 100\n}`);
    expect(doc.root?.attrs["width"]).toBe("100");
  });
});
