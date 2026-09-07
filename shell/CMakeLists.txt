cmake_minimum_required(VERSION 3.16)


project(
    LumaShell
    VERSION 0.5
    LANGUAGES CXX
)


set(
    CMAKE_CXX_STANDARD
    17
)

set(
    CMAKE_CXX_STANDARD_REQUIRED
    ON
)


find_package(
    Qt6 REQUIRED

    COMPONENTS

        Quick
        Gui
        WebEngineQuick
)


qt_standard_project_setup()


qt_add_executable(

    lumashell

    main.cpp

    SystemBackend.cpp
    SystemBackend.h

    InputBackend.cpp
    InputBackend.h
)


target_link_libraries(

    lumashell

    PRIVATE

        Qt6::Quick
        Qt6::Gui
        Qt6::WebEngineQuick
)


set(

    LUMASHELL_QML_DIR

    "${CMAKE_CURRENT_SOURCE_DIR}/qml"

    CACHE STRING

    "LumaShell QML directory"
)


target_compile_definitions(

    lumashell

    PRIVATE

        LUMASHELL_QML_DIR="${LUMASHELL_QML_DIR}"
)
