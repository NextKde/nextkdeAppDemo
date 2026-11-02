import QtQuick
import QtQuick.Window
import QtTest
import "../shared/qml/foundation" as Foundation

Item {
    id: harness
    width: 500; height: 200
    QtObject {
        id: target
        property int visibility: Window.Windowed
        property int closed: 0
        function showMaximized() { visibility = Window.Maximized }
        function showNormal() { visibility = Window.Windowed }
        function showMinimized() { visibility = Window.Minimized }
        function close() { closed++ }
    }
    Component {
        id: factory
        Foundation.KosWindowControls {
            targetWindow: target
            maximizeMode: true
            circleSize: 14; buttonWidth: 22; buttonHeight: 22; spacing: 6
        }
    }
    TestCase {
        name: "WindowControlOwnership"
        when: windowShown
        function init() {
            failOnWarning(/ReferenceError|TypeError|Binding loop|Unable to assign|Cannot assign/)
            target.visibility = Window.Windowed
            target.closed = 0
        }
        function make() {
            const controls = createTemporaryObject(factory, harness)
            verify(controls !== null)
            tryCompare(controls, "width", 78)
            return controls
        }
        function test_dynamic_list_and_layout() {
            const controls = make()
            tryCompare(controls.buttonLayout, "length", 3)
            controls.actions = ["close"]
            tryCompare(controls, "width", 22)
            tryVerify(() => controls.buttonLayout.length === 1 && controls.buttonLayout[0].action === "close")
            compare(controls.buttonLayout[0].x, 4)
            compare(controls.buttonLayout[0].y, 4)
            controls.actions = []
            tryVerify(() => controls.buttonLayout.length === 0)
            controls.actions = ["close", "maximize"]
            tryCompare(controls, "width", 50)
            tryVerify(() => controls.buttonLayout.length === 2 && controls.buttonLayout[1].x > controls.buttonLayout[0].x)
            compare(controls.buttonLayout[0].action, "close")
            controls.circleSize = 18
            tryVerify(() => controls.buttonLayout[0].width === 18 && controls.buttonLayout[0].x === 2)
        }
        function test_takeover_and_fallback_actions() {
            const controls = make()
            const maximize = findChild(controls, "windowfullscreenButton")
            mouseClick(maximize)
            compare(target.visibility, Window.Maximized)
            mouseClick(maximize)
            compare(target.visibility, Window.Windowed)
            controls.externalDrawing = true
            compare(controls.width, 78)
            verify(!maximize.enabled)
            compare(maximize.opacity, 0)
            mouseClick(maximize)
            compare(target.visibility, Window.Windowed)
            controls.externalDrawing = false
            verify(maximize.enabled)
            maximize.forceActiveFocus()
            keyClick(Qt.Key_Space)
            compare(target.visibility, Window.Maximized)
            controls.actions = ["close"]
            tryCompare(controls, "width", 22)
            mouseClick(findChild(controls, "windowcloseButton"))
            compare(target.closed, 1)
        }
    }
}
