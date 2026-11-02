# Window control ownership and layout

[简体中文](WindowControls.zh-CN.md)

This is the integration contract for custom application window controls. Applications
own which actions exist and where they are laid out. An optional platform adapter
may delegate their rendering and window actions to the compositor. Portable controls
must remain usable without NextKde, KWin, Wayland or an adapter.

## Portable component

Use canonical `KosWindowControls` for the ordinary row and its client-rendered fallback:

```qml
KosWindowControls {
    targetWindow: root
    maximizeMode: true
    actions: ["close"]
    circleSize: 14
    buttonWidth: 22
    buttonHeight: 22
}
```

- `actions` is the actual ordered list: `maximize`, `minimize`, `close`. Each action
  appears at most once. Default: all three in that order. `[]` means no controls.
- `maximizeMode: true` makes green maximize/restore. For backward compatibility,
  `false` retains the original fullscreen behavior; that mode is not delegated to
  the NextKde maximize-only protocol.
- `buttonLayout` exposes `{action, x, y, width, height}` entries for the visible
  circles, in coordinates local to this component. Read the actual layout; do not
  reconstruct it using a fixed top-right offset or assumed button count.
- `externalDrawing` defaults to `false`. Only a host adapter's confirmed takeover
  may set it true. This hides/disables the fallback delegates without removing
  their layout. Reset it immediately when the external service disappears.
- `hoverGlyphs` defaults to `true`; the adapter can supply the shared always/hover
  preference. Keep application fallback functional, keyboard-operable and labelled.

Changing lists, positions, sizes or visibility must replace the complete declaration.
Removed buttons must lose both drawing and input handling. Action identity is never
inferred from list index, colour sampling or window title. A close-only window must
never acquire a maximize/minimize button or leave their old hit rectangles behind.

## Optional NextKde adapter

Platform code belongs in the consuming application or its platform integration
package, not this repository's `shared/qml`. Do not add unconditional KWin/Wayland
imports or polling timers to portable components. This library exposes data and
fallback ownership; it does not ship the native protocol implementation.

The NextKde adapter uses `Kos.SurfaceShape.WindowControlSlot` and version 2 of
`kos_window_controls_v1`. It maps each declared rectangle into that window's
`wl_surface` logical coordinates. For a custom arrangement, aggregate the actual
buttons into one list per surface, including buttons in different header groups.
Never register competing adapters for the same surface. Reordering, spacing and
individual sizes need not follow the standard row.

Delegation requires all of: supported protocol, the existing **KOS window appearance**
switch enabled, an eligible window/layout, and compositor acknowledgement. Do not
add a second default opt-in or guess support from the desktop name or app ID.
Unsupported versions, other desktops, disabled integration and rejected layouts
retain client rendering. The shared icon-display preference also governs fallback
while connected. Selecting KOS window decoration is not required.

Layout/state events schedule an update after layout settles. Send only changed
lists, not periodic probes. The compositor sends configure; the client changes
fallback rendering, acknowledges its serial and commits a frame. Geometry and
ownership apply at surface commit. Service loss immediately restores fallback.
On unsupported transforms or translucent controls, request client rendering.

KWin draws the declared circles only: transparent background, no title-bar pixel
sampling and no background colour panel. Empty lists draw/intercept nothing; gaps
between circles remain with the application. Declared surfaces bypass legacy
placement overlays even during fallback. Unadapted third-party windows keep the
existing platform path.

Current NextKde v2 limits are zero to three unique actions, square circles 6–40
logical pixels, no overlapping or out-of-window rectangles, and a union no larger
than 4096×4096. Unknown/duplicate actions or invalid geometry reject the whole list;
never silently truncate it or draw a guessed arrangement. Maximize means restore
when already maximized. More action types require explicit protocol evolution.

## Acceptance

In a VM or hosted CI only, check three/one/zero buttons, reordered and resized
layouts, independent windows, removal of stale click areas, actual actions,
switch changes and service-unavailable fallback. Check that optional-module failure
does not prevent the application from starting. A successful portable component
test does not establish compositor or GPU acceptance. NextKde's native integration
and its VM harness live in the NextKde repository under
`docs/CooperativeWindowControls.md` and `tests/cooperative-controls`.
