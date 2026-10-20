cmake_minimum_required(VERSION 3.21)
project(nextkdeAppDemo LANGUAGES CXX)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickDialogs2)
qt_standard_project_setup(REQUIRES 6.8)

# Optional static library build. The Gallery itself runs from QML with Quickshell.
add_subdirectory(shared/qml)
