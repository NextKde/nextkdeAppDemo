cmake_minimum_required(VERSION 3.21)
project(KosNotes VERSION 0.1.0 LANGUAGES CXX)
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 LinguistTools)
qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(KOS_UI_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." CACHE PATH "Pinned nextkdeAppDemo checkout")
if(NOT TARGET Kos::Ui)
    if(NOT EXISTS "${KOS_UI_SOURCE_DIR}/shared/qml/CMakeLists.txt")
        message(FATAL_ERROR "Set KOS_UI_SOURCE_DIR to a pinned nextkdeAppDemo checkout")
    endif()
    add_subdirectory("${KOS_UI_SOURCE_DIR}/shared/qml" kos-ui)
endif()
qt_add_executable(kos-notes src/main.cpp src/NotesAdapter.cpp src/NotesAdapter.h src/TranslationManager.cpp src/TranslationManager.h)
qt_add_qml_module(kos-notes URI Kos.Notes VERSION 1.0 RESOURCE_PREFIX /qt/qml
    QML_FILES qml/Main.qml qml/EditorWindow.qml qml/Preferences.qml qml/TaskDemo.qml)
target_link_libraries(kos-notes PRIVATE Kos::Ui Kos::UiPlugin Qt6::Quick Qt6::QuickControls2)
include(GNUInstallDirs)
install(TARGETS kos-notes RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES data/org.nextkde.KosNotes.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES data/org.nextkde.KosNotes.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps)

option(KOS_NOTES_BUILD_TESTS "Build native notes regression tests" OFF)
if(KOS_NOTES_BUILD_TESTS)
    enable_testing()
    find_package(Qt6 6.8 REQUIRED COMPONENTS Test)
    qt_add_executable(kos-notes-tests tests/tst_notes.cpp src/NotesAdapter.cpp src/NotesAdapter.h src/TranslationManager.cpp src/TranslationManager.h)
    target_include_directories(kos-notes-tests PRIVATE src)
    qt_add_qml_module(kos-notes-tests URI Kos.Notes VERSION 1.0 RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/test-qml/Kos/Notes"
        QML_FILES qml/Main.qml qml/EditorWindow.qml qml/Preferences.qml qml/TaskDemo.qml)
    target_link_libraries(kos-notes-tests PRIVATE Kos::Ui Kos::UiPlugin Qt6::Quick Qt6::QuickControls2 Qt6::Test)
    add_test(NAME native-notes COMMAND kos-notes-tests)
    set_tests_properties(native-notes PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software")
endif()

# Catalogs are executable resources: build-tree and installed runs use the same
# bytes and never depend on a source checkout or runtime translations directory.
qt_add_lrelease(TS_FILES i18n/kos_notes_en_US.ts i18n/kos_notes_zh_CN.ts
    QM_FILES_OUTPUT_VARIABLE notes_qm)
qt_add_lupdate(SOURCE_TARGETS kos-notes
    SOURCES "${KOS_UI_SOURCE_DIR}/shared/qml/foundation/KosWindowControls.qml"
            "${KOS_UI_SOURCE_DIR}/shared/qml/foundation/SettingsTextField.qml"
    TS_FILES i18n/kos_notes_en_US.ts i18n/kos_notes_zh_CN.ts)
get_target_property(notes_qmake Qt6::qmake IMPORTED_LOCATION)
execute_process(COMMAND "${notes_qmake}" -query QT_INSTALL_TRANSLATIONS
    OUTPUT_VARIABLE qt_translations_dir OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY)
set(notes_qt_qm "${qt_translations_dir}/qtbase_zh_CN.qm"
                "${qt_translations_dir}/qtdeclarative_zh_CN.qm")
foreach(catalog IN LISTS notes_qt_qm)
    if(NOT EXISTS "${catalog}")
        message(FATAL_ERROR "Install Qt translations: missing ${catalog}")
    endif()
endforeach()
foreach(target kos-notes kos-notes-tests)
    if(TARGET ${target})
        qt_add_resources(${target} notes_translations PREFIX /i18n
            BASE "${CMAKE_CURRENT_BINARY_DIR}" FILES ${notes_qm})
        qt_add_resources(${target} notes_qt_translations PREFIX /i18n
            BASE "${qt_translations_dir}" FILES ${notes_qt_qm})
    endif()
endforeach()
