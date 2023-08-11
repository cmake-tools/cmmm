set(conf_path "${CMAKE_CURRENT_SOURCE_DIR}")
set(project "${PROJECT_NAME}")
set(PROJECT_AUTHOR "flagarde")
set(PROJECT_COPYRIGHT "2023, flagarde")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in" "${CMAKE_CURRENT_BINARY_DIR}/conf.py")
file(COPY "${CMAKE_SOURCE_DIR}/cmake/Changelog.cmake" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/html/latest")
file(COPY "${CMAKE_SOURCE_DIR}/cmake/CMakeMM.cmake" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/html/latest")

add_custom_target(docs-all ALL sphinx-build "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/html" -b html -c "${CMAKE_CURRENT_BINARY_DIR}" DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Generating doc using Sphinx")

install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" DESTINATION share/doc)