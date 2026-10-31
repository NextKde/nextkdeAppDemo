# Settings groups and items

[简体中文](Settings.zh-CN.md)

This is the common settings-form contract. Use `SettingsGroup` and `SettingsItem`
from `shared/qml/foundation`; do not rebuild their card, heading or row per page.
It takes precedence over earlier generic secondary-card recipes for settings forms.
The Theme **Interface shape** example is the reference composition, not a second
visual implementation. Its controls update only example-owned state.

## Hierarchy and dimensions

| Element | Default contract |
| --- | --- |
| Group heading | 15px, Bold (700), primary text; outside the card |
| Item name | 12px, Normal (400); one setting name, no extra heading or icon |
| Optional description | 10px, Normal; light `#8E8E93`, dark `#98989D`; wraps |
| Group surface | Ordinary, light `#f7f7f7`, dark `#242426`; radius 12px; no outline or shadow |
| Heading to surface | 6px |
| Between groups | Host column spacing 12px |
| Group top/bottom padding | 2px |
| Between items | 0px extra spacing |
| Item height | Minimum 28px; grows for description, wrapped name and controls |
| Item padding | 16px horizontal, 2px vertical |
| Name to description | 2px |
| Name block to controls | 12px horizontally; 6px if stacked |
| Standard trailing controls | 24px layout height for segmented controls and sliders; switches 20px |
| Separator | 1px, inset 16px on both ends, only between visible setting rows |

The compact switch has a 44×20px visible body, without extra vertical margins.
Sliders use a 26×14px thumb and 4px track. Their 24px layout height matches the
segmented control; all three remain centered on their row.

`title` on SettingsItem means the single setting name, not a second section title.
Do not add an icon, a separate small heading, or another card around every row.
Descriptions are optional supporting text and never use the group heading style.

The surface and item rows are ordinary material. The host explicitly chooses the
existing control's liquid or solid variant. Retain its keyboard and accessible
behaviour; liquid controls never acquire an accent focus/selection outline. Choice
preview tiles are ordinary controls and may show their actual selected state.
Reduced transparency uses existing controls' opaque variants.

## Choice controls

Use this dropdown for settings with **three or more options**. Only two-choice
settings may remain segmented. Dropdown option text uses **Normal (400)** weight,
including the selected option; use `popupFontWeight: Font.Normal`. Use canonical `LiquidSelect` with `indicatorStyle: "upDown"`: the closed
trigger uses `plainTrigger: true` and shows only the current value and paired
up/down chevrons. Only the chevron area has an ordinary gray rounded background
(`indicatorBackground: true`); the value text has no button fill, capsule, outline,
shadow or hover background. This remains true on focus, press and popup opening. Keep its 24px
settings height and the SettingsItem right inset. The example follows this rule.
The settings popup uses `popupMaterialForm: true`, opaque theme-aware defaults (light `#f0f0f1`, dark `#2c2c2e`),
8px corners, 3px padding and 24px rows. Use `compactPopup: true` to size the menu
from its longest option plus the checkmark gutter and padding; do not impose the
generic 160px minimum. Clamp long menus to the window width. Opaque settings menus
remain fully opaque during opening/closing too. Set `popupBorderWidth: 0` and
`popupShadowEnabled: true`: use one subtle outer shadow on all sides (zero X/Y
offset, 0.14 opacity, 7px softness, 18px extent). The panel has no border. This
QML shadow samples no desktop and requests no KWin effects. With `neutralOptionHighlight: true`,
the selected row is identified only by a leading theme-aware checkmark: no blue active
fill, no blue text. Hover and keyboard navigation use a neutral gray hint; all
rows remain ordinary material. This is the explicit settings-select exception to the
general floating liquid-panel recipe. Selection stays
host-owned through `activated(int)`; do not save on opening or focus changes.

## Component API

`SettingsGroup` accepts `title` and default child content. It owns the heading,
one ordinary panel and a zero-spacing content column. `background` exposes the
panel Item for a separate same-window `LiquidBackdrop`; it excludes the foreground
and all controls. `contentItem` exposes the content layout. The default width is
420px; bind `width` or `Layout.fillWidth` in the host. Height follows the content.
Supported overrides are `backgroundColor`, `titleColor`, `cornerRadius`,
`titleSpacing`, `verticalPadding` and `titleFont`; use defaults for unified forms.

`SettingsItem` accepts `title`, optional `description`, and default trailing
controls. It owns labels, geometry and separators, with no settings-state model.
Controls stay right-aligned on all rows. If 120px for the name plus 12px spacing
and the controls' preferred width cannot fit, they move below the labels and fit
the available width, keeping the same right inset. Long text wraps and increases the row height; no fixed height
may clip a description. `stacked` exposes the actual layout choice. `separator`
can suppress an intermediate separator; no separator is drawn after the last
visible item. Ordinary `enabled` propagates to child controls. Supply each
interactive control's accessible name as well as its host-owned state binding.

