# 架构与归属

[English](Architecture.md)

## 源码边界

| 路径 | 责任 |
| --- | --- |
| `shared/qml/foundation` | AppTheme 语义颜色、应用安全控件、对话框和滚动 |
| `shared/qml/controls` | 液态材质、输入及导航控件 |
| `shared/qml/i18n` | 可移植的翻译及区域设置辅助 |
| `shared/qml/controls/shaders` | 可移植液态表面的 GLSL 及已提交 QSB |
| `demo/gallery.qml` | 一个普通 Quickshell FloatingWindow，承载组件目录 |
| `demo/sidebar-demo.qml` | 一个普通窗口，承载完整侧栏布局 |
| `demo/gallery` | 目录、双语 API 说明及真实交互示例 |
| `demo/Kos/Ui` | 源码入口，通过软链接指向本仓库唯一的共享实现 |

Demo 不依赖其他工作区。Quickshell 源码导入必须通过 `Kos/Ui` 留在 `demo`
配置树内，越出根目录的路径会被转为 `qrc:/qs-blackhole`。复制仓库时保留这些映射。
源码入口和 CMake 导出应引用同一份实现。

## 渲染

`LiquidBackdrop` 对同级、宿主持有的 QML 场景统一采样一次。采样树必须排除
所有使用它的控件；表面拒绝祖先背景源或来自其他 QQuickWindow 的背景。
采样器可注册为当前窗口默认值，局部示例和滑块使用显式源及
`registerAsDefault: false`。

`LiquidSurface` 将二维坐标映射到纹理，提供边缘透镜位移、放大、可选模糊、
染色及可读性处理，并保留预乘 alpha。没有合法背景源或使用软件渲染器时，
使用透明染色及反射边缘降级。当前映射不承诺透视变换。

独立 SidebarDemo 默认使用桌面模式：窗口底色透明，停用本地图片及其捕获，仅对材质背景
分组设置 0.95 不透明度，文字保持不透明。窗口内背景模式在同一窗口绘制图片，
再用 QML 采样实现光学。两种模式都不请求 KWin 特效，也不采集其他应用像素。
普通透明窗口仍由系统合成器显示；真实桌面模糊或折射需要单独的可选适配层。

Gallery 左侧导航遵循 GalleryDesign.zh-CN.md 的 2026-10-27 规则：采用与窗口边缘衔接的整块普通面板，
无悬浮卡片造型与容器级液态光学，仅背景不透明度为 0.95，通过 QML shader／MultiEffect 模糊同窗实际下层内容。
窗口底色保持不透明；不使用 KWin 液态特效或桌面捕获提供模糊，采样源排除导航材质及控件。
这是界面组合要求，代码接入状态以 GalleryDesign.zh-CN.md 的记录为准。

开关、下拉框、分段选择和导航栏仍使用原有 QML 渐变或遮罩光学，尚未全部迁移到
采样核心。`sampling` 只表示背景及渲染路径选择，不代表视觉验收通过。

## 应用接入

AppTheme 提供语义颜色和动效。应用可通过已有属性注入偏好，本仓库不提供
NextKde 平台服务、原生材质能力或偏好同步。业务操作及持久化状态属于应用宿主。

默认 CMake 只导出静态 `Kos.Ui` 模块，不编译 Gallery 可执行程序。
Qt Quick 应用链接 `Kos::Ui` 和 `Kos::UiPlugin`；Quickshell 预览通过源码入口
使用同一模块。

向 NextKde 反哺时，在它的共享 UI 边界接入。主项目当前工作区里的 Shell 适配
尚未自动关联本仓库，不能把平台服务复制进可移植控件。

## 修改及验收约定

初始导入包含尚未提交的原工作区修改，迁出后尚未构建或启动，未宣称 CI、
发布或运行验收完成。只在明确要求时于虚拟机或托管 CI 中验证，不启动或替换
维护者本机的 Shell。源码和 Git 审阅不等于运行验证。临时产物不进入跟踪文档。
