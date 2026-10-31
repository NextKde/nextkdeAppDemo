# Components and application integration

> For current material placement, palette and dimensions, follow the four rules in [Gallery design language](GalleryDesign.md). Earlier optical implementation notes below are not default UI recipes.

[简体中文](Components.zh-CN.md)

## Focus rule for application integration

Follow the **Focus and selection contract** in [Gallery design language](GalleryDesign.md).
Liquid inputs/search, buttons and selectors keep their glass edge on focus or selection;
never add a blue/accent border or outer ring in the control or its application wrapper.
Only ordinary solid forms use the semantic `AppTheme.focusRing`; do not hardcode colours.
Keep keyboard focus, editing, activation and accessibility behaviour. This current rule
supersedes generic ring advice in the historical implementation notes below; those notes
are not proof that every legacy control already complies.

## Common tooltips

Use canonical `KosToolTip` for floating liquid hover/keyboard help, not Qt attached
ToolTip styles. [Tooltip contract and API](Tooltips.md) define 0.7 material coverage,
14px corners, 10px horizontal / 5px vertical padding, 11px normal opaque text,
real same-window sampling and the truncation policy.

## Floating panels in applications

Follow the **Floating panel material contract** in [Gallery design language](GalleryDesign.md).
Context menus, search dropdowns, select-option popups and popovers use one liquid
panel background. Internal categories, rows and menu items use ordinary material,
including their hover/selected/pressed fills; Button delegates do not change that.
Use `LiquidPanelSurface` with `LiquidBackdrop`; the shared coverage default is
`LiquidStyle.panelMaterialOpacity` (0.95). `LiquidDialogSurface` uses this same
material with dialog geometry. Never fade the composited texture again over the
sharp source; see the shared material recipe in GalleryDesign.md.
Keep foreground text opaque, use real same-window sampling and QML blur, and
provide an opaque fallback. Never add liquid surfaces to every row or an extra
blue focus border. Increase background coverage when text underneath interferes.

## Liquid glass numbers

`LiquidGlassNumber` is display-only glass typography for large temperatures,
clocks and prominent values. The host formats `text`; the component accepts
normal font glyphs, including signs, decimal points, colons and degree symbols.
Use ordinary text for compact labels and long passages.

Supply a sibling `LiquidBackdrop` containing the real scene behind the digits.
The component masks that texture to the actual font outline, softens it and
refracts it across rounded bevels. QML `MultiEffect` supplies the softened glyph field; `ShaderEffect` uses that
field for a registered soft cast shadow, transmitted background pixels and
directional lighting. Shadow alone does not blur or refract the background.
There are no KWin effects, native blur requests or desktop capture.

```qml
LiquidBackdrop { id: numberBackdrop; sourceItem: scene; registerAsDefault: false }
LiquidGlassNumber {
    anchors.centerIn: parent
    text: "−3.5°"
    font.pixelSize: 144
    backdrop: numberBackdrop
    thickness: 5
    refractionStrength: 8
    blurRadius: 1.5
}
```

Keep `scene`, the provider and the number as separate sibling subtrees. Never
include the number in the captured scene. Ordinary 2D transforms and scrolling
are mapped into the provider's texture; perspective transforms are unsupported.
`thickness`, `refractionStrength` and `blurRadius` use logical pixels.
`tintStrength` defaults to .08, `reflectionStrength` to .75 and `shadowOpacity`
to .16. The `font` property controls family, size and weight; the default Black weight
leaves a broad glass interior. Leave room for the
component's implicit size, which includes bevel/shadow padding.

`reduceTransparency` follows AppTheme by default. Reduced transparency, missing
or rejected sources and software rendering use ordinary glyphs in `fallbackColor`
(default AppTheme.text). Accessible.name exposes `text` once; glyph masks are
excluded. The component owns no animation; hosts control background motion and
respect AppTheme.reduceMotion. The Gallery's **Glass numbers** page provides
editable text, presets and optical controls, plus a reduced-transparency comparison.

## Catalogue and state

Settings forms use **SettingsGroup** and **SettingsItem**. Their typography,
ordinary surface, compact rows and optional descriptions follow
[the common settings specification](Settings.md). The Gallery Settings groups page
and `demo/settings-demo.qml` consume the same Theme example.

