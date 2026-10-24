export const entries = [
    {
        id: "button", name: "Button", zh: "按钮", group: "input", type: "LiquidActionButton",
        summary: "Trigger an action with primary, secondary, destructive or disabled states.",
        summaryZh: "触发操作，提供主要、次要、危险操作和禁用状态。",
        source: "shared/qml/controls/LiquidActionButton.qml", example: "ButtonExample.qml",
        api: [["text / highlighted / enabled", "Label, emphasis and availability.", "文字、强调状态和可用性。"],
              ["destructive / secondary", "Optional action styles.", "可选的危险操作和次要操作样式。"],
              ["clicked()", "Handle the action in the host.", "由宿主处理操作。"]]
    },
    {
        id: "text-field", name: "Text field", zh: "文本输入", group: "input", type: "LiquidTextField",
        summary: "Single-line application input with selection and theme-aware focus styling.",
        summaryZh: "单行应用输入框，支持选中文字，并随主题显示焦点。",
        source: "shared/qml/controls/LiquidTextField.qml", example: "TextFieldExample.qml",
        api: [["text / placeholderText", "Current input and empty prompt.", "当前输入和空值提示。"],
              ["liquidFinish / backdrop", "Enable the shared liquid surface and optionally supply an in-window backdrop.", "启用共享液态表面，可选传入窗口内背景源。"],
              ["sampling", "True when an eligible backdrop and the shader path are selected; not a visual acceptance result.", "选用可用背景及着色器路径时为 true，不代表视觉验收通过。"],
              ["textEdited() / accepted()", "React to editing or Enter.", "响应用户编辑或回车。"]]
    },
    {
        id: "checkbox", name: "Checkbox", zh: "复选框", group: "input", type: "LiquidCheckBox",
        summary: "Choose an independent option. The control updates its checked state.",
        summaryZh: "选择独立选项，控件会自行更新选中状态。",
        source: "shared/qml/controls/LiquidCheckBox.qml", example: "CheckBoxExample.qml",
        api: [["text / checked / tristate", "Label and selection state.", "文字及选中状态。"],
              ["toggled()", "Read checked after a user change.", "用户切换后读取 checked。"]]
    },
    {
        id: "switch", name: "Switch", zh: "开关", group: "input", type: "LiquidGlassSwitch",
        summary: "Request a setting change. The host must apply toggled(checked) to its own state.",
        summaryZh: "请求设置变更，宿主必须接收 toggled(checked) 并更新自己的状态。",
        source: "shared/qml/controls/LiquidGlassSwitch.qml", example: "SwitchExample.qml",
        api: [["checked: bool", "Bind to host-owned state.", "绑定宿主持有的状态。"],
              ["Accessible.name", "Describe the setting for assistive tools.", "为辅助工具描述设置用途。"],
              ["toggled(bool checked)", "A request, not automatic persistence.", "变更请求，不会自动持久化。"]]
    },
    {
        id: "slider", name: "Slider", zh: "滑块", group: "input", type: "LiquidSlider",
        summary: "Adjust a numeric value by dragging or Ctrl + wheel; the glass thumb refracts its own QML track.",
        summaryZh: "拖动或 Ctrl 加滚轮调整数值，玻璃拇指折射自身的 QML 轨道。",
        source: "shared/qml/controls/LiquidSlider.qml", example: "SliderExample.qml",
        api: [["value / wheelStep", "Normalized range 0–1 and fine wheel step.", "数值范围为 0–1，wheelStep 控制精细滚轮步长。"],
              ["refractionStrength / magnification", "Track lens displacement in logical pixels and magnification ratio.", "轨道透镜位移（逻辑像素）及放大倍率。"],
              ["previewChanged(value) / commitRequested(value)", "Preview changes while dragging; commit on release.", "拖动时预览，松开后提交。"],
              ["canceled()", "Restore the last committed value.", "恢复上次提交的值。"]]
    },
    {
        id: "combo-box", name: "Combo box", zh: "下拉选择", group: "input", type: "LiquidSelect",
        summary: "Standard or liquid dropdown, with the same trigger surface as Button.", summaryZh: "普通或液态下拉框，触发按钮与 Button 共用外观。",
        source: "shared/qml/controls/LiquidSelect.qml", example: "ComboBoxExample.qml",
        api: [["model / textRole / currentIndex", "Options, display role and selection.", "选项、显示字段和当前选择。"],
              ["materialForm / liquidIntensity", "Solid when materialForm is true; otherwise use Button’s liquid intensity.", "materialForm 为 true 时为普通实色，否则使用 Button 的液态强度。"],
              ["activated(int index)", "Handle a user selection.", "处理用户选择。"]]
    },
    {
        id: "segmented", name: "Segmented control", zh: "分段选择", group: "navigation", type: "LiquidSegmentedControl",
        summary: "Switch between related views. The host confirms selectionRequested(index).",
        summaryZh: "切换相关视图，由宿主确认 selectionRequested(index)。",
        source: "shared/qml/controls/LiquidSegmentedControl.qml", example: "SegmentedExample.qml",
        api: [["labels / currentIndex", "Segment labels and host selection.", "分段名称和宿主选择。"],
              ["selectionRequested(int index)", "Apply the requested index in the host.", "宿主写回请求的索引。"]]
    },
    {
        id: "bottom-navigation", name: "Liquid navigation bar", zh: "液态导航栏", group: "navigation", type: "LiquidNavBar",
        summary: "A glass selection lens that moves when destinations change.",
        summaryZh: "点击导航项时，玻璃选中透镜随之移动并切换内容。",
        source: "shared/qml/controls/LiquidNavBar.qml", example: "BottomNavigationExample.qml",
        api: [["model / currentIndex / size", "Destinations, host selection and size preset.", "导航项、宿主选择和尺寸档位。"],
              ["selectionChanged(int index)", "Update the host page and selected index.", "更新宿主页面及选中索引。"]]
    },
    {
        id: "navigation", name: "Sidebar navigation", zh: "侧栏导航", group: "navigation", type: "LiquidCard + LiquidNavigationButton",
        summary: "A working sidebar: selecting a destination changes the adjacent content.",
        summaryZh: "可操作的侧栏，选择导航项会切换旁边的内容。",
        source: "shared/qml/controls/LiquidNavigationButton.qml", example: "NavigationExample.qml",
        api: [["LiquidCard / Layout.preferredWidth", "An ordinary sidebar with ordinary navigation rows.", "普通材质侧栏容器，内部使用普通导航行。"],
              ["text / checked / clicked()", "The host owns the selected destination.", "宿主维护当前页面，按钮显示选择并发出点击。"]]
    },
    {
        id: "card", name: "Card", zh: "卡片", group: "layout", type: "LiquidCard",
        summary: "Ordinary content cards and a floating search panel with one adaptive glass layer.",
        summaryZh: "普通内容卡片，以及只有外层使用自适应玻璃的悬浮搜索面板。",
        source: "shared/qml/controls/LiquidCard.qml", example: "CardExample.qml",
        api: [["padding / contentItem", "Inner spacing and content.", "内边距与内容。"],
              ["Layout.fillWidth", "Use Qt Quick Layouts for adaptive sizing.", "通过 Qt Quick Layouts 适应窗口宽度。"]]
    },
    {
        id: "liquid-surface", name: "Liquid surface", zh: "液态透明表面", group: "layout", type: "LiquidSurface",
        summary: "Refract and magnify a shared in-window background texture, with optional blur and readable glass tint.",
        summaryZh: "对共享的窗口内背景纹理进行折射和放大，可叠加模糊及可读性染色。",
        source: "shared/qml/controls/LiquidSurface.qml", example: "LiquidSurfaceExample.qml",
        api: [["LiquidBackdrop.sourceItem / backdrop", "Capture a sibling background once; assign its provider or use the window default.", "对同级背景统一采样，传入采样器或使用当前窗口默认值。"],
              ["refractionStrength / magnification / edgeWidth", "Edge displacement in logical pixels, zoom ratio and lens depth.", "边缘位移（逻辑像素）、放大倍率及透镜边缘范围。"],
              ["tintStrength / blurStrength / readability", "Tint, blur and contrast protection.", "染色、模糊和可读性保护。"]]
    },
    {
        id: "empty-state", name: "Empty state", zh: "空状态", group: "layout", type: "KosEmptyState + LiquidActionButton",
        summary: "Explain missing content and offer a meaningful next action.",
        summaryZh: "说明内容为空的原因，并提供下一步操作。",
        source: "shared/qml/foundation/KosEmptyState.qml", example: "EmptyStateExample.qml",
        api: [["title / description", "Explain the current state.", "说明当前状态。"],
              ["LiquidActionButton.clicked()", "Connect an ordinary content action to the host.", "将普通内容按钮接到宿主操作。"]]
    },
    {
        id: "scroll", name: "Scrollable list", zh: "滚动列表", group: "layout", type: "KosKineticScroll + LiquidNavigationButton",
        summary: "A bounded list with row selection and shared scrolling behavior.",
        summaryZh: "有边界的滚动列表，支持行选择，并使用共享滚动策略。",
        source: "shared/qml/foundation/KosKineticScroll.qml", example: "ScrollExample.qml",
        api: [["target / flickable", "Attach once per view; automatic parent discovery is supported.", "每个视图挂载一个实例，支持自动查找父视图。"],
              ["AppTheme.reduceMotion", "Shared reduced-motion policy.", "共享的减少动态效果策略。"]]
    },
    {
        id: "dialog", name: "Dialog", zh: "对话框", group: "feedback", type: "LiquidDialog",
        summary: "Open a modal dialog, confirm or cancel, and show the result.",
        summaryZh: "打开模态对话框，确认或取消后显示操作结果。",
        source: "shared/qml/controls/LiquidDialog.qml", example: "DialogExample.qml",
        api: [["open() / close() / modal", "Explicit lifecycle and modality.", "显式控制生命周期和模态状态。"],
              ["standardButtons / accepted() / rejected()", "Actions and results inherited from Qt Quick Controls Dialog.", "继承 Qt Quick Controls Dialog 的操作与结果。"]]
    },
];

export function title(entry, language) { return language === "zh" ? entry.zh : entry.name; }
export function summary(entry, language) { return language === "zh" ? entry.summaryZh : entry.summary; }
export function find(id) { return entries.find(entry => entry.id === id) || null; }
export function filter(query) {
    const words = query.trim().toLowerCase().split(/\s+/).filter(Boolean);
    return entries.filter(entry => words.every(word =>
        [entry.name, entry.zh, entry.type, entry.source, entry.summary, entry.summaryZh].join(" ").toLowerCase().includes(word)));
}
export function groupTitle(group, language) {
    const titles = {
        input: ["Input", "输入控件"], navigation: ["Navigation", "导航"],
        layout: ["Layout & content", "布局与内容"], feedback: ["Feedback", "反馈"],
    };
    return titles[group][language === "zh" ? 1 : 0];
}
