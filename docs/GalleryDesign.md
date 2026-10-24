## Rule one: only floating operation layers use glass

Scope: these rules govern application composition, not removal of liquid component capabilities. Gallery keeps liquid buttons, inputs, switches, sliders and selectors alongside solid comparisons. Compact dimensions and material selection are independent.

Ask: **Does this component float above content?**

| Answer | Material |
| --- | --- |
| Yes | Liquid Glass |
| No | Ordinary material |

Gallery uses **transparency between layers inside the application**. The original full-width rectangular floating region overlays real scrolling app content. At the top, the header and body form one ordinary surface with no shadow, highlight or dividing edge. Once actual content scrolls underneath, the floating material becomes 95% opaque with QML blur and no bottom shadow. Returning to the top restores the flat surface; the window always stays opaque.
Keep the original decoration coordinates and avoid an inset rounded block. Top actions, selector and sidebar search retain their liquid finish.

---

## Rule two: avoid nested glass by default; explicitly compose the main pane and liquid actions

| Context | Container | Children |
| --- | --- | --- |
| Ordinary Dialog | Ordinary | Ordinary buttons and search |
| Floating search panel | Light glass | Ordinary search and list |
| Popover | Light glass | Ordinary buttons and list |
| Original full-width rectangular floating region | 95% material opacity, QML blur of underlying app content, no bottom shadow | Decorations unchanged; top actions and selector use light liquid |
| Embedded toolbar | Ordinary | Ordinary controls |
| Left navigation | Ordinary | Ordinary rows; liquid search input |
| Control center | Glass | Mostly ordinary controls |

> **Generally emphasize one glass layer. Gallery explicitly combines its 95% in-window floating material with light liquid top controls, without another rounded header block or control shadows.**

---

## Rule three: only three color families

Use content, control and glass families rather than inventing a palette per component.

| Family | Purpose | Light | Dark |
| --- | --- | --- | --- |
| Content | Text areas, lists, editors and content panels | `#FFFFFF` | `#1C1C1E` |
| Secondary content | Groups, striped areas and secondary panels | `#F5F5F7` | `#242426` |
| Control | Ordinary buttons, search and settings | `#EDEDF0` | `#3A3A3C` |
| Control (Dialog) | Dialog container | `#F7F7F9` | `#2C2C2E` |
| Glass | Determined by the backdrop | Adaptive light glass | Adaptive dark glass |

### 3.1 Dialog and button backgrounds differ

Dialog and buttons belong to the control family but retain one discernible brightness step.

| Theme | Brighter surface | Values |
| --- | --- | --- |
| Light | Dialog container | `#F7F7F9` is brighter than `#EDEDF0` |
| Dark | Button control | `#3A3A3C` is brighter than `#2C2C2E` |

The direction reverses with the theme. Keep the separation modest.

### 3.2 IF / ELSE for AI contributors

```text
IF material == Glass
    background = AdaptiveGlass
    // Never substitute a fixed RGB fill for glass

ELSE IF theme == Light
    content.background = #FFFFFF
    content.secondary  = #F5F5F7
    control.background = #EDEDF0
    dialog.background  = #F7F7F9
    search.background  = #EDEDF0

ELSE IF theme == Dark
    content.background = #1C1C1E
    content.secondary  = #242426
    control.background = #3A3A3C
    dialog.background  = #2C2C2E
    search.background  = #3A3A3C

ELSE
    background = SemanticColor
```

---

## Rule four: material does not change dimensions

The same component keeps its dimensions when its material changes.

| Property | Starting value |
| --- | --- |
| Body | 13px |
| Button, input and selector text (including placeholders) | 11px |
| Ordinary button | Height 28px |
| Search | Height 30px |
| Navigation row | Height 30px |
| List row | Height 32px |
| Toolbar action row | Height 48px |
| Window decoration row | Height 30px, original position |
| Base spacing | 4 / 8 / 12 / 16px |
| Ordinary radius | 8px |
| Floating container radius | 12–16px |

