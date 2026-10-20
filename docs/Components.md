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
