import QtQuick
import QtTest
import Kos.Ui

Item {
    width: 700; height: 220
    Component { id: navigation; KosNavigationButton { symbol: "house"; text: "Home"; width: 180 } }
    Component {
        id: tabs
        LiquidNavBar { width: 360; model: [{id: "home", label: "Home", icon: "house"}, {id: "search", label: "Search", icon: "search"}] }
    }
    Component { id: chrome; KosWindowControls { targetWindow: QtObject { property int visibility: 0 }
        actions: ["minimize", "maximize", "close"] } }
    TestCase {
        name: "IconHosts"
        when: windowShown
        function glyphs(item) {
            let result = []
            if (item.available !== undefined && item.name !== undefined) result.push(item)
            for (const child of item.children || []) result = result.concat(glyphs(child))
            return result
        }
        function test_navigation_preserves_label_and_updates_glyph() {
            const item = createTemporaryObject(navigation, parent)
            verify(item !== null)
            const icons = glyphs(item)
            compare(icons.length, 1)
            tryCompare(icons[0], "ready", true)
            verify(icons[0].available)
            item.symbol = "search"
            compare(icons[0].name, "search")
            verify(icons[0].available)
            compare(item.text, "Home")
        }
        function test_tab_model_icons_are_font_glyphs() {
            const item = createTemporaryObject(tabs, parent)
            verify(item !== null)
            tryVerify(() => glyphs(item).length >= 2)
            for (const icon of glyphs(item)) verify(icon.available, icon.name)
            item.currentIndex = 1
            compare(item.currentIndex, 1)
            compare(item.model[1].label, "Search")
        }
        function test_window_actions_keep_geometry_and_glyphs() {
            const item = createTemporaryObject(chrome, parent)
            verify(item !== null)
            tryVerify(() => item.buttonLayout.length === 3)
            const icons = glyphs(item)
            compare(icons.length, 3)
            compare(icons.map(icon => icon.name).sort().join(","), "minus,square,xmark")
            compare(item.buttonLayout.map(button => button.action).join(","), "minimize,maximize,close")
            for (const icon of icons) verify(icon.available)
        }
    }
}
