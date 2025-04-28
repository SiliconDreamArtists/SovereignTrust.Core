class BaseAttachment {
    [string]$Name

    BaseAttachment([string]$name) {
        $this.Name = $name
    }

    [void] Start([Conduit]$conduit) {
        throw "Start() must be implemented by Attachment subclass."
    }

    [void] Stop() {
        throw "Stop() must be implemented by Attachment subclass."
    }
}
