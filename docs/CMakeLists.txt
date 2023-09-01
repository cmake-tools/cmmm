set(CONF_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
set(PROJECT_AUTHOR "flagarde")
set(PROJECT_COPYRIGHT "2023, flagarde")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in" "${CMAKE_CURRENT_BINARY_DIR}/conf.py")
file(COPY "${CMAKE_SOURCE_DIR}/cmake/Changelog.cmake" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/html/latest")
file(COPY "${CMAKE_SOURCE_DIR}/cmake/CMakeMM.cmake" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/html/latest")

find_program(SPHINX_BUILD NAMES sphinx-build HINTS ENV CONDA_PREFIX DOC "sphinx-build")

add_custom_target(docs-html "${SPHINX_BUILD}" "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/html" -b html -c "${CMAKE_CURRENT_BINARY_DIR}" DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Generating doc using Sphinx (html).")
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" DESTINATION share/doc)

find_package(LATEX COMPONENTS LUALATEX)
if(LATEX_LUALATEX_FOUND)
  add_custom_target(docs-pdf "${SPHINX_BUILD}" "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/pdf" -b latex -c "${CMAKE_CURRENT_BINARY_DIR}"
          DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/conf.py"
          WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
          COMMENT "Generating doc using Sphinx (pdf).")
  add_custom_target(docs-generate-pdf ${LUALATEX_COMPILER} "${CMAKE_CURRENT_BINARY_DIR}/pdf/cmmm.tex"
          COMMAND ${LUALATEX_COMPILER} "${CMAKE_CURRENT_BINARY_DIR}/pdf/cmmm.tex"
          DEPENDS docs-pdf
          WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/pdf"
          COMMENT "Generating pdf using LuaLaTeX.")
  add_custom_target(docs-all ALL
          DEPENDS docs-pdf docs-html docs-generate-pdf
          WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
          COMMENT "Generating doc using Sphinx (all).")
else()
  add_custom_target(docs-all ALL DEPENDS docs-html
          WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
          COMMENT "Generating doc using Sphinx (all).")
endif()
