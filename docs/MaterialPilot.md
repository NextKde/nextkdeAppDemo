# Material specification pilot

## 2026-10-22 sidebar rows

Follow-up: the navigation search opts into the shared plain text-field form
(34px, radius10, fill.06, focus2px with offset2). Sidebar padding16, title17/600,
caption/group11, body14, label.92/.62. The footer uses a standard Switch and a
plain guide action. Sidebar background is retained and is not claimed to match
regular/E2. Other pages and KMusic remain unchanged. User reviews hot reload;
no screenshots or runtime verification.

Gallery sidebar rows opt into shared LiquidNavigationButton.specificationForm.
The sidebar background and all other consumers remain unchanged. Rows are plain
(no glass): height30, radius8, body14, selected tint.13, hover.06/.08,
pressed.10/.12, pressScale.96, 100/150ms, focus2px with offset2, disabled.38.
Specification values are grouped in the component; no new specification token.
Additional glass budget: persistent0/2, transient0/1. User reviews hot reload;
no build, run, screenshot or verification performed.

## Toolbar pilot

2026-10-22: a standalone toolbar pilot appears above the retained comparisons on
Gallery's Buttons page. KMusic and shared control defaults are unchanged.

Only the L1 toolbar samples scrolling content. Its standard Qt Quick Controls
button and input use plain fills, with no additional glass. Pilot values are
centralized in `demo/gallery/components/MaterialSpecTokens.qml`: 44px toolbar,
20px radius, 8px inset, 28px controls, 10px control radius, regular fill .58/.52,
plain/hover/pressed fills, label .92/.62, two E2 shadow layers, 2px focus border,
.96 press scale, and 100/150ms transitions.

Glass budget: pilot 1/2 persistent, 0/1 transient. Retained comparison sections
are not claimed to satisfy the whole-screen glass budget.

Recorded exceptions: retain existing diagonal highlights and refraction3,
magnification1.025, reflection.50, normalized backdropBlur.20 pending user review.
The 240px scene height is demo geometry. Blur and shadow radii are not visually
calibrated to the specification. Saturation, noise, luminosity shift, contextual
shadow multipliers, increased contrast and all state rules remain unresolved.
Reduced transparency makes this pilot solid; reduced motion removes its button
scale and color animations.

User review: light/dark, scrolling actual image/text under the fixed toolbar,
typing/selecting/clearing, Tab focus, press feedback, Enabled and Reduce motion.
No build, launch, screenshot or visual acceptance was performed.