---

# Gallery design language: implementation

[简体中文](GalleryDesign.zh-CN.md) · Version 2.9 · 2026-10-24

The four rules above take precedence over conflicting older material, color and
geometry specifications. Compact desktop proportions and restrained optics remain
the direction; values are project decisions, not official Apple measurements.

## Implementation

AppTheme owns contentBackground, contentSecondaryBackground, controlBackground
and dialogBackground. Gallery opts into compactDesign for common control dimensions
without changing materialForm, specificationForm or liquid optics. Hosts explicitly
select ordinary material where appropriate; existing defaults remain compatible. Gallery
layout values live in demo/gallery/components/MaterialSpecTokens.qml.

The right content scene contains an opaque base and the complete scrolling page.
The floating region overlays it, flush to the original top and side boundaries with
radius=0. It has no inset rounded card. Decorations retain their original 30px row at
y=0, with 14.5px right and 10.5px top control margins. The page initially reserves
30 + 16 + 48 + 12px, then scrolls beneath the region. Both pages expose scrollOffset
from contentY minus originY, clamped at zero. Blur and material activate only
after the 12px initial gap has scrolled away. Returning to the top disables them;
changing component pages resets scroll. Geometry and decoration coordinates stay fixed.
Language/theme actions and the background selector use the light liquid finish.
They sample only the main material background, excluding controls, text and decorations.
Control text stays 11px and fully opaque. The left navigation background and rows remain ordinary. Its search explicitly
uses the light liquid input, sampling the separate sidebar background; reduced
transparency falls back to an ordinary input.
Cards, code and lists use content colors. Ordinary Dialog containers use the Dialog
role, and their buttons use the distinct control role. The floating search example
has one glass container with an ordinary search field and ordinary list.

## Adaptive glass

adaptiveGlass samples an eligible sibling scene through LiquidBackdrop. The existing
LiquidSurface shader responds to sampled pixel luminance for readability. The actual
background and theme determine the result; a fixed RGB rectangle must not substitute
for glass. A thin neutral tint only adjusts appearance.

Composition: opaque app base and actual scrolling content, QML background blur,
95% floating material, then clear controls. LiquidBackdrop.sourceItem references
contentScene with its real lists, cards and text, excluding the floating layer.
Sampling stops at the top, where an ordinary fill matches the body background.
MultiEffect applies blur (.35) while the original content remains displayed below.
LiquidSurface groups its material with layer.enabled and opacity=.95; labels,
buttons and decorations remain opaque. Window.color and the content base are opaque,
so the remaining 5% shows the application's contents, never external windows.
The floating region has no added bottom shadow. No KWin
liquid plugin, compositor blur or native shadow is requested. The background selector
controls component examples only and is not a source for the main floating material.
Reduced transparency uses an opaque material and ordinary top controls.

General light glass uses edge refraction .6, magnification 1 and reflection .12.
The floating material and sidebar search use the shared light optical intensity: resting
refraction 1.5, magnification 1.012 and reflection .28. Avoid thick rims and layered shadows. Ordinary controls/cards
have no shadow; floating containers may have one subdued shadow. The optics page is
an explicitly labelled floating operation-layer demonstration, not a content template.

## States and review

Body 13, actions 28 high, search 30, navigation rows 30, list rows 32 and toolbar 48
remain identical across materials. Button, input, placeholder and selector text use
11px Font.Normal (400), centered vertically. Buttons and inputs use 4px vertical
and 12px standard horizontal padding, with additional space for search icons and
shortcuts. Heading typography stays separate. Keep a separate 2px focus indicator and the theme
focus fallback. Use fill changes for press and hover; honor AppTheme reduced motion.

On 2026-10-24 the user explicitly requested a workstation preview. Gallery loaded
and reloaded successfully. No build, tests or shader bake were performed; full
visual, keyboard, popup and theme acceptance remains pending. Further verification
defaults to a VM or hosted CI unless the user explicitly requests the workstation.
