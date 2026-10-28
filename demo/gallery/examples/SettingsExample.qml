import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property string language: "en"
    property string sectionPrefix: "01"
    property bool showVariants: true
    property int selectedShape: 0
    property int selectedMaterial: 0
    property real blurValue: 0.42
    property real savedBlur: 0.42
    property real liquidValue: 1
    property real savedLiquid: 1
    property bool followAppearance: false
    property bool switchAtSunset: false
    readonly property int settingControlHeight: 24
    function tr(en, zh) {
        return language === "zh" ? zh : en;
    }
    spacing: 12
    implicitWidth: 620

    Controls.LiquidBackdrop {
        id: groupBackdrop
        sourceItem: shapeGroup.background
        registerAsDefault: false
        blur: example.blurValue * 0.6
        active: !Ui.AppTheme.reduceTransparency
    }

    Ui.SettingsGroup {
        id: shapeGroup
        objectName: "settingsShapeGroup"
        title: example.tr("Interface shape", "界面形态")

        Item {
            Layout.fillWidth: true
            implicitHeight: 158
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                Repeater {
                    model: ["macOS", "Material Design"]
                    AbstractButton {
                        id: choice
                        required property int index
                        required property string modelData
                        objectName: "settingsShapeChoice" + index
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true
                        hoverEnabled: true
                        Accessible.name: modelData
                        Accessible.role: Accessible.RadioButton
                        Accessible.checked: example.selectedShape === index
                        onClicked: example.selectedShape = index
                        background: Rectangle {
                            radius: 10
                            color: choice.hovered ? Ui.AppTheme.withAlpha(Ui.AppTheme.text, .025) : "transparent"
                            border.width: example.selectedShape === choice.index || choice.visualFocus ? 2 : 0
                            border.color: Ui.AppTheme.accent
                        }
                        contentItem: ColumnLayout {
                            spacing: 6
                            Ui.SettingsAppearancePreview {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 64
                                Layout.margins: 10
                                Layout.bottomMargin: 0
                                objectName: "settingsAppearancePreview" + choice.index
                                form: choice.index === 0 ? "macos" : "material"
                                windowTitle: example.tr("Settings", "设置")
                                settingTitle: example.tr("Appearance", "外观")
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 12
                                Layout.bottomMargin: 10
                                text: choice.modelData
                                color: Ui.AppTheme.text
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Ui.SettingsItem {
            objectName: "settingsMaterialItem"
            title: example.tr("Material style", "材质风格")
            Controls.LiquidSelect {
                objectName: "settingsMaterialPicker"
                indicatorStyle: "upDown"
                plainTrigger: true
                indicatorBackground: true
                popupMaterialForm: true
                sheetColor: "#f0f0f1"
                popupTextColor: "#1c1c1e"
                neutralOptionHighlight: true
                compactPopup: true
                popupBorderWidth: 0
                popupShadowEnabled: true
                popupFontWeight: Font.Normal
                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: 0
                Layout.preferredHeight: example.settingControlHeight
                materialForm: Ui.AppTheme.reduceTransparency || example.selectedShape === 1
                backdrop: groupBackdrop
                model: [example.tr("Liquid", "液态玻璃"), example.tr("Soft light", "柔光玻璃"), example.tr("Frosted", "磨砂玻璃")]
                currentIndex: example.selectedMaterial

                textColor: Ui.AppTheme.dark ? Ui.AppTheme.text : "#000000"

                onActivated: index => example.selectedMaterial = index
                Accessible.name: example.tr("Material style", "材质风格")
            }
        }

        Ui.SettingsItem {
            objectName: "settingsBlurItem"
            title: example.tr("Blur strength", "模糊强度")
            description: example.tr("Soften the content behind liquid controls.", "柔化液态组件背后的内容。")
            Text {
                text: Math.round(example.blurValue * 100) + "%"
                color: Ui.AppTheme.mutedText
                font.pixelSize: 11
                Layout.preferredWidth: 32
                horizontalAlignment: Text.AlignRight
            }
            Controls.LiquidSlider {
                objectName: "settingsBlurSlider"
                Layout.preferredWidth: 170
                Layout.minimumWidth: 80
                Layout.preferredHeight: example.settingControlHeight
                thumbWidth: 26
                thumbHeight: 14
                trackHeight: 4
                value: example.blurValue
                materialForm: Ui.AppTheme.reduceTransparency || example.selectedShape === 1
                Accessible.name: example.tr("Blur strength", "模糊强度")
                onPreviewChanged: value => example.blurValue = value
                onCommitRequested: value => {
                    example.blurValue = value;
                    example.savedBlur = value;
                }
                onCanceled: example.blurValue = example.savedBlur
            }
        }

        Ui.SettingsItem {
            objectName: "settingsLiquidItem"
            title: example.tr("Liquid strength", "液态强度")
            description: example.tr("Adjust refraction and highlights.", "调整折射与高光的强弱。")
            Text {
                text: Math.round(example.liquidValue * 100) + "%"
                color: Ui.AppTheme.mutedText
                font.pixelSize: 11
                Layout.preferredWidth: 32
                horizontalAlignment: Text.AlignRight
            }
            Controls.LiquidSlider {
                objectName: "settingsLiquidSlider"
                Layout.preferredWidth: 170
                Layout.minimumWidth: 80
                Layout.preferredHeight: example.settingControlHeight
                thumbWidth: 26
                thumbHeight: 14
                trackHeight: 4
                refractionStrength: 1 + example.liquidValue * 4
                value: example.liquidValue
                materialForm: Ui.AppTheme.reduceTransparency || example.selectedShape === 1
                Accessible.name: example.tr("Liquid strength", "液态强度")
                onPreviewChanged: value => example.liquidValue = value
                onCommitRequested: value => {
                    example.liquidValue = value;
                    example.savedLiquid = value;
                }
                onCanceled: example.liquidValue = example.savedLiquid
            }
        }
    }

    Ui.SettingsGroup {
        visible: example.showVariants
        title: example.tr("Description and availability", "说明与可用状态")
        Ui.SettingsItem {
            title: example.tr("Follow system appearance", "跟随系统外观")
            description: example.tr("An optional description uses smaller, lighter text and wraps without a second heading.", "可选说明使用更小、更浅的文字，长说明会自动换行，不另加一层标题。")
            Item {
                Layout.preferredWidth: 44
                Layout.preferredHeight: example.settingControlHeight
                Controls.LiquidGlassSwitch {
                    objectName: "settingsFollowSwitch"
                    anchors.centerIn: parent
                    width: 44
                    height: 20
                    checked: example.followAppearance
                    materialForm: Ui.AppTheme.reduceTransparency
                    Accessible.name: example.tr("Follow system appearance", "跟随系统外观")
                    onToggled: checked => example.followAppearance = checked
                }
            }
        }
        Ui.SettingsItem {
            title: example.tr("Switch at sunset", "日落时切换")
            description: example.tr("Available after following system appearance is enabled.", "启用跟随系统外观后可用。")
            enabled: example.followAppearance
            Item {
                Layout.preferredWidth: 44
                Layout.preferredHeight: example.settingControlHeight
                Controls.LiquidGlassSwitch {
                    objectName: "settingsSunsetSwitch"
                    anchors.centerIn: parent
                    width: 44
                    height: 20
                    checked: example.switchAtSunset
                    enabled: example.followAppearance
                    materialForm: Ui.AppTheme.reduceTransparency
                    Accessible.name: example.tr("Switch at sunset", "日落时切换")
                    onToggled: checked => example.switchAtSunset = checked
                }
            }
        }
    }
}
