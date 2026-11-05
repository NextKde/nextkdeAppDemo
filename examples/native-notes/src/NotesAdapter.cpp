#include "NotesAdapter.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStringList>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>
#include <QSet>
#include <QStandardPaths>
#include <QTimer>
#include <QUuid>

NotesAdapter::NotesAdapter(QObject *parent) : QObject(parent) {
    m_path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/notes.json";
    m_draftPath = QFileInfo(m_path).absolutePath() + "/draft.json";
    m_lock = std::make_unique<QLockFile>(QFileInfo(m_path).absolutePath() + "/notes.lock");
    m_lock->setStaleLockTime(0);
    QTimer::singleShot(0, this, &NotesAdapter::reload);
}
void NotesAdapter::fail(const QString &code) { m_error = code; emit changed(); }
void NotesAdapter::reload() {
    m_deletedNote.clear(); m_deletionError.clear(); emit deletionChanged();
    if (!m_lock->isLocked() && (!QDir().mkpath(QFileInfo(m_path).absolutePath()) || !m_lock->tryLock(0))) {
        m_state = "failed"; fail("locked"); return;
    }
    m_draft.clear(); m_committedDraftToken.clear();
    m_state = "loading"; m_error.clear(); emit changed();
    QTimer::singleShot(150, this, [this] {
        QFile file(m_path);
        if (!file.exists()) {
            m_notes = {QVariantMap{{"id", "welcome"}, {"title", "Welcome / 欢迎"},
                {"body", "Select a note, then Edit. Changes are saved only when you choose Save.\n选择笔记后点击编辑；只有保存才会写入磁盘。"}}};
            loadDraft(); m_state = "ready"; emit changed(); return;
        }
        if (!file.open(QIODevice::ReadOnly)) { m_state = "failed"; fail("read"); return; }
        QJsonParseError parse;
        const auto doc = QJsonDocument::fromJson(file.readAll(), &parse);
        const auto obj = doc.object();
        if (parse.error != QJsonParseError::NoError || !doc.isObject()
            || obj.value("version").toInt() != 1 || !obj.value("notes").isArray()
            || !obj.value("preferences").isObject()) {
            m_state = "failed"; fail("format"); return;
        }
        QVariantList notes;
        QSet<QString> ids;
        for (const auto &entry : obj.value("notes").toArray()) {
            const auto note = entry.toObject();
            const auto id = note.value("id").toString();
            if (id.isEmpty() || ids.contains(id) || !note.value("title").isString()
                || note.value("title").toString().trimmed().isEmpty() || !note.value("body").isString()) {
                m_state = "failed"; fail("format"); return;
            }
            ids.insert(id); notes.append(note.toVariantMap());
        }
        const auto prefs = obj.value("preferences").toObject().toVariantMap();
        if (!QStringList{"system", "light", "dark"}.contains(prefs.value("theme").toString())
            || !QStringList{"en", "zh"}.contains(prefs.value("language").toString())
            || prefs.value("reduced").metaType().id() != QMetaType::Bool) {
            m_state = "failed"; fail("format"); return;
        }
        if (obj.contains("committedDraftToken") && !obj.value("committedDraftToken").isString()) {
            m_state = "failed"; fail("format"); return;
        }
        m_committedDraftToken = obj.value("committedDraftToken").toString();
        m_notes = notes; m_preferences = prefs;
        loadDraft(); m_state = "ready"; emit changed();
    });
}
bool NotesAdapter::commit(const QVariantList &notes, const QVariantMap &preferences, const QString &draftToken) {
    if (m_state != "ready" || !m_lock->isLocked()) { fail("unavailable"); return false; }
    // Explicit fault injection for VM acceptance; never destroys existing data.
    if (qEnvironmentVariableIsSet("KOS_NOTES_FAIL_SAVE")) { fail("write"); return false; }
    if (!QDir().mkpath(QFileInfo(m_path).absolutePath())) { fail("write"); return false; }
    QSaveFile file(m_path);
    const QByteArray data = QJsonDocument(QJsonObject{{"version", 1},
        {"notes", QJsonArray::fromVariantList(notes)},
        {"preferences", QJsonObject::fromVariantMap(preferences)},
        {"committedDraftToken", draftToken.isEmpty() ? m_committedDraftToken : draftToken}}).toJson();
    if (!file.open(QIODevice::WriteOnly) || file.write(data) != data.size() || !file.commit()) {
        fail("write"); return false;
    }
    if (!draftToken.isEmpty()) m_committedDraftToken = draftToken;
    m_notes = notes; m_preferences = preferences; m_error.clear(); emit changed(); return true;
}
QString NotesAdapter::saveNote(const QString &id, const QString &title, const QString &body) {
    if (title.trimmed().isEmpty()) { fail("title"); return {}; }
    // Upgrade legacy checkpoints before confirming them. Never infer a commit
    // from equal text: a checkpoint can lag behind the current editor contents.
    if (m_draftInvalid) { fail("unavailable"); return {}; }
    const bool ownsDraft = !m_draft.isEmpty() && m_draft.value("id").toString() == id;
    if (ownsDraft && m_draft.value("token").toString().isEmpty()) {
        if (!saveDraft(m_draft.value("id").toString(), m_draft.value("title").toString(),
                       m_draft.value("body").toString(), m_draft.value("originalTitle").toString(),
                       m_draft.value("originalBody").toString())) { fail("write"); return {}; }
    }
    auto notes = m_notes;
    const auto savedId = id.isEmpty() ? QUuid::createUuid().toString(QUuid::WithoutBraces) : id;
    const QVariantMap note{{"id", savedId}, {"title", title.trimmed()}, {"body", body}};
    bool found = false;
    for (auto &entry : notes) if (entry.toMap().value("id").toString() == savedId) { entry = note; found = true; break; }
    if (!id.isEmpty() && !found) { fail("missing"); return {}; }
    if (!found) notes.prepend(note);
    return commit(notes, m_preferences, ownsDraft ? m_draft.value("token").toString() : QString()) ? savedId : QString();
}
bool NotesAdapter::savePreferences(const QString &theme, const QString &language, bool reduced) {
    if (!QStringList{"system", "light", "dark"}.contains(theme) || !QStringList{"en", "zh"}.contains(language)) return false;
    return commit(m_notes, {{"theme", theme}, {"language", language}, {"reduced", reduced}});
}