| Purpose | Component | State contract |
| --- | --- | --- |
| Settings form | `SettingsGroup`, `SettingsItem` | Host supplies labels, descriptions and state-bound controls; 24px compact controls |
| Shared in-window capture | `LiquidBackdrop` | Host supplies a separate scene subtree |
| Glass display numerals | `LiquidGlassNumber` | Host formats text and supplies a sibling backdrop |
| Material and container | `LiquidSurface`, `LiquidCard` | Host supplies geometry, provider and readability |
| Actions and navigation | `LiquidActionButton`, `LiquidNavigationButton` | Handle `clicked()`; own the selected destination |
| Grouped icon actions | `LiquidActionButtonGroup` | Supply icons, labels and optional `enabledActions` booleans; handle `triggered(index)` in the host. Liquid groups keep the glass edge on keyboard focus |
| Input | `LiquidTextField` | Qt Quick Controls text editing and acceptance |
| Independent option | `LiquidCheckBox` | Native `checked` / `toggled()` behavior |
| Setting toggle | `LiquidGlassSwitch` | Confirm `toggled(bool)` by updating host state |
| Numeric value | `LiquidSlider` | Normalized 0–1, preview, commit and cancellation |
| Choice | `LiquidSelect` | Confirm `activated(int)` in host state |
| Page selection | `LiquidSegmentedControl` | Confirm `selectionRequested(int)` |
| Navigation lens | `LiquidNavBar` | Confirm `selectionChanged(int)` |
| Modal feedback | `LiquidDialog` | `open()`, `close()`, `accepted()` and `rejected()` |
| App foundation | `AppTheme`, `KosApplicationWindow`, `KosEmptyState`, `KosKineticScroll` | Application owns preferences, content and business operations |

The Gallery loads the actual files under `demo/gallery/examples`. Its source panel
reads those same files, replacing demo directory imports with `import Kos.Ui` aliases
for copying into an application. Page changes recreate the example; they do not
persist demo actions. Keep catalogue metadata and bilingual API explanations in
`demo/gallery/ComponentCatalog.mjs`.

`LiquidTextField` enables its liquid surface with `materialForm: false` and
`liquidFinish: true`. Set `materialForm: false` on controls that support both forms.
Its compact default height is 28px, matching `LiquidActionButton`. At a shared
placement, use the same height: inline content 20px (provisional), secondary
Dialog 24px, toolbar 26px, and important Dialog 30px. Small solid fields use
6px corners; liquid fields and solid fields from 28px are capsules.
`LiquidSelect.appearanceMode` accepts `system`, `light` and `dark`. AppTheme supplies
semantic colours and reduced-motion policy; applications may override supported inputs.

## Supply a background

```qml
import QtQuick
import QtQuick.Window
import Kos.Ui

Window {
    width: 720
    height: 480
    visible: true

    Item {
        anchors.fill: parent
        Rectangle {
            id: scene
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: "#246b82" }
                GradientStop { position: 1; color: "#a96e94" }
            }
        }
        LiquidBackdrop { id: sceneBackdrop; sourceItem: scene }
        LiquidSurface {
            anchors.centerIn: parent
            width: 320
            height: 180
            radius: 12
            backdrop: sceneBackdrop
            adaptiveGlass: true
            refractionStrength: .6
            magnification: 1
            reflectionStrength: .12
            Button {
                anchors.centerIn: parent
                text: "Continue"
            }
        }
    }
}
```

The source and every consuming surface must be separate subtrees in the same window.
Do not capture a card or the window content root when it contains the consuming glass.
`hideSource` defaults to false: one visible scene can feed many surfaces without a
duplicate. `active: false` releases its capture; `resolutionScale` controls sampling
density and `maximumTextureSize` defaults to 2048 pixels on the longest dimension.

With `registerAsDefault: true`, a provider is discovered by surfaces in its own window
through `LiquidStyle.backdropFor(window)`. Local scenes use `registerAsDefault: false`
and explicit `backdrop`. Defaults never intentionally cross windows.

