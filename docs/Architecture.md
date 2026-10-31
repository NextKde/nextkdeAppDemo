# Architecture and ownership

[简体中文](Architecture.zh-CN.md)

## Source boundaries

| Path | Responsibility |
| --- | --- |
| `shared/qml/foundation` | Semantic AppTheme, application-safe controls, dialogs and scrolling |
| `shared/qml/controls` | Liquid material, input and navigation controls |
| `shared/qml/i18n` | Portable translation and locale helpers |
| `shared/qml/controls/shaders` | GLSL and committed QSB assets for the portable liquid surface |
| `demo/gallery.qml` | One ordinary Quickshell FloatingWindow hosting the catalogue |
| `demo/sidebar-demo.qml` | One ordinary window hosting the complete sidebar layout |
| `demo/gallery` | Catalogue, bilingual API notes and actual interactive examples |
| `demo/Kos/Ui` | Source facade; symlinks resolve to this repository's canonical shared sources |

The demo does not depend on another checkout. Quickshell source imports must remain
inside its `demo` configuration tree through `Kos/Ui`; paths escaping that tree are
intercepted as `qrc:/qs-blackhole`. Preserve the source mappings when copying the repo.
The source facade and CMake export must refer to the same implementations.

## Rendering

`LiquidBackdrop` captures a sibling, host-owned QML scene once. Every consumer must
be excluded from the captured subtree. A surface rejects an ancestor source or a
different QQuickWindow. Providers may register a per-window default; local examples
and sliders use explicit providers with `registerAsDefault: false`.

`LiquidSurface` maps 2D item coordinates into that texture and implements edge lens
displacement, magnification, optional blur, tint and readability. It preserves
premultiplied alpha. Without an eligible source, the surface uses transparent tint
and reflective rims. The software renderer also uses that fallback. Perspective
transforms are outside the current mapping contract.

The standalone SidebarDemo starts in desktop mode: the window background is transparent, the local
image and its capture are disabled, and only the grouped material background has
opacity 0.95. Text remains opaque. In Window scene mode, the image is drawn inside
the same window and sampled for QML optics. Neither mode requests KWin effects or
captures pixels from other applications. A compositor still displays normal window
transparency. Real desktop blur/refraction would need a separate optional adapter.

Gallery navigation follows the 2026-10-27 contract in GalleryDesign.md: one continuous
ordinary panel without floating geometry or container-level liquid optics,
background-only opacity 0.95, and QML shader /
MultiEffect blur of actual same-window content underneath. Its window stays
opaque; neither KWin liquid effects nor desktop capture provide this blur.
Navigation material and controls must be excluded from its source subtree.
This is a composition requirement; implementation status is recorded in GalleryDesign.md.

Switch, select, segmented control and navigation bar retain their existing QML
gradient/mask optics; migration of every control to sampled optics is unfinished.
`sampling` indicates source/path selection, not visual acceptance.

## Application integration

AppTheme holds semantic colours and motion settings. An application may inject its
own preferences through supported properties; this repository does not provide
NextKde platform services, native material availability, or preference synchronization.
Business operations and persistent state belong to the application.

The default CMake build only exports the static `Kos.Ui` module. It does not build a
Gallery executable. A consuming Qt Quick application links `Kos::Ui` and
`Kos::UiPlugin`; the Quickshell preview uses the same source module through its facade.

When feeding improvements back to NextKde, adapt them at its shared UI boundary.
The current Shell integration in the parent working tree is not automatically
connected to this repository. Do not copy platform services into portable controls.

## Change and verification policy

The initial import included working-tree changes from its parent workspace; the source
prerelease candidate contains committed components. Release tags identify immutable
source snapshots, not stable API/ABI or runtime acceptance. Applications pin an exact
release commit and upgrade independently; explicit local-checkout overrides are for
development. Publication status and scoped verification results belong in GitHub releases.

There is no automatic CI or standalone Gallery/GPU acceptance claim. Run this
repository's verification only when requested, and only in a VM or hosted CI. Do not
start or replace the maintainer's Shell. Source inspection, consumer integration tests
and standalone graphical acceptance are separate results. Keep temporary artifacts
outside tracked docs.
