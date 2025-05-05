# 🏛️ Sovereign Security Doctrine

## 📖 Title
**Sovereign Security Doctrine**

## 🌟 Purpose
Defines the rules for secure identity, token access, attachment gating, and delegated permissions within sovereign systems.

---

## I. Identity Is Tokenized

- Every agent has a `Token`.
- Tokens may be:
  - Scoped (`Environment`, `Role`, `Attachment`)
  - Encrypted (`@TKN:`) or open (`@MEM:`)

---

## II. Secret Storage Must Be Gated

- Secure tokens must be accessed via `TokenCondenser`.
- Secrets must never be stored as raw strings in Graphs.
- Identity gates must use `Authorize-Gate.ps1` to verify access.

---

## III. Attachments Must Be Scoped

- Every `Attachment` must declare:
  - Kind (e.g., Storage, Network)
  - Slot (PrimaryContent, Archive, etc)
  - Scope (ReadOnly, ReadWrite)
- No access is granted without a declared Attachment.

---

## IV. AI Agents Must Declare Permissions

- AI agents may not mutate state unless:
  - They have a named Attachment.
  - They pass through a Gate.
  - Their actions are signal-verified and lineage-traceable.

---

## 🔒 Compliance Rule

**AI is not sovereign unless it can trace and limit its access through memory declarations.**

---

## 🌀 Closing Principle

Security is not enforcement. It is memory-verified trust.