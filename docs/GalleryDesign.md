> Settings forms use the canonical `SettingsGroup` and `SettingsItem` contract in
> [Settings.md](Settings.md): 15px bold group title, 12px normal item name, optional
> 10px muted description, compact rows and an ordinary `#f7f7f7` borderless group.
> The settings reference uses 24px control slots; switches are 44×20px and centered.

## Rule one: only floating operation layers use glass

Scope: these rules govern application composition, not removal of liquid component capabilities. Gallery keeps liquid buttons, inputs, switches, sliders and selectors alongside solid comparisons. Compact dimensions and material selection are independent.

Ask: **Does this component float above content?**

| Answer | Material |
| --- | --- |
| Yes | Liquid Glass |
| No | Ordinary material |

Gallery uses **transparency between layers inside the application**. The original full-width rectangular floating region overlays real scrolling app content. At the top, the header and body form one ordinary surface with no shadow, highlight or dividing edge. Once actual content scrolls underneath, the floating material becomes 95% opaque with QML blur and no bottom shadow. Returning to the top restores the flat surface; the window always stays opaque.
Keep the original decoration coordinates and avoid an inset rounded block. Top actions, selector and sidebar search retain their liquid finish.

---

## Rule two: avoid nested glass by default; explicitly compose the main pane and liquid actions

| Context | Container | Children |
| --- | --- | --- |
| Ordinary Dialog | Ordinary | Ordinary buttons and search |
| Floating search panel | Light glass | Ordinary search and list |
| Popover | Light glass | Ordinary buttons and list |
| Original full-width rectangular floating region | 95% material opacity, QML blur of underlying app content, no bottom shadow | Decorations unchanged; top actions and selector use light liquid |
| Embedded toolbar | Ordinary | Ordinary controls |
| Left navigation | One ordinary background panel, `opacity: 0.95`, QML underlay blur; no container-level liquid effects | Ordinary directory rows; light liquid navigation search and action buttons; opaque text |
| Control center | Glass | Mostly ordinary controls |

> **Generally emphasize one glass layer. Gallery explicitly combines its 95% in-window floating material with light liquid top controls, without another rounded header block or control shadows.**

---

### Floating panel material contract (2026-10-27)

Context/right-click menus, search suggestion dropdowns, select-option popups and
popovers are floating panels because they overlay the current page. **Use one
liquid material for the panel background.** This applies regardless of whether
the trigger is a search field, a button or a right-click gesture.

- Internal categories, candidate rows, menu items and separators use ordinary
  material. Hover, selection and press use ordinary fills; a row implemented as
  a Button is still an ordinary row. Do not create a liquid tile for every item.
- Text, icons and interactive foreground stay opaque. Adjust the background's
  tint/readability to increase opacity; never fade the entire popup. Keep enough
  blur and coverage that underlying text does not compete with its labels.
- Sample actual same-window content, excluding the popup and its capture. Use
  QML blur/refraction, with no KWin liquid plugin or desktop capture. In Qt Quick
  Controls, keep sampled popups in the same window with `Popup.Item`.
- Reduced transparency, software rendering or missing sampling uses an opaque
  ordinary fallback. Keep keyboard navigation, dismissal and accessibility.
- Keep the glass edge; do not add a blue/accent outline on focus or opening.

This is the default for application integration and overrides generic advice
that every control inside a floating layer should itself be liquid. The continuous
sidebar retains its ordinary-panel contract below. Panel corner radii follow panel
geometry; the capsule rule for liquid buttons does not apply to the whole panel.

### Left navigation material contract (2026-10-27)

The sidebar is one continuous ordinary background panel adjoining the window
edges. Do not make it an inset floating card or a LiquidSurface container; no
container-level refraction, highlights, rounded glass rims or floating shadows.
Background `opacity: 0.95` and QML underlay blur are compositing rules, not a liquid
material for the sidebar itself. Apply opacity only to the background, keeping
text, icons and interactive content clear.

- Navigation search fields and action buttons: light liquid, sampling a separate sidebar background.
- Directory group headings and rows: ordinary material; ordinary selection, hover and press fills.
- A directory row implemented as a Button still follows the row rule, without liquid effects.

Use **QML shader / `MultiEffect` blur**, exposed through `LiquidBackdrop.blur`,
starting at `.35` as for the main floating region. Background blur is not a
`DropShadow` shadow. Do not use a KWin liquid plugin, compositor blur requests or
native shadows.

The host supplies a subtree of the actual background/content underneath the
navigation coverage in the same QQuickWindow. Exclude the navigation material,
text, controls and capture itself. Map real coordinates and clip output to the
navigation region. Do not stretch or duplicate the right page's edge underneath
the sidebar, or substitute an example image or desktop screenshot. A featureless
underlay may produce a quiet material; do not invent texture. Keep the window
opaque so transparency reveals only this application's contents.

Navigation material opacity `.95` does not depend on the right header's
`scrollOffset > 12px` threshold. Only that header returns to an ordinary surface
at scroll origin. Reduced transparency, software rendering or a missing eligible
same-window source uses a fully opaque navigation background and stops capture;
text and interaction states remain readable.

## Rule three: only three color families

Use content, control and glass families rather than inventing a palette per component.
In light mode, ordinary solid control text is black; liquid control text uses
an opaque, softer dark gray. Primary, destructive and disabled text keep their roles.

| Family | Purpose | Light | Dark |
| --- | --- | --- | --- |
| Content | Text areas, lists, editors and content panels | `#FFFFFF` | `#1C1C1E` |
| Secondary content | Groups, striped areas and secondary panels | `#F5F5F7` | `#242426` |
| Control | Ordinary buttons, search and settings | `#EDEDF0` | `#3A3A3C` |
| Control (Dialog) | Dialog container | `#F7F7F9` | `#2C2C2E` |
| Glass | Determined by the backdrop | Adaptive light glass | Adaptive dark glass |

### 3.1 Dialog and button backgrounds differ

Dialog and buttons belong to the control family but retain one discernible brightness step.

| Theme | Brighter surface | Values |
| --- | --- | --- |
| Light | Dialog container | `#F7F7F9` is brighter than `#EDEDF0` |
| Dark | Button control | `#3A3A3C` is brighter than `#2C2C2E` |

The direction reverses with the theme. Keep the separation modest.

### 3.2 IF / ELSE for AI contributors

```text
IF material == Glass
    background = AdaptiveGlass
    // Never substitute a fixed RGB fill for glass

ELSE IF theme == Light
    content.background = #FFFFFF
    content.secondary  = #F5F5F7
    control.background = #EDEDF0
    dialog.background  = #F7F7F9
    search.background  = #EDEDF0

ELSE IF theme == Dark
    content.background = #1C1C1E
    content.secondary  = #242426
    control.background = #3A3A3C
    dialog.background  = #2C2C2E
    search.background  = #3A3A3C

ELSE
    background = SemanticColor
```

---

## Rule four: material does not change dimensions

The same component keeps its dimensions when its material changes.

| Property | Starting value |
| --- | --- |
| Body | 13px |
| Button, input and selector text (including placeholders) | 11px |
| Ordinary button | Height 28px |
| Shared input default | Height 28px, matching the button |
| Inline button beside body text (provisional) | Height 20px |
| Secondary dialog footer button | Height 24px |
| Important liquid Dialog footer button, usually solid | Height 30px |
| Toolbar button | Height 26px |
| Gallery sidebar search | Height 30px, an explicit host size |
| Navigation row | Height 30px; selected fill inset 2px vertically |
| List row | Height 32px |
| Toolbar action row | Height 48px |
| Window decoration row | Height 30px, original position |
| Base spacing | 4 / 8 / 12 / 16px |
| Other ordinary-control radius | 8px; action-button corners follow their size and role |
| Floating container radius | 12–16px |

---

# Gallery design language: implementation

[简体中文](GalleryDesign.zh-CN.md) · Version 2.10 · 2026-10-27

The four rules above take precedence over conflicting older material, color and
geometry specifications. Compact desktop proportions and restrained optics remain
the direction; values are project decisions, not official Apple measurements.

## Implementation

AppTheme owns contentBackground, contentSecondaryBackground, controlBackground
and dialogBackground. Gallery opts into compactDesign for common control dimensions
without changing materialForm, specificationForm or liquid optics. Hosts explicitly
select ordinary material where appropriate; existing defaults remain compatible. Gallery
layout values live in demo/gallery/components/MaterialSpecTokens.qml.

The right content scene contains an opaque base and the complete scrolling page.
The floating region overlays it, flush to the original top and side boundaries with
radius=0. It has no inset rounded card. Decorations retain their original 30px row at
y=0, with 14.5px right and 10.5px top control margins. The page initially reserves
30 + 16 + 48 + 12px, then scrolls beneath the region. Both pages expose scrollOffset
from contentY minus originY, clamped at zero. Blur and material activate only
after the 12px initial gap has scrolled away. Returning to the top disables them;
changing component pages resets scroll. Geometry and decoration coordinates stay fixed.
Language/theme actions and the background selector use the light liquid finish.
They sample only the main material background, excluding controls, text and decorations.
Control text stays 11px and fully opaque. The left navigation background follows the
`.95` ordinary-panel contract above; rows retain ordinary fills. Its search and action buttons explicitly
use light liquid material, sampling the separate sidebar material background; reduced
transparency falls back to ordinary controls.
Navigation items have no gap between rows, 30px row height and 12px Medium (500)
labels, including the selected row. The selected blue fill is inset 2px at the
top and bottom; hover still fills the ordinary solid row. Hover uses `#dbdbdd`
in light mode, while the selected fill uses the blue accent.
Selected item text is white.
The Button, Input and Select rule pages share a compact macOS 15-inspired text
hierarchy: 24px Bold primary page title, 17px DemiBold primary rule heading,
15px DemiBold placement heading and 13px regular secondary explanation. Sidebar
group labels stay 11px DemiBold in the secondary label color, with 12px above
and 4px below. These are Gallery tokens, not fixed Apple control measurements.
Cards, code and lists use content colors. Ordinary Dialog containers use the Dialog
role, and their buttons use the distinct control role. The floating search example
has one glass container with an ordinary search field and ordinary list.

