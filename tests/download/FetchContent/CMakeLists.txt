#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.11)
  cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
  project(FetchContentCMMM LANGUAGES NONE)
  include(FetchContent)
  FetchContent_Declare(cmmm GIT_REPOSITORY https://github.com/cmake-tools/cmmm.git GIT_TAG main)
  FetchContent_GetProperties(cmmm)
  if(NOT cmmm_POPULATED)
    FetchContent_Populate(cmmm)
    add_subdirectory(${cmmm_SOURCE_DIR} ${cmmm_BINARY_DIR})
  endif()
  cmmm(VERSION latest)
  cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")
  message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")
else()
  cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
  project(FetchContentCMMM LANGUAGES NONE)
endif()
