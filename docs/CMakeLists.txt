configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in" "${CMAKE_CURRENT_SOURCE_DIR}/conf.py")
file(COPY "${CMAKE_SOURCE_DIR}/cmake/Changelog.cmake" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/static")
