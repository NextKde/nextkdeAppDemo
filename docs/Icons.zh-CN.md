# 平台图标字体

[English](Icons.md)

`Kos.Icons` 是 NextKde 界面图标的统一入口，随应用携带一份 Framework7＋NextKde
扩展字体，不查找系统字体或图标主题，不拼 SVG、不联网。应用 Logo、服务商标志、
封面和外部托盘图标仍是原属方的图片，不属于操作图标字体。

```qml
import Kos.Icons as Symbols
Symbols.Icon { name: "folder"; size: 16; color: AppTheme.text }
Symbols.Icon { name: "coffee"; size: 16; color: AppTheme.text }
Symbols.SignalIcon { connected: true; signalStrength: 55; color: AppTheme.text }
Symbols.VolumeIcon { level: 0.5; muted: false; color: AppTheme.text }
Symbols.BatteryIcon { level: 0.63; charging: false; color: AppTheme.text }
```

`size` 限定实际字形大小，控件拉伸 contentItem 时也不会把图标放大。宿主继续负责
布局、颜色、禁用状态和可访问名称。`filled` 选择已有实心变体，不代表加粗。
目前只提供经过设计的 Regular 字重，不用模拟粗体或随意加描边。Wi-Fi 强度复用
同一原始字形的轮廓；电池单独裁切字体中的填充轮廓，保留连续电量变化。

字体每个 QML 引擎加载一次。`IconRegistry.has(name)` 判断覆盖；未知名称显示问号框，
不会悄悄变成勾。`VectorIcon` 只保留兼容接口，内部路径表已经删除，旧 `strokeWidth`
参数不再影响字形。笔记文件夹等已保存的标识保持不变，由公共别名表转换。

## 新增和维护

上游版本、输入／输出哈希及许可记录在 `shared/Icons/provenance.json` 和
`LICENSE.Framework7`。`tools/icons` 保存固定上游字体、有序名称、别名、可编辑扩展
路径和构建脚本。原创扩展沿用 GPL-3.0-or-later；由上游轮廓生成的 Wi-Fi／电池
状态保留 Framework7 的 MIT 来源。

1. 有合适字形就复用，语义别名统一写入 `aliases.json`。
2. 真正缺失时，在 `extensions.json` 增加统一 24 单位画布的图标及未使用码位。
3. 不重排上游名称表，不重用既有码位，不在应用里另加 SVG、Canvas 或字符替身。
4. 只在虚拟机／CI 按 provenance 中的依赖版本运行 `tools/icons/build_font.py`，
   字体、映射、来源记录一起提交。
5. 按英文文档命令运行 `tests/icons`，并检查小尺寸、浅深色和状态切换。

测试用 QRawFont 打开实际打包字体，逐个确认字形存在；通过测试不等于视觉验收。
上游图标从 U+F0000 分配补充私用区码位，扩展从 U+F1000 分配，保持稳定。

## 应用接入

Kos.Ui 自动链接图标模块；独立宿主添加 `shared/Icons` 并链接 `Kos::Icons`、
`Kos::IconsPlugin`。Quickshell 和 Gallery 的源码入口为 `Kos/Icons`。同一进程内
旧 Kos.Ui 与 Kos.Demo 共用该模块，不重复定义字体系统。

各应用保留现有组件 API 和材质版本。`tools/sync_icons.py <shared/qml>` 仅同步
公共图标模块、兼容入口和内嵌图标替换，不覆盖其余控件。测试后固定子模块提交或
vendor 清单，保留许可和来源；默认构建不追踪浮动分支，也不依赖本机绝对路径。

## 检查遗漏

在虚拟机执行 `python3 tools/icons/audit_usage.py <各项目源码目录> --inventory`。
检查同时覆盖固定字符、条件表达式、自定义按钮、动态图标字段、字形名称和失效的 SVG 相对路径；
Canvas、内嵌及文件 SVG 清单仍需逐项审查，不能把所有绘图都当成冗余图标删除。
数学与尺寸文本、路径分隔符、用户头像／封面／自定义 emoji、品牌标志、
天气背景、数据图表、材质遮罩以及教学动画中的光标属于保留项。
公共导航、标签栏与窗控另由 `tests/icons/tst_hosts.qml` 验证加载、状态和几何契约。
