# Native application starter and AI entry point

[简体中文](ApplicationStarter.zh-CN.md)

Start new native Qt applications from [`examples/native-notes`](../examples/native-notes).
It consumes the canonical `Kos.Ui` module without Quickshell, NextKde services,
KWin protocols or another application checkout. English is the initial language.
This is a small application reference, not a production storage framework.

## Read before changing an application

Read [AGENTS.md](../AGENTS.md), [Architecture](Architecture.md),
[Components](Components.md), [GalleryDesign](GalleryDesign.md),
[WindowControls](WindowControls.md), [Dialogs](Dialogs.md),
[Popovers](Popovers.md) and [Settings](Settings.md), in that order.
Current material contracts take precedence over historical optical recipes.
Keep application business logic and persistence out of `shared/qml`.

| Copy or consume | Purpose |
| --- | --- |
| `examples/native-notes/CMakeLists.txt`, `src/main.cpp`, `data/` | Executable, resource module, app identity, desktop/icon installation; rename all identities for your app |
| `src/NotesAdapter.*` | Small typed boundary, validation, atomic JSON commit, error recovery; replace with your domain adapter |
| `qml/Main.qml` | Content list, filter, selection, detail, empty/loading/error states and main-window exit coordination |
| `qml/EditorWindow.qml` | Separate nonmodal window, local draft, Save, failed save and Save/Don't Save/Cancel close guard |
| `qml/Preferences.qml` | Canonical grouped settings, draft/commit/cancel; changes apply only after durable success |
| `shared/qml/foundation/KosAppWindow.qml` | Consume as `KosAppWindow`; do not copy its controls into your app |
| Gallery examples | Copy individual API usage after checking its placement; optical demonstrations, test images, experimental sliders and standalone glass cards are not application page templates |

The NkMail comparison informed the separation of window chrome, application
adapter and independent editor lifecycle. No mail models, services, credentials,
protocol imports, accounts or composer formatting are copied into this starter.
NkMail remains an application reference, not a dependency or canonical UI library.

## Recommended shell

`KosAppWindow` is a new additive API. Existing `KosApplicationWindow` consumers
keep their current behavior. The recommended shell has an opaque, rectangular,
edge-to-edge content plane with no application-painted outer radius, outline or
shadow. It owns a 36px title row, canonical `KosWindowControls`, system drag,
maximize on double-click (when declared) and canonical resize handles. Set the
inherited `title`, `width`, `height`, `minimumWidth`, `minimumHeight`, `header`,
`footer` and content as needed. Its 960×660 default is a starting size only;
choose usable minimums for your content, preserve resizing and implement saved
geometry in your application adapter if required. It does not persist geometry.
The editor demonstrates independent 720×540 dimensions.

`windowActions` is the actual ordered list of unique actions; use
`["maximize", "minimize", "close"]`, `["close"]` or `[]` as appropriate.
`windowControls` exposes the canonical control object and its actual
`buttonLayout`; never calculate positions from an assumed button count.
`titleBarHeight` changes the title row. Replacing `header` means the host must
provide its own canonical controls and drag area; do not retain an invisible
adapter declaration for the removed row.

`windowControlsAdapter` defaults to null. An optional, application-owned adapter
receives the window and exposed controls. Its observable `available` and
`takeoverConfirmed` properties must both be true to hide client controls;
`hoverGlyphs` optionally supplies the shared display preference. Reset availability
immediately on service loss. The adapter must negotiate the shared KOS window
appearance switch, supported protocol and acknowledgement, publish complete
actual geometry after layout events, and exist only once per surface. This
starter ships no protocol adapter and claims no compositor integration. Do not
import optional native modules unconditionally or use timers/pixel sampling to
infer geometry. Without an adapter, the ordinary client controls remain active.

AppTheme is configured once by the application, not by each shell. Content and
embedded toolbar actions use ordinary material. The left column is a content
list, not the translucent navigation-sidebar experiment. Dialogs sample their
own window's scene, excluding overlays and captures; the editor never samples
the main window. Reduced transparency uses the canonical opaque fallback.

## Build and install in an authorized environment

Requires Qt 6.8+ development packages (Core, Gui, Qml, Quick, QuickControls2, LinguistTools;
the repository root also finds QuickDialogs2), a C++17 compiler, CMake 3.21+,
Qt Quick Controls runtime, Qt5Compat.GraphicalEffects and SVG support. Use the
committed shaders; do not bake them on the workstation.

