include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/modulesList2")