## Adaptive glass

adaptiveGlass samples an eligible sibling scene through LiquidBackdrop. The existing
LiquidSurface shader responds to sampled pixel luminance for readability. The actual
background and theme determine the result; a fixed RGB rectangle must not substitute
for glass. A thin neutral tint only adjusts appearance.

Composition: opaque app base and actual scrolling content, QML background blur,
95% floating material, then clear controls. LiquidBackdrop.sourceItem references
contentScene with its real lists, cards and text, excluding the floating layer.
The right header stops sampling at scroll origin, where an ordinary fill matches the body background.
MultiEffect applies blur (.35) while the original content remains displayed below.
LiquidSurface groups its material with layer.enabled and opacity=.95; labels,
buttons and decorations remain opaque. Window.color and the content base are opaque,
so the remaining 5% shows the application's contents, never external windows.
The floating region has no added bottom shadow. No KWin
liquid plugin, compositor blur or native shadow is requested. The background selector
controls component examples only and is not a source for the main floating material.
Reduced transparency uses an opaque material and ordinary top controls.

General light glass uses edge refraction .6, magnification 1 and reflection .12.
The floating material and sidebar search use the shared light optical intensity: resting
refraction 1.5, magnification 1.012 and reflection .28. Avoid thick rims and layered shadows. Ordinary controls/cards
have no shadow; floating containers may have one subdued shadow. The optics page is
an explicitly labelled floating operation-layer demonstration, not a content template.

## Focus and selection contract (2026-10-27)

**Instruction for AI and application authors:** liquid controls keep their own glass
edge when focused, selected, pressed or opened. Do not add a blue/accent border,
an outer focus ring, or a wrapper Rectangle/overlay for those states. Do not copy
the ordinary-control focus recipe onto a liquid surface. Do not hardcode focus
colours such as `#9CCAFF`, `#007AFF` or `#0A84FF`.

| Actual material | Focus and selection presentation |
| --- | --- |
| Liquid search, input, action button or selector | Keep the shared component's glass edge and built-in state treatment; no additional focus/selection outline |
| Ordinary solid control, including an explicit solid fallback | Use the component's semantic `AppTheme.focusRing` treatment; no application-specific colour literal |
| Ordinary directory row | Keep the defined ordinary selection/hover fill; do not turn it into liquid material or add a liquid outline |

Choose by the actual rendered material, not a `Liquid*` type name. `activeFocus`,
`visualFocus`, `checked` and popup-open state are different interaction states;
none implies a blue outline on liquid material. Keep focus ownership, caret,
text selection, Tab/arrow/Enter/Space behaviour and accessibility intact.
Use the shared component's supported state properties rather than an extra border.

Reference: `shared/qml/controls/LiquidTextField.qml` draws its focus outline only
when `!root._liquid && root.activeFocus && root.enabled`; `LiquidSelect.qml` also
gates its outline on the solid form. These are material-specific rules, not a
reason to disable focus. This contract overrides earlier generic 2px-ring advice
and historical integration notes. Some older controls may still need alignment;
this documentation update does not claim a completed implementation audit.

## States and review

2026-10-27: updated the left navigation contract and companion documentation only.
GalleryRoot still needs the actual underlay capture and `.95` ordinary navigation background;
this rule revision does not claim implementation or runtime acceptance.

Body 13, actions 28 high, search 30, navigation rows 30, list rows 32 and toolbar 48
remain identical across materials. Button, input, placeholder and selector text use
11px, centered vertically. Button and selector labels use Font.Medium (500);
input and placeholder text use Font.Normal (400). Buttons and ordinary-height inputs use 4px vertical
padding; inputs below 26px use 2px. Standard horizontal padding is 12px,
with additional space for search icons and
shortcuts. Heading typography stays separate. Only ordinary solid controls use a 2px
semantic focus indicator; liquid controls follow the focus and selection contract above. Use fill changes for press and hover; honor AppTheme reduced motion.

On 2026-10-24 the user explicitly requested a workstation preview. Gallery loaded
and reloaded successfully. No build, tests or shader bake were performed; full
visual, keyboard, popup and theme acceptance remains pending. Further verification
defaults to a VM or hosted CI unless the user explicitly requests the workstation.

## Help tooltips

Hover/keyboard help uses compact floating liquid `KosToolTip`: 0.7 material
coverage, 14px corners, 11px opaque normal text and 10px horizontal / 5px vertical
padding. Sample real same-window content with QML blur/refraction; no KWin plugin.
Opaque material is only the accessibility/rendering fallback. Follow
[Tooltips](Tooltips.md); show full navigation labels only when elided.
