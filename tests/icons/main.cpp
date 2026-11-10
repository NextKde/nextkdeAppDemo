#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>
#include <QRawFont>
class FontProbe : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE bool supports(const QString &text) const {
        QRawFont font(QStringLiteral(":/qt/qml/Kos/Icons/NextKdeIcons.ttf"), 16);
        if (!font.isValid() || text.isEmpty()) return false;
        const auto glyphs = font.glyphIndexesForString(text);
        for (const auto glyph : glyphs) if (glyph == 0) return false;
        return !glyphs.isEmpty();
    }
};
class Setup : public QObject {
    Q_OBJECT
    FontProbe probe;
public slots:
    void qmlEngineAvailable(QQmlEngine *engine) { engine->rootContext()->setContextProperty("fontProbe", &probe); }
};
QUICK_TEST_MAIN_WITH_SETUP(kos_icons, Setup)
#include "main.moc"
