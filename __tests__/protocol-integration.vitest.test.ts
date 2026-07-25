import { describe, it, expect } from "vitest";
import { encodeBridgeCall, parseBridgeCall, validateBridgeCall, serializePropertyValue, deserializePropertyValue } from "@mocha/bridge-api";

describe("Protocol integration with QML", () => {
  it("encode-decode roundtrip preserves method calls", () => {
    const original = { type: "method" as const, method: "myMethod", args: [42, "hello", true] };
    const encoded = encodeBridgeCall(original);
    const decoded = parseBridgeCall(encoded);
    expect(decoded).toEqual(original);
  });

  it("encode-decode roundtrip preserves bind calls", () => {
    const original = { type: "bind" as const, property: "name", value: "test-value" };
    const encoded = encodeBridgeCall(original);
    const decoded = parseBridgeCall(encoded);
    expect(decoded).toEqual(original);
  });

  it("validateBridgeCall accepts valid method calls", () => {
    const result = validateBridgeCall(JSON.stringify(["echo", 1, 2, 3]));
    expect(result.ok).toBe(true);
  });

  it("legacy fallback passes through as method call", () => {
    const result = validateBridgeCall("myMethod");
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.call).toEqual({ type: "method", method: "myMethod", args: [] });
    }
  });

  it("empty string is rejected as invalid call", () => {
    const result = validateBridgeCall("");
    expect(result.ok).toBe(false);
  });

  it("serializePropertyValue roundtrip", () => {
    const cases = [
      { input: "hello", expected: "hello" },
      { input: 42, expected: 42 },
      { input: 3.14, expected: 3.14 },
      { input: true, expected: true },
      { input: false, expected: false },
      { input: null, expected: null },
      { input: { a: 1 }, expected: { a: 1 } },
      { input: [1, 2, 3], expected: [1, 2, 3] },
    ];
    for (const { input, expected } of cases) {
      const encoded = serializePropertyValue(input);
      const decoded = deserializePropertyValue(encoded);
      expect(decoded).toEqual(expected);
    }
  });

  it("parseBridgeCall discriminates between method, bind, and route", () => {
    expect(parseBridgeCall(JSON.stringify(["onClick", 1])).type).toBe("method");
    expect(parseBridgeCall(JSON.stringify(["_bind_name", "val"])).type).toBe("bind");
    expect(parseBridgeCall(JSON.stringify(["routeLeave", "/home"])).type).toBe("route");
  });
});
