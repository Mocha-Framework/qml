import { describe, expect, it } from "vitest";
import { createLazyViewChild, getViewChildStateProps, viewChild } from "../src/view-child.js";
import {
  QMLComboBox,
  QMLItem,
  QMLSwitch,
  QMLTextField,
} from "../src/widget-wrappers.js";

describe("getViewChildStateProps", () => {
  it("reads state props from a viewChild ref", () => {
    const ref = viewChild("countryCombo", QMLComboBox) as any;

    expect(getViewChildStateProps(ref)).toEqual(["currentIndex"]);
  });

  it("reads state props from a lazy proxy without resolving native nodes", () => {
    const ref = viewChild("rememberSwitch", QMLSwitch) as any;
    const proxy = createLazyViewChild(ref) as any;

    expect(proxy.__viewChild).toBe(true);
    expect(getViewChildStateProps(proxy)).toEqual(["checked"]);
  });

  it("returns an empty list for wrappers with no transient state", () => {
    const ref = viewChild("layoutRoot", QMLItem) as any;

    expect(getViewChildStateProps(ref)).toEqual([]);
  });

  it("keeps text inputs scoped to text state", () => {
    const ref = viewChild("searchField", QMLTextField) as any;

    expect(getViewChildStateProps(ref)).toEqual(["text"]);
  });
});
