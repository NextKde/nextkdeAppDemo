# nextkdeAppDemo

<!-- progress-links:start -->
[Live Gallery progress and screenshots](https://github.com/NextKde/nextkdeAppDemo/blob/ui-evidence/README.md) · [KMusic progress](https://github.com/NextKde/KMusic/blob/ui-evidence/README.md)
<!-- progress-links:end -->

[简体中文](README.zh-CN.md)

Reusable Qt Quick liquid components, an interactive component Gallery, and a complete
sidebar layout demo for NextKde application authors and AI contributors.

The visual components use QML and baked shaders. They do not import NextKde Shell
services, request KWin blur, or require the NextKde KWin plugin. The preview host uses
Quickshell for ordinary windows and source-code previews; the component library itself
is portable Qt Quick.

## Open a demo

From this checkout, in a graphical VM session when runtime review is requested:

```sh
qs -p demo/gallery.qml
qs -p demo/sidebar-demo.qml
qs -p demo/settings-demo.qml
```

Run either command to open its own normal, resizable window. Closing the window exits
that preview process. No NextKde installation or running Shell is needed.

- **Gallery:** interactive controls, searchable navigation, properties/signals and
  copyable QML examples. English is the default, with Chinese explanations available.
- **Tooltip:** compact floating liquid help at 0.7 material coverage, with truncated-label handling. [Specification](docs/Tooltips.md).
- **Settings:** the shared `SettingsGroup` / `SettingsItem` form, demonstrated with
  Theme's Interface shape group. [Common settings specification](docs/Settings.md).
- **Sidebar:** real navigation, file filtering and selection, opaque content, and a
  sidebar background starting at `opacity: 0.95`. Text stays fully opaque. Desktop
  mode leaves the window background transparent. Enable **Window scene** to compare
  QML blur/refraction of the bundled local images.

Runtime dependencies are Quickshell, a compatible Qt Quick installation, Qt Quick
Controls, Qt5Compat.GraphicalEffects, and Qt's SVG image support. Shader optics need
a supported Qt Quick GPU backend. Use Qt 6.8 or newer for the exported foundation.
`GALLERY_LANGUAGE=zh` and `GALLERY_THEME=light` set initial Gallery preferences.

## Use the components

Canonical sources are in [`shared/qml`](shared/qml). The optional CMake build exports
the static `Kos.Ui` QML module and the `Kos::Ui` / `Kos::UiPlugin` targets. The demo's
`demo/Kos/Ui` directory maps to the same sources; it is not a second implementation.

Both liquid and solid controls remain available. The example below explicitly
chooses ordinary material; for a liquid input use `specificationForm: false`,
`materialForm: false` and `liquidFinish: true`. Compact dimensions work with either.

```qml
import QtQuick
import Kos.Ui

LiquidTextField {
    width: 280
    specificationForm: true
    implicitHeight: 28
    cornerRadius: height / 2
    placeholderText: "Search"
    textColor: AppTheme.text
    mutedTextColor: AppTheme.mutedText
}
```

Sampled optics require a host-owned in-window `LiquidBackdrop`. Alpha transparency
alone cannot supply a texture of the desktop or other applications. Desktop mode
does not blur the real desktop. An ordinary desktop compositor still performs normal
window composition.

See [components and integration](docs/Components.md), [architecture and ownership](docs/Architecture.md),
[Gallery design language](docs/GalleryDesign.md), and [extraction provenance](NOTICE.md).

## Optional library build

In a VM or hosted CI, when a build is requested:

```sh
cmake -S . -B build
cmake --build build
```

This builds the component module, not a native Gallery executable. The preview uses
the `qs` commands above and the committed QSB assets, without a local build.

This repository starts from the current NextKde Gallery development snapshot, including
uncommitted component work. The extracted checkout has not been built or launched.
There is no release or automatic test workflow in this initial import. Run builds,
tests and graphical checks only when requested, and only in a VM or hosted CI.

The original [GPL-3.0 license text](LICENSE) is preserved.

Floating dialog contract and example: [`LiquidDialog`](docs/Dialogs.md), with G2 corners, 0.95 background opacity, blur/refraction and solid interior actions.
