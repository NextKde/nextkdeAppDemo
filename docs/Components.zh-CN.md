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

独立旧材质仍待逐项审查：LiquidSelect弹层、LiquidGlassSwitch轨道/拇指、
LiquidNavBar、LiquidSegmentedControl。必须保留Material分支及焦点指示；本轮未宣称全库完成。

### 选择器闭合场与弹层

LiquidSelect 的闭合按钮直接复用 LiquidActionButton：materialForm 为 true 时是普通
实色下拉框，为 false 时与液态 Button 共用填充、高光、折射和悬停外观。
liquidIntensity 共用 Button 的强度档位；shadowEnabled 默认关闭，shadowLevel 共用
阴影档位。箭头使用矢量图标。appearanceMode 继续支持独立的深浅色外观。
Button 新增的 darkAppearance、reduceMotion 默认跟随 AppTheme，原调用方默认效果不变。

选项弹层保留实色/液态分支及 sheetColor，backdrop 提供有效窗口内纹理。
activated(index)、乐观选择及宿主确认/回滚契约不变，保留独立焦点环和 Tab、方向键、
Enter、Escape 操作，过渡尊重减少动态。Gallery 展示液态、禁用和普通款。
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

### 导航透镜

LiquidNavBar非Material轨道、静止拇指、活动透镜共享方向性LiquidSurface，移除
RGB/白色闭合描边、固定高光斑及垂直深度渐变。可选backdrop提供真实窗口内纹理，
透镜保留部分透明度，使原有透镜下方的图标/文字可读。Material填充与选中文字角色
独立保留，不引入桌面纹理或合成器访问。
保留原有可变currentIndex/selectionChanged契约、桌面点击指针行为、16ms弹簧积分、
100ms显示层缓动和280ms活动超时；减少动态直接定位。增加独立焦点指示及
Tab/方向键/Home/End/Space/Enter路径，禁用时拒绝激活。真实事件/辅助技术验收仍待
独立审阅。Gallery含裁切真实彩条、禁用/Material对照。可选状态序列记录实际elapsed，
保留全部GPU抓帧后才压缩PNG，避免编码阻塞动画；状态入口实图不等同键鼠事件验收。

### 共享矢量图标

VectorIcon新增一致的原创描线音乐/播放控制图形。LiquidActionButton.iconName默认
空字符串，非空时居中绘制矢量图标，iconSize默认16，原text/iconOnly用法保留。
LiquidNavigationButton的iconName/iconColor提供可选16px图标，cornerRadius默认保持10。
纯图标操作需无障碍名称，导航与播放不再依赖字体符号。

ActionButton光学：内容保留按压压缩，背景透镜轻微展开；实际hover/down驱动
折射/放大/反光并遵循reduceMotion。只读sampling/opticalExpansion/opticalRefraction/
opticalMagnification/opticalReflection可查询实际动画值；动作及backdrop仍由宿主提供。

新增兼容的应用配色覆盖：ActionButton的textColor/iconColor/surfaceColor/accentColor/
focusRingColor/keyboardFocusOnly；NavigationButton的selectionColor/hoverColor/
focusRingColor/keyboardFocusOnly；Select的focusRingColor/selectedTextColor独立于accentColor。
默认配色与焦点行为保持原样。LiquidCard新增材质光学参数、可选shadowEnabled（默认false）
及只读sampling；浮动消费方须提供排除自身且包含真实滚动内容的同窗sibling backdrop。

LiquidBackdrop.blur (default 0) optionally prefilters the actual sibling scene with a continuous QML blur for larger panels; consumers retain local refraction and lighting.

LiquidSurface.diffuseStrength默认0，仅影响未采样底层：连续低对比面光与静态细颗粒保持tintStrength透明度，不模糊外部像素；软件渲染保留纯色退化路径。

LiquidSurface.convexLens默认false：四阶凸面边缘法线同时控制Snell折射和薄方向高光，
中心保持坐标连续，refractionStrength为0时不位移。共享按钮和液态输入启用此profile，
保留focus/Material/disabled契约；Card/播放器保持原profile。LiquidBackdrop.rawTexture
配合LiquidSurface.unfilteredBackdrop可将同一真实隐藏场景供给右侧清晰裁剪显示和另一个
连续模糊的镜片，所有消费者必须排除在源之外。半透明折射层下不得再画原始清晰内容，
以免漏出未折射副本形成双影。


## 液态强度档位（2026-10-22）

按钮 LiquidActionButton、输入 LiquidTextField 新增 liquidIntensity：light（轻）、medium（中）、strong（强）。默认跟随 LiquidStyle.intensityLevel=medium，保持现有中档参数；Gallery导航搜索单独设为strong。档位联动折射、放大、高光、局部模糊和向内染色；布局、字体、填充透明度不变。现有shader将向内染色上限限制为.10，所以中强两档此项相同，强档提高其他光学值。其他组件类型尚未接入档位。未截图、未运行验证。


2026-10-22 填充修订：液态按钮和输入禁用原自适应向内染色，改为上下各3px白色10%→0渐隐。普通液态填充中心#f2f2f4向外椭圆渐变至#c4c4c8，两种主题使用同一灰白/灰色配色，默认20%与hover25%保持不变。主题色主操作按钮保留accent。折射shader关闭原均匀填充，由共享LiquidSurface单次绘制渐变，不重复叠加平色；对角高光与档位光学值不变。新增QML绘制无需更改或重烘焙QSB。未运行验证。
