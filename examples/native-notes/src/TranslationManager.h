#pragma once
#include <QObject>
#include <QTranslator>
class NotesAdapter;
class QQmlEngine;

// One application-owned translator set per application engine. Preferences are
// observed only after the adapter publishes a successful atomic commit/reload.
class TranslationManager : public QObject {
    Q_OBJECT
public:
    TranslationManager(NotesAdapter *store, QQmlEngine *engine);
    ~TranslationManager() override;
private:
    void apply();
    NotesAdapter *m_store;
    QQmlEngine *m_engine;
    QString m_language;
    QTranslator m_application, m_qtbase, m_qtdeclarative;
};
