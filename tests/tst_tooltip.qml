import QtQuick
import QtQuick.Controls
import QtTest
import "../demo/Kos/Ui/foundation" as Ui
import "../demo/Kos/Ui/controls" as Liquid

Item {
    id: harness
    width: 440
    height: 360
    readonly property alias toolTipBackdrop: sampledBackdrop
    Rectangle { id: scene; anchors.fill: parent; color: "#ffffff" }
    Liquid.LiquidBackdrop {
        id: sampledBackdrop
        sourceItem: scene
        registerAsDefault: false
    }
    Component {
        id: buttonFactory
        Button {
            id: button
            width: 80; height: 28
            hoverEnabled: true
            property int clicks: 0
            text: "+"
            onClicked: clicks++
            Ui.KosToolTip {
                objectName: "help"
                target: button
                text: "Open settings"
                delay: 60
                timeout: 0
                showOnFocus: false
            }
        }
    }
    TestCase {
        name: "CommonToolTip"
        when: windowShown
        function init() {
            failOnWarning(/ReferenceError|TypeError|Binding loop|Unable to assign|Cannot assign/)
            mouseMove(harness, harness.width - 1, harness.height - 1)
        }
        function cleanup() {
            scene.color = "#ffffff"
            sampledBackdrop.sourceItem = scene
            sampledBackdrop.active = true
        }
        function makeButton(properties) {
            const button = createTemporaryObject(buttonFactory, harness,
                Object.assign({x: 140, y: 150}, properties || {}))
            verify(button !== null)
            verify(waitForRendering(button))
            return button
        }
        function tipFor(button) {
            const tip = findChild(button, "help")
            verify(tip !== null)
            return tip
        }
        function hover(button, tip) {
            mouseMove(button, button.width / 2, button.height / 2)
            tryVerify(() => tip.opened)
        }
        function test_hoverDelayAndLeave() {
            const button = makeButton()
            const tip = tipFor(button)
            mouseMove(button, 20, 14)
            wait(20)
            verify(!tip.visible, "do not flash immediately on pointer entry")
            tryVerify(() => tip.opened)
            mouseMove(harness, 1, harness.height - 1)
            tryVerify(() => !tip.visible)
        }
        function test_onlyTruncatedAndAvailability() {
            const button = makeButton()
            const tip = tipFor(button)
            tip.onlyWhenTruncated = true
            mouseMove(button, 20, 14)
            wait(100)
            verify(!tip.visible, "complete labels must not repeat themselves")
            tip.truncated = true
            tryVerify(() => tip.opened)
            tip.truncated = false
            tryVerify(() => !tip.visible)
            tip.onlyWhenTruncated = false
            tip.text = ""
            wait(100)
            verify(!tip.visible)
            tip.text = "Open settings"
            tip.when = false
            wait(100)
            verify(!tip.visible)
        }
        function test_pressAndDisabledDoNotInterfere() {
            const button = makeButton()
            const tip = tipFor(button)
            hover(button, tip)
            mouseClick(button, 20, 14)
            compare(button.clicks, 1, "the tooltip must not consume the action")
            tryVerify(() => !tip.visible)
            wait(100)
            verify(!tip.visible, "a press dismisses help until a new hover")
            mouseMove(harness, 1, harness.height - 1)
            hover(button, tip)
            button.enabled = false
            tryVerify(() => !tip.visible)
        }
        function test_keyboardFocusAndEscape() {
            const button = makeButton()
            const tip = tipFor(button)
            tip.showOnFocus = true
            button.forceActiveFocus(Qt.TabFocusReason)
            tryVerify(() => tip.opened)
            verify(button.activeFocus, "help must not take keyboard focus")
            keyClick(Qt.Key_Escape)
            tryVerify(() => !tip.visible)
            keyClick(Qt.Key_Space)
            compare(button.clicks, 1)
        }
        function test_themeAndPlainTextWrapping() {
            const button = makeButton()
            const tip = tipFor(button)
            tip.maximumWidth = 150
            tip.text = "<b>Inspect</b> the selected item's details without changing saved settings"
            hover(button, tip)
            verify(tip.width <= 150)
            verify(tip.contentItem.lineCount > 1)
            compare(tip.contentItem.textFormat, Text.PlainText)
            compare(tip.font.pixelSize, 11)
            compare(tip.font.weight, Font.Normal)
            compare(tip.topPadding, 5)
            compare(tip.bottomPadding, 5)
            compare(tip.leftPadding, 10)
            compare(tip.rightPadding, 10)
            compare(tip.cornerRadius, 14)
            compare(tip.materialOpacity, 0.7)
            compare(tip.opacity, 1)
            compare(tip.contentItem.opacity, 1)
            tip.reduceTransparency = true
            tryVerify(() => !tip.sampling)
            const fallback = findChild(tip.background, "toolTipFallback")
            verify(fallback !== null && fallback.visible)
            compare(fallback.radius, 14)
            tip.darkAppearance = false
            compare(fallback.color, "#f0f0f1")
            compare(tip.contentItem.color, "#55555a")
            tip.darkAppearance = true
            compare(fallback.color, "#303034")
            compare(tip.contentItem.color, "#d6d6da")
            compare(fallback.color.a, 1)
            compare(fallback.border.width, 0)
        }
        function test_sampledGlassAndSafeFallback() {
            if (harness.GraphicsInfo.api === GraphicsInfo.Software)
                skip("Sampled optics require a GPU backend")
            const button = makeButton()
            const tip = tipFor(button)
            scene.color = "#d84030"
            hover(button, tip)
            tryVerify(() => tip.sampling)
            compare(tip.backdrop, sampledBackdrop)
            const surface = findChild(tip.background, "toolTipLiquidSurface")
            verify(surface !== null)
            compare(surface.tintStrength, 0.7)
            verify(surface.blurStrength > 0 && surface.refractionStrength > 0)
            const pixel = () => grabImage(tip.background).pixel(
                Math.floor(tip.width / 2), Math.floor(tip.height - 6))
            const before = pixel()
            scene.color = "#2040d0"
            wait(80)
            const after = pixel()
            verify(Math.abs(before.r-after.r) + Math.abs(before.b-after.b) > 0.1,
                "the open bubble must sample changing real content")
            tip.reduceTransparency = true
            tryVerify(() => !tip.sampling)
            const fallback = findChild(tip.background, "toolTipFallback")
            verify(fallback.visible && fallback.color.a === 1)
            tip.reduceTransparency = false
            tryVerify(() => tip.sampling)
            // An ancestor source would capture its own sampler and must be rejected.
            tip.backdrop = sampledBackdrop
            sampledBackdrop.sourceItem = harness
            tryVerify(() => !tip.sampling)
            verify(fallback.visible && fallback.color.a === 1)
            sampledBackdrop.sourceItem = scene
            tryVerify(() => tip.sampling)
        }
        function test_windowBounds_data() {
            return [{tag:"top-left",x:0,y:0,below:true},
                {tag:"bottom-right",x:360,y:330,below:false}]
        }
        function test_windowBounds(data) {
            const button = makeButton({x:data.x, y:data.y})
            const tip = tipFor(button)
            tip.maximumWidth = 180
            tip.text = "Inspect the selected item's settings"
            hover(button, tip)
            const point = tip.background.mapToItem(harness, 0, 0)
            verify(point.x >= 7.5 && point.x + tip.width <= harness.width - 7.5)
            verify(point.y >= 7.5 && point.y + tip.height <= harness.height - 7.5)
            if (data.below) verify(point.y >= button.y + button.height)
            else verify(point.y + tip.height <= button.y)
        }
        function test_timeout() {
            const button = makeButton()
            const tip = tipFor(button)
            tip.timeout = 100
            hover(button, tip)
            tryVerify(() => !tip.visible)
        }
        function test_navigationOnlyShowsElidedLabels() {
            const component = Qt.createComponent("../demo/Kos/Ui/controls/LiquidNavBar.qml")
            compare(component.status, Component.Ready, component.errorString())
            const navigation = createTemporaryObject(component, harness, {
                x: 140, y: 150, itemWidthOverride: 90, labelFontPixelSize: 13,
                materialForm: true, reduceMotion: true,
                model: [{id: "work", label: "Work"}]
            })
            verify(navigation !== null)
            verify(waitForRendering(navigation))
            function navigationTip() {
                for (const child of navigation.children) {
                    const tip = findChild(child, "liquid-nav-tooltip-0")
                    if (tip) return tip
                }
                return null
            }
            let tip = navigationTip()
            verify(tip !== null)
            tip.delay = 60
            tip.showOnFocus = false
            mouseMove(tip.target, 20, 14)
            wait(100)
            verify(!tip.visible, "a complete navigation label must not repeat")
            navigation.model = [{id: "work", label: "Window appearance and animation preferences"}]
            tip = navigationTip()
            verify(tip !== null)
            tip.delay = 60
            tip.showOnFocus = false
            mouseMove(harness, 1, 1)
            mouseMove(tip.target, 20, 14)
            tryVerify(() => tip.opened)
        }
        function test_galleryExampleLoads() {
            const component = Qt.createComponent("../demo/gallery/examples/ToolTipExample.qml")
            compare(component.status, Component.Ready, component.errorString())
            const example = createTemporaryObject(component, harness, {width:400})
            verify(example !== null)
            tryVerify(() => example.implicitHeight > 0)
        }
    }
}
