# 组件及应用接入

[English](Components.md)

## 目录及状态

| 用途 | 组件 | 状态约定 |
| --- | --- | --- |
| 共享窗口内采样 | `LiquidBackdrop` | 宿主提供独立的场景子树 |
| 材质及容器 | `LiquidSurface`、`LiquidCard` | 宿主提供几何、背景源及可读性策略 |
| 操作及导航 | `LiquidActionButton`、`LiquidNavigationButton` | 处理 `clicked()`，宿主持有当前页面 |
| 输入 | `LiquidTextField` | Qt Quick Controls 的文字编辑及确认 |
| 独立选项 | `LiquidCheckBox` | 原生 `checked` / `toggled()` 行为 |
| 设置开关 | `LiquidGlassSwitch` | 接收 `toggled(bool)` 并更新宿主状态 |
| 数值 | `LiquidSlider` | 归一化 0–1、预览、提交及取消 |
| 选择 | `LiquidSelect` | 宿主确认 `activated(int)` |
| 分页 | `LiquidSegmentedControl` | 宿主确认 `selectionRequested(int)` |
| 导航透镜 | `LiquidNavBar` | 宿主确认 `selectionChanged(int)` |
| 模态反馈 | `LiquidDialog` | `open()`、`close()`、`accepted()` 和 `rejected()` |
| 应用基础 | `AppTheme`、`KosApplicationWindow`、`KosEmptyState`、`KosKineticScroll` | 应用负责偏好、内容和业务操作 |

Gallery 加载 `demo/gallery/examples` 下的真实文件，代码面板读取同一文件，
只把 Demo 的目录导入替换为 `import Kos.Ui` 别名以便复制到应用。
切换页面会重建示例，不持久化操作。目录及双语 API 说明归属
`demo/gallery/ComponentCatalog.mjs`。

`LiquidTextField` 使用 `materialForm: false`、`liquidFinish: true` 启用液态表面。
支持两种形态的控件使用 `materialForm: false` 保留液态外观。
`LiquidSelect.appearanceMode` 接收 `system`、`light`、`dark`。
AppTheme 提供语义颜色和减少动效策略；应用可覆盖已开放的输入属性。

## 提供背景

```qml
import QtQuick
import QtQuick.Window
import Kos.Ui

Window {
    width: 720
    height: 480
    visible: true

    Item {
        anchors.fill: parent
        Rectangle {
            id: scene
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: "#246b82" }
                GradientStop { position: 1; color: "#a96e94" }
            }
        }
        LiquidBackdrop { id: sceneBackdrop; sourceItem: scene }
        LiquidSurface {
            anchors.centerIn: parent
            width: 320
            height: 180
            radius: 24
            backdrop: sceneBackdrop
            refractionStrength: 4
            magnification: 1.06
        }
    }
}
```

背景源与使用它的表面必须是同一窗口中彼此独立的子树，不能采样包含玻璃自身的
卡片或窗口内容根节点。`hideSource` 默认 false，一个可见场景即可供多个表面使用，
无需复制。`active: false` 释放捕获资源；`resolutionScale` 控制采样密度，
`maximumTextureSize` 默认将最长边限制为 2048 像素。

`registerAsDefault: true` 时，当前窗口的表面通过 `LiquidStyle.backdropFor(window)`
查找采样器。局部场景使用 `registerAsDefault: false` 及显式 `backdrop`，
默认源不能跨窗口串用。

`refractionStrength` 和 `edgeWidth` 使用逻辑像素。`magnification: 1` 关闭中心放大，
同时设置 `refractionStrength: 0` 可关闭边缘位移；`blurStrength: 0` 关闭模糊扩散。
`readability` 控制可读性处理。滑块使用该核心采样自身同级轨道，并裁去透镜下方的
原始可见轨道，避免未折射的进度边缘重叠。

Alpha 透明是独立操作。透出桌面时，窗口及父容器背景必须透明，还要移除对应区域
下方的不透明图片及采样副本。仅对材质背景设置不透明度；需要让重叠材质一起淡出时
进行分组，文字和交互内容保持不透明。侧栏 Demo 直接实现了这条路径，默认值 0.95。

## 链接静态模块

在已有 Qt Quick 应用的 CMake 工程里，找到所需 Qt 组件并创建应用目标后：

```cmake
add_subdirectory(/path/to/nextkdeAppDemo/shared/qml kos-ui)
target_link_libraries(my_app PRIVATE Kos::Ui Kos::UiPlugin)
```