`refractionStrength` and `edgeWidth` are logical pixels. `magnification: 1` removes
central zoom; also set `refractionStrength: 0` to remove edge displacement.
`blurStrength: 0` removes blur spread. `readability` controls contrast treatment.
The slider uses this core with its own sibling track provider and clips the original
track around its lens to avoid an unrefracted edge underneath.

Alpha transparency is a separate operation. To reveal the desktop, keep the window
and ancestor containers transparent and remove every opaque image or sampled copy
under that area. Apply opacity only to the material background, grouped where
overlapping layers must fade together. Keep text and interactive content opaque.
Gallery's left navigation follows the in-window `.95` ordinary-panel contract
in GalleryDesign.md: QML blur samples actual underlying app content, while the
window stays opaque. This does not reveal or blur the desktop.

## Link the static module

In an existing Qt Quick application's CMake project, after finding the required Qt
components and creating the application target:

```cmake
add_subdirectory(/path/to/nextkdeAppDemo/shared/qml kos-ui)
target_link_libraries(my_app PRIVATE Kos::Ui Kos::UiPlugin)
```

The parent project must provide Qt 6.8+ Core, Gui, Qml, Quick, QuickControls2 and
QuickDialogs2. The runtime also needs the imported QML modules, including
Qt5Compat.GraphicalEffects for existing switch/navigation effects. Use
`import Kos.Ui` in the application's QML. No NextKde app runtime is shipped here.

Source previews use `demo/Kos/Ui/{foundation,controls,i18n}` instead. Keep these
in-repository symlinks intact and maintain their qmldir exports when adding types.
Do not mix copied component implementations into individual applications.

## Shader assets and review

The portable shader source and QSB pair are in `shared/qml/controls/shaders`.
To regenerate them when requested, in a VM or hosted CI:

```sh
bash shared/qml/controls/shaders/compile.sh
```

Commit the GLSL and both matching QSB assets together. The script uses Qt 6 shader
variants and QSB format 64. The source and committed assets were copied together from
the parent working tree; this extraction did not regenerate or run them.

No real desktop texture is available to these shaders. Ordinary window transparency
works through normal compositor composition. Do not claim KWin blur, desktop capture,
GPU acceptance, or measured performance from a successful source export.

`KosWindowControls` keeps fullscreen/minimize/close by default. Desktop consumers
may set `maximizeMode: true` to use maximize/restore instead of fullscreen, and
set `circleSize`, `buttonWidth`, `buttonHeight` plus inherited `spacing` to match
host chrome. Defaults (18px circles, 22×32 buttons, 10px spacing) are unchanged.

`LiquidActionButton.iconOnly` defaults to false. Opt in for a 36px compact action
with zero horizontal label padding and centered, unelided glyph content. Supply
an `Accessible.name` when the text is only a symbol. Disabled icons retain the
existing opacity treatment. The Gallery shows enabled and disabled examples.

### Directional reflections and text input

`LiquidSurface` draws a positive, directional reflection using the rounded-shape
normal. It no longer adds two closed perimeter borders or a fixed top-to-bottom
bevel. `reflectionStrength` and `rimColor` remain supported; they now control the
soft arc/sheens rather than a continuous outline. A separate, texture-independent
shader keeps reflection behaviour consistent with or without a sampled backdrop.
Software rendering uses a restrained directional canvas arc without sampled optics.

`LiquidActionButton.backdrop` allows an explicit eligible sibling texture provider.
Its normal state is subdued, with small hover/pressed reflection changes respecting
reduced motion. In light mode, `LiquidTextField` uses softer dark-gray text for
liquid inputs and black text for solid inputs. Dark mode uses lighter text on
liquid and theme text on solid. Liquid text selection uses neutral gray; solid
inputs retain the accent color. Explicit colour overrides remain supported.
Liquid inputs show no focus outline; solid inputs draw an edge-hugging ring.

The Button example includes a real coloured/striped source texture, enabled and
disabled buttons and a typed field. Interact with hover/press/tab/selection in both
appearances; a source export or shader bake is not visual acceptance.

Independent legacy optics still need separate review: LiquidSelect (popup), LiquidGlassSwitch (track and knob), LiquidNavBar and
LiquidSegmentedControl. Their Material branches and keyboard focus behaviour must remain
intact; outline appearance follows the material-specific focus rule above. This surface change does not claim to finish those controls.

