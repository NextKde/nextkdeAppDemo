# Extraction provenance / 迁出来源

This initial import was extracted on 2026-10-20 from
[NextKde/NextKde](https://github.com/NextKde/NextKde), local branch
`codex/gallery-normal-window`, based on commit
`38f3fb88` (`docs(glass): drop archived gallery screenshots`) plus the current
uncommitted Gallery, liquid component and sidebar-demo work.

2026-10-20 从 NextKde 本地 `codex/gallery-normal-window` 分支迁出，基础提交为
`38f3fb88`，并包含当前尚未提交的 Gallery、液态组件和侧栏 Demo 修改。

- `shared/qml/foundation`, `controls` and `i18n` retain their NextKde source ownership.
  The original root LICENSE is copied unchanged. The existing contributors and
  component comments remain part of the source provenance.
- `demo/gallery` comes from the active `shell/gallery` component catalogue. Native
  Shell examples, the old fullscreen prototypes and KWin integration are excluded.
- `demo/assets/forest.png` and `underwater.png` are the existing NextKde generated
  cinematic backgrounds. Their original generation record is retained in
  [demo/assets/PROVENANCE.txt](demo/assets/PROVENANCE.txt).
- Only selected current files are imported. The parent repository's Git history,
  archived documentation screenshots, credentials, build trees and user state are
  not part of this repository.
- The original NextKde working tree remains in place during this extraction. Future
  integration and removal of duplicate ownership require a separate change there.

组件保留 NextKde 原始归属及原有许可证；背景图片的生成记录随资源保留。
这里只导入选定的当前文件，不导入主仓库历史、归档截图、凭据、构建目录或用户状态。
本次迁出保留主项目现有工作区，后续接回共享组件和清理重复归属另行处理。

The native convex-bezel profile was independently derived in QML/GLSL after
reviewing mkj0kjay/vue-web-liquid-glass, revision
934404c05167417945e73a36388c20cc201b5a55 (README declares MIT), specifically its
convex-squircle/Snell model and matching specular demonstration. Reference:
https://github.com/mkj0kjay/vue-web-liquid-glass and
https://vue-web-liquid-glass.netlify.app/ . No Vue framework, displacement-map
implementation, website image or other webpage asset is copied into this library.

原生凸面边缘profile参考上述固定版本的凸面/Snell模型与实效后用QML/GLSL独立重推；
未复制Vue框架、位移图实现或网页图片素材。参考项目README声明MIT许可。

The Gallery Contrast preview subsequently uses the Unsplash photo explicitly
requested by the user on 2026-10-21 (photo-1651784627380-58168977f4f9), credited
by the reference demo to VISAX / @visaxslr. This demo-only asset has separate
provenance and its Unsplash license link in demo/assets/PROVENANCE.txt; it is not
part of the portable shared UI module.

2026-10-21按用户要求，Gallery Contrast预览采用指定Unsplash图片；图片仅属Demo，
来源、署名及Unsplash许可链接见demo/assets/PROVENANCE.txt，不属于共享UI模块。
