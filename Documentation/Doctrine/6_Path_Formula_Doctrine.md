# 🧮 Path Formula Doctrine

## 📖 Title
**Path Formula Doctrine**

## 🌟 Purpose
Defines strategy-based conversion of VirtualPaths into Graphs. It is the standard mechanism for resolving publishing layouts, module locations, and artifact memory structure.

---

## I. WirePath → Graph Transformation

- Use `Resolve-PathFormulaGraph` with a `StrategyType`
- Result is a Graph with:
  - Signals for each hierarchy level
  - `.Result` containing the full subgraph

---

## II. Strategy Types

- `Publisher`: SDA artifact folders and filenames
- `Module`: Source structure for `.psd1`, manifest, trainer
- Future: `NFT`, `Vault`, `AgentProfile`

---

## III. Relative Path Resolution

Each node has:
- `RelativeFolderPath`
- `RelativeFilePath`
- `FullFilePath` (when joined with base root)

---

## IV. Signal Naming

- Each level of the graph uses a signal named:
  - `Publisher`, `Agency`, `Project`, `Collection`, etc.
- `Manifest` and `Trainer` are registered by Module strategy.

---

## V. Integration Points

- Used by:
  - `Resolve-DependencyModuleFromGraph`
  - `GraphCondenser` and SDA publishing tools

---

## 🌀 Closing Principle

A VirtualPath is not a string — it is a graph formula.
Path formulas allow agents to navigate memory-defined structures.