Run builds, translation tools, tests and graphical checks only in a VM or hosted CI.
Do not run these on the maintainer workstation or start/replace its Shell.
From this repository in the VM:

```sh
cmake -S . -B build -DKOS_BUILD_NATIVE_NOTES=ON
cmake --build build --target kos-notes
cmake --install build --prefix "$HOME/.local"
```

Or build the example independently:

```sh
cmake -S examples/native-notes -B build-notes
cmake --build build-notes
cmake --install build-notes --prefix "$HOME/.local"
```

For a copied example, pass `-DKOS_UI_SOURCE_DIR=/path/to/pinned/nextkdeAppDemo`.
Pin that checkout by exact commit (normally a submodule); do not use a moving
branch in releases. Link both `Kos::Ui` and `Kos::UiPlugin`. Preserve GPL license
and provenance. The default repository build still builds only the UI library.
Installation provides `kos-notes`, `org.nextkde.KosNotes.desktop` and its scalable
icon. Qt runtime packaging/deployment is the consuming distributor's job.

## Translation catalogs and maintenance

`examples/native-notes/i18n/kos_notes_{en_US,zh_CN}.ts` are application catalogs.
They cover the four application QML contexts plus the used shared
`KosWindowControls` and `SettingsTextField` contexts. The shared component source
remains unchanged. This is **not** complete language coverage for every `Kos.Ui`
control, the Gallery or a future consuming application; add the contexts actually
used by that application. The asynchronous sample uses `%n` and English singular/
plural forms, and formats progress through the selected `Qt.locale` with its
percent symbol. No date feature is added.

Install matching Qt Linguist tools and Qt translations in the VM. CMake requires
`qtbase_zh_CN.qm` and `qtdeclarative_zh_CN.qm` from Qt's translation directory;
these cover available Qt built-in messages. Application, relevant shared-control
and Qt catalogs are embedded in both executable targets, so root, standalone and
installed builds all work without a source checkout or an external catalog path.
Qt translation coverage is limited to the upstream catalog contents; unrelated
platform/system UI follows its own localization. Preserve Qt translation licenses
when redistributing Qt resources alongside the application.

After editing `qsTr` strings, in the VM run (use `build-notes` for a standalone
build):

```sh
cmake --build build --target update_translations
# Review both TS files with Qt Linguist; translate new messages and numerus forms.
cmake --build build --target release_translations
cmake --build build --target kos-notes
```

`update_translations` explicitly scans the two used shared contexts as well as
application sources. Review the TS diff, keep completed English plural forms and
Chinese translations, and remove obsolete entries only after reviewing their
usage. `release_translations` invokes `lrelease`; ordinary executable builds also
generate and embed the QM resources. Commit TS sources, not build-tree QM files.
Copied applications must maintain their own catalogs/context list and rebuild;
changing `QLocale` alone does not translate QML bindings.

The subsequent 2026-11-05 internationalization acceptance uses Qt 6.10.2 in the
VM: both build entry points run the full regression suite, including the eight
`commitCrash` scenarios and `translationBindings`. The opt-in `desktopI18n` case
uses real visible Wayland/OpenGL windows at normal size and DPR 1. It covers
English → Chinese → English, settings failure/cancellation, existing editor error
text, task plurals, shared window-button accessibility names and persisted Chinese
on restart. Run it like `desktopDeleteTask`, substituting `desktopI18n` as the test
function. The installed executable also runs from `/tmp` with the source directory
unavailable. `update_translations`/`release_translations` were exercised in the VM;
both catalogs contain 85 completed messages. This is application translation
acceptance, not a new compositor, scaling or complete-library language matrix.

## State and lifecycle

The C++ adapter loads `notes.json` below
`QStandardPaths::AppDataLocation` (normally
`~/.local/share/NextKdeExamples/KosNotes` on Linux). A missing file seeds one
bilingual note in memory. The first successful save persists it. An existing
unreadable, unsupported or malformed file enters failure state and disables
writes; Retry re-reads it after repair. It is never silently replaced with defaults.
The schema is `{version: 1, notes: [{id, title, body}], preferences: {theme,
language, reduced}}`. Empty note arrays are valid. IDs remain stable across edits.
Filtering is case-insensitive over title/body; selection stays on its ID even
when filtered out, so the detail view does not jump unexpectedly.

