# macOS 27 设计规范（中文）

本目录收录以 macOS 27 HIG 逆向研究为基础产出的两份规范：

| 文件 | 内容 |
|---|---|
| `macOS27-design-guide.zh-CN.md` | 《设计指导》——设计原理、材质、导航排版、组件逐项分析（对应 Apple 官方截图的逆向成果） |
| `macOS27-implementation-spec.zh-CN.md` | 《实现规范》——令牌级取值表（颜色/尺寸/圆角/间距），可直接对照 `shared/qml` 实现 |

## 图片说明

《设计指导》正文引用的 223 张 `images/…` 截图为 Apple 官方素材，**因版权原因不随仓库分发**，
仅存于设计工作机（172.22.33.99 的 `~/kosRemoteDev/macos27-design/images/`）。
文本内容自洽，图片缺失不影响规则阅读。

## 权威关系

- 组件取值规则的**唯一权威来源**是组件源码注释（如 `shared/qml/controls/LiquidActionButton.qml` 头部）。
- 本目录的《实现规范》与组件源码注释保持同步；若两者冲突，以源码注释为准并回改本文件。
- 旧的 `docs/GalleryDesign.md` 为组件库早期设计说明，其中与上述规范冲突的条目已被取代。

## 生成方式

两份文档由设计工作机上的脚本从素材生成（`build_doc_cn.py` / `build_spec_cn.py`），
更新流程：在工作机重新生成 → 覆盖本目录同名文件 → 提交。
