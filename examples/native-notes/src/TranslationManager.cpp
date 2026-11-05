#include "TranslationManager.h"
#include "NotesAdapter.h"
#include <QCoreApplication>
#include <QLocale>
#include <QQmlEngine>

TranslationManager::TranslationManager(NotesAdapter *store, QQmlEngine *engine)
    : m_store(store), m_engine(engine) {
    connect(store, &NotesAdapter::changed, this, &TranslationManager::apply);
    apply();
}
TranslationManager::~TranslationManager() {
    for (auto translator : {&m_application, &m_qtbase, &m_qtdeclarative})
        QCoreApplication::removeTranslator(translator);
}
void TranslationManager::apply() {
    const auto language = m_store->preferences().value("language").toString();
    if (m_language == language) return;
    m_language = language;
    for (auto translator : {&m_application, &m_qtbase, &m_qtdeclarative})
        QCoreApplication::removeTranslator(translator);
    const auto locale = language == "zh" ? QStringLiteral("zh_CN") : QStringLiteral("en_US");
    QLocale::setDefault(QLocale(locale));
    if (language == "zh") {
        if (!m_qtbase.load(":/i18n/qtbase_zh_CN.qm") || !m_qtdeclarative.load(":/i18n/qtdeclarative_zh_CN.qm"))
            qFatal("Bundled Qt translation catalog missing");
        QCoreApplication::installTranslator(&m_qtbase);
        QCoreApplication::installTranslator(&m_qtdeclarative);
    }
    if (!m_application.load(":/i18n/kos_notes_" + locale + ".qm"))
        qFatal("Bundled application translation catalog missing");
    QCoreApplication::installTranslator(&m_application);
    m_engine->retranslate();
}
