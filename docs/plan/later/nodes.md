# nodes

Not started. These items stay out of the active slice.

## Behavior

The landed node set is the Basic and Lambert subset in [../done/nodes.md](../done/nodes.md). Phase 4 stopped at the nodes those two materials reach.

The rest of TSL and `WGSLNodeBuilder.js` stay upstream. The whole of `src/nodes` and MaterialX stay out until a material needs that fragment. The equirectangular PMREM atlas used by Standard environment maps lives in `materials`.

## Checklist

| status | phase | item | packages |
|---|---|---|---|
| later | 7 | The whole of `WGSLNodeBuilder.js`, the whole of `src/nodes`, MaterialX | The fragment a material needs, when it needs it |
