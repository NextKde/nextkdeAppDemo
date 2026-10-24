import QtQuick
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

// Gallery chrome and composition example. Shared component defaults stay independent.
QtObject {
    property bool dark: false
    readonly property int gap: 8
    readonly property int pageInset: 16
    readonly property int sectionGap: 12
    readonly property int sectionTitleSize: 17
    readonly property int sectionPadding: 8
    readonly property int cardRadius: 8
    readonly property int cardPadding: 12
    readonly property int cardHeight: 196
    readonly property int thumbnailHeight: 88
    readonly property int sidebarWidth: 224
    readonly property int sidebarPadding: 16
    readonly property int sidebarSpacing: 8
    readonly property int titleSize: 17
    readonly property int captionSize: 11
    readonly property int searchHeight: 30
    readonly property int searchFontSize: Ui.AppTheme.compactControlFontSize
    readonly property int searchIconSize: 14
    readonly property int searchInset: 12
    readonly property int searchIconGap: 6
    readonly property int sceneHeight: 240
    readonly property int windowChromeHeight: 30
    readonly property int toolbarHeight: 48
    readonly property int toolbarTitleSize: 17
    readonly property int toolbarGroupGap: 2
    readonly property real toolbarBlur: .30
    readonly property int toolbarRadius: 12
    readonly property var toolbarOptics: Controls.LiquidStyle.intensityProfile("light")
    readonly property real mainMaterialOpacity: .95
    readonly property real mainBackdropBlur: .35
    readonly property int controlHeight: 28
    readonly property int navigationHeight: 30
    readonly property int listHeight: 32
    readonly property int controlRadius: 8
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
    readonly property int bodySize: 13
    readonly property int fast: 150
    readonly property int instant: 100
    readonly property real pressScale: 1
    readonly property real disabledOpacity: .38
    readonly property real shadowMainAlpha: .08
    readonly property int shadowMainOffset: 2
    readonly property int shadowMainBlur: 8
    readonly property color contentFill: Ui.AppTheme.contentBackground
    readonly property color secondaryFill: Ui.AppTheme.contentSecondaryBackground
    readonly property color controlFill: Ui.AppTheme.controlBackground
    readonly property color dialogFill: Ui.AppTheme.dialogBackground
    readonly property color plainFill: controlFill
    readonly property color hoverFill: dark ? Qt.rgba(1, 1, 1, .08) : Qt.rgba(0, 0, 0, .06)
    readonly property color pressFill: dark ? Qt.rgba(1, 1, 1, .12) : Qt.rgba(0, 0, 0, .10)
    readonly property color inputFill: controlFill
    readonly property color cardFill: secondaryFill
    readonly property color cardHoverFill: Ui.AppTheme.mix(secondaryFill, labelPrimary, .04)
    readonly property color cardPressFill: Ui.AppTheme.mix(secondaryFill, labelPrimary, .08)
    readonly property color separator: dark ? Qt.rgba(1, 1, 1, .10) : Qt.rgba(0, 0, 0, .10)
    readonly property color labelPrimary: dark ? Qt.rgba(1, 1, 1, .92) : Qt.rgba(0, 0, 0, .92)
    readonly property color labelSecondary: dark ? Qt.rgba(1, 1, 1, .62) : Qt.rgba(0, 0, 0, .62)
    readonly property color labelTertiary: dark ? Qt.rgba(1, 1, 1, .40) : Qt.rgba(0, 0, 0, .40)
    // Restrained in-window optics; these are project values, not Apple measurements.
    readonly property real refraction: .6
    readonly property real magnification: 1
    readonly property real reflection: .12
    // Normalized API, not a physical blur-radius measurement.
    readonly property real backdropBlur: toolbarBlur
}