Only successful QSaveFile commits publish new notes/preferences. A failed note
save leaves the editor draft and prior durable file intact. Settings have their
own draft and leave confirmed settings active after failure or Cancel/Escape.
Theme (system/light/dark), English/Chinese and reduced transparency persist.
The application uses standard Qt `qsTr`, TS/QM catalogs and its own
`TranslationManager`. English (`en_US`) is the default regardless of the host
locale; simplified Chinese (`zh_CN`) follows the persisted `language: "zh"`.
Only published preferences after a successful commit/reload replace translators,
set the application locale and call `QQmlEngine::retranslate()`. Existing editor,
settings, task and error bindings update immediately. Cancel or failed settings
writes leave the current language intact. Note titles, bodies and recovery drafts
are user data and are never translated.

One independent editor is reused: requesting another note while it is visible
raises the existing editor without replacing its draft. Closing a dirty editor,
including a main-window quit request, offers Save, Don't Save and Cancel. Save
must succeed before close; Cancel cancels the pending application quit. Empty
titles cannot be saved. A separate `draft.json` recovery copy is atomically updated
600 ms after the last edit and immediately when a dirty close is requested. It
never changes `notes.json`; Save remains the explicit confirmation. Startup
reopens a valid recovery draft in the editor. Save or Don't Save removes recovery;
a failed save leaves the draft in memory and the last successful recovery copy.
Every normal close also removes recovery, including closing immediately after
undoing back to the original content. Removal failure keeps the editor open with
a retry/cancel guard, including subsequent Close and Quit requests. If note commit
succeeded first, its ID and saved baseline are retained: retrying cleanup cannot
create a second note. Save remains available to retry cleanup even with no edits.
An autosave failure is visible and does not close the editor; edits since the last
successful checkpoint can still be lost in a crash. An invalid recovery file is
preserved, blocks starting another editor, and can be repaired while stopped or
explicitly discarded through confirmation. Recovery is one local draft, not history.
Each checkpoint lineage has a random `token`. Confirming a note atomically writes
`committedDraftToken` in the same `notes.json` transaction. Startup validates notes
before recovery and never opens an acknowledged token as edits, even when the
checkpoint lags the saved text, the process exits before cleanup, or cleanup fails.
Subsequent edits receive a new token; uncommitted and failed-save checkpoints remain
recoverable. Existing version 1 files remain readable: tokenless legacy drafts are
atomically upgraded before confirmation; upgrade failure preserves the draft and
rejects the save. Equal text never implies a confirmed transaction. Cleanup errors
retain existing retry protection. This covers process exits, not cross-device
transactions or a guarantee of durability after power loss.

`QLockFile` holds `notes.lock` for the adapter lifetime. A second process cannot
load/write this data directory; it shows a lock/access error and Retry. Dead-process
locks are recovered by Qt; age alone never overrides a live lock. This is cooperative
single-writer protection, not protection from unrelated programs editing files.
The example has no network service, migration or conflict merging. Do not turn this small adapter into an
implicit production database contract.

## Delete, undo and asynchronous sample task

Delete note opens a canonical confirmation dialog. Any open editor (including an
uncheckpointed draft), valid recovery draft or recovery-file error blocks deletion;
save or discard edits and close the editor, or resolve recovery first. The adapter
checks this guard too. Only a successful atomic commit removes the note. Failure
leaves the note, selection and previous undo intact; repair storage and retry.
Deleting the selected note clears selection without selecting an unrelated row.
Undo restores the original ID, content and list position and selects that ID, even
if the filter hides it. Undo failure preserves its record for retry. There is one
in-memory undo slot, replaced by the next successful deletion and cleared by reload
or application exit; this is not a trash folder or durable history.

The visible **Task demo** action opens a standalone **Sample data task** dialog.
Load sample data schedules five small batches asynchronously through context-bound
C++ `QTimer` callbacks. Loading percentage, cancellation, a controllable simulated
failure and Retry demonstrate adapter-owned state. Retry removes the injected
failure; closing the dialog cancels an active task. Every start/cancel changes a
request generation, so stale callbacks cannot publish progress, errors or results.
Adapter destruction removes pending callbacks. Three fictional results stay in a
separate transient property: no network, note writes or recovery changes occur.
This demonstrates event-loop scheduling, not a worker for blocking CPU/I/O work.

