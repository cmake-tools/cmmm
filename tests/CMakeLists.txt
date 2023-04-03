include(GetCMakeMM)

cmmm(VERSION 0 TIMEOUT 30 INACTIVITY_TIMEOUT 20 TLS_VERIFY OFF RETRIES 2)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake")

cmmm_modules_list(URI "gl:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake")

cmmm_modules_list(URI "bb:cmake-tools/cmmm.test" FILEPATH "/ModulesList.cmake")

cmmm_modules_list(URI "https://bitbucket.org/cmake-tools/cmmm.test/raw/main/README.md")
