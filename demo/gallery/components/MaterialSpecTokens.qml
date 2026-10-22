import QtQuick
import "../../Kos/Ui/foundation" as Ui

// Pilot only: do not change shared defaults or the retained comparisons.
QtObject {
    property bool dark: false
    readonly property int gap: 8
    readonly property int sidebarWidth: 224
    readonly property int sidebarPadding: 16
    readonly property int sidebarSpacing: 12
    readonly property int titleSize: 17
    readonly property int captionSize: 11
    readonly property int searchHeight: 34
    readonly property int searchFontSize: 13
    readonly property int searchIconSize: 14
    readonly property int searchInset: 12
    readonly property int searchIconGap: 6
    readonly property int sceneHeight: 240
    readonly property int toolbarHeight: 44
    readonly property int toolbarTitleSize: 20
    readonly property int toolbarGroupGap: 2
    readonly property real toolbarBlur: .50
    readonly property int toolbarRadius: 20
    readonly property int controlHeight: 28
    readonly property int controlRadius: 10
    readonly property int focusWidth: 2
    readonly property int focusOffset: 2
    // A neutral desktop highlight must not turn an input focus ring black.
    readonly property color focusFallback: "#3478f6"
    readonly property real focusMinimumLightness: .25
    readonly property real focusMaximumLightness: .85
    readonly property color focusAccent: {
        const accent = Ui.AppTheme.accent
        const maximum = Math.max(accent.r, accent.g, accent.b)
        const minimum = Math.min(accent.r, accent.g, accent.b)
        const chroma = maximum - minimum
        const lightness = (maximum + minimum) / 2
        return accent.a <= 0 || chroma < .08
            || lightness < focusMinimumLightness || lightness > focusMaximumLightness
            ? focusFallback : accent
    }
    readonly property int bodySize: 14
    readonly property int fast: 150
    readonly property int instant: 100
    readonly property real pressScale: .96
    readonly property real disabledOpacity: .38
    readonly property real shadowMainAlpha: .20
    readonly property real shadowContactAlpha: .10
    readonly property int shadowMainOffset: 12
    readonly property int shadowMainBlur: 32
    readonly property int shadowContactOffset: 2
    readonly property int shadowContactBlur: 6
    readonly property real regularAlpha: dark ? .52 : .58
    readonly property color regularColor: dark ? "#1c1c1e" : "#ffffff"
    readonly property color plainFill: dark ? Qt.rgba(1, 1, 1, .06) : Qt.rgba(0, 0, 0, .04)
    readonly property color hoverFill: dark ? Qt.rgba(1, 1, 1, .08) : Qt.rgba(0, 0, 0, .06)
    readonly property color pressFill: dark ? Qt.rgba(1, 1, 1, .12) : Qt.rgba(0, 0, 0, .10)
    readonly property color inputFill: dark ? Qt.rgba(1, 1, 1, .06) : Qt.rgba(0, 0, 0, .06)
    readonly property color labelPrimary: dark ? Qt.rgba(1, 1, 1, .92) : Qt.rgba(0, 0, 0, .92)
    readonly property color labelSecondary: dark ? Qt.rgba(1, 1, 1, .62) : Qt.rgba(0, 0, 0, .62)
    readonly property color labelTertiary: dark ? Qt.rgba(1, 1, 1, .40) : Qt.rgba(0, 0, 0, .40)
    // §9 exceptions: retain approved optics until user reviews the pilot.
    readonly property real refraction: 3
    readonly property real magnification: 1.025
    readonly property real reflection: .50
    // Existing normalized API; not a claim of measured 20 logical-pixel blur.
    readonly property real backdropBlur: .20
}
