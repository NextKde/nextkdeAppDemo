# 浮动液态 Dialog 规格

[English](Dialogs.md)

## 必须遵守

添加、编辑、确认等覆盖当前页面的 Dialog 属于**浮动窗口**。使用通用
`LiquidDialog`，不能因内部是表单就改成普通实体面板。

- 外层只有一块液态背景，默认 **32px 大圆角、G2 连续轮廓**。不能用普通
  `Rectangle.radius` 的圆弧拼接冒充 G2；当前轮廓采用四阶超椭圆，连接直边处
  曲率趋于零。轮廓遮罩、折射方向和投影使用同一个形状。
- **玻璃层不透明度为 0.95**，与底色覆盖率分开。先充分模糊背景，再折射、
  轻微着色；将玻璃层以 0.95 合成到已模糊的底层上。禁止混入 95% 实体底色，
  也不能把最终结果再次透明叠到清晰原图上。前景文字保持不透明。
- 背景仍然模糊并折射实际覆盖的同窗口内容；`sourceItem` 必须排除弹窗、
  遮罩和采样器自身。使用 QML `MultiEffect` 与已烘焙 ShaderEffect；不使用
  KWin 液态插件、原生模糊、桌面截图或虚构的壁纸。
- Dialog 内部的**按钮、输入框、选择器触发区和表单条目使用实体材质**。
  文字保持不透明；不要给每行叠玻璃。**添加／保存／确认是主按钮**：可用时固定浅色 `#007AFF`、深色 `#0A84FF`，
  白字 `#FFFFFF`。使用 `AppTheme.defaultAccentSeed`，不得跟随系统强调色、
  改成偏青色或被液态背景的不透明度淡化。禁用时使用普通灰色底和禁用文字色。
  自定义底栏也必须使用通用 `LiquidDialogButton`。
  取消等底部操作按钮不加描边或焦点外框；保留键盘焦点与激活行为，不叠加装饰外圈。
- 允许一层轻柔的 QML 阴影。不要额外添加描边、蓝色焦点外框或装饰渐变。
- 减少透明度、软件渲染或缺少有效采样源时，使用同样 G2 轮廓的不透明普通
  底色回退；不能把未采样的透明颜色称为模糊折射。
- 保留模态、Tab、键盘操作、Escape 和关闭生命周期；业务数据与提交逻辑归宿主。

这条规则优先于旧文档中的“普通 Dialog = 普通材质”以及“浮动容器 12–16px”。
嵌入页面的设置分组仍使用普通材质；Dialog 内下拉出的独立浮动面板按自身规范处理。

## 使用

```qml
LiquidDialog {
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(440, parent.width - 32)
    title: qsTr("Add item")
    sourceItem: pageScene // 页面实际内容，必须不包含这个 Dialog
    cornerRadius: 32
    materialOpacity: 0.95
    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: controller.save()
}
```

`sourceItem` 会创建独立的 QML 模糊采样器。已有合格 `LiquidBackdrop` 的宿主也可
直接传 `backdrop`；省略来源时只会普通回退，不能实现液态采样。
`sampling` 报告有效 ShaderEffect 路径；仍需检查实际画面。
默认 padding 为 24px，紧凑标题 17px DemiBold。**所有液态 Dialog 内的实体操作按钮
统一 30px 高、胶囊圆角（半径 = 高度 / 2）**，不再按“重要／非主”区分。
`actionHeight` 固定只读为 30；自定义底栏也使用 `LiquidDialogButton`。
24px 高、6px 圆角仅适用于普通非液态 Dialog，不得套用到液态 Dialog。
应用可以调整内容尺寸、按钮和业务表单，不得覆写 `background` 绕开通用材质。

## 验证

Gallery 的 Dialog 示例使用真实页面作为底图，确认/取消更新示例状态。
检查深浅主题、文字经过面板底下时的模糊、边缘折射、放大后的 G2 轮廓、
减少透明度回退，以及主按钮/禁用按钮的实体样式。测试位置遵循用户当前授权。
