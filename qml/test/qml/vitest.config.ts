import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "qml-design-system",
    include: ["**/*.test.ts"],
  },
});
