# Common tooltips

[简体中文](Tooltips.zh-CN.md)

Use `KosToolTip` from `shared/qml/foundation` for application help. The Gallery
**Tooltip** entry consumes the same component. Do not recreate its bubble per app
or use attached Qt `ToolTip.visible/text` when the shared appearance is required.

## Appearance and content

| Property | Shared default |
| --- | --- |
| Material | Floating liquid glass, `materialOpacity: 0.7`; light tint `#f0f0f1`, dark `#303034` |
| Text | 11px Normal (400), fully opaque; light `#55555a`, dark `#d6d6da`; plain text |
| Corners / padding | 14px / 10px horizontal, 5px vertical |
| Border / arrow / focus ring | No added outline or arrow; shared glass rim and subtle QML shadow |
| Width | Fit text up to 280px and window width, then wrap |
| Placement | 6px from the trigger; prefer above, flip below near the top |
| Window inset | 8px minimum |
| Delay / timeout | 700ms / 5000ms; inherited native ToolTip timers |

The radius is clamped to half the shorter side, so short single-line hints become capsules.

Tooltips belong to the floating liquid material family. The shared `LiquidSurface`
blurs and gently refracts actual same-window content. `materialOpacity` controls
only tint coverage, not the whole Popup or its text. Do not request KWin effects.
They remain non-interactive: no buttons and no focus stealing. Reduced transparency,
software rendering, or unavailable/unsafe sampling uses an opaque readable fallback.
No accent outline or additional decorative animation is added.

Describe the action briefly, ideally with a verb and no final punctuation.
Aim for at most 60–75 characters. Do not repeat an already visible label. For
elided navigation text, revealing the complete label is useful and allowed.

## Use

```qml
import Kos.Ui as Ui

Ui.KosToolTip {
    target: openSettingsButton
    text: qsTr("Open settings")
}
```

`target` is required. Buttons and other Controls supply `hovered` automatically;
keyboard help follows visual keyboard focus. A plain Item can supply its own
HoverHandler through the optional `hovered` input:

```qml
Text {
    id: name
    width: 148
    text: fullName
    elide: Text.ElideRight
    activeFocusOnTab: true
    HoverHandler { id: pointer }
    Ui.KosToolTip {
        target: name
        hovered: pointer.hovered
        text: name.text
        onlyWhenTruncated: true
        truncated: name.truncated
    }
}
```

The host owns the text and truncation decision. `when` gates availability;
`showOnFocus` defaults to true. Empty text, disabled/hidden targets and complete
labels under `onlyWhenTruncated` never show a bubble. Leaving, pressing the
trigger, Escape or timeout dismisses it. Pressing still reaches the original
control, and Escape does not move focus.

The host can expose `toolTipBackdrop` on an ancestor Item for popup-specific
sampling. Its `LiquidBackdrop` must capture the actual application content and be
a sibling of that scene; the popup overlay must remain outside the source subtree.
`backdrop` also accepts an explicit provider. Resolution prefers `toolTipBackdrop`,
then eligible scoped `contentBackdrop`, then the registered window default.
Never capture the entire window including its overlay or the tooltip itself.

Other inputs are `materialOpacity` (0.7), `cornerRadius` (14), `reduceTransparency`,
`maximumWidth`, `targetGap`, `darkAppearance`, `delay`, `timeout`, read-only `sampling`
and inherited font/Popup properties. Keep the default geometry for consistent
forms. Do not add an accent ring or independent shadow/glass layer in a wrapper.

## Review in a VM

```sh
/usr/lib/qt6/bin/qmltestrunner -input tests/tst_tooltip.qml -platform offscreen
```

The focused checks exercise actual hover delay, leave/press/timeout dismissal,
keyboard focus and Escape, truncation/availability, plain-text wrapping, light/dark
appearance, window-edge placement, sampled-material fallback and the Gallery example.
Run the sampling check with a GPU backend to exercise blur/refraction; software
checks cover fallback and behavior. No automated scheduler
or workstation verification is installed.