The 2026-11-05 VM run built the root and standalone entry points with Qt 6.10.2
and ran all ordinary regressions. Coverage includes failed delete/undo durability,
retry, one-step undo, editor/draft guards, filtered selection, cancellation,
request-generation isolation and callback lifetime. The opt-in
`desktopDeleteTask` case additionally uses mouse/key events on visible Wayland
windows at 960×660 and DPR 1 with OpenGL (VMware SVGA3D): Delete/Cancel/Escape,
failed delete then retry, deleting the last note, failed undo then retry, editor
draft protection, and Task demo success/failure/retry/cancel/close/reopen.
No application method invocation substitutes for these desktop actions.

Run this focused case with `KOS_NOTES_DESKTOP_ACCEPTANCE=1` and optionally
`KOS_NOTES_CAPTURE_DIR` (create that directory first), using the test executable's
`desktopDeleteTask` argument. Keep XDG data/config/cache directories disposable.
Ordinary `ctest` skips all opt-in desktop cases. This VM run did not repeat the
historical installation, compositor controls, dark/reduced-transparency or
cross-platform matrix; it did not use extreme scaling. The historical results
below are separate evidence, not claims about this VM run.

## Acceptance checklist

Use a VM or hosted CI only. Record actual commands,
Qt/platform/backend versions, screenshots, logs and results outside tracked docs.
An unrun item stays **not verified**; source review is not runtime acceptance.

1. Build both entry points above in separate build directories. Launch the
   installed desktop entry outside the source directory. Check resource imports,
   icon, absence of QML warnings and operation without Quickshell/NextKde/KWin.
2. Use a disposable `XDG_DATA_HOME` when launching `kos-notes`. Observe loading,
   select the sample, filter matching/nonmatching text, clear the filter, navigate
   with Tab/arrows and read/select long text. With several notes, click one, hide it
   with a filter and clear the filter: its ID/detail must stay selected and its row
   highlight must return. Repeat after keyboard selection and after saving an edit
   that changes filter membership; model replacement must not select another note.
   With a stopped app, set the disposable
   file's `notes` to `[]`; relaunch and check the empty state and New action.
3. Create a note, enter a title and multiline body, Save and restart. Edit the same
   note and verify stable selection and persisted content. Open another edit while
   the editor is visible: the first draft must remain intact and be raised.
4. Test editor close and main-window quit with dirty data: Cancel, Don't Save,
   Save, blank title, keyboard Close/Quit and title-bar close. Check that a failed
   Save never closes the editor or exits the app. Repeat the Quit shortcut with
   the independent editor active: Save must persist before both windows close,
   Don't Save must discard and quit, and Cancel must keep both windows and the
   draft open. Inject a save failure and use Quit from the active editor again:
   failed Save must retain the draft and both windows; Cancel must cancel quitting.
5. Launch with `KOS_NOTES_FAIL_SAVE=1` and the disposable data directory. Both note
   and settings writes must fail without changing the durable JSON. Restart without
   this variable to retry successfully. Separately exercise a real unwritable path.
6. With the app stopped, damage the disposable JSON or version. Relaunch, verify
   the load-error state and disabled writes, repair the file and click Retry.
7. Save each theme/language/reduced-transparency setting, restart, and verify it.
   Cancel draft settings and repeat with injected failure: the old settings remain.
   Check dark settings menus, all application labels and readable text at 100/200%
   scaling, minimum window sizes, long titles and long note content.
8. Move/resize/maximize/restore/minimize each independent window; minimize the
   main window while editing. Check edge-to-edge rectangular content, no outer
   app border/shadow/corners, controls hit areas, double-click and keyboard focus.
   Exercise three/one/zero/reordered action declarations in a temporary VM harness.
9. Inspect dialog pixels on a GPU: same-window blur/refraction, 32px G2 contour,
   solid interior actions and no accent focus outline around liquid layers.
   Repeat with reduced transparency and software rendering. Never claim GPU optics
   from an offscreen/software check.
10. If adding an optional platform adapter, separately test switch off/on, rejection,
    delayed acknowledgement, service loss, moved/resized controls, independent
    windows and removal of stale hit areas. No adapter is implemented here.


