include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest TLS_VERIFY OFF)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")

message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")

include(RootDirectory)
if(NOT "${MODULE_NAME}" STREQUAL "RootDirectory")
  message(FATAL_ERROR "RootDirectory is not loaded :(")
endif()
