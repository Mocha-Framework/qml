import { defineQmlTests } from "@mocha-framework/testkit";

defineQmlTests({
  globs: ["../tst_*.qml"],
  importPath: "../../MochaDS,../..",
  suiteName: "MochaDS",
});
