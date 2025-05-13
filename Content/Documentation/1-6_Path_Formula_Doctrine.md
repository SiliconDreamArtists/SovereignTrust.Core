# 🧮 Path Formula Doctrine

## 📖 Title
**Path Formula Doctrine v1.1**

## 🌟 Purpose
Defines strategy-based resolution of VirtualPaths into Graph-based memory structures. It is the canonical method for constructing structured memory and adapter surfaces from declarative jackets or source arrays.

---

## I. Path Formula as Graph Construction

- A **Path Formula Adapter** takes a `Signal` (typically a ConductionSignal) and returns a `Graph` wrapped in a `Signal`.
- Resulting graph:
  - Contains one signal per node or level.
  - Embeds meaningful `.Result`, `.Pointer`, or `.Jacket` on each signal.
  - May wrap internal Graphs (nested memory).

---

## II. Supported Strategies

- ✅ `Publisher`: Artifact lineage paths, e.g., `Publisher.Agency.Project...`
- ✅ `Module`: File structure paths for `.psd1`, `.psm1`, manifest.
- ✅ `Conduction`: Builds a memory graph from an input WirePath or hierarchical object (e.g., project structure).
- ✅ `AgentRoles`: Builds a multi-agent graph with nested roles per agent.
- ✅ `CondenserAdapter`: Creates dynamic phases for Conduction execution based on memory-driven logic.
- 🔜 Future: `NFT`, `Vault`, `AgentProfile`, `QueueRoute`

---

## III. WirePath & VirtualPath Behavior

- Each segment of a dot-delimited path (e.g., `Publisher.Agency.Project`) is:
  - Interpreted as a level key.
  - Used to construct `RelativeFolderPath`, `RelativeFilePath`, and `FullFilePath`.
  - Assigned a canonical label (`Publisher`, `Project`, `Set`, etc.).

---

## IV. Signal Structure Per Node

Each node in the graph contains:
- `.Name` — Derived from the segment key.
- `.Result` — Canonical memory for that level.
- `.Jacket` — Optional metadata from source.
- `.Pointer` — Graphs, phases, or dependency objects.
- `.ReversePointer` — Source signal (optional; external use only).

---

## V. Usage Patterns

Used by:
- `Resolve-DependencyModuleFromGraph`
- `GraphCondenser` (Conduction planning)
- `Resolve-ConductionPhasesFromPathFormula`
- SDA artifact publishers, AI planners, and agent configurators.

---

## 🌀 Closing Principle

A Path Formula is a sovereign memory template.
Each formula resolves to a living signal graph — composable, traceable, and recursive.
