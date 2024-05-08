#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

cmake_minimum_required(VERSION 3.0...${CMAKE_VERSION} FATAL_ERROR)

project(cmmm VERSION 1.0 LANGUAGES NONE)

if("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
  option(CMMM_BUILD_DOCS "Build the docs" ON)
  option(CMMM_BUILD_TESTS "Build the tests" ON)
else()
  option(CMMM_BUILD_DOCS "Build the docs" OFF)
  option(CMMM_BUILD_TESTS "Build the tests" OFF)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
  set(CMMM_FETCHED_VERSION "${cmmm_VERSION}" CACHE INTERNAL "Fetched CMakeMM version")
  include(GetCMakeMM)
endif()

if(CMMM_BUILD_TESTS)
  include(CTest)
  add_subdirectory(tests)
endif()

if(CMMM_BUILD_DOCS)
  add_subdirectory(docs)
endif()