The `commitCrash` regression launches real subprocesses which call `std::_Exit(73)`
after `saveNote`, without `clearDraft`, normal window closure or destructors. Cases
cover new and existing notes with lagging checkpoints, uncommitted edits, failed
saves, subsequent edits, legacy upgrade and upgrade failure, and equal-content
uncommitted checkpoints. Restart checks also inject cleanup failure. Run the full
suite in the authorized VM; these are process-recovery checks, not graphical or
power-loss acceptance.

## Optional regression tests and recorded scope

Configure either entry with `-DKOS_NOTES_BUILD_TESTS=ON` (the root also requires
`-DKOS_BUILD_NATIVE_NOTES=ON`), build, then run `ctest --test-dir build --output-on-failure`.
Tests use temporary data directories and an offscreen software renderer. The option
is OFF by default and introduces no CI. `KOS_NOTES_FAIL_DRAFT=1` injects recovery
write failure independently of `KOS_NOTES_FAIL_SAVE=1`;
`KOS_NOTES_FAIL_CLEAR_DRAFT=1` injects recovery removal failure.

The authorized 2026-11-05 workstation run built both entry points, installed outside
the checkout and loaded the installed resource QML from `/tmp`. Qt 6.12.0 regression
cases exercise atomic persistence, validation, injected/real write failure, corrupt
file repair, selection/filtering, editor reuse and close protection, separate-process
lock contention, abrupt-process recovery, corrupt draft preservation and QML recovery.
The five test functions (seven data rows) plus init/cleanup passed in both builds.
Cleanup regressions cover immediate Close/Quit after reverting a checkpointed edit,
restart without recovery, explicit Save followed by injected and real-path removal
failure, repeated Save/Close/Quit protection, and successful retry without duplicate
notes or leftover recovery. The real-path case temporarily replaces `draft.json`
with a directory. The subsequent authorized desktop run uses the optional `desktopInput` case with
`KOS_NOTES_DESKTOP_ACCEPTANCE=1`; ordinary `ctest` skips this case. It sends Qt
mouse/key events to visible application windows rather than invoking application
methods. `KOS_NOTES_CAPTURE_DIR` saves only those windows. For example, in an
authorized desktop session:

```sh
QT_QPA_PLATFORM=xcb QSG_RHI_BACKEND=opengl QT_SCREEN_SCALE_FACTORS=1 \
QT_FONT_DPI=96 QT_SCALE_FACTOR=1 KOS_NOTES_DESKTOP_ACCEPTANCE=1 \
KOS_NOTES_CAPTURE_DIR=/tmp/notes-captures ./build-notes/kos-notes-tests desktopInput
```

Create the capture directory first and isolate `XDG_DATA_HOME`, `XDG_CONFIG_HOME`
and `XDG_CACHE_HOME`. Repeat with `QT_SCALE_FACTOR=2` and separately with
`QT_QUICK_BACKEND=software`. No global display configuration is changed. The
XCB input case uses `xdotool` only for activating its own window IDs and bounded
native geometry checks; the Qt events drive application controls.

The run covers New, Unicode/long-title/multiline input, Tab, save, selection after
click/Up/Down/filtering, active-editor Quit Save/Discard/Cancel/Escape and failed
Save, settings commit/cancel/failure, English/Chinese and light/dark appearances,
minimum sizes, window-control declarations and independent window states. Custom
footer geometry asserts 30px actions and 24px right/bottom padding. The selected
row takes keyboard focus on click; long detail titles elide after three lines.
GPU images on Intel Arc/OpenGL at effective DPR 1 and 2 compare real text behind
liquid dialogs with reduced-transparency/software opaque fallback. Capture scenes
include an opaque theme base, so uncaptured sharp content cannot leak through
transparent source texels. Fallback uses the ordinary dialog background.
Installed `gtk-launch` identity, desktop/icon resources and window properties are
checked separately from the input test. Qt-injected drag/edge-resize events alone
do not establish compositor seat acceptance; native pointer checks are separate.
No optional compositor adapter or cross-platform rendering acceptance is claimed.
No shaders were baked. Window geometry persistence is not implemented.

Additional manual recovery checks: edit and wait over 600 ms, terminate only the
isolated example process, restart and review the restored draft; repeat with
`KOS_NOTES_FAIL_DRAFT=1`. Start two instances with the same disposable data directory,
then close the first and Retry the second. Never test this with personal notes.