Other supported geometry/style inputs are `minimumRowHeight`, `horizontalPadding`,
`verticalPadding`, `controlSpacing`, `minimumLabelWidth`, `titleColor`,
`descriptionColor`, `separatorColor`, `titleFont` and `descriptionFont`.
The host owns the surrounding scroll view; neither component creates nested scrolling.

```qml
import QtQuick
import QtQuick.Layouts
import Kos.Ui

SettingsGroup {
    id: section
    width: 600
    title: "Interface shape"
    property real blurStrength: 0.42

    SettingsItem {
        title: "Blur strength"
        description: "Soften the content behind liquid controls."
        LiquidSlider {
            Layout.preferredWidth: 170
            Layout.preferredHeight: 24
            materialForm: true
            value: section.blurStrength
            Accessible.name: "Blur strength"
            onPreviewChanged: value => section.blurStrength = value
        }
    }
}
```

Application adapters keep confirmed and draft values, save on `commitRequested`,
and restore the confirmed value on `canceled` or save failure. Component grouping
does not change those existing control contracts.

## Reference demo and review

Open `qs -p demo/settings-demo.qml` in a requested graphical review environment.
`GALLERY_LANGUAGE=zh` selects Chinese; `GALLERY_THEME=dark` selects dark appearance.
The Gallery entry **Settings groups** uses the exact same `SettingsExample.qml`.
The first group contains the macOS/Material previews followed by Material style,
Blur strength and Liquid strength. The next group demonstrates wrapping,
conditional availability, and the 12px inter-group spacing.
Use an ordinary solid page background and neutral solid preview backgrounds;
do not add a gradient behind the group or its appearance previews.

Review actual segmented changes, slider preview/commit/cancel, keyboard focus,
disabled controls, light/dark appearance, long descriptions and a narrow window.
Use only actual same-window background sampling and QML effects; no KWin plugin.

The focused Qt Quick checks are in `tests/tst_settings.qml`. In an authorized review
environment run the Qt 6 `qmltestrunner -input tests -platform offscreen`. They exercise
real pointer/keyboard interaction, draft/commit/cancel, conditional availability and
wrapped/stacked layouts. The QML preview requires no compilation or shader baking.

The appearance choices share canonical `SettingsAppearancePreview` artwork: the
same miniature settings scene with a sidebar, switch and slider. macOS is neutral
and compact with traffic lights and small translucent toolbar pills; Material
uses a tonal header, navigation rail and larger rounded surfaces. Labels show
only macOS and Material Design; do not add descriptive taglines. The preview takes `form` (`macos`
or `material`), `darkAppearance`, `windowTitle` and `settingTitle`. It is static,
scales to fit, has no interaction or gradients, and is not a live system capture.
The enclosing radio button remains responsible for selection and accessibility.

Plain solid selects inherit panel/text colours from LiquidSelect. Do not override them with light-only literals. Dark text/checkmarks use #f5f5f7; neutral hover uses white at 12% in dark mode.

## Grouped editor fields

Use SettingsTextField, SettingsTextArea, SettingsSwitch, SettingsDateField and
SettingsTimeField inside SettingsGroup/SettingsItem. The group supplies one
ordinary background spanning the title and control: no separate input capsule,
per-control card or nested glass. Text fields are 24px high with 12px text;
switches use a 44×20px body. Rows keep their 28px minimum and 2px vertical padding.
Date/time fields retain editable text, whole-field activation and keyboard navigation.
Their ordinary opaque menus follow the theme; hosts provide locale parsing,
formatting and accent colour. Validation and persistence remain in the application.

For narrow editors set `SettingsItem.allowStacking: false`: reserve minimumLabelWidth for the label and constrain the right-aligned controls to the remaining width. Flexible fields must use Layout.minimumWidth: 0; switches retain a fixed width. The default remains true for general settings pages.

Grouped text fields/areas also support `filled: true`: a solid #E5E5E8 input in light mode and #2C2C2E in dark mode, 6px corners, no border. Use this explicit option when the host requests contrast against a darker group; the default remains unfilled.

Compact rows: 28px minimum, 2px item vertical padding and 2px group outer padding; no additional margins on SettingsSwitch. Descriptions can increase row height.

Plain select triggers align the selected label and optional colour dot together to the right, with 6px between the label and chevron. Expanded menu rows retain their left-aligned checkmark/text layout.

Standalone title, notes and URL inputs use `blockInput: true`: horizontal padding 12px, 12px Normal text, AppTheme.mutedText placeholders. Their host groups use 8px corners; no inner background. Notes remain multiline.
