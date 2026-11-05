// Opt-in real visible windows. Language changes go through pointer/key input.
void NotesTest::desktopI18n() {
    if (!qEnvironmentVariableIsSet("KOS_NOTES_DESKTOP_ACCEPTANCE"))
        QSKIP("Requires an explicitly authorized visible desktop session");
    QTemporaryDir dir; qputenv("XDG_DATA_HOME", dir.path().toUtf8());
    {
    NotesAdapter store; QTRY_COMPARE(store.state(), QString("ready"));
    QQmlApplicationEngine engine;
    TranslationManager translations(&store, &engine);
    engine.setInitialProperties({{"store", QVariant::fromValue(&store)}});
    engine.loadFromModule("Kos.Notes", "Main"); QVERIFY(!engine.rootObjects().isEmpty());
    auto main = qobject_cast<QQuickWindow*>(engine.rootObjects().first()); QVERIFY(main);
    auto editor = main->findChild<QQuickWindow*>("editor"); QVERIFY(editor);
    QVERIFY(QTest::qWaitForWindowExposed(main));
    auto item = [](QObject *scope, const char *name) { return scope->findChild<QQuickItem*>(name); };
    auto click = [&](QQuickItem *target) {
        QVERIFY(target); auto window=target->window(); QVERIFY(window); window->requestActivate(); QTest::qWait(100);
        QTest::mouseClick(window,Qt::LeftButton,Qt::NoModifier,target->mapToScene(QPointF(target->width()/2,target->height()/2)).toPoint());
        QTest::qWait(150);
    };
    auto key = [&](QQuickWindow *w, Qt::Key k) { w->requestActivate(); QTest::qWait(100); QTest::keyClick(w,k); QTest::qWait(100); };
    auto shot = [&](QQuickWindow *w, const QString &name) {
        QTest::qWait(250); const auto dest=qEnvironmentVariable("KOS_NOTES_CAPTURE_DIR");
        if (!dest.isEmpty()) QVERIFY(w->grabWindow().save(dest+"/i18n-"+name+".png"));
        qInfo()<<"I18N capture"<<name<<w->size()<<w->devicePixelRatio();
    };
    auto accessible = [&](QQuickWindow *window, const char *name) {
        QQmlExpression expression(qmlContext(window), window,
            QString("windowControls.children.filter(item => item.objectName === '%1')[0].Accessible.name").arg(name));
        const auto value=expression.evaluate();
        if (expression.hasError()) qWarning()<<expression.error();
        return value.toString();
    };
    auto prefs=main->findChild<QObject*>("preferences"); QVERIFY(prefs);
    auto choose = [&](bool chinese) {
        click(item(main,"settingsButton")); click(item(prefs,"languageSelect"));
        key(main,chinese ? Qt::Key_End : Qt::Key_Home); key(main,Qt::Key_Return);
    };
    click(item(main,"newNote")); QTRY_VERIFY(editor->isVisible());
    click(item(editor,"titleField"));
    for (auto ch : QString("My note 中文")) {
        QKeyEvent event(QEvent::KeyPress,0,Qt::NoModifier,QString(ch)); QGuiApplication::sendEvent(editor,&event);
    }
    // Keep a visible failure status while switching language in the other window.
    qputenv("KOS_NOTES_FAIL_SAVE","1");
    QTest::keyClick(editor,Qt::Key_S,Qt::ControlModifier); QTRY_COMPARE(editor->property("status").toString(),QString("failed"));
    choose(true); click(item(prefs,"savePreferences"));
    QVERIFY(prefs->property("failed").toBool()); QCOMPARE(main->title(),QString("Kos Notes")); shot(main,"settings-failure-en");
    qunsetenv("KOS_NOTES_FAIL_SAVE"); click(item(prefs,"cancelPreferences"));
    QCOMPARE(main->title(),QString("Kos Notes"));
    choose(true); click(item(prefs,"savePreferences"));
    QTRY_COMPARE(main->title(),QString("Kos 笔记"));
    QCOMPARE(item(editor,"titleField")->property("text").toString(),QString("My note 中文"));
    QCOMPARE(item(editor,"titleField")->property("placeholderText").toString(),QString("必填"));
    QCOMPARE(editor->property("status").toString(),QString("failed"));
    QCOMPARE(QCoreApplication::translate("KosWindowControls","Minimize"),QString("最小化"));
    QCOMPARE(accessible(main,"windowminimizeButton"),QString("最小化"));
    QCOMPARE(accessible(editor,"windowcloseButton"),QString("关闭"));
    shot(editor,"open-editor-failure-zh");
    click(item(main,"taskExample")); click(item(main,"startTask"));
    QTRY_COMPARE(store.taskState(),QString("succeeded"));
    QTRY_COMPARE(item(main,"taskStatus")->property("text").toString(),QString("已完成，加载了 3 个示例条目。"));
    shot(main,"task-plural-zh"); click(item(main,"closeTask"));
    choose(false); click(item(prefs,"cancelPreferences")); QCOMPARE(main->title(),QString("Kos 笔记"));
    choose(false); click(item(prefs,"savePreferences"));
    QTRY_COMPARE(main->title(),QString("Kos Notes"));
    QCOMPARE(item(editor,"titleField")->property("placeholderText").toString(),QString("Required"));
    QCOMPARE(QCoreApplication::translate("KosWindowControls","Minimize"),QString("Minimize"));
    QCOMPARE(QCoreApplication::translate("TaskDemo","Complete — %n sample item(s) loaded.",nullptr,1),QString("Complete — 1 sample item loaded."));
    QCOMPARE(QCoreApplication::translate("TaskDemo","Complete — %n sample item(s) loaded.",nullptr,3),QString("Complete — 3 sample items loaded."));
    QCOMPARE(accessible(main,"windowminimizeButton"),QString("Minimize"));
    QCOMPARE(accessible(editor,"windowcloseButton"),QString("Close"));
    shot(editor,"open-editor-en");
    choose(true); click(item(prefs,"savePreferences"));
    click(item(main,"settingsButton")); shot(main,"settings-zh"); key(main,Qt::Key_Escape);
    // End the draft via the real close decision; preserve the committed language.
    editor->requestActivate(); QTRY_VERIFY(editor->isActive());
    QTest::keyClick(editor,Qt::Key_W,Qt::ControlModifier);
    QTRY_VERIFY(editor->findChild<QObject*>("decision")->property("visible").toBool());
    click(item(editor,"discardClose"));
    QTRY_VERIFY(!editor->isVisible());
    }
    {
    NotesAdapter store; QTRY_COMPARE(store.state(),QString("ready"));
    QQmlApplicationEngine engine; TranslationManager translations(&store,&engine);
    engine.setInitialProperties({{"store",QVariant::fromValue(&store)}});
    engine.loadFromModule("Kos.Notes","Main"); QVERIFY(!engine.rootObjects().isEmpty());
    QCOMPARE(engine.rootObjects().first()->property("title").toString(),QString("Kos 笔记"));
    QCOMPARE(store.preferences().value("language").toString(),QString("zh"));
    qInfo()<<"I18N restart: persisted Chinese catalog loaded";
    }
}
