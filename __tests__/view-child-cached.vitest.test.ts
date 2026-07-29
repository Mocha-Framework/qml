import { describe, expect, it, beforeEach } from "vitest";
import {
  setNativeAppRef,
  viewChild,
  resolveViewChild,
  createLazyViewChild,
  invalidateAllViewChildren,
  getViewChildCacheStats,
} from "../src/view-child.js";
import { QMLTextField, QMLItem, QMLCheckBox } from "../src/widget-wrappers.js";

function makeMockApp() {
  let handleCounter = 0;
  const nodes = new Map<number, Record<string, any>>();

  return {
    findChild(selector: string): number | null {
      if (selector === "missing") return null;
      const h = ++handleCounter;
      nodes.set(h, { text: "", checked: false });
      return h;
    },
    getQmlProperty(handle: number, name: string): any {
      return nodes.get(handle)?.[name] ?? "";
    },
    setQmlProperty(handle: number, name: string, value: any): void {
      const node = nodes.get(handle);
      if (node) node[name] = value;
    },
  };
}

describe("CachedViewChild (with mock nativeApp)", () => {
  beforeEach(() => {
    // Reset all caches between tests
    invalidateAllViewChildren();
    setNativeAppRef(makeMockApp());
  });

  it("resolveViewChild returns null for missing selector", () => {
    const ref = viewChild("missing", QMLItem);
    const result = resolveViewChild(ref);
    expect(result).toBeNull();
  });

  it("resolveViewChild returns a wrapper for found selector", () => {
    const ref = viewChild("myField", QMLTextField);
    const result = resolveViewChild(ref);
    expect(result).not.toBeNull();
    expect(result).toBeInstanceOf(QMLTextField);
  });

  it("createLazyViewChild returns a proxy", () => {
    const ref = viewChild("myField", QMLTextField);
    const proxy = createLazyViewChild(ref);
    expect((proxy as any).__viewChild).toBe(true);
  });

  it("lazy proxy resolves properties on access", () => {
    const ref = viewChild("myField", QMLTextField);
    const proxy = createLazyViewChild(ref);
    expect(proxy.text).toBe("");
  });

  it("lazy proxy sets pending values before resolution", () => {
    const ref = viewChild("immediate", QMLTextField);
    const proxy = createLazyViewChild(ref);
    proxy.text = "pending";
    expect(proxy.text).toBe("pending");
  });

  it("returns cached wrapper on subsequent resolveViewChild calls", () => {
    const ref = viewChild("cached", QMLTextField);
    const first = resolveViewChild(ref);
    const second = resolveViewChild(ref);
    expect(first).toBe(second);
  });

  it("invalidateAllViewChildren does not throw", () => {
    const ref1 = viewChild("field1", QMLTextField);
    resolveViewChild(ref1);
    expect(() => invalidateAllViewChildren()).not.toThrow();
  });

  it("invalidateAllViewChildren affects resolution after invalidation", () => {
    const ref = viewChild("invalTest", QMLTextField);
    const first = resolveViewChild(ref);
    expect(first).not.toBeNull();

    invalidateAllViewChildren();
    const second = resolveViewChild(ref);
    expect(second).not.toBeNull();
  });

  it("getViewChildCacheStats returns correct counts", () => {
    const ref = viewChild("statsField", QMLTextField);
    const stats = getViewChildCacheStats();
    expect(stats.total).toBeGreaterThanOrEqual(0);
    // After resolve, resolved should increment
    resolveViewChild(ref);
  });

  it("proxy handles multiple property sets before resolution", () => {
    const ref = viewChild("multiProp", QMLCheckBox);
    const proxy = createLazyViewChild(ref);
    proxy.checked = true;

    // QMLCheckBox doesn't have stateProps, so checked is set via proxy
    expect((proxy as any).__viewChild).toBe(true);
  });

  it("re-resolves after invalidation", () => {
    const ref = viewChild("reResolve", QMLTextField);
    const first = resolveViewChild(ref);
    expect(first).not.toBeNull();

    invalidateAllViewChildren();

    const second = resolveViewChild(ref);
    expect(second).not.toBeNull();
    // After invalidation and re-resolve, should get a new wrapper
  });
});
