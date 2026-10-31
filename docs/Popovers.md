# Anchored liquid popovers

[简体中文](Popovers.zh-CN.md)

Use `LiquidPopover` for a short action list opened by a toolbar button, such as
Calendar’s plus button. The arrow points to its trigger. This is an anchored,
non-modal action chooser; contextual editing opens `LiquidContentPopover`,
while independent modal tasks use `LiquidDialog`. Do not style menu rows as dialog primary buttons.

## Visual contract

- One continuous body-and-arrow silhouette, one sampled liquid material and one
  soft shadow. No separate opaque triangle, seam or accent focus ring. An explicitly configured neutral outline is allowed.
- Body corners 12px, arrow 18px wide and 8px high, trigger gap 4px.
- Glass layer opacity 0.95, independent of tint and foreground opacity. Reuse
  `LiquidPanelSurface`: source blur 0.85, light tint 0.18 / dark tint 0.24,
  local blur 0.7, refraction 8. Never add a 95% solid tint cover.
- Capture actual same-window content excluding the popup. QML blur/refraction;
  no KWin plugin, wallpaper substitution or desktop capture.
- Rows are ordinary material: 30px high, 13px normal text, 16px icon, 8px horizontal
  padding. Neutral hover/keyboard highlight, 6px row corners, no blue fill or border.
- Panel padding 6px, arrow space added separately. Text/icons stay fully opaque.
- Missing source, reduced transparency or software rendering uses an opaque
  body-and-arrow silhouette. Do not claim refraction in fallback mode.

## API and interaction

Set `anchorItem` to the triggering button and `sourceItem` to the separate scene.
Call `openAtAnchor()`. Placement centers on the trigger, clamps to an 8px window
margin and flips above when there is insufficient space below. The arrow follows
the trigger, clamped away from the body corners. Escape and outside press dismiss;
Menu/MenuItem retain keyboard navigation and activation. Use `LiquidPopoverItem`
for ordinary action rows and handle `onTriggered` in the application.

```qml
LiquidPopover {
    id: actions
    anchorItem: addButton
    sourceItem: pageScene
    LiquidPopoverItem {
        text: qsTr("New event")
        iconName: "calendar"
        onTriggered: eventDialog.open()
    }
}
```

The Gallery Dialog example includes this anchored chooser and the subsequent dialog.
`LiquidPopoverSurface` uses the body-and-arrow contour for both optical normals
and masking; corners and arrow edges share the same refractive/specular bevel.

Popover width follows the widest row’s natural text/icon width plus row and panel padding. Do not reserve icon space when iconName is empty. Avoid fixed widths for short action menus.

## Contextual content and editors (2026-10-28)

Use `LiquidContentPopover` for anchored creation, inspection and editing. It is
non-modal and does not dim the window. This supersedes the generic “editing opens
LiquidDialog” recommendation above for contextual calendar workflows. Modal
category management/confirmations can retain LiquidDialog.

Supply `anchorItem` and optionally `anchorRect` in that item's coordinates (for a
dragged time range). `preferredSide` defaults to right; it flips left if necessary,
then above/below when neither side fits. `preferredSide: "bottom"` suits toolbar
launchers. Position follows the anchor and is clamped to 8px window margins.
The common liquid background/arrow has 22px body corners; interior fields and
compact groups are solid. Escape/outside dismisses an unsaved draft, without
writing; Save/Add is explicit. Hosts must preserve validation, saving locks and
business data. Do not silently convert existing events into reminders via a tab.

`Calendar` uses separate action-menu (`LiquidPopover`) and content-editor
(`LiquidContentPopover`) containers. The Gallery Dialog page demonstrates both.
The shared Popover shader derives its optical field from the complete contour.

## Background readability

`materialOpacity` blends refracted glass with an already blurred underlay. It is
not solid colour coverage; 0.99 does not hide 99% of the background. Do not use it
alone to suppress lettering behind an editor.

`LiquidContentPopover` exposes independent `backdropBlur` (0–1, default 0.85),
`blurStrength` (default 0.7) and `tintStrength` (0–1, default 0.18 light / 0.24 dark).
For large Calendar creation/editing panels, the current tuning is 1.0 / 1.0 / 0.42,
with `materialOpacity: 0.99`. Other popovers retain their defaults. Refraction
remains enabled; interior controls stay solid. This tuning awaits VM visual review:
background colour should remain visible, while lettering should not compete with
form text. Check both themes and dense text behind the panel.

## Optional outline

`LiquidPopover` and `LiquidContentPopover` accept `borderWidth` (logical pixels,
default 0) and `borderColor` (default transparent). The shared surface draws one
continuous outline around body and arrow; hosts must not add a rectangular wrapper.
Calendar editors use 0.5px, black at 12% in light mode or white at 18% in dark mode.
This neutral outline is independent of focus, selection and material opacity.
The shader already provides a directional optical glint; an outline is not a
replacement for it. The Popover optical field follows the quadratic corners, arrow slopes and body edges.

## Contour optics and window boundary

`highlightStrength` defaults to 0.32 (0 disables the specular highlight). It is
independent of `borderWidth`, tint and material opacity. The Popover shader computes
the nearest contour edge and outward normal; quadratic corners are approximated
with 16 segments each. The same normal drives refraction and a narrow directional
specular bevel. Light stays at the scene's upper left when the surface rotates.
The arrow shares the body's blur, tint, alpha and optical field. Opaque fallback
does not pretend to have sampled refraction.

These containers use `Popup.Item`: placement is confined to the host window.
Calendar additionally caps editor height to its client area and scrolls the form.
Switching to `Popup.Window` alone is not a supported glass implementation: the
current `LiquidBackdrop` deliberately rejects cross-window sources. A future
external-window adapter needs explicit texture transfer, screen-aware placement,
and a fallback for regions outside the source window. It must not imply access
to desktop pixels or silently depend on KWin effects.

Popover shadows surround the complete body and arrow evenly: horizontal/vertical offsets 0, opacity 0.36, blur 0.85, blurMax 48.

## Arrow placement and tall forms

`LiquidContentPopover.preferredSide` accepts right, left, top and bottom. Try the
preferred side first, its opposite next, then the remaining sides. After clamping
to the window, show an arrow only if the panel fits outside its anchor and the
actual tip remains on the straight edge, clear of both rounded corners. Hide it
when the anchor is outside the viewport. Never clamp a pointer to a different target.

Both popover types expose `arrowEnabled` (default true) and `arrowVisible`
(read-only, includes placement feasibility). Set `arrowEnabled: false` for tall
creation/editing forms; Calendar uses this for event and reminder editors. This
removes arrow padding as well as its silhouette; material, highlight, shadow and
non-modal interaction remain unchanged. Short anchored menus retain their pointer
when it can point accurately. Check all four sides, corner anchors, resize and
light/dark appearance in a VM before visual acceptance.
