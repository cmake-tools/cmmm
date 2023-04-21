include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest)

cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")

message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")

include(Example1)
if(NOT DEFINED Example1)
  message(FATAL_ERROR "Example1 is not loaded :(")
endif()

include(Example2)
if(NOT DEFINED Example2)
  message(FATAL_ERROR "Example2 is not loaded :(")
endif()