### Select field and popup

`LiquidSelect.plainTrigger: true` exposes a value-only trigger without any
button surface, border, shadow or hover fill. Pair it with `indicatorStyle:
"upDown"` for settings. This does not change the popup material or selection
confirmation contract. `popupOpened` reports when its opening transition finishes.

`LiquidSelect` reuses `LiquidActionButton` for its closed trigger: `materialForm:
true` selects an ordinary solid fill; `false` selects the same liquid fill,
highlight, refraction and hover treatment as Button. `liquidIntensity` shares
Button's presets; `shadowEnabled` defaults to false and `shadowLevel` shares its
shadow presets. The dropdown uses a vector chevron rather than a font glyph.
`appearanceMode` continues to control light/dark appearance independently of the
host theme. Button's new `darkAppearance` and `reduceMotion` overrides default to
AppTheme, so existing Button users retain their defaults.

In light mode, Select's solid trigger and default choice sheet use `#f6f6f6`;
the liquid trigger keeps its sampled surface. The choice sheet retains its
solid/liquid branches and `sheetColor`; `backdrop`
provides eligible in-window texture. `activated(index)`, optimistic selection and
owner acknowledgement/rollback remain unchanged. Solid Select draws an
edge-hugging semantic focus ring; liquid Select draws no focus ring. Liquid choice
hover is neutral; solid choice hover retains its accent fill. Tab, arrows, Enter
and Escape remain available. Transitions respect
reduced motion. The Gallery shows liquid, disabled and standard variants.

The Button example's coloured source clips its rotated stripes to the scene
boundary; this does not change glass clipping or sample-mapping rules.

### Switch and segmented reflection review

Non-Material `LiquidGlassSwitch` track/handle and expanded lens now use
`LiquidSurface` directional reflection. The expanded lens samples the actual
sibling track; closed white/red/cyan strokes and fixed bevels are removed.
The existing position, expansion and wobble durations remain; reduced motion
suppresses those animations. Space/Enter and accessibility activation request
`toggled` without assigning host-owned `checked`. A separate focus ring remains.

`LiquidSegmentedControl` keeps its geometry, optimistic `selectionRequested`,
owner acknowledgement and rollback deadline. Its liquid lens shares the same
surface, accepts an optional eligible `backdrop`, and removes the old closed
white rim, vertical bevel and lens shadow. Material fills/outlines remain.
Gallery examples include disabled/Material controls and a real striped sampling
scene. Review hooks use the real press/release state paths; state-driven frames
do not establish pointer/keyboard event acceptance. Expanded/moving light/dark
review is required. LiquidNavBar's independent older material remains pending.

### Navigation lens

`LiquidNavBar` shares directional LiquidSurface for its non-Material track,
resting pill and active lens. The old RGB/white closed strokes, fixed glint and
vertical depth gradients are removed. An optional eligible `backdrop` supplies
actual in-window texture. The lens retains partial opacity so the existing
under-lens icon/label layer remains readable. Material fill and selected text
roles stay separate. No desktop texture or compositor access is introduced.

The existing mutable `currentIndex` / `selectionChanged` contract, click-only
desktop pointer behaviour, 16ms spring integration, 100ms display easing and
280ms active timeout remain. Reduced motion settles position without animation.
A separate focus indicator and tab/arrow/Home/End/Space/Enter activation path
are available; disabled navigation rejects activation. Runtime event delivery
and assistive-technology acceptance still need independent review.

Gallery's Nav example contains real clipped coloured stripes, disabled and
Material comparisons. Its opt-in state sequence records actual elapsed time
and retains GPU grab results until all frames are captured; PNG encoding follows
capture so it cannot stall the observed animation. These are actual scene frames
from shared state entry, not synthetic pointer/keyboard event verification.

### Shared vector icons

