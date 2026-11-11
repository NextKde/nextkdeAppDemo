# Platform icon font

[简体中文](Icons.zh-CN.md)

`Kos.Icons` owns interface glyphs across NextKde. It bundles one local font,
Framework7 Icons plus NextKde extensions; it does not use system fonts, theme lookup,
SVG data URLs or network loading. App logos, provider marks, album art and external
tray artwork remain images, because they identify their owners rather than actions.

```qml
import Kos.Icons as Symbols
Symbols.Icon { name: "folder"; size: 16; color: AppTheme.text }
Symbols.Icon { name: "coffee"; size: 16; color: AppTheme.text }
Symbols.SignalIcon { connected: true; signalStrength: 55; color: AppTheme.text }
Symbols.VolumeIcon { level: 0.5; muted: false; color: AppTheme.text }
Symbols.BatteryIcon { level: 0.63; charging: false; color: AppTheme.text }
```

`size` caps the glyph's drawing size even when a control stretches its content item.
Hosts retain layout, tint, enabled opacity and accessibility labels. Icons themselves
are decorative. `filled` chooses an upstream filled variant where available. This
is not a weight selector: the font has a designed Regular weight, without synthetic
bold or arbitrary stroke changes. Wi-Fi states reuse the upstream contours; battery
fill uses a separate font contour and continuous clipping, not coarse charge steps.

`IconRegistry` loads the font once per QML engine. `has(name)` is the coverage check;
unknown names show a question square rather than silently becoming checkmarks.
`VectorIcon` is a compatibility facade with no path table. Its `strokeWidth` input
is deprecated and has no visual effect. Persisted application names, including
NkNotes' folder category IDs, resolve through the shared alias map.

## Source and extensions

The exact upstream commit, MIT license and input/output hashes are recorded in
`shared/Icons/provenance.json` and `LICENSE.Framework7`. `tools/icons` contains
the pinned upstream font, ordered upstream names, semantic aliases, editable
extension paths and deterministic builder. Original NextKde drawings are GPL-3.0-
or-later; derived Wi-Fi/battery contours retain their Framework7 MIT provenance.

Use the existing glyph when its meaning fits. Add aliases to `aliases.json`; do not
add per-application SVG, Canvas or Unicode substitutes. When a glyph is missing,
add a reviewed 24-unit extension to `extensions.json` and allocate a new unused
codepoint. Keep line endings, optical proportions and small-size legibility consistent.
Never reorder `upstream-names.json` or reassign existing extension codepoints.
Upstream glyphs use supplementary private-use codepoints starting at U+F0000;
extensions start at U+F1000. The current lock leaves ample separation between them.

Bake only in a VM/CI using the versions in `provenance.json`:

```sh
python3 tools/icons/build_font.py
cmake -S tests/icons -B build-icons
cmake --build build-icons
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software build-icons/kos-icon-tests
```

Commit the generated TTF, map and provenance together. The test opens the actual
packaged font with QRawFont and checks every mapped glyph, not merely nonempty text.
Review 14/16/18/24px renderings, light/dark colours, filled states and status transitions
in the VM. A passing coverage test does not by itself establish visual acceptance.

## Consumer integration

Kos.Ui links `Kos::Icons` / `Kos::IconsPlugin` transitively. A host using the module
independently adds `shared/Icons` and links those two targets. Source-based
Quickshell configurations expose it as `Kos/Icons`; the demo facade does the same.
One module serves both legacy Kos.Ui and Kos.Demo in a process.

Consumers keep their pinned UI APIs/materials. `tools/sync_icons.py <shared/qml>`
imports the canonical runtime module, font facade and embedded-glyph migrations
into a reviewed UI source snapshot. It does not replace other controls. Snapshot
repositories should record that source revision and preserve license/provenance;
source consumers must update their fixed gitlink or vendor manifest after validation.
The build never follows a floating branch or a workstation-specific path by default.

## Coverage audit

In the VM, run `python3 tools/icons/audit_usage.py <checkout roots> --inventory`.
The scan covers literal characters, conditional bindings, custom buttons, dynamic
icon fields and glyph names. Review the Canvas/SVG inventory individually. Retain
mathematical/dimension text, path separators, user avatars/covers/emoji, branding,
weather scenes, data plots, material masks and cursors in instructional animations.
`tests/icons/tst_hosts.qml` also exercises navigation, tab-model icons and window
action geometry. A clean source scan does not establish visual acceptance.