void NotesAdapter::loadDraft() {
    m_draft.clear(); m_draftError.clear(); m_draftInvalid = false;
    QFile file(m_draftPath);
    if (!file.exists()) { emit draftChanged(); return; }
    QJsonParseError parse;
    const auto doc = file.open(QIODevice::ReadOnly) ? QJsonDocument::fromJson(file.readAll(), &parse) : QJsonDocument();
    const auto obj = doc.object();
    bool valid = doc.isObject() && obj.value("version").toInt() == 1;
    for (const auto &key : {"id", "title", "body", "originalTitle", "originalBody"})
        valid = valid && obj.value(key).isString();
    valid = valid && (!obj.contains("token") || (obj.value("token").isString() && !obj.value("token").toString().isEmpty()));
    if (!valid) { m_draftInvalid = true; m_draftError = "read"; }
    else if (!m_committedDraftToken.isEmpty() && obj.value("token").toString() == m_committedDraftToken) {
        // The notes transaction acknowledges this entire checkpoint lineage,
        // including older text. Cleanup is retryable; never expose it as edits.
        clearDraft();
    } else m_draft = obj.toVariantMap();
    emit draftChanged();
}
bool NotesAdapter::saveDraft(const QString &id, const QString &title, const QString &body,
                             const QString &originalTitle, const QString &originalBody) {
    if (!m_lock->isLocked() || m_state != "ready" || m_draftInvalid) {
        m_draftError = "unavailable"; emit draftChanged(); return false;
    }
    auto token = m_draft.value("token").toString();
    if (token.isEmpty() || token == m_committedDraftToken)
        token = QUuid::createUuid().toString(QUuid::WithoutBraces);
    const QVariantMap draft{{"token", token}, {"version", 1}, {"id", id}, {"title", title}, {"body", body},
                            {"originalTitle", originalTitle}, {"originalBody", originalBody}};
    QSaveFile file(m_draftPath);
    const auto bytes = QJsonDocument(QJsonObject::fromVariantMap(draft)).toJson();
    if (qEnvironmentVariableIsSet("KOS_NOTES_FAIL_DRAFT") || !file.open(QIODevice::WriteOnly)
        || file.write(bytes) != bytes.size() || !file.commit()) {
        m_draftError = "write"; emit draftChanged(); return false;
    }
    m_draft = draft; m_draftError.clear(); emit draftChanged(); return true;
}
bool NotesAdapter::clearDraft() {
    if (!m_lock->isLocked() || qEnvironmentVariableIsSet("KOS_NOTES_FAIL_CLEAR_DRAFT")
        || (QFile::exists(m_draftPath) && !QFile::remove(m_draftPath))) {
        m_draftError = "remove"; emit draftChanged(); return false;
    }
    m_draft.clear(); m_draftError.clear(); m_draftInvalid = false; emit draftChanged(); return true;
}

