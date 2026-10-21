# Components and application integration

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
            radius: 24
            backdrop: sceneBackdrop
            refractionStrength: 4
            magnification: 1.06
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
The sidebar demo implements this directly and defaults to opacity 0.95.

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

Independent legacy optics still need separate review: LiquidSelect (closed field
and popup), LiquidGlassSwitch (track and knob), LiquidNavBar and
LiquidSegmentedControl. Their Material branches and focus indicators must remain
intact. This surface change does not claim to finish those controls.

### Select field and popup

`LiquidSelect` now uses `LiquidSurface` for its non-Material closed field and
choice sheet. The former bright-top/dark-bottom perimeter and parked glint are
removed. An optional `backdrop` property supplies the same eligible in-window
texture to both surfaces. `sheetColor` still controls popup colour/opacity.
The Material branch retains its solid outline/fill. `activated(index)`, optimistic
selection and owner acknowledgement/rollback stay unchanged. Actual keyboard
focus has a separate indicator, and Tab plus arrow/Enter/Escape navigation remain
available. Popup/reflection transitions respect reduced motion.

The Gallery select example exposes normal/disabled/preserved-Material controls.
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
