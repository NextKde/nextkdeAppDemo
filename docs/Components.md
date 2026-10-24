# Components and application integration

> For current material placement, palette and dimensions, follow the four rules in [Gallery design language](GalleryDesign.md). Earlier optical implementation notes below are not default UI recipes.

[简体中文](Components.zh-CN.md)

## Catalogue and state

| Purpose | Component | State contract |
| --- | --- | --- |
| Shared in-window capture | `LiquidBackdrop` | Host supplies a separate scene subtree |
| Material and container | `LiquidSurface`, `LiquidCard` | Host supplies geometry, provider and readability |
| Actions and navigation | `LiquidActionButton`, `LiquidNavigationButton` | Handle `clicked()`; own the selected destination |
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
Gallery's left navigation uses an opaque ordinary background; it does not use this transparency path.

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
reduced motion. `LiquidTextField` defaults follow AppTheme text/muted/selection
colours; explicit colour overrides remain supported. The liquid input's actual
focus indicator is drawn separately from decorative reflection.

The Button example includes a real coloured/striped source texture, enabled and
disabled buttons and a typed field. Interact with hover/press/tab/selection in both
appearances; a source export or shader bake is not visual acceptance.

Independent legacy optics still need separate review: LiquidSelect (popup), LiquidGlassSwitch (track and knob), LiquidNavBar and
LiquidSegmentedControl. Their Material branches and focus indicators must remain
intact. This surface change does not claim to finish those controls.

### Select field and popup

`LiquidSelect` reuses `LiquidActionButton` for its closed trigger: `materialForm:
true` selects an ordinary solid fill; `false` selects the same liquid fill,
highlight, refraction and hover treatment as Button. `liquidIntensity` shares
Button's presets; `shadowEnabled` defaults to false and `shadowLevel` shares its
shadow presets. The dropdown uses a vector chevron rather than a font glyph.
`appearanceMode` continues to control light/dark appearance independently of the
host theme. Button's new `darkAppearance` and `reduceMotion` overrides default to
AppTheme, so existing Button users retain their defaults.

The choice sheet retains its solid/liquid branches and `sheetColor`; `backdrop`
provides eligible in-window texture. `activated(index)`, optimistic selection and
owner acknowledgement/rollback remain unchanged. Keyboard focus has a separate
indicator; Tab, arrows, Enter and Escape remain available. Transitions respect
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
retain their liquid defaults and use 8px corners only for compact ordinary controls;
liquid controls keep their rounded shape. Select.fieldRadius remains read-only.
LiquidCard.materialForm defaults to false; ordinary containers explicitly choose
true. LiquidTextField.specificationForm remains opt-in. Gallery retains liquid
examples and solid comparisons, with 28px buttons and 30px inputs in both forms.

LiquidSurface.adaptiveGlass and LiquidActionButton.adaptiveGlass reuse existing
sampled shaders and luminance-dependent readability. They never replace sampled
glass with a fixed RGB fill. Missing sources, software rendering and reduced
transparency fall back to ordinary material. Composition rules apply to application
layouts; they do not remove liquid controls from the component catalogue. Gallery’s original full-width rectangular floating region overlays actual app
content without an inset rounded block. Window decorations retain their original coordinates;
its top actions and selector explicitly use the light liquid finish. Left navigation rows and background remain
ordinary; the search uses the light liquid finish with a separate sidebar backdrop.
LiquidCard.adaptiveGlass
forwards to the shared surface and disables nested content capture.

Select owns keyboard focus at its outer item; a separate ring follows that item's
focus and configured radius. Host-owned state, signals and selection acknowledgement
remain intact. The explicitly requested workstation preview loaded and reloaded;
full interaction and visual acceptance remains pending.

Compact button/input typography: 11px Font.Normal (400), vertically centered,
4px top/bottom padding and 12px standard horizontal padding. Select labels also
use 11px Font.Normal in compact mode. AppTheme.compactControlFontSize owns this
size; liquid and solid forms share it.

Gallery uses 95% opacity on the floating material only. Its QML MultiEffect
provider samples the actual scrolling page; the floating region has no bottom shadow.
Window and content base stay opaque. Example backgrounds never feed this provider.
Top controls sample the material; decorations retain their original coordinates.

At scroll origin, Gallery renders the header and body as one ordinary surface.
Only real page content scrolling beneath the header enables the 95% material and blur
without a shadow (scrollOffset > 12px). Returning to origin restores the flat surface
without moving controls or decorations. Top liquid buttons keep their own finish.
