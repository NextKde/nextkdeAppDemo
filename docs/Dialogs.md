# Floating liquid dialog contract

[简体中文](Dialogs.zh-CN.md)

## Required behavior

Add, edit and confirmation dialogs overlaying the current page are **floating
windows**. Use canonical `LiquidDialog`, including when its content is a form.

- One liquid background with **32px G2 continuous corners**. Circular
  `Rectangle.radius` joins do not satisfy G2. The fourth-order superellipse
  joins straight edges with zero curvature; mask, refraction normals and shadow
  follow that contour.
- **Glass-layer opacity is 0.95**, independent of tint coverage. Blur the source
  strongly, refract it, apply a light tint, then composite this glass layer over
  the blurred underlay at 0.95. Never use 95% solid tint or fade the composed
  result over the sharp page. Text stays opaque.
- Sample actual same-window page content, excluding the dialog, scrim and
  capture itself. Use QML MultiEffect and baked ShaderEffect, without KWin
  liquid effects, native blur, desktop screenshots or simulated wallpaper.
- **Buttons, fields, selector triggers and form rows inside the dialog are
  solid.** Do not give each row its own glass. Add/Save/Confirm are primary actions.
  When enabled, use fixed `AppTheme.defaultAccentSeed`: light `#007AFF`, dark
  `#0A84FF`, with `#FFFFFF` text. Never substitute the host/system accent or
  dilute the fill with glass opacity; disabled actions use a neutral solid background
  and disabled text colour. Use canonical `LiquidDialogButton` for custom footers.
  Cancel and other footer actions have no border or focus outline; preserve
  keyboard focus and activation without adding a decorative ring.
- At most one soft QML shadow; no extra borders, accent focus outlines or
  decorative gradients.
- Reduced transparency, software rendering and unavailable sources use an
  opaque ordinary fallback with the same G2 contour. An unsampled tint must
  not be presented as blur/refraction. `LiquidPanelSurface.fallbackColor` is
  independent of optical tint and follows its explicit `darkAppearance` using
  ordinary dialog tokens (light `#F7F7F9`, dark `#2C2C2E`). Hosts may override it.
- Preserve modality, keyboard focus, Escape and lifecycle signals. The host
  owns data, validation and submission.

This supersedes older “Ordinary Dialog = ordinary material” and “floating
corners 12–16px” recipes. Embedded settings groups remain ordinary. Independent
popups opened inside a dialog follow their own floating-panel contracts.

## Integration

```qml
LiquidDialog {
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(440, parent.width - 32)
    title: qsTr("Add item")
    sourceItem: pageScene // Actual page; must exclude this dialog.
    cornerRadius: 32
    materialOpacity: 0.95
    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: controller.save()
}
```

`sourceItem` creates a local QML blur provider. Hosts with an eligible provider
may pass `backdrop` instead. Missing sources deliberately use ordinary fallback.
`sampling` reports the active shader path; inspect actual pixels as well.
Default padding is 24px, compact headings are 17px DemiBold and solid footer
buttons are always **30px tall with capsule corners** (radius = height / 2),
regardless of importance. `actionHeight` is read-only at 30. The 24px/6px
secondary-dialog rule applies only to ordinary non-liquid dialogs. Custom footer
buttons use `LiquidDialogButton` with the same dimensions. Hosts may adapt content geometry and actions, but must
not override `background` to bypass this shared material.

## Review

Gallery's Dialog example samples the real page and reports confirm/cancel.
Review light/dark appearances, blurred content underneath, edge refraction,
G2 corners at magnification, reduced-transparency fallback and solid primary /
disabled buttons. Run verification in the environment currently authorized by
the user.

## Shared footer and file-selection APIs

`LiquidDialog` defaults to the window overlay, centered and constrained to its
client area. `acceptText`, `rejectText`, and `closeText` optionally localize or
name standard actions; `acceptEnabled` controls standard Accept/Apply actions.
The ordinary footer is omitted for `Dialog.NoButton`. Custom footers still use
`LiquidDialogButton` and keep the standard 24px / 12px padding and 8px spacing.
Long forms must scroll their body while keeping the footer available.

`LiquidFilePicker` shares this dialog, material fields, ordinary file rows and
footer. It returns URLs; the consuming application owns IO and validation.
`mode` accepts `openFile`, `openFiles`, `folder`, or `saveFile`. Supply glob
`nameFilters` (for example `["*.md", "*.MD"]`), `currentFolder`, and optionally
`defaultSuffix`. Read `selectedFile`, `selectedFiles`, or `selectedFolder` in
`onAccepted`. Directory double-click navigates; Ctrl/Command and Shift select
multiple files. Ctrl+L focuses the path field. Keyboard arrows select rows and
Enter opens/navigates. Save mode confirms a visible same-name file before return.
Localized body strings are configurable independently of appearance. This is an
in-window picker, not a replacement for every platform file-manager feature.

Solid `LiquidTextField` forms use `AppTheme.controlBackground`, rather than the
translucent liquid tint. `LiquidCheckBox.textWrapMode` can enable wrapped labels
without clipping long options. These changes were integrated into Notes; they do
not claim standalone Gallery/GPU acceptance.

Public dialog footers use `DialogButtonBox.MacLayout` for a consistent cancel-before-primary order across hosts.
