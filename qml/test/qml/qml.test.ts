import { defineQmlTests } from "@mocha/testkit";

defineQmlTests({
  globs: ["../tst_*.qml"],
  importPath: "../../MochaDS,../..",
  suiteName: "MochaDS",
});
