// Opt-in desktop acceptance: application actions are driven by visible-window
// mouse/key events. Environment changes below are failure-injection fixtures.
void NotesTest::desktopDeleteTask() {
    if (!qEnvironmentVariableIsSet("KOS_NOTES_DESKTOP_ACCEPTANCE"))
        QSKIP("Requires an explicitly authorized visible desktop session");
    QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
    NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
    QQmlApplicationEngine engine;
    TranslationManager translations(&store, &engine);
    engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
    engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
    auto main = qobject_cast<QQuickWindow*>(engine.rootObjects().first()); QVERIFY(main);
    auto editor = main->findChild<QQuickWindow*>("editor"); QVERIFY(editor);
    main->requestActivate(); QVERIFY(QTest::qWaitForWindowExposed(main));
    qInfo() << "Desktop platform/DPR/window" << QGuiApplication::platformName() << main->devicePixelRatio() << main->size();
    auto item = [&](QObject *scope, const char *name) { return scope->findChild<QQuickItem*>(name); };
    auto click = [&](QQuickItem *target) {
        QVERIFY(target); QVERIFY(target->isVisible()); QVERIFY(target->isEnabled());
        auto window=target->window(); window->requestActivate(); QTest::qWait(80);
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier,
            target->mapToScene(QPointF(target->width()/2,target->height()/2)).toPoint());
        QTest::qWait(100);
    };
    auto key = [&](QQuickWindow *window, Qt::Key k, Qt::KeyboardModifiers modifiers=Qt::NoModifier) {
        window->requestActivate(); QTest::qWait(100); QTest::keyClick(window,k,modifiers); QTest::qWait(100);
    };
    const auto captures=qEnvironmentVariable("KOS_NOTES_CAPTURE_DIR");
    auto shot = [&](const QString &name) {
        QTest::qWait(200);
        if(!captures.isEmpty()) QVERIFY(main->grabWindow().save(captures+"/"+name+".png"));
        qInfo()<<"CAPTURE"<<name;
    };
    auto list=item(main,"noteList"); QVERIFY(list);
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,list->mapToScene(QPointF(50,16)).toPoint());
    QTRY_COMPARE(main->property("selectedId").toString(),QString("welcome"));
    const auto original=store.notes();
    auto deletion=main->findChild<QObject*>("deleteDecision"); QVERIFY(deletion);
    click(item(main,"deleteNote")); QTRY_VERIFY(deletion->property("visible").toBool());
    shot("delete-confirmation"); click(item(main,"cancelDelete"));
    QTRY_VERIFY(!deletion->property("visible").toBool()); QCOMPARE(store.notes(),original);
    click(item(main,"deleteNote")); key(main,Qt::Key_Escape);
    QTRY_VERIFY(!deletion->property("visible").toBool()); QCOMPARE(store.notes(),original);
    click(item(main,"deleteNote")); qputenv("KOS_NOTES_FAIL_SAVE","1");
    click(item(main,"confirmDelete")); qunsetenv("KOS_NOTES_FAIL_SAVE");
    QVERIFY(deletion->property("visible").toBool()); QCOMPARE(store.notes(),original);
    QCOMPARE(main->property("selectedId").toString(),QString("welcome")); shot("delete-failed");
    click(item(main,"confirmDelete")); QTRY_VERIFY(store.notes().isEmpty());
    QVERIFY(main->property("selectedId").toString().isEmpty()); QVERIFY(store.canUndoDelete()); shot("delete-last-note");
    qputenv("KOS_NOTES_FAIL_SAVE","1"); click(item(main,"undoDelete")); qunsetenv("KOS_NOTES_FAIL_SAVE");
    QVERIFY(store.notes().isEmpty()); QVERIFY(store.canUndoDelete()); shot("undo-failed");
    click(item(main,"undoDelete")); QCOMPARE(store.notes(),original);
    QCOMPARE(main->property("selectedId").toString(),QString("welcome"));
    click(item(main,"editNote")); QTRY_VERIFY(editor->isVisible());
    auto title=item(editor,"titleField"); click(title);
    key(editor,Qt::Key_A,Qt::ControlModifier); for (const auto ch:QString("Protected draft")) {
        QKeyEvent press(QEvent::KeyPress,0,Qt::NoModifier,QString(ch)); QGuiApplication::sendEvent(editor,&press);
        QKeyEvent release(QEvent::KeyRelease,0,Qt::NoModifier,QString(ch)); QGuiApplication::sendEvent(editor,&release);
    }
    click(item(main,"deleteNote"));
    QVERIFY(!item(main,"confirmDelete")->isEnabled());
    key(main,Qt::Key_Tab); // The disabled destructive action must remain unavailable.
    QCOMPARE(store.notes(),original); QCOMPARE(title->property("text").toString(),QString("Protected draft"));
    QVERIFY(editor->isVisible()); shot("draft-blocks-delete");
    click(item(main,"cancelDelete")); key(editor,Qt::Key_W,Qt::ControlModifier);
    auto decision=editor->findChild<QObject*>("decision"); QTRY_VERIFY(decision->property("visible").toBool());
    click(item(editor,"discardClose")); QTRY_VERIFY(!editor->isVisible());
    auto task=main->findChild<QObject*>("taskDialog"); QVERIFY(task);
    click(item(main,"taskExample")); QTRY_VERIFY(task->property("visible").toBool());
    click(item(main,"startTask")); QTRY_COMPARE(store.taskState(),QString("succeeded"));
    QCOMPARE(store.taskResult().size(),3); shot("task-success");
    click(item(main,"failTask")); QTRY_COMPARE(store.taskState(),QString("failed")); shot("task-failed");
    click(item(main,"startTask")); QTRY_COMPARE(store.taskState(),QString("succeeded"));
    click(item(main,"startTask")); click(item(main,"cancelTask"));
    QTRY_COMPARE(store.taskState(),QString("cancelled")); QTest::qWait(450);
    QCOMPARE(store.taskState(),QString("cancelled")); QVERIFY(store.taskResult().isEmpty()); shot("task-cancelled");
    click(item(main,"startTask")); click(item(main,"closeTask"));
    QTRY_VERIFY(!task->property("visible").toBool()); QTRY_COMPARE(store.taskState(),QString("cancelled"));
    click(item(main,"taskExample")); click(item(main,"startTask"));
    QTRY_COMPARE(store.taskState(),QString("succeeded")); QCOMPARE(store.notes(),original); shot("task-reopened-success");
    key(main,Qt::Key_Escape); QTRY_VERIFY(!task->property("visible").toBool());
    key(main,Qt::Key_Q,Qt::ControlModifier); QTRY_VERIFY(!main->isVisible());
}
