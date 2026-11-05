# 历史设计研究与令牌参考

本目录保留 2026-10-24 的 macOS 27 设计研究及早期实现参考，供追溯来源；
它们不是当前组件接入规范，也不是运行验收记录。

| 文件 | 内容 |
| --- | --- |
| [设计指导 Markdown](macOS27-design-guide.zh-CN.md) | 原则、组件分析及来源等级；缺失的原素材名保留为文字索引 |
| [设计指导 PDF](macOS27-design-guide.zh-CN.pdf) | 历史排版快照，内嵌研究截图 |
| [实现规范 Markdown](macOS27-implementation-spec.zh-CN.md) | 早期令牌表及后续补充；与当前契约冲突的旧配方不再适用 |

## 当前规范入口

遵循 [AGENTS.md](../../AGENTS.md)、[Gallery 设计语言](../GalleryDesign.zh-CN.md)
及其链接的 [Dialog](../Dialogs.zh-CN.md)、[Popover](../Popovers.zh-CN.md)、
[Tooltip](../Tooltips.zh-CN.md)、[Settings](../Settings.zh-CN.md) 和
[窗口控件](../WindowControls.zh-CN.md) 专项契约。
这些当前约定优先于本目录旧表格、历史 PDF 和过时源码注释；
源码描述实际实现，但不能用旧注释降低当前要求。发现差异时明确记录并对齐，不能自行改设计值。

## 图片与维护

历史设计指导引用的 223 张图片没有作为 `images/` 目录随 Markdown 分发；
请通过现存 PDF 查看插图。Markdown 保留原素材名及图注，避免显示失效图片。
素材来源及可信度仍按正文记录；本次整理不重新核验其外部来源。
PDF 随仓库分发的历史决定日期为 2026-10-26。

历史生成脚本 `build_doc_cn.py` / `build_spec_cn.py` 位于原设计工作机，
不属于本仓库的可复现构建入口。维护 Markdown 时保留来源，勿用旧生成结果
覆盖当前规范；PDF 是历史快照，不承诺随 Markdown 同步。
