include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")

message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")

include(RootDirectory)
if(NOT "${MODULE_NAME}" STREQUAL "RootDirectory")
  message(FATAL_ERROR "RootDirectory is not loaded :(")
endif()

include(RemoteURLRootDirectory)
if(NOT "${MODULE_NAME}" STREQUAL "GithubRemote")
  message(FATAL_ERROR "RemoteURLRootDirectory is not loaded :(")
endif()
