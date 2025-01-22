#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2025 flagarde
#
# SPDX-License-Identifier: MIT
#

include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.2)

  cmmm(VERSION latest)

  cmmm_modules_list(URL "bb:cmake-tools/cmmm.test")

  message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")

  if(NOT ${PROVIDER} STREQUAL "bitbucket")
    message(FATAL_ERROR "PROVIDER should be 'github' not ${PROVIDER}")
  endif()

  if(NOT ${TAG} STREQUAL "main")
    message(FATAL_ERROR "TAG should be 'main' not ${TAG}")
  endif()

  if(NOT ${FOLDER} STREQUAL "/")
    message(FATAL_ERROR "FOLDER should be '/' not ${FOLDER}")
  endif()

  if(NOT ${FILENAME} STREQUAL "ModulesList.cmake")
    message(FATAL_ERROR "FILENAME should be 'ModulesList.cmake' not ${FILENAME}")
  endif()
endif()
