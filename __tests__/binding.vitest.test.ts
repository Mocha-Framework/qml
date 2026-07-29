import { describe, expect, it, beforeEach } from "vitest";
import { QProperty, QObject } from "@mocha/core";
import { BindingEngine } from "../src/binding.js";

describe("BindingEngine", () => {
  let engine: BindingEngine;
  let source: Record<string, QProperty<any>>;
  let target: Record<string, QProperty<any>>;

  beforeEach(() => {
    engine = new BindingEngine();
    source = { name: new QProperty("hello"), count: new QProperty(0) };
    target = { label: new QProperty(""), total: new QProperty(0) };
  });

  describe("bind", () => {
    it("connects source property to target", () => {
      const unsub = engine.bind(target, source, { label: "source.name" });

      expect(target.label.value).toBe("hello");

      source.name.value = "world";
      expect(target.label.value).toBe("world");

      unsub();
    });

    it("returns disconnect function", () => {
      const unsub = engine.bind(target, source, { label: "source.name" });
      source.name.value = "world";
      expect(target.label.value).toBe("world");

      unsub();
      source.name.value = "foo";
      expect(target.label.value).toBe("world");
    });

    it("warns when source property does not exist", () => {
      engine.bind(target, source, { label: "source.missing" } as any);
      expect(target.label.value).toBe("");
    });
  });

  describe("bindTwoWay", () => {
    it("syncs values in both directions", () => {
      const propA = new QProperty("A");
      const propB = new QProperty("B");
      const unsub = engine.bindTwoWay(propA, propB);

      expect(propA.value).toBe("B");
      expect(propB.value).toBe("B");

      propA.value = "changed";
      expect(propB.value).toBe("changed");

      unsub();
    });

    it("returns disconnect function", () => {
      const propA = new QProperty("A");
      const propB = new QProperty("B");
      const unsub = engine.bindTwoWay(propA, propB);

      unsub();
      propA.value = "alone";
      expect(propB.value).toBe("B");
    });
  });

  describe("bindToExpression", () => {
    it("evaluates expression and keeps it in sync", () => {
      const a = new QProperty(2);
      const b = new QProperty(3);
      const result = new QProperty(0);

      const unsub = engine.bindToExpression(result, [a, b], (x, y) => x + y);

      expect(result.value).toBe(5);

      a.value = 10;
      expect(result.value).toBe(13);

      unsub();
    });
  });

  describe("disposeAll", () => {
    it("disconnects all bindings", () => {
      engine.bind(target, source, { label: "source.name" });
      engine.bindTwoWay(new QProperty(1), new QProperty(2));

      expect(engine.dependencyCount).toBe(2);

      engine.disposeAll();
      expect(engine.dependencyCount).toBe(0);
    });
  });

  describe("bindFromQMLBindings", () => {
    it("processes binding map entries", () => {
      const bindings = {
        "controller.nameField.text": {
          expression: "controller.name",
          property: "text",
          nodeId: "nameField",
        },
      };

      const component = { name: new QProperty("test") };
      engine.bindFromQMLBindings(component, bindings);
    });

    it("warns for unknown binding targets", () => {
      const bindings = {
        "controller.missingField.text": {
          expression: "controller.missing",
          property: "text",
          nodeId: "missingField",
        },
      };

      const component = { name: new QProperty("test") };
      engine.bindFromQMLBindings(component, bindings);
    });
  });
});
