import QtQuick
import QtTest
import "../demo/gallery/examples" as Examples

Item {
    id: harness
    width: 760
    height: 680
    Rectangle { anchors.fill: parent; color: "white" }
    Component { id: exampleComponent; Examples.SettingsExample { language: "zh" } }

    TestCase {
        name: "SettingsComposition"
        when: windowShown

        function init() {
            failOnWarning(/ReferenceError|TypeError|Binding loop|Unable to assign|Cannot assign/)
        }
        function makeExample(width) {
            const item = createTemporaryObject(exampleComponent, harness, {x: 16, y: 16, width: width || 620})
            verify(item !== null)
            verify(waitForRendering(item))
            return item
        }
        function find(root, name) {
            const item = findChild(root, name)
            verify(item !== null, name)
            return item
        }
        function test_pointer_and_keyboard_selection() {
            const example = makeExample()
            const picker = find(example, "settingsMaterialPicker")
            compare(picker.indicatorStyle, "upDown")
            verify(picker.plainTrigger)
            mouseClick(picker, picker.width / 2, picker.height / 2)
            tryVerify(() => picker.popupOpened)
            keyClick(Qt.Key_End)
            keyClick(Qt.Key_Return)
            compare(example.selectedMaterial, 2)
            picker.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Space)
            tryVerify(() => picker.popupOpened)
            keyClick(Qt.Key_Up)
            keyClick(Qt.Key_Return)
            compare(example.selectedMaterial, 1)
            const shape = find(example, "settingsShapeChoice1")
            mouseClick(shape, shape.width / 2, shape.height / 2)
            compare(example.selectedShape, 1)
            verify(picker.materialForm)
        }
        function test_slider_preview_commit_and_cancel() {
            const example = makeExample()
            const slider = find(example, "settingsBlurSlider")
            const at = fraction => slider.edgeInset + slider.travel * fraction
            const saved = example.savedBlur
            mousePress(slider, at(.2), slider.height / 2)
            mouseMove(slider, at(.8), slider.height / 2)
            verify(example.blurValue > .7)
            compare(example.savedBlur, saved, "drag preview must not save")
            mouseRelease(slider, at(.8), slider.height / 2)
            compare(example.savedBlur, example.blurValue)
            const confirmed = example.savedBlur
            mousePress(slider, at(.2), slider.height / 2)
            slider.cancelInteraction()
            mouseRelease(slider, at(.2), slider.height / 2)
            compare(example.blurValue, confirmed, "cancellation restores the confirmed value")
            compare(example.savedBlur, confirmed)
        }
        function test_switches_and_compact_controls() {
            const example = makeExample()
            const follow = find(example, "settingsFollowSwitch")
            const sunset = find(example, "settingsSunsetSwitch")
            const picker = find(example, "settingsMaterialPicker")
            compare(follow.parent.height, picker.height)
            verify(follow.height < picker.height)
            compare(find(example, "settingsBlurSlider").height, picker.height)
            verify(!sunset.enabled)
            mouseClick(sunset, sunset.width / 2, sunset.height / 2)
            verify(!example.switchAtSunset)
            follow.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Space)
            verify(example.followAppearance)
            verify(sunset.enabled)
            mouseClick(sunset, sunset.width / 2, sunset.height / 2)
            verify(example.switchAtSunset)
        }
        function test_narrow_width_and_wrapped_description() {
            const example = makeExample()
            const group = find(example, "settingsShapeGroup")
            const material = find(example, "settingsMaterialItem")
            const blur = find(example, "settingsBlurItem")
            const liquid = find(example, "settingsLiquidItem")
            verify(!material.stacked)
            verify(group.titleFont.pixelSize > material.titleFont.pixelSize)
            verify(blur.descriptionFont.pixelSize < blur.titleFont.pixelSize)
            example.width = 310
            tryVerify(() => !material.stacked, 1000, "compact select fits where a three-segment control did not")
            example.width = 220
            tryVerify(() => material.stacked)
            const originalHeight = blur.height
            blur.description = "This is a deliberately long description that wraps over multiple lines at narrow widths without pushing the control outside the group or overlapping the following setting row."
            tryVerify(() => blur.height > originalHeight)
            verify(liquid.y >= blur.y + blur.height)
            verify(group.background.height >= liquid.y + liquid.height)
            const picker = find(example, "settingsMaterialPicker")
            const corner = picker.mapToItem(group.background, picker.width, picker.height)
            verify(corner.x <= group.background.width)
            verify(corner.y <= group.background.height)
            liquid.visible = false
            tryVerify(() => !blur.followedByItem)
            example.width = 620
            tryVerify(() => !material.stacked)
        }
    }
}
