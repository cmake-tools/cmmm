include(GetCMakeMM)

cmmm(VERSION 0 TIMEOUT 30 INACTIVITY_TIMEOUT 20 TLS_VERIFY OFF RETRIES 2)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake" RETRIES 5 ALWAYS_DOWNLOAD)

#cmmm_modules_list(URI "gl:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake" DESTINATION "${CMAKE_BINARY_DIR}/moduleslist/gitlab/" RETRIES 5 ALWAYS_DOWNLOAD)

cmmm_modules_list(URI "bb:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake" DESTINATION "${CMAKE_BINARY_DIR}/moduleslist/bitbucket/" RETRIES 5 ALWAYS_DOWNLOAD)
