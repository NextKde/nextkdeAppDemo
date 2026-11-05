// Included by tst_notes.cpp. Opt-in visible-window tests; no application method
// invocation or text-property writes stand in for keyboard/pointer interaction.
void NotesTest::desktopInput() {
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
    main->setPosition(100,100); main->requestActivate();
    QVERIFY(QTest::qWaitForWindowExposed(main)); QTest::qWait(300);
    qInfo() << "Desktop platform/DPR/window" << QGuiApplication::platformName() << main->devicePixelRatio() << main->size() << main->winId();
    auto item = [&](QObject *scope, const char *name) { return scope->findChild<QQuickItem*>(name); };
    auto click = [&](QQuickItem *target) {
        Q_ASSERT(target); auto w=target->window(); w->requestActivate(); QTest::qWait(80);
        QTest::mouseClick(w, Qt::LeftButton, Qt::NoModifier, target->mapToScene(QPointF(target->width()/2,target->height()/2)).toPoint()); QTest::qWait(180);
    };
    auto key = [&](QQuickWindow *w, Qt::Key k, Qt::KeyboardModifiers m=Qt::NoModifier) {
        w->raise(); w->requestActivate();
        if(QGuiApplication::platformName()=="xcb") { QProcess::execute("xdotool",{"windowactivate","--sync",QString::number(w->winId())}); QProcess::execute("xdotool",{"windowfocus","--sync",QString::number(w->winId())}); }
        QTRY_VERIFY_WITH_TIMEOUT(w->isActive(),3000);
        QTRY_COMPARE_WITH_TIMEOUT(QGuiApplication::focusWindow(),w,3000);
        QTest::keyClick(w,k,m); QTest::qWait(120);
    };
    auto type = [&](QQuickWindow *w,const QString &text) {
        QTRY_VERIFY_WITH_TIMEOUT(w->isActive(),3000);
        QVERIFY(w->activeFocusItem());
        for (const auto ch:text) {
            if(ch=='\n') QTest::keyClick(w,Qt::Key_Return);
            else { QKeyEvent press(QEvent::KeyPress,0,Qt::NoModifier,QString(ch)); QGuiApplication::sendEvent(w,&press); QKeyEvent release(QEvent::KeyRelease,0,Qt::NoModifier,QString(ch)); QGuiApplication::sendEvent(w,&release); }
        }
        QTest::qWait(120);
    };
    auto footerGeometry = [&](QObject *dialog, QQuickItem *last) {
        QTest::qWait(350);
        const auto origin=last->mapToScene(QPointF(0,0));
        const auto right=dialog->property("x").toReal()+dialog->property("width").toReal();
        const auto bottom=dialog->property("y").toReal()+dialog->property("height").toReal();
        QVERIFY(qAbs(right-origin.x()-last->width()-24)<1.1);
        QVERIFY(qAbs(bottom-origin.y()-last->height()-24)<1.1);
        QCOMPARE(qRound(last->height()),30);
    };
    const auto captures=qEnvironmentVariable("KOS_NOTES_CAPTURE_DIR");
    auto shot = [&](QQuickWindow *w,const QString &name) { QTest::qWait(400); if(!captures.isEmpty()) { const auto im=w->grabWindow(); if(!im.save(captures+"/"+name+".png")) qFatal("capture failed"); } qInfo()<<"CAPTURE"<<name<<w->size()<<w->devicePixelRatio(); };
    click(item(main,"newNote")); QTRY_VERIFY(editor->isVisible()); editor->setPosition(160,160);
    auto title=item(editor,"titleField"); auto body=item(editor,"bodyField"); QVERIFY(title); QVERIFY(body);
    const auto longTitle=QString("Desktop note / 中文标题 ")+QString("Long title detail ").repeated(12);
    type(editor,longTitle); QCOMPARE(title->property("text").toString(),longTitle);
    key(editor,Qt::Key_Tab); QVERIFY(body->hasActiveFocus());
    QString detail; for(int n=0;n<25;++n) detail+=QString("Line %1: Actual background detail 中文文字, saved using keyboard.\n").arg(n);
    type(editor,detail); QCOMPARE(body->property("text").toString(),detail);
    key(editor,Qt::Key_S,Qt::ControlModifier); QTRY_VERIFY(!editor->property("dirty").toBool());
    const auto id=editor->property("noteId").toString(); QVERIFY(!id.isEmpty()); shot(editor,"editor-saved");
    QTest::mouseClick(editor,Qt::LeftButton,Qt::NoModifier,QPoint(editor->width()-79,18)); QTRY_COMPARE(editor->visibility(),QWindow::Maximized);
    QTest::mouseClick(editor,Qt::LeftButton,Qt::NoModifier,QPoint(editor->width()-79,18)); QTRY_COMPARE(editor->visibility(),QWindow::Windowed);
    QTest::mouseClick(editor,Qt::LeftButton,Qt::NoModifier,QPoint(editor->width()-51,18)); QTRY_COMPARE(editor->visibility(),QWindow::Minimized); editor->showNormal(); QTRY_COMPARE(editor->visibility(),QWindow::Windowed);
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-51,18)); QTRY_COMPARE(main->visibility(),QWindow::Minimized); QVERIFY(editor->isVisible()); main->showNormal(); QTRY_COMPARE(main->visibility(),QWindow::Windowed);
    key(editor,Qt::Key_W,Qt::ControlModifier); QTRY_VERIFY(!editor->isVisible());
    key(main,Qt::Key_F,Qt::ControlModifier); type(main,"nonmatching");
    QCOMPARE(main->property("selectedId").toString(),id); QCOMPARE(main->property("filtered").value<QJSValue>().property("length").toInt(),0); shot(main,"filter-retains-selection");
    key(main,Qt::Key_A,Qt::ControlModifier); key(main,Qt::Key_Backspace);
    auto list=item(main,"noteList"); QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,list->mapToScene(QPointF(50,16)).toPoint());
    key(main,Qt::Key_Down); QCOMPARE(main->property("selectedId").toString(),QString("welcome"));
    key(main,Qt::Key_Up); QCOMPARE(main->property("selectedId").toString(),id); shot(main,"keyboard-selection");
    click(item(main,"editNote")); QTRY_VERIFY(editor->isVisible()); click(body); key(editor,Qt::Key_End,Qt::ControlModifier); type(editor,"Pending change");
    key(editor,Qt::Key_Q,Qt::ControlModifier); auto decision=editor->findChild<QObject*>("decision"); QTRY_VERIFY(decision->property("visible").toBool()); footerGeometry(decision,item(editor,"saveClose")); shot(editor,"gpu-dialog-text-background");
    key(editor,Qt::Key_Escape); QTRY_VERIFY(!decision->property("visible").toBool()); QVERIFY(main->isVisible()); QVERIFY(editor->isVisible()); QVERIFY(editor->property("dirty").toBool());
    key(editor,Qt::Key_Q,Qt::ControlModifier); click(item(editor,"cancelClose")); QTRY_VERIFY(!decision->property("visible").toBool()); QVERIFY(!editor->property("quitAfterClose").toBool());
    qputenv("KOS_NOTES_FAIL_SAVE","1"); key(editor,Qt::Key_Q,Qt::ControlModifier); click(item(editor,"saveClose"));
    QVERIFY(editor->isVisible()); QVERIFY(main->isVisible()); QVERIFY(editor->property("dirty").toBool()); QCOMPARE(editor->property("status").toString(),QString("failed")); shot(editor,"quit-save-failed");
    click(item(editor,"cancelClose")); qunsetenv("KOS_NOTES_FAIL_SAVE");
    key(editor,Qt::Key_Q,Qt::ControlModifier); click(item(editor,"saveClose")); QTRY_VERIFY(!editor->isVisible()); QTRY_VERIFY(!main->isVisible()); QVERIFY(store.draft().isEmpty());
    // Reset the test fixture after exit; each close decision above used real input.
    engine.clearComponentCache(); main->setProperty("quitting",false); main->show(); main->requestActivate(); QTest::qWait(200);
    click(item(main,"newNote")); type(editor,"Discard from editor Quit"); key(editor,Qt::Key_Q,Qt::ControlModifier); click(item(editor,"discardClose")); QTRY_VERIFY(!editor->isVisible()); QTRY_VERIFY(!main->isVisible()); QCOMPARE(store.notes().size(),2);
    main->setProperty("quitting",false); main->show(); main->requestActivate(); QTest::qWait(200);
    auto prefs=main->findChild<QObject*>("preferences"); QVERIFY(prefs);
    click(item(main,"settingsButton")); QTRY_VERIFY(prefs->property("visible").toBool());
    footerGeometry(prefs,item(prefs,"savePreferences")); click(item(prefs,"themeSelect")); key(main,Qt::Key_End); key(main,Qt::Key_Return); QCOMPARE(prefs->property("draftTheme").toString(),QString("dark"));
    click(item(prefs,"languageSelect")); key(main,Qt::Key_End); key(main,Qt::Key_Return); QCOMPARE(prefs->property("draftLanguage").toString(),QString("zh"));
    click(item(prefs,"cancelPreferences")); QCOMPARE(store.preferences().value("theme").toString(),QString("system"));
    click(item(main,"settingsButton")); QCOMPARE(prefs->property("draftTheme").toString(),QString("system")); key(main,Qt::Key_Escape); QTRY_VERIFY(!prefs->property("visible").toBool());
    click(item(main,"settingsButton")); click(item(prefs,"themeSelect")); key(main,Qt::Key_End); key(main,Qt::Key_Return); click(item(prefs,"languageSelect")); key(main,Qt::Key_End); key(main,Qt::Key_Return);
    qputenv("KOS_NOTES_FAIL_SAVE","1"); click(item(prefs,"savePreferences")); QVERIFY(prefs->property("failed").toBool()); QCOMPARE(store.preferences().value("theme").toString(),QString("system")); shot(main,"settings-failed"); qunsetenv("KOS_NOTES_FAIL_SAVE");
    click(item(prefs,"savePreferences")); QTRY_COMPARE(store.preferences().value("theme").toString(),QString("dark")); QCOMPARE(store.preferences().value("language").toString(),QString("zh"));
    click(item(main,"settingsButton")); click(item(prefs,"themeSelect")); shot(main,"dark-chinese-menu"); key(main,Qt::Key_Escape); key(main,Qt::Key_Escape);
    main->resize(main->minimumWidth(),main->minimumHeight()); QTest::qWait(200); shot(main,"main-minimum-dark-chinese");
    click(item(main,"settingsButton")); shot(main,"settings-minimum-dark-chinese"); click(item(prefs,"reducedSwitch")); click(item(prefs,"savePreferences")); QTRY_VERIFY(store.preferences().value("reduced").toBool());
    click(item(main,"editNote")); QTRY_VERIFY(editor->isVisible()); editor->resize(editor->minimumWidth(),editor->minimumHeight()); click(body); type(editor," Reduced fallback"); key(editor,Qt::Key_Q,Qt::ControlModifier); shot(editor,"dialog-reduced-minimum-dark-chinese"); key(editor,Qt::Key_Escape); key(editor,Qt::Key_S,Qt::ControlModifier); key(editor,Qt::Key_W,Qt::ControlModifier);
    // The same scene and text in normal/reduced modes permits a meaningful material comparison.
    main->resize(960,660); click(item(main,"settingsButton")); click(item(prefs,"themeSelect")); key(main,Qt::Key_Home); key(main,Qt::Key_Down); key(main,Qt::Key_Return); click(item(prefs,"savePreferences"));
    click(item(main,"settingsButton")); shot(main,"light-reduced-text-background"); click(item(prefs,"reducedSwitch")); click(item(prefs,"savePreferences")); click(item(main,"settingsButton")); shot(main,"light-glass-text-background"); key(main,Qt::Key_Escape);
    // Configuring alternate declarations is fixture setup; actions are actual mouse clicks.
    main->setProperty("windowActions",QStringList{"close"}); QTest::qWait(200); shot(main,"controls-one");
    QTest::mouseDClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(200,18)); QCOMPARE(main->visibility(),QWindow::Windowed);
    main->setProperty("windowActions",QStringList{}); QTest::qWait(200); shot(main,"controls-zero");
    for(int offset:{79,51,23}) QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-offset,18)); QVERIFY(main->isVisible()); QCOMPARE(main->visibility(),QWindow::Windowed);
    main->setProperty("windowActions",QStringList{"close","minimize","maximize"}); QTest::qWait(200); shot(main,"controls-reordered");
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-23,18)); QTRY_COMPARE(main->visibility(),QWindow::Maximized); shot(main,"maximized");
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-23,18)); QTRY_COMPARE(main->visibility(),QWindow::Windowed);
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-51,18)); QTRY_COMPARE(main->visibility(),QWindow::Minimized); main->showNormal(); main->requestActivate(); QTRY_COMPARE(main->visibility(),QWindow::Windowed);
    main->setProperty("windowActions",QStringList{"maximize","minimize","close"}); QTest::qWait(200); QTest::mouseDClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(200,18)); QTRY_COMPARE(main->visibility(),QWindow::Maximized); QTest::mouseDClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(200,18)); QTRY_COMPARE(main->visibility(),QWindow::Windowed);
    shot(main,"restored-final");
    // Scoped native X11 geometry operations; do not mistake these for a successful
    // drag when the compositor rejects synthetic seat/pointer events.
    if (QGuiApplication::platformName()=="xcb" && main->devicePixelRatio()==1) {
        const auto wid=QString::number(main->winId());
        const auto pixels=[&](int n){return QString::number(qRound(n*main->devicePixelRatio()));};
        QCOMPARE(QProcess::execute("xdotool",{"windowmove",wid,pixels(220),pixels(240)}),0); QTest::qWait(250);
        qInfo()<<"NATIVE_MOVE"<<main->position(); QCOMPARE(main->position(),QPoint(220,240));
        QCOMPARE(QProcess::execute("xdotool",{"windowsize",wid,pixels(800),pixels(600)}),0); QTest::qWait(250);
        qInfo()<<"NATIVE_RESIZE"<<main->size(); QCOMPARE(main->size(),QSize(800,600));
        const auto before=main->position();
        QTest::mousePress(main,Qt::LeftButton,Qt::NoModifier,QPoint(200,18)); QTest::mouseMove(main,QPoint(260,60),120); QTest::mouseRelease(main,Qt::LeftButton,Qt::NoModifier,QPoint(260,60)); QTest::qWait(250);
        qInfo()<<"SYSTEM_DRAG_INPUT before/after (unchanged means seat restriction)"<<before<<main->position();
        const auto sizeBefore=main->size();
        QTest::mousePress(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-2,main->height()-2)); QTest::mouseMove(main,QPoint(main->width()-50,main->height()-50),120); QTest::mouseRelease(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-50,main->height()-50)); QTest::qWait(250);
        qInfo()<<"SYSTEM_RESIZE_INPUT before/after (unchanged means seat restriction)"<<sizeBefore<<main->size();
    }
    main->setProperty("windowActions",QStringList{"close"}); QTest::qWait(200);
    QTest::mouseClick(main,Qt::LeftButton,Qt::NoModifier,QPoint(main->width()-23,18)); QTRY_VERIFY(!main->isVisible());
}
