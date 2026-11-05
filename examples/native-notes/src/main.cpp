#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include "NotesAdapter.h"
#include "TranslationManager.h"

int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("NextKdeExamples");
    app.setApplicationName("KosNotes");
    app.setDesktopFileName("org.nextkde.KosNotes");
    app.setWindowIcon(QIcon::fromTheme("org.nextkde.KosNotes"));
    NotesAdapter adapter;
    QQmlApplicationEngine engine;
    TranslationManager translations(&adapter, &engine);
    engine.setInitialProperties({{"store", QVariant::fromValue(&adapter)}});
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Kos.Notes", "Main");
    return app.exec();
}
