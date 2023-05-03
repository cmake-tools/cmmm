set(CMAKE_TLS_VERIFY FALSE)
add_subdirectory(download)
add_subdirectory(moduleList)
add_test(NAME two_module_lists COMMAND ${CMAKE_COMMAND} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/two_module_lists.cmake)
