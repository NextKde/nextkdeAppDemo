"""Small source migrations for embedded glyphs; preserve consumer UI styling."""
import re
from pathlib import Path

def migrate(root):
    root = Path(root)
    for relative in ['foundation/KosNavigationButton.qml', 'foundation/KosWindowControls.qml', 'controls/LiquidNavBar.qml', 'foundation/KosEmptyState.qml', 'foundation/KosCheckBox.qml', 'controls/LiquidCheckBox.qml', 'foundation/KosComboBox.qml', 'foundation/SettingsDateField.qml', 'foundation/KosSettingsDialog.qml', 'controls/LiquidGlassButton.qml']:
        p = root / relative
        if not p.exists():
            continue
        s = p.read_text()
        original = s
        if p.name in ['KosNavigationButton.qml', 'LiquidNavBar.qml']:
            expression = 'root.symbol' if p.name == 'KosNavigationButton.qml' else 'modelData.icon || ""'
            def glyph(match):
                body = match[1]
                if 'text: ' + expression not in body:
                    return match[0]
                body = body.replace('text: ' + expression, 'name: ' + expression)
                body = body.replace('font.pixelSize:', 'size:')
                body = re.sub(r'^\s*(?:horizontalAlignment|elide|font.weight):[^\n]+', '', body, flags=re.M)
                return 'Symbols.Icon {' + body + '}'
            s = re.sub(r'(?:Label|Text) \{([^{}]*)\}', glyph, s)
        elif p.name == 'KosWindowControls.qml':
            marker = 'anchors.centerIn: parent; width: 9; height: 9'
            if marker in s:
                start = s.rfind('Item {', 0, s.index(marker))
                finish = s.index('{', start) + 1
                depth = 1
                while depth:
                    depth += (s[finish] == '{') - (s[finish] == '}')
                    finish += 1
                s = s[:start] + """Symbols.Icon {
                        anchors.centerIn: parent
                        size: 9
                        name: button.modelData === "maximize" ? "square" : button.modelData === "minimize" ? "minus" : "xmark"
                        color: "black"
                        opacity: !root.hoverGlyphs || groupHover.hovered || button.activeFocus ? .72 : 0
                        Behavior on opacity { NumberAnimation { duration: AppTheme.motionFast } }
                    }""" + s[finish:]
        elif p.name == 'KosEmptyState.qml':
            s = s.replace('Label {\n            Layout.alignment: Qt.AlignHCenter\n            text: root.symbol', 'Symbols.Icon {\n            Layout.alignment: Qt.AlignHCenter\n            name: root.symbol')
            s = re.sub(r'(name: root.symbol\s+color: root.symbolColor\s+)font.pixelSize:', r'\1size:', s)
        elif p.name in ['KosCheckBox.qml', 'LiquidCheckBox.qml']:
            s = re.sub(r'Text \{(\s*anchors.centerIn: parent\s*)text: root.checkState === Qt.PartiallyChecked \? "−" : "✓"', r'Symbols.Icon {\1name: root.checkState === Qt.PartiallyChecked ? "minus" : "checkmark"', s)
            # Only the indicator has this fixed pixelSize in these components.
            s = s.replace('color: AppTheme.accentText; font.pixelSize: 14', 'color: AppTheme.accentText; size: 14')
            s = s.replace('            font.pixelSize: 15', '            size: 15')
        elif p.name == 'KosComboBox.qml':
            s = s.replace('indicator: Text {', 'indicator: Symbols.Icon {').replace('text: "⌄"; color: AppTheme.mutedText; font.pixelSize: 16', 'name: "chevron_down"; color: AppTheme.mutedText; size: 16')
        elif p.name == 'SettingsDateField.qml':
            s = s.replace('contentItem: Label { text: parent.text; color: AppTheme.text; font.pixelSize: 18; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }', 'contentItem: Symbols.Icon { name: parent.text === "‹" ? "chevron_left" : "chevron_right"; color: AppTheme.text; size: 18 }')
        elif p.name == 'KosSettingsDialog.qml':
            s = s.replace('Label {\n                    anchors.centerIn: parent\n                    text: "⚙"', 'Symbols.Icon {\n                    anchors.centerIn: parent\n                    name: "gear_alt"')
            s = s.replace('color: AppTheme.accent\n                    font.pixelSize: 20', 'color: AppTheme.accent\n                    size: 20')
            s = s.replace('text: "×"\n                font.pixelSize: 18', 'contentItem: Symbols.Icon { name: "xmark"; color: AppTheme.text; size: 18 }')
            pattern = r'contentItem: Label \{\s*text: accentButton.checked \? "✓" : ""(.*?)\n                            \}'
            def accent(m):
                body = re.sub(r'^\s*(?:horizontalAlignment|verticalAlignment|font.weight):[^\n]+', '', m[1], flags=re.M)
                return 'contentItem: Symbols.Icon {\n                                name: "checkmark"; visible: accentButton.checked; size: 14' + body + '\n                            }'
            s = re.sub(pattern, accent, s, flags=re.S)
        elif p.name == 'LiquidGlassButton.qml':
            a = s.find('    // Icon (crisp layer on top)')
            b = s.find('    // Interaction', a)
            if a >= 0 and b > a:
                s = s[:a] + '''    Symbols.Icon {
        anchors.centerIn: parent
        name: root.symbol
        color: root.iconColor
        outlined: String(root.iconColor).toLowerCase() === "#ffffff"
        outlineColor: Qt.rgba(0, 0, 0, 0.45)
        size: root.primary ? 16 : 12
    }

''' + s[b:]
        if s != original:
            if 'import "../../Icons" as Symbols' not in s:
                s = s.replace('import QtQuick\n', 'import QtQuick\nimport "../../Icons" as Symbols\n', 1)
            p.write_text(s)

if __name__ == '__main__':
    import sys
    for root in sys.argv[1:]:
        migrate(root)
