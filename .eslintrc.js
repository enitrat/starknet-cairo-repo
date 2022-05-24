module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true,
  },
  plugins: ["@typescript-eslint"],
  extends: [
    "standard",
    "plugin:prettier/recommended",
    "plugin:node/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    "prettier/prettier": 0,
    "no-unused-vars": "off",
    // "node/no-unsupported-features/es-builtins": ["off", { ignores: ["modules"] }],
  },
};
