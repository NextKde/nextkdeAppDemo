#pragma once
#include <QObject>
#include <QStringList>
#include <QLockFile>
#include <memory>
#include <QVariantList>
#include <QVariantMap>

// Confirmed notes and recovery drafts have separate atomic files.
class NotesAdapter : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList notes READ notes NOTIFY changed)
    Q_PROPERTY(QVariantMap preferences READ preferences NOTIFY changed)
    Q_PROPERTY(QString state READ state NOTIFY changed)
    Q_PROPERTY(QString error READ error NOTIFY changed)
    Q_PROPERTY(QVariantMap draft READ draft NOTIFY draftChanged)
    Q_PROPERTY(QString draftError READ draftError NOTIFY draftChanged)
    Q_PROPERTY(bool editorOpen READ editorOpen WRITE setEditorOpen NOTIFY editorOpenChanged)
    Q_PROPERTY(bool canUndoDelete READ canUndoDelete NOTIFY deletionChanged)
    Q_PROPERTY(QString deletionError READ deletionError NOTIFY deletionChanged)
    Q_PROPERTY(QString taskState READ taskState NOTIFY taskChanged)
    Q_PROPERTY(int taskProgress READ taskProgress NOTIFY taskChanged)
    Q_PROPERTY(QStringList taskResult READ taskResult NOTIFY taskChanged)
public:
    bool editorOpen() const { return m_editorOpen; }
    void setEditorOpen(bool open) { if (m_editorOpen == open) return; m_editorOpen = open; emit editorOpenChanged(); }
    bool canUndoDelete() const { return !m_deletedNote.isEmpty(); }
    QString deletionError() const { return m_deletionError; }
    QString taskState() const { return m_taskState; }
    int taskProgress() const { return m_taskProgress; }
    QStringList taskResult() const { return m_taskResult; }
    Q_INVOKABLE bool deleteNote(const QString &id);
    Q_INVOKABLE QString undoDelete();
    Q_INVOKABLE void startTask(bool simulateFailure = false);
    Q_INVOKABLE void cancelTask();
    Q_INVOKABLE void retryTask();
    explicit NotesAdapter(QObject *parent = nullptr);
    QVariantList notes() const { return m_notes; }
    QVariantMap preferences() const { return m_preferences; }
    QString state() const { return m_state; }
    QString error() const { return m_error; }
    QVariantMap draft() const { return m_draft; }
    QString draftError() const { return m_draftError; }
    Q_INVOKABLE bool saveDraft(const QString &id, const QString &title, const QString &body,
                               const QString &originalTitle, const QString &originalBody);
    Q_INVOKABLE bool clearDraft();
    Q_INVOKABLE void reload();
    Q_INVOKABLE QString saveNote(const QString &id, const QString &title, const QString &body);
    Q_INVOKABLE bool savePreferences(const QString &theme, const QString &language, bool reduced);
signals:
    void editorOpenChanged();
    void deletionChanged();
    void taskChanged();
    void changed();
    void draftChanged();
private:
    void scheduleTaskStep(quint64 generation, bool simulateFailure);
    bool m_editorOpen = false;
    QVariantMap m_deletedNote;
    qsizetype m_deletedIndex = 0;
    QString m_deletionError;
    quint64 m_taskGeneration = 0;
    QString m_taskState = "idle";
    int m_taskProgress = 0;
    QStringList m_taskResult;
    void loadDraft();
    QString m_committedDraftToken;
    std::unique_ptr<QLockFile> m_lock;
    QVariantMap m_draft;
    QString m_draftPath, m_draftError;
    bool m_draftInvalid = false;
    bool commit(const QVariantList &notes, const QVariantMap &preferences, const QString &draftToken = {});
    void fail(const QString &code);
    QString m_path, m_state = "loading", m_error;
    QVariantList m_notes;
    QVariantMap m_preferences{{"theme", "system"}, {"language", "en"}, {"reduced", false}};
};