VectorIcon includes a consistent original stroked music/transport set.
LiquidActionButton.iconName (default empty) selects a centered vector icon;
iconSize defaults16. Existing text/iconOnly use is preserved.
LiquidNavigationButton.iconName/iconColor add an optional16px vector before its
label; cornerRadius defaults to the original10px. Supply accessible action names.
`specificationFontSize` overrides the plain navigation row's default font size
without changing other uses; Gallery sets it to 12px.
`specificationSelectedVerticalInset` reduces only the selected row's solid fill;
Gallery uses 2px above and below.
`specificationSelectedFillColor` and `specificationHoverFillColor` let a host
set the two ordinary row fills independently; Gallery uses blue for selected
rows and `#dbdbdd` for hover in light mode.
`specificationSelectedTextColor` sets the selected row's label; Gallery uses white.
These additions support actual app navigation and playback, not font-symbol icons.

Action button optics: the shared background lens expands slightly while content
retains its press compression. Refraction/magnification/reflection respond to
actual hover/down, honoring reduceMotion. Read-only sampling/opticalExpansion/
opticalRefraction/opticalMagnification/opticalReflection expose actual animated
values for inspection; callers still own content/actions and backdrop selection.

Application palette overrides are additive: ActionButton exposes textColor,
iconColor, surfaceColor, accentColor, focusRingColor and keyboardFocusOnly;
NavigationButton exposes selectionColor/hoverColor/focusRingColor and keyboardFocusOnly.
Select exposes focusRingColor/selectedTextColor independently of accentColor.
All defaults preserve the original palette and focus behaviour.
LiquidCard now exposes surface optics, optional shadowEnabled (false by default),
and read-only sampling. Its host must provide a sibling backdrop excluding the
card, especially for floating overlays over scrolling content.

LiquidBackdrop.blur (default 0) optionally prefilters the actual sibling scene with a continuous QML blur for larger panels; consumers retain local refraction and lighting.

LiquidSurface.diffuseStrength defaults to0 and affects only the unsampled fallback: continuous low-contrast face light and static fine grain preserve tintStrength alpha. It does not blur external pixels. Software rendering retains the flat tint fallback.

`LiquidSurface.convexLens` is opt-in (false on the surface): the fourth-order
convex bezel normal drives Snell refraction and its matching thin specular light.
The interior stays registered; refractionStrength0 removes displacement. Shared
action buttons and liquid text inputs enable this profile, with their usual
focus, material and disabled contracts. Cards/player surfaces retain classic optics.
`LiquidBackdrop.rawTexture` and `LiquidSurface.unfilteredBackdrop` allow one hidden
real scene capture to feed an unfiltered clipped display and a separately filtered
lens. Exclude all consumers from the source. Never overlay the clear scene beneath
a partially transparent lens; this would leak an unrefracted duplicate.


## Liquid intensity (2026-10-22)

LiquidActionButton and LiquidTextField accept liquidIntensity: light, medium,
or strong. The default follows LiquidStyle.intensityLevel=medium, preserving
existing values. Gallery chrome uses plain controls; its sidebar search explicitly uses the light liquid finish. Liquid examples may explicitly choose an intensity. Profiles adjust
refraction, magnification, reflection, local blur and inward shade; geometry,
typography and fill alpha remain unchanged. The existing shader caps inward
shade at .10, shared by medium/strong. Other types are not yet migrated.
No runtime or visual acceptance is claimed.


2026-10-22 fill revision: liquid buttons/inputs replace adaptive inward pigment with white .10-to-zero bands, 3px from top/bottom. Normal fill is an elliptical #f2f2f4-to-#c4c4c8 gradient in both themes, retaining .20/.25 alpha. Primary actions retain accent. The optical pass disables its flat tint so the shared QML fill is applied once. Diagonal highlights and intensity optics remain unchanged. No QSB changes or runtime verification.


## Compact Gallery composition

Follow the four rules at the top of [Gallery design language](GalleryDesign.md).
Gallery enables AppTheme.compactDesign: body 13, actions 28 high, search 30,
navigation rows 30, list rows 32 and toolbar 48. Ordinary areas use semantic
content/control colors; Dialog containers and buttons retain a brightness step.

Compact mode does not choose a material. LiquidActionButton and LiquidSelect
retain their liquid defaults. Solid action buttons below 28px use 6px corners;
at 28px and above they are capsules. Liquid actions remain capsules.
Both Select triggers remain capsules. Their popup uses 8px corners and 24px
option rows, with one hover fill per row. Select.fieldRadius remains read-only.
LiquidCard.materialForm defaults to false; ordinary containers explicitly choose
true. LiquidTextField.specificationForm remains opt-in. Gallery retains liquid
examples and solid comparisons. Buttons, inputs and selects default to 28px;
Gallery's sidebar search explicitly uses 30px for its own layout.

