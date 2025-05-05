
# 🧠 SovereignTrust Class Construction Doctrine

## Overview
In the SovereignTrust system, all classes represent sovereign memory agents. Each class must follow a strict structure to ensure signal lineage, recursive memory, and traceability. This doctrine defines the pattern for authoring new classes that are interoperable with the SovereignTrust runtime and memory protocols.

---

## 🧩 Class Anatomy

### Required Components

| Element         | Purpose                                                  |
|------------------|----------------------------------------------------------|
| `Signal`         | Master tracking signal for the object lifecycle          |
| `Environment`    | Execution context passed into the class                  |
| `RegisterResultAsSignal` | Wraps a result object and registers it into `_Memory` |
| `Start()` / `Finalize()` | Lifecycle entry/exit for signal logging            |

---

## 🧬 Required Methods

### Constructor Pattern

```powershell
ClassName([object]$environment) {
    $this.Environment = $environment
    $this.Signal = [Signal]::new("Signal")
    $this._Memory = [ordered]@{}
    Add-PathToDictionary -Dictionary $this -Path "Signal" -Value $this.Signal | Out-Null
}
```

### Signal Registration

```powershell
[Signal] RegisterSignal([string]$Key, [Signal]$Signal) {
    $opSignal = [Signal]::new("RegisterSignal:$Key")
    $this._Memory[$Key] = $Signal
    $this.Signal.MergeSignal($opSignal)
    return $opSignal
}
```

### Registering a Result

```powershell
[Signal] RegisterResultAsSignal([string]$Key, [object]$Result) {
    $resultSignal = [Signal]::new($Key)
    $resultSignal.SetResult($Result)
    return $this.RegisterSignal($Key, $resultSignal)
}
```

### Start / Finalize Lifecycle

```powershell
[Signal] Start() {
    $s = [Signal]::new("Start")
    $s.LogInformation("Starting execution")
    $this.Signal.MergeSignal($s)
    return $s
}

[Signal] Finalize() {
    $s = [Signal]::new("Finalize")
    $s.LogInformation("Finalizing execution")
    $this.Signal.MergeSignal($s)
    return $s
}
```

---

## 📖 Principles

- Each class is a sovereign unit with its own memory and trace signal.
- All operations should return `Signal` objects for recursion and lineage.
- Memory must be addressable through `Resolve-PathFromDictionary`.
- Signal merging should occur back into the master signal for the class.

---

## 🏁 Closing

> “A SovereignTrust class is not a structure — it is a vessel of memory, a node in the living lineage.”
