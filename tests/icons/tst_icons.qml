import QtQuick
import QtTest
import Kos.Icons
import "../../shared/Icons/IconMap.js" as Map

Item {
    width: 640; height: 240
    Rectangle { anchors.fill: parent; color: "#f5f5f7" }
    Row {
        spacing: 12
        Repeater {
            model: ["folder", "editRounded", "trash", "coffee", "running", "cycling", "swimming", "bluetooth", "cpu", "calculator"]
            Icon { required property string modelData; name: modelData; size: 32; color: "#242426" }
        }
    }
    Component { id: iconFactory; Icon { color: "black" } }
    TestCase {
        name: "UnifiedIcons"
        when: windowShown
        function initTestCase() { tryCompare(IconRegistry, "ready", true) }
        function test_aliases_are_complete() {
            for (const alias of Object.keys(Map.aliases)) {
                verify(IconRegistry.has(alias), alias)
                compare(IconRegistry.glyph(alias, false), Map.glyphs[Map.aliases[alias]], alias)
            }
        }
        function test_all_font_glyphs_are_mapped() {
            compare(IconRegistry.names.length, 1279)
            for (const name of IconRegistry.names) verify(fontProbe.supports(IconRegistry.glyph(name, false)), name)
        }
        function test_unknown_is_not_a_checkmark() {
            compare(IconRegistry.has("nonexistent-icon"), false)
            compare(IconRegistry.glyph("nonexistent-icon", false), Map.glyphs.question_square)
            compare(IconRegistry.glyph("placeholder-dot", false), "")
        }
        function test_small_and_large_sizes() {
            for (const size of [14, 16, 18, 24, 32]) {
                const item = createTemporaryObject(iconFactory, parent, {name: "coffee", size: size})
                verify(item !== null)
                compare(item.width, size)
                compare(item.height, size)
                verify(item.available)
                verify(item.ready)
            }
        }
        function test_filled_variant() {
            compare(IconRegistry.resolve("folder", true), "folder_fill")
            compare(IconRegistry.resolve("coffee", true), "nk_coffee")
        }
    }
}
