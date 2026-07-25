import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "qml",
    include: ["**/__tests__/**/*.vitest.test.ts"],
  },
});
