cmake_minimum_required(VERSION 3.21)
project(nextkdeAppDemo LANGUAGES CXX)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickDialogs2)
qt_standard_project_setup(REQUIRES 6.8)

# Optional static library build. The Gallery itself runs from QML with Quickshell.
add_subdirectory(shared/qml)

option(KOS_BUILD_NATIVE_NOTES "Build the native Qt application starter" OFF)
option(KOS_NOTES_BUILD_TESTS "Build native notes regression tests" OFF)
if(KOS_BUILD_NATIVE_NOTES)
    if(KOS_NOTES_BUILD_TESTS)
        enable_testing()
    endif()
    add_subdirectory(examples/native-notes)
endif()