// A single in-memory undo slot, replaced only by a successful deletion.
bool NotesAdapter::deleteNote(const QString &id) {
    if (m_editorOpen || m_draftInvalid || !m_draft.isEmpty() || !m_draftError.isEmpty()) {
        m_deletionError = "editing"; emit deletionChanged(); return false;
    }
    auto notes = m_notes;
    for (qsizetype index = 0; index < notes.size(); ++index) {
        const auto note = notes.at(index).toMap();
        if (note.value("id").toString() != id) continue;
        notes.removeAt(index);
        if (!commit(notes, m_preferences)) {
            m_deletionError = "write"; emit deletionChanged(); return false;
        }
        m_deletedNote = note; m_deletedIndex = index;
        m_deletionError.clear(); emit deletionChanged(); return true;
    }
    m_deletionError = "missing"; emit deletionChanged(); return false;
}
QString NotesAdapter::undoDelete() {
    if (m_deletedNote.isEmpty()) return {};
    auto notes = m_notes;
    const auto id = m_deletedNote.value("id").toString();
    for (const auto &entry : notes) {
        if (entry.toMap().value("id").toString() == id) {
            m_deletionError = "conflict"; emit deletionChanged(); return {};
        }
    }
    notes.insert(qMin(m_deletedIndex, notes.size()), m_deletedNote);
    if (!commit(notes, m_preferences)) {
        m_deletionError = "write"; emit deletionChanged(); return {};
    }
    m_deletedNote.clear(); m_deletionError.clear(); emit deletionChanged(); return id;
}

void NotesAdapter::startTask(bool simulateFailure) {
    const auto generation = ++m_taskGeneration;
    m_taskState = "running"; m_taskProgress = 0; m_taskResult.clear();
    emit taskChanged();
    scheduleTaskStep(generation, simulateFailure);
}
void NotesAdapter::scheduleTaskStep(quint64 generation, bool simulateFailure) {
    // Context-bound callbacks cannot outlive this adapter. Each small simulated
    // batch yields to the event loop; real blocking work needs a worker/service.
    QTimer::singleShot(250, this, [this, generation, simulateFailure] {
        if (generation != m_taskGeneration || m_taskState != "running") return;
        m_taskProgress += 20;
        if (simulateFailure && m_taskProgress == 60) {
            m_taskState = "failed";
        } else if (m_taskProgress == 100) {
            m_taskResult = {QStringLiteral("Sample A"), QStringLiteral("Sample B"), QStringLiteral("Sample C")};
            m_taskState = "succeeded";
        }
        emit taskChanged();
        if (generation == m_taskGeneration && m_taskState == "running")
            scheduleTaskStep(generation, simulateFailure);
    });
}
void NotesAdapter::cancelTask() {
    if (m_taskState != "running") return;
    ++m_taskGeneration; m_taskState = "cancelled"; m_taskResult.clear(); emit taskChanged();
}
void NotesAdapter::retryTask() {
    if (m_taskState == "failed" || m_taskState == "cancelled") startTask(false);
}
