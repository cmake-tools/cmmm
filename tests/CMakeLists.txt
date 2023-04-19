

add_test(NAME download_cmmm COMMAND ${CMAKE_COMMAND} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/download_cmmm.cmake)
add_test(NAME module_list_bitbucket COMMAND ${CMAKE_COMMAND} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/module_list_bitbucket.cmake)
add_test(NAME module_list_github COMMAND ${CMAKE_COMMAND} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/module_list_github.cmake)
add_test(NAME module_list_gitlab COMMAND ${CMAKE_COMMAND} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/module_list_gitlab.cmake)
