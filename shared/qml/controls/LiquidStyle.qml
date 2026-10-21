pragma Singleton
import QtQuick

QtObject {
    property var _backdrops: []

    function registerBackdrop(backdrop) {
        _backdrops = _backdrops.concat([backdrop])
    }

    function unregisterBackdrop(backdrop) {
        _backdrops = _backdrops.filter(item => item !== backdrop)
    }

    // Start at the parent: a material container must never select its own
    // content provider when it resolves the source for its background.
    function backdropForItem(item, window) {
        for (let host = item ? item.parent : null; host; host = host.parent) {
            if (!("contentBackdrop" in host)) continue
            const candidate = host.contentBackdrop
            if (candidate && typeof candidate.canSample === "function" && candidate.canSample(item))
                return candidate
        }
        return backdropFor(window)
    }

    function backdropFor(window) {
        if (!window) return null
        for (let index = _backdrops.length - 1; index >= 0; --index) {
            const backdrop = _backdrops[index]
            if (backdrop && backdrop.registerAsDefault && backdrop.available
                    && backdrop.hostWindow === window)
                return backdrop
        }
        return null
    }
}
