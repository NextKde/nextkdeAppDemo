import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls
import "../components" as Sections

ColumnLayout {
    id: galleryExample
    property string language: "en"
    property string sectionPrefix: "01"
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: 16

    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".1"; title: galleryExample.tr("Default", "默认输入") }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Enter text"
        Accessible.name: "Default input"
    }
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".2"; title: galleryExample.tr("Filled", "已填内容") }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        text: "Liquid glass"
        Accessible.name: "Filled input"
    }
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".3"; title: galleryExample.tr("Password", "密码输入") }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Enter password"
        echoMode: TextInput.Password
        Accessible.name: "Password input"
    }
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".4"; title: galleryExample.tr("Read only", "只读") }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        text: "Read-only text"
        readOnly: true
        Accessible.name: "Read-only input"
    }
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".5"; title: galleryExample.tr("Disabled", "禁用") }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Disabled input"
        enabled: false
        Accessible.name: "Disabled input"
    }
}
