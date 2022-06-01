# Protostar

Protostar is a StarkNet smart contract development toolchain.
It allows you manages your dependencies, compiles your project, and runs tests.

This repository uses Protostar to test the code written in the cairo-pools repository.

I had to install the openzeppelin contracts here, and reference its location with inside `protostar.toml` with

```toml
["protostar.shared_command_configs"]
cairo_path = ["./lib/cairo_contracts/src"]
```

I also had to edit `libs_path` so that when protostar looks for `contracts.lib.IPool`,
it searches recursively from the `cairo-pools/` directory.

## Issues

For now, protostar doesn't support e2e testing hooks. It misses hooks like
`beforeEach`, `beforeAll` or `setup_state` to only deploy contracts once and use them in individual testcases.
I had to adapt my testcases so that there would only be one huge testcase, and calling test methods inside it,
with the deployed contract addresses as parameter.