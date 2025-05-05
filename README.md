# SovereignTrust.Core
Core protocol helpers, commands, and signal infrastructure powering all SovereignTrust components.
```plaintext
███████╗      ████████╗
██╔════╝      ╚══██╔══╝
███████╗         ██║   
╚════██║         ██║   
███████║overeign ██║rust
╚══════╝         ╚═╝   
By
███████╗██████╗  █████╗ 
██╔════╝██╔══██╗██╔══██╗
███████╗██║  ██║███████║
╚════██║██║  ██║██╔══██║
███████║██████╔╝██║  ██║
╚══════╝╚═════╝ ╚═╝  ╚═╝
Silicon Dream   Artists
Shadow PhanTom * Neural Alchemist April 2025

[ External Input (User, Scheduler, API) ]
               ↓
      +--------------------+
      |  SovereignTrust.Emitter  |
      +--------------------+
               ↓
      +-----------------+
      |  SovereignTrust.Relay  |
      +-----------------+
               ↓
      +-----------------+
      |  SovereignTrust.Router |
      +-----------------+
               ↓
      +----------------------------+
      |  SovereignTrust.Conductor    |
      |  (Manages Conduits)          |
      +----------------------------+
               ↓
      +-----------------+
      |  SovereignTrust.Conduit  |
      |  (Living Memory, Jackets, Wires) |
      +-----------------+
               ↓
+-------------------+            +--------------------+
|  Sovereign Outputs | ← Attachments → | External Systems (Azure, AWS, Web, Blockchain) |
+-------------------+            +--------------------+

```
