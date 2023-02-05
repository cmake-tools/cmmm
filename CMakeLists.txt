cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

project(CMMM VERSION 0.1 LANGUAGES NONE)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GetCMakeMM)

option(BUILD_TESTS "Build the tests" OFF)

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()