LiquidSurface.adaptiveGlass and LiquidActionButton.adaptiveGlass reuse existing
sampled shaders and luminance-dependent readability. They never replace sampled
glass with a fixed RGB fill. Missing sources, software rendering and reduced
transparency fall back to ordinary material. Composition rules apply to application
layouts; they do not remove liquid controls from the component catalogue. Gallery’s original full-width rectangular floating region overlays actual app
content without an inset rounded block. Window decorations retain their original coordinates;
its top actions and selector explicitly use the light liquid finish. Left navigation is one ordinary panel with `.95` background opacity and QML blur,
without floating geometry or container-level liquid optics;
directory headings and rows have no liquid effect, including selection/hover/press;
navigation search fields and action buttons use light liquid with a separate material capture.
LiquidCard.adaptiveGlass
forwards to the shared surface and disables nested content capture.

Select owns keyboard focus at its outer item; only the solid form draws a ring
following that item's focus and configured radius. Host-owned state, signals and selection acknowledgement
remain intact. The explicitly requested workstation preview loaded and reloaded;
full interaction and visual acceptance remains pending.

Compact button typography: 11px Font.Medium (500); inputs remain 11px
Font.Normal (400). Both are vertically centered, with 4px top/bottom padding
at ordinary heights; inputs below 26px use 2px. Standard horizontal padding is 12px. Select labels also
use 11px Font.Medium in compact mode. AppTheme.compactControlFontSize owns this
size; liquid and solid forms share it.

Gallery requires 95% opacity on floating and left-navigation material backgrounds only. Its QML MultiEffect
provider samples the actual scrolling page; the floating region has no bottom shadow.
Window and content base stay opaque. Example backgrounds never feed this provider.
Top controls sample the material; decorations retain their original coordinates.
Navigation samples the real content under its own coverage, excluding its material
and controls. `LiquidBackdrop.blur` uses QML shader/MultiEffect blur, not DropShadow
or a KWin liquid plugin. Missing sources or reduced transparency use opaque fallback.
See GalleryDesign.md for the 2026-10-27 rule revision and implementation status.

At scroll origin, Gallery renders the header and body as one ordinary surface.
Only real page content scrolling beneath the header enables the 95% material and blur
without a shadow (scrollOffset > 12px). Returning to origin restores the flat surface
without moving controls or decorations. Top liquid buttons keep their own finish.

### Segmented selection geometry and motion

Toolbar hosts set `LiquidSegmentedControl.height` to 26px, matching toolbar
actions. The selected capsule uses a uniform 2px inset and half-height radii;
the first/last capsule endcaps are concentric with the track. Liquid selection
uses `selectionColor` as its persistent tint, with `backgroundColor` on the track.
Defaults are neutral, not accent-coloured; no liquid focus/selection ring is added.
Compact labels use the shared 11px control font token.

A confirmed or optimistic selection change slides the lens and triggers a short
stretch, squash and settle, including keyboard changes. Press feedback is separate.
Reduced motion disables both movement and deformation; material form retains the
ordinary static selection. Host-owned selection and rollback are preserved.
These QML timings and dimensions are our implementation choices, not measured
macOS 27 constants. Apple's macOS 27 release notes distinguish content-navigation
`tabs` from value-selection segmented controls; this does not establish pixel or
animation parity for this component.

Segmented label weights can be supplied through `fontWeight` (default Normal) and `selectedFontWeight` (default DemiBold). Use Medium for both when a host requires uniformly slightly heavier labels.

## Floating dialogs

Use `LiquidDialog`: 32px G2 corners, background opacity 0.95, actual same-window QML blur/refraction and solid interior controls. See [the complete contract](Dialogs.md).

## Anchored action popovers

Use `LiquidPopover`, `LiquidPopoverItem` and `LiquidPopoverSurface` for toolbar action choosers with an arrow. See [the contract](Popovers.md).
