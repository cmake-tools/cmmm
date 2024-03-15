#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

cmake_minimum_required(VERSION 3.0...${CMAKE_VERSION} FATAL_ERROR)

project(cmmm VERSION 1 LANGUAGES NONE)

if("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
  option(BUILD_DOCS "Build the docs" ON)
  option(BUILD_TESTS "Build the tests" ON)
else()
  option(BUILD_DOCS "Build the docs" OFF)
  option(BUILD_TESTS "Build the tests" OFF)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
  include(GetCMakeMM)
endif()

if(BUILD_TESTS)
  include(CTest)
  add_subdirectory(tests)
endif()

if(BUILD_DOCS)
  add_subdirectory(docs)
endif()
