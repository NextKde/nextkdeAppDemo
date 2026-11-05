#include <QtTest>
#include <QGuiApplication>
#include <QQmlExpression>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QJSValue>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QQuickWindow>
#include <QQuickItem>
#include <QKeyEvent>
#include <cstdlib>
#include <QTemporaryDir>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include "NotesAdapter.h"
#include "TranslationManager.h"

class NotesTest : public QObject {
    Q_OBJECT
private slots:
    void desktopInput();
    void desktopI18n();
    void translationBindings();
    void desktopDeleteTask();
    void deletionAndUndo() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
        const auto id = store.saveNote({}, "Delete me", "Keep my contents");
        const auto original = store.notes();
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/notes.json";
        auto disk = [&] { QFile file(path); return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray(); };
        const auto originalDisk = disk();
        store.setEditorOpen(true);
        QVERIFY(!store.deleteNote(id)); QCOMPARE(store.notes(), original);
        store.setEditorOpen(false);
        QVERIFY(store.saveDraft(id, "Draft", "unsaved", "Delete me", "Keep my contents"));
        QVERIFY(!store.deleteNote(id)); QVERIFY(!store.draft().isEmpty());
        QVERIFY(store.clearDraft());
        qputenv("KOS_NOTES_FAIL_SAVE", "1");
        const bool failedDelete = store.deleteNote(id);
        qunsetenv("KOS_NOTES_FAIL_SAVE");
        QVERIFY(!failedDelete); QCOMPARE(disk(), originalDisk); QVERIFY(!store.canUndoDelete());
        QVERIFY(store.deleteNote(id)); QVERIFY(store.canUndoDelete());
        QCOMPARE(store.notes().size(), original.size() - 1);
        const auto deletedDisk = disk();
        qputenv("KOS_NOTES_FAIL_SAVE", "1");
        const auto failedUndo = store.undoDelete();
        const bool failedSecondDelete = store.deleteNote("welcome");
        qunsetenv("KOS_NOTES_FAIL_SAVE");
        QVERIFY(failedUndo.isEmpty()); QVERIFY(!failedSecondDelete);
        QVERIFY(store.canUndoDelete()); QCOMPARE(disk(), deletedDisk);
        QCOMPARE(store.undoDelete(), id); QCOMPARE(store.notes(), original);
        QCOMPARE(disk(), originalDisk); QVERIFY(!store.canUndoDelete());
        QVERIFY(store.deleteNote(id)); QVERIFY(store.deleteNote("welcome"));
        QCOMPARE(store.undoDelete(), QString("welcome"));
        QCOMPARE(store.notes().size(), 1); // Only the latest successful deletion is undoable.
        QVERIFY(store.deleteNote("welcome"));
        store.reload(); QTRY_COMPARE(store.state(), QString("ready"));
        QVERIFY(store.notes().isEmpty()); QVERIFY(!store.canUndoDelete());
    }
    void deletionSelectionAndEditor() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
        const auto id = store.saveNote({}, "Alpha", "body");
        QQmlApplicationEngine engine;
        TranslationManager translations(&store, &engine);
        engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
        engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
        auto root = engine.rootObjects().first();
        root->setProperty("selectedId", id); root->setProperty("deletionTarget", id);
        root->findChild<QObject*>("search")->setProperty("text", "no match");
        QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, QVariant())));
        auto editor = root->findChild<QObject*>("editor");
        auto title = editor->findChild<QObject*>("titleField"); title->setProperty("text", "Uncheckpointed draft");
        QVERIFY(store.editorOpen());
        QVERIFY(QMetaObject::invokeMethod(root, "confirmDeletion"));
        QCOMPARE(root->property("selectedId").toString(), id);
        QCOMPARE(title->property("text").toString(), QString("Uncheckpointed draft"));
        QVERIFY(QMetaObject::invokeMethod(editor, "finishClose"));
        QTRY_VERIFY(!store.editorOpen());
        QVERIFY(QMetaObject::invokeMethod(root, "confirmDeletion"));
        QVERIFY(root->property("selectedId").toString().isEmpty());
        QVERIFY(QMetaObject::invokeMethod(root, "undoDeletion"));
        QCOMPARE(root->property("selectedId").toString(), id);
        root->findChild<QObject*>("search")->setProperty("text", "");
        QTRY_COMPARE(root->findChild<QObject*>("noteList")->property("currentIndex").toInt(), 0);
    }
    void asynchronousSampleTask() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
        const auto notes = store.notes();
        store.startTask(true); QCOMPARE(store.taskProgress(), 0);
        QTRY_COMPARE(store.taskState(), QString("failed")); QVERIFY(store.taskResult().isEmpty());
        store.retryTask(); QTRY_COMPARE(store.taskState(), QString("succeeded"));
        QCOMPARE(store.taskProgress(), 100); QCOMPARE(store.taskResult().size(), 3);
        store.startTask(); QTRY_VERIFY(store.taskProgress() > 0);
        store.cancelTask(); const auto cancelledProgress = store.taskProgress();
        QTest::qWait(400); QCOMPARE(store.taskState(), QString("cancelled"));
        QCOMPARE(store.taskProgress(), cancelledProgress); QVERIFY(store.taskResult().isEmpty());
        // Restart before the old failure callback runs: old generations cannot
        // advance progress, fail, or publish results into the replacement request.
        store.startTask(true); store.startTask(false);
        QTRY_COMPARE(store.taskState(), QString("succeeded")); QCOMPARE(store.taskProgress(), 100);
        QCOMPARE(store.notes(), notes);
        QVERIFY(!QFile::exists(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/notes.json"));
        auto transient = new NotesAdapter;
        transient->startTask(); delete transient;
        QTest::qWait(400); // Context-bound pending callback must not use a dead adapter.
    }

    void persistence() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        QByteArray durable;
        {
            NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
            const auto id = store.saveNote({}, "  First  ", "line one\nline two");
            QVERIFY(!id.isEmpty());
            QCOMPARE(store.notes().first().toMap().value("title").toString(), QString("First"));
            const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/notes.json";
            QFile file(path); QVERIFY(file.open(QIODevice::ReadOnly)); durable = file.readAll(); file.close();
            qputenv("KOS_NOTES_FAIL_SAVE", "1");
            QVERIFY(store.saveNote(id, "replacement", "bad").isEmpty());
            QVERIFY(!store.savePreferences("dark", "zh", true));
            qunsetenv("KOS_NOTES_FAIL_SAVE");
            QVERIFY(file.open(QIODevice::ReadOnly)); QCOMPARE(file.readAll(), durable); file.close();
            QVERIFY(store.saveNote(id, "", "body").isEmpty());
            QVERIFY(store.saveNote("missing", "title", "body").isEmpty());
            QVERIFY(store.savePreferences("dark", "zh", true));
        }
        {
            NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
            QCOMPARE(store.preferences().value("language").toString(), QString("zh"));
            const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/notes.json";
            QFile file(path); QVERIFY(file.open(QIODevice::WriteOnly)); file.write("broken"); file.close();
            store.reload(); QTRY_COMPARE(store.state(), QString("failed"));
            QVERIFY(store.saveNote({}, "title", "body").isEmpty());
            QVERIFY(file.open(QIODevice::ReadOnly)); QCOMPARE(file.readAll(), QByteArray("broken")); file.close();
            QVERIFY(file.open(QIODevice::WriteOnly)); file.write(durable); file.close();
            store.reload(); QTRY_COMPARE(store.state(), QString("ready"));
            QVERIFY(QFile::remove(path)); QVERIFY(QDir().mkdir(path));
            QVERIFY(store.saveNote({}, "real failure", "body").isEmpty());
        }
    }
    void commitCrash_data() {
        QTest::addColumn<QString>("scenario");
        for (const auto &name : {"new", "edit", "uncommitted", "failed", "again", "legacy", "same-text", "legacy-failed"})
            QTest::newRow(name) << QString::fromLatin1(name);
    }
    void commitCrash() {
        QFETCH(QString, scenario);
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        QProcess child;
        child.start(QCoreApplication::applicationFilePath(), {"--commit-crash", scenario});
        QVERIFY(child.waitForFinished());
        QCOMPARE(child.exitCode(), 73); // Only reached via _Exit, never normal close/destructors.
        const auto base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QFile checkpoint(base + "/draft.json"); QVERIFY(checkpoint.open(QIODevice::ReadOnly));
        const auto before = checkpoint.readAll(); QVERIFY(before.contains("Checkpoint")); checkpoint.close();
        const bool pending = scenario == "uncommitted" || scenario == "failed" || scenario == "again" || scenario == "same-text" || scenario == "legacy-failed";
        {
            // An acknowledged checkpoint is suppressed even when cleanup fails.
            qputenv("KOS_NOTES_FAIL_CLEAR_DRAFT", "1");
            NotesAdapter recovered; QTRY_COMPARE(recovered.state(), QString("ready"));
            qunsetenv("KOS_NOTES_FAIL_CLEAR_DRAFT");
            QCOMPARE(!recovered.draft().isEmpty(), pending);
            if (pending) {
                QCOMPARE(recovered.draft().value("title").toString(), QString("Checkpoint"));
                if (scenario == "again") QCOMPARE(recovered.draft().value("body").toString(), QString("Next edit"));
            } else {
                QCOMPARE(recovered.draftError(), QString("remove"));
                const auto notes = recovered.notes();
                QCOMPARE(notes.size(), scenario == "edit" ? 1 : 2);
                QCOMPARE(notes.first().toMap().value("title").toString(), QString("Latest saved"));
                QCOMPARE(notes.first().toMap().value("body").toString(), QString("Beyond checkpoint"));
                if (scenario == "edit") QCOMPARE(notes.first().toMap().value("id").toString(), QString("welcome"));
                QVERIFY(recovered.clearDraft());
            }
        }
        NotesAdapter restarted; QTRY_COMPARE(restarted.state(), QString("ready"));
        QCOMPARE(!restarted.draft().isEmpty(), pending);
        if (!pending) QVERIFY(!QFile::exists(base + "/draft.json"));
    }
    void lockAndRecovery() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        {
            NotesAdapter owner; QTRY_COMPARE(owner.state(), QString("ready"));
            QProcess contender; contender.start(QCoreApplication::applicationFilePath(), {"--lock-probe"});
            QVERIFY(contender.waitForFinished()); QCOMPARE(contender.exitCode(), 0);
            QVERIFY(owner.saveDraft("welcome", "draft title", "draft body", "Welcome / 欢迎", "original"));
            qputenv("KOS_NOTES_FAIL_DRAFT", "1");
            QVERIFY(!owner.saveDraft({}, "failed update", "body", "", ""));
            qunsetenv("KOS_NOTES_FAIL_DRAFT");
            QCOMPARE(owner.draft().value("title").toString(), QString("draft title"));
        }
        {
            NotesAdapter recovered; QTRY_COMPARE(recovered.state(), QString("ready"));
            QCOMPARE(recovered.draft().value("title").toString(), QString("draft title"));
            QVERIFY(recovered.clearDraft()); QVERIFY(recovered.draft().isEmpty());
        }
        QProcess crash; crash.start(QCoreApplication::applicationFilePath(), {"--draft-crash"});
        QVERIFY(crash.waitForFinished()); QCOMPARE(crash.exitCode(), 0);
        {
            NotesAdapter recovered; QTRY_COMPARE(recovered.state(), QString("ready"));
            QCOMPARE(recovered.draft().value("title").toString(), QString("Crash draft"));
            QQmlApplicationEngine engine;
            TranslationManager translations(&recovered, &engine);
            engine.setInitialProperties({{"store", QVariant::fromValue(&recovered)}});
            engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
            auto editor = engine.rootObjects().first()->findChild<QObject*>("editor");
            QTRY_VERIFY(editor->property("visible").toBool());
            QVERIFY(editor->property("dirty").toBool());
            QCOMPARE(editor->findChild<QObject*>("titleField")->property("text").toString(), QString("Crash draft"));
        }
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/draft.json";
        QFile file(path); QVERIFY(file.open(QIODevice::WriteOnly)); file.write("broken draft"); file.close();
        NotesAdapter broken; QTRY_COMPARE(broken.state(), QString("ready"));
        QVERIFY(!broken.draftError().isEmpty());
        QVERIFY(!broken.saveDraft({}, "new", "body", "", ""));
        QVERIFY(file.open(QIODevice::ReadOnly)); QCOMPARE(file.readAll(), QByteArray("broken draft")); file.close();
        QVERIFY(broken.clearDraft()); QVERIFY(broken.saveDraft({}, "new", "body", "", ""));
    }
    void revertedClose_data() {
        QTest::addColumn<bool>("quit");
        QTest::newRow("editor-close") << false;
        QTest::newRow("application-quit") << true;
    }
    void revertedClose() {
        QFETCH(bool, quit);
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/draft.json";
        {
            NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
            QQmlApplicationEngine engine;
            TranslationManager translations(&store, &engine);
            engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
            engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
            auto root = engine.rootObjects().first();
            auto editor = root->findChild<QObject*>("editor");
            QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, store.notes().first())));
            auto title = editor->findChild<QObject*>("titleField");
            const auto original = title->property("text");
            title->setProperty("text", "Reverted edit");
            QTRY_COMPARE(store.draft().value("title").toString(), QString("Reverted edit"));
            QVERIFY(QFile::exists(path));
            title->setProperty("text", original);
            QVERIFY(!editor->property("dirty").toBool());
            // Close synchronously, before the next 600 ms checkpoint.
            QVERIFY(QMetaObject::invokeMethod(quit ? root : editor, "close"));
            QVERIFY(!editor->property("visible").toBool());
            if (quit) QTRY_VERIFY(!root->property("visible").toBool());
            QVERIFY(!QFile::exists(path)); QVERIFY(store.draft().isEmpty());
        }
        NotesAdapter restarted; QTRY_COMPARE(restarted.state(), QString("ready"));
        QVERIFY(restarted.draft().isEmpty());
        QQmlApplicationEngine engine;
        TranslationManager translations(&restarted, &engine);
        engine.setInitialProperties({{"store", QVariant::fromValue(&restarted)}});
        engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
        QVERIFY(!engine.rootObjects().first()->findChild<QObject*>("editor")->property("visible").toBool());
    }
    void cleanupFailure_data() {
        QTest::addColumn<bool>("realFailure");
        QTest::newRow("injected-remove-failure") << false;
        QTest::newRow("real-path-remove-failure") << true;
    }
    void cleanupFailure() {
        QFETCH(bool, realFailure);
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/draft.json";
        QString savedId;
        {
            NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
            QQmlApplicationEngine engine;
            TranslationManager translations(&store, &engine);
            engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
            engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
            auto root = engine.rootObjects().first();
            auto editor = root->findChild<QObject*>("editor");
            auto decision = editor->findChild<QObject*>("decision");
            QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, QVariant())));
            editor->findChild<QObject*>("titleField")->setProperty("text", "Committed once");
            QTRY_COMPARE(store.draft().value("title").toString(), QString("Committed once"));
            if (realFailure) {
                QVERIFY(QFile::rename(path, path + ".held"));
                QVERIFY(QDir().mkdir(path)); // QFile::remove cannot remove a directory.
            } else qputenv("KOS_NOTES_FAIL_CLEAR_DRAFT", "1");
            QVariant result;
            QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
            QVERIFY(!result.toBool());
            savedId = editor->property("noteId").toString(); QVERIFY(!savedId.isEmpty());
            QCOMPARE(store.notes().size(), 2);
            QCOMPARE(editor->property("originalTitle").toString(), QString("Committed once"));
            QVERIFY(!editor->property("dirty").toBool());
            QVERIFY(editor->property("cleanupPending").toBool());
            QCOMPARE(store.draftError(), QString("remove"));
            // A second Save must only retry cleanup, not create another note.
            QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
            QVERIFY(!result.toBool()); QCOMPARE(store.notes().size(), 2);
            QVERIFY(QMetaObject::invokeMethod(editor, "close"));
            QTRY_VERIFY(decision->property("visible").toBool());
            QVERIFY(editor->property("visible").toBool());
            QVERIFY(QMetaObject::invokeMethod(editor->findChild<QObject*>("cancelClose"), "clicked"));
            QVERIFY(QMetaObject::invokeMethod(root, "close"));
            QTRY_VERIFY(decision->property("visible").toBool());
            QVERIFY(root->property("visible").toBool()); QVERIFY(editor->property("visible").toBool());
            QVERIFY(QMetaObject::invokeMethod(editor->findChild<QObject*>("discardClose"), "clicked"));
            QVERIFY(root->property("visible").toBool()); QVERIFY(editor->property("visible").toBool());
            if (realFailure) {
                QVERIFY(QDir().rmdir(path)); QVERIFY(QFile::rename(path + ".held", path));
            } else qunsetenv("KOS_NOTES_FAIL_CLEAR_DRAFT");
            QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
            QVERIFY(result.toBool()); QVERIFY(!editor->property("cleanupPending").toBool());
            QCOMPARE(editor->property("noteId").toString(), savedId); QCOMPARE(store.notes().size(), 2);
            QVERIFY(!QFile::exists(path)); QVERIFY(store.draft().isEmpty());
            QVERIFY(QMetaObject::invokeMethod(editor->findChild<QObject*>("discardClose"), "clicked"));
            QTRY_VERIFY(!root->property("visible").toBool()); QVERIFY(!editor->property("visible").toBool());
        }
        NotesAdapter restarted; QTRY_COMPARE(restarted.state(), QString("ready"));
        QVERIFY(restarted.draft().isEmpty()); QCOMPARE(restarted.notes().size(), 2);
        QCOMPARE(restarted.notes().first().toMap().value("id").toString(), savedId);
        QCOMPARE(restarted.notes().first().toMap().value("title").toString(), QString("Committed once"));
    }
    void lifecycle() {
        QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
        NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
        const auto id = store.saveNote({}, "Alpha", "body");
        QQmlApplicationEngine engine;
        TranslationManager translations(&store, &engine);
        engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
        engine.loadFromModule("Kos.Notes", "Main");
        QVERIFY(!engine.rootObjects().isEmpty());
        auto root = engine.rootObjects().first();
        auto search = root->findChild<QObject*>("search");
        auto editor = root->findChild<QObject*>("editor");
        QVERIFY(search); QVERIFY(editor);
        root->setProperty("selectedId", id); search->setProperty("text", "no match");
        QTRY_COMPARE(root->property("selectedId").toString(), id);
        QCOMPARE(root->property("filtered").value<QJSValue>().property("length").toInt(), 0);
        search->setProperty("text", "");
        QTRY_COMPARE(root->findChild<QObject*>("noteList")->property("currentIndex").toInt(), 0);
        QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, QVariant())));
        auto title = editor->findChild<QObject*>("titleField"); QVERIFY(title);
        title->setProperty("text", "Draft");
        QTRY_VERIFY(editor->property("dirty").toBool());
        QTRY_COMPARE(store.draft().value("title").toString(), QString("Draft"));
        if (qEnvironmentVariableIsSet("KOS_NOTES_CAPTURE_DIR")) {
            QTest::qWait(100);
            const auto captureDir = qEnvironmentVariable("KOS_NOTES_CAPTURE_DIR");
            QVERIFY(qobject_cast<QQuickWindow*>(root)->grabWindow().save(captureDir + "/main-software.png"));
            QVERIFY(qobject_cast<QQuickWindow*>(editor)->grabWindow().save(captureDir + "/editor-software.png"));
        }
        QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, QVariant())));
        QCOMPARE(title->property("text").toString(), QString("Draft"));
        QVERIFY(QMetaObject::invokeMethod(root, "close"));
        auto decision = editor->findChild<QObject*>("decision");
        QTRY_VERIFY(decision->property("visible").toBool());
        qputenv("KOS_NOTES_FAIL_SAVE", "1");
        QVariant result; QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(!result.toBool()); QVERIFY(editor->property("visible").toBool());
        qunsetenv("KOS_NOTES_FAIL_SAVE");
        QVERIFY(QMetaObject::invokeMethod(editor->findChild<QObject*>("cancelClose"), "clicked"));
        QTRY_VERIFY(!editor->property("quitAfterClose").toBool());
        QVERIFY(root->property("visible").toBool());
        QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.toBool()); QVERIFY(!editor->property("dirty").toBool());
        title->setProperty("text", "Save on quit");
        QVERIFY(QMetaObject::invokeMethod(root, "close"));
        QTRY_VERIFY(decision->property("visible").toBool());
        QVERIFY(QMetaObject::invokeMethod(editor, "save", Q_RETURN_ARG(QVariant, result)));
        QVERIFY(result.toBool());
        QVERIFY(QMetaObject::invokeMethod(editor, "finishClose"));
        QTRY_VERIFY(!root->property("visible").toBool());
        QVERIFY(!editor->property("visible").toBool());
        root->setProperty("quitting", false);
        QVERIFY(QMetaObject::invokeMethod(root, "show"));
        QVERIFY(QMetaObject::invokeMethod(root, "begin", Q_ARG(QVariant, QVariant())));
        title->setProperty("text", "Discard me");
        QVERIFY(QMetaObject::invokeMethod(root, "close"));
        QTRY_VERIFY(decision->property("visible").toBool());
        QVERIFY(QMetaObject::invokeMethod(editor->findChild<QObject*>("discardClose"), "clicked"));
        QTRY_VERIFY(!editor->property("visible").toBool());
        QTRY_VERIFY(!root->property("visible").toBool());
        QVERIFY(store.draft().isEmpty());
    }
};
#include "desktop_input.h"
#include "desktop_i18n.h"
#include "translation_bindings.h"
#include "desktop_delete_task.h"
int main(int argc, char **argv) {
    QGuiApplication app(argc, argv); app.setQuitOnLastWindowClosed(false);
    app.setOrganizationName("NextKdeExamples"); app.setApplicationName("KosNotesTests");
    if (app.arguments().contains("--commit-crash")) {
        NotesAdapter store;
        QTimer::singleShot(500, &app, [&] {
            if (store.state() != "ready") std::_Exit(80);
            const auto scenario = app.arguments().last();
            const QString id = scenario == "edit" ? QString("welcome") : QString();
            if (!store.saveDraft(id, "Checkpoint", "Older body", "", "")) std::_Exit(81);
            if (scenario == "legacy" || scenario == "legacy-failed") {
                const auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/draft.json";
                QFile file(path); if (!file.open(QIODevice::ReadOnly)) std::_Exit(82);
                auto obj = QJsonDocument::fromJson(file.readAll()).object(); file.close(); obj.remove("token");
                if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) std::_Exit(83);
                file.write(QJsonDocument(obj).toJson()); file.close(); store.reload();
            }
            QTimer::singleShot(300, &app, [&store, scenario, id] {
                if (scenario == "uncommitted") std::_Exit(73);
                if (scenario == "same-text") {
                    const auto savedId = store.saveNote(id, "Checkpoint", "Older body");
                    if (savedId.isEmpty() || !store.clearDraft()
                        || !store.saveDraft(savedId, "Checkpoint", "Older body", "Checkpoint", "Older body")) std::_Exit(88);
                    std::_Exit(73);
                }
                if (scenario == "legacy-failed") qputenv("KOS_NOTES_FAIL_DRAFT", "1");
                if (scenario == "failed") qputenv("KOS_NOTES_FAIL_SAVE", "1");
                const auto saved = store.saveNote(id, "Latest saved", "Beyond checkpoint");
                if (scenario == "failed" || scenario == "legacy-failed") std::_Exit(saved.isEmpty() ? 73 : 84);
                if (saved.isEmpty()) std::_Exit(85);
                // Crash precisely after saveNote returns, without clearDraft or editor close.
                if (scenario == "again" && !store.saveDraft(saved, "Checkpoint", "Next edit", "Latest saved", "Beyond checkpoint"))
                    std::_Exit(86);
                std::_Exit(73);
            });
        });
        QTimer::singleShot(5000, &app, [] { std::_Exit(87); });
        return app.exec();
    }
    if (app.arguments().contains("--lock-probe") || app.arguments().contains("--draft-crash")) {
        NotesAdapter store;
        QObject::connect(&store, &NotesAdapter::changed, &app, [&] {
            if (app.arguments().contains("--lock-probe") && store.state() == "failed")
                app.exit(store.error() == "locked" ? 0 : 2);
            if (app.arguments().contains("--draft-crash") && store.state() == "ready") {
                const bool saved = store.saveDraft({}, "Crash draft", "unsaved body", "", "");
                std::_Exit(saved ? 0 : 3); // Deliberately skip destructors: stale lock + recovery.
            }
        });
        QTimer::singleShot(3000, &app, [&] { app.exit(4); });
        return app.exec();
    }
    NotesTest tests; return QTest::qExec(&tests, argc, argv);
}
#include "tst_notes.moc"