父工程需要提供 Qt 6.8+ 的 Core、Gui、Qml、Quick、QuickControls2 和 QuickDialogs2。
运行环境还需提供已导入的 QML 模块，包括原有开关及导航效果使用的
Qt5Compat.GraphicalEffects。应用中使用 `import Kos.Ui`，本仓库不附带 NextKde 应用运行时。

源码预览使用 `demo/Kos/Ui/{foundation,controls,i18n}`，保留这些仓库内软链接。
新增类型时维护 qmldir 导出，不要把另一份组件实现复制进各应用。

## 着色器及审阅

可移植着色器源码和两个 QSB 位于 `shared/qml/controls/shaders`。
需要重新生成时，在虚拟机或托管 CI 中执行：

```sh
bash shared/qml/controls/shaders/compile.sh
```

GLSL 及匹配的两个 QSB 一起提交。脚本使用 Qt 6 变体及 QSB 格式 64。
本次从主项目工作区成对复制源码和已提交资源，没有重新烘焙或运行它们。

这些着色器无法直接取得真实桌面纹理。普通透明窗口通过合成器常规合成显示，
不能从成功迁出源码推断 KWin 模糊、桌面采集、GPU 验收或性能测量已完成。

`KosWindowControls` 默认仍为全屏/最小化/关闭。桌面应用可设 `maximizeMode: true`
使用最大化/还原，并通过 `circleSize`、`buttonWidth`、`buttonHeight` 与 `spacing`
适配窗口骨架；默认18px圆点、22×32按钮和10px间距保持不变。

`LiquidActionButton.iconOnly` 默认 false。设为 true 后，使用36px紧凑宽度，
取消文字按钮的左右内边距，图标居中且不省略。纯符号应提供 `Accessible.name`。
禁用态保留原透明度处理；Gallery 同时展示启用与禁用示例。

### 方向性反光与输入文字

LiquidSurface 使用圆角形状法线产生方向性的正光，移除了全周双描边与固定上下浮雕渐变。
reflectionStrength/rimColor 属性保留，控制柔光弧与弱面内反射；独立无纹理shader保证有无
backdrop时反光一致。软件路径为克制的方向性Canvas光弧，不声称采样光学。
按钮新增可选显式backdrop，普通态收敛、悬停/按下轻增并尊重减少动态。
输入框默认文字/占位/选中文字使用AppTheme语义色，显式覆盖仍有效；液态焦点环独立绘制。
Gallery按钮页包含真实彩色条纹纹理及启用/禁用按钮、中英文输入，可实际悬停/按下/Tab/选择。
编译和shader bake不等于视觉验收。

独立旧材质仍待逐项审查：LiquidSelect闭合场与弹层、LiquidGlassSwitch轨道/拇指、
LiquidNavBar、LiquidSegmentedControl。必须保留Material分支及焦点指示；本轮未宣称全库完成。

### 选择器闭合场与弹层

LiquidSelect 非Material的闭合场和选项弹层改为共享LiquidSurface，移除上亮下黑的
金属边缘与固定高光斑。可选backdrop让两者采样同一有效窗口内纹理，sheetColor仍控制
弹层颜色/透明度。Material实心描边/填充分支保留，activated(index)、乐观选择及宿主
确认/回滚契约不变。真实键盘焦点独立绘制，保留Tab、方向键、Enter、Escape流程，
弹层/反光过渡尊重减少动态。Gallery增加普通/禁用/Material对照。
按钮页的旋转条纹源现裁切在场景边界内，不改变玻璃自身裁切与采样映射。

### 开关与分段控件反光审阅

非Material的LiquidGlassSwitch轨道、拇指与展开透镜改用LiquidSurface方向性反光，
展开透镜采样真实同级轨道；移除全周白/红/青描边及固定浮雕。保留位移、展开、
回弹动画时长，减少动态时关闭动画。Space/Enter与无障碍激活只发toggled请求，
不覆盖宿主checked绑定；真实焦点环独立保留。
LiquidSegmentedControl保留几何、selectionRequested乐观选择、宿主确认与超时回滚。
液态透镜共享Surface，支持有效backdrop，移除旧白圈、垂直浮雕和透镜阴影；
Material填充/轮廓保留。Gallery含禁用/Material对照及真实条纹采样场景。
审阅钩子调用真实按下/释放状态路径；状态驱动连续帧不能代替指针/键盘事件验收。
仍须审阅浅深色展开和移动过程；LiquidNavBar独立旧材质留待后续。
