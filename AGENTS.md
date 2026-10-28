# Contributor instructions

This repository is a portable QML component library and demo workspace.
Read README.md, docs/Architecture.md and docs/Components.md before editing.

- Canonical components live in shared/qml. Demos consume them through demo/Kos/Ui
  source mappings. Do not create separate visual implementations for the Gallery.
- Keep components free of Quickshell, KWin, Wayland protocols and NextKde services.
  Quickshell is allowed only in the demo host for windows and reading example source.
- Do not confuse in-window texture sampling with access to the desktop. Do not add
  native blur requests or wallpaper replicas as an implicit desktop backdrop.
- Follow the focus/selection contract in docs/GalleryDesign.md when integrating
  controls: liquid inputs, search, buttons and selectors retain their glass edge.
  Do not add a blue/accent border or outer ring on focus, selection, press or popup
  opening, including in application wrappers. Never hardcode a focus colour such
  as #9CCAFF or #007AFF. Only ordinary solid forms use the semantic AppTheme.focusRing.
  Preserve keyboard focus, Tab/arrow/Enter/Space activation, text editing and
  accessibility; hiding a decorative ring must not disable those behaviours.
  This rule overrides older generic "2px focus ring" recipes in the documentation.
- Floating panel contract: context/right-click menus, search suggestion dropdowns,
  select-option popups and popovers use one liquid panel background. Their internal
  rows, categories, menu items and hover/selected/pressed fills use ordinary material,
  including delegates implemented as Buttons. Do not nest liquid surfaces per row.
  Sample actual same-window content excluding the popup and capture; use QML blur,
  never KWin liquid effects. Keep text opaque and provide an ordinary opaque fallback
  for reduced transparency or unavailable sampling. See GalleryDesign.md; this
  overrides generic advice to make every control inside a floating layer liquid.
- Help tooltips are floating liquid panels too. Use canonical KosToolTip and
  docs/Tooltips.md: 0.7 material coverage, 14px corners, compact 11px text and
  10px horizontal / 5px vertical padding. Keep text fully opaque. Use actual
  same-window sampling and QML blur/refraction, with an opaque fallback only
  for reduced transparency, software rendering or unavailable sampling.
  Do not repeat complete navigation labels or add accent borders.
- Keep business logic, persistence and service calls in application adapters.
- Settings forms use the canonical SettingsGroup and SettingsItem, not page-specific
  card/title/row replicas. Follow docs/Settings.md: larger bold group headings,
  one normal-weight item name, optional smaller muted description, no leading icon,
  zero extra gaps between compact rows, ordinary borderless group material.
- Preserve host-owned state and existing public signals when changing controls.
- Register new types in source qmldir files, the demo facade and shared/qml/CMakeLists.txt.
  Commit GLSL and its matching QSB assets together. Bake shaders only in a VM or CI.
- Do not launch demos, compile, run tests or perform graphical verification on the
  maintainer workstation. Execute these only when explicitly requested, in a VM or
  hosted CI. Source review, edits and Git operations on the workstation are allowed.
- Do not add automatic verification workflows without a request. Do not describe an
  extraction or source review as successful runtime acceptance.
- English is the default. Update Chinese companions with maintained documentation.
  Keep docs operational for AI/app contributors; keep captures, logs and temporary
  reports out of tracked docs. Preserve LICENSE and extraction provenance.
- Preserve unrelated edits. Stage explicit paths. Do not merge or publish releases
  without maintainer authorization.
