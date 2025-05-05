# 📦 Adapter Manifest Doctrine

## 📖 Title
**Adapter Manifest Doctrine**

## 🌟 Purpose
Defines rules for adapter resolution, virtual path usage, manifest hydration, and secure instantiation.

---

## I. Every Adapter Has a VirtualPath

- This path identifies the location of the attachment's Manifest file.
- Used by `Resolve-DependencyModuleFromGraph` to load and hydrate the module.

---

## II. Manifests Hold Metadata

- Each Manifest JSON contains:
  - `Module.Name`
  - `RelativeFilePath`
  - `Classes[]` with `.Name`, `.Source`
- Manifest is loaded into a Graph via `Resolve-PathFormulaGraph`

---

## III. Hydration Creates the Instance

- After module load, the attachment is instantiated via:
  - `New-Object` with type from manifest
  - Call to `.Construct()` method if available

---

## IV. Adapters Must Be Signalized

- All resolved adapters must be stored in signals.
- Placement:
  - `Memory.Attachments.{Name}`
  - `Mapped{Kind}Attachments[{Slot}]`

---

## V. Adapters Must Be Verified

- Use `.Test()` or `.Verify()` methods when available.
- Ensure adapters are not null and responsive.

---

## 🧠 Summary

Adapters are the sovereign execution surfaces of the system. No operation may use external capability unless it is declared, loaded, and traced via an adapter manifest.
