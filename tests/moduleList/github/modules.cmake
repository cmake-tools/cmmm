#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2026 flagarde
#
# SPDX-License-Identifier: MIT
#

include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest)

cmmm_modules_list(URL "gh:cmake-tools/cmmm.test")

message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")

include(RootDirectory)
if(NOT "${MODULE_NAME}" STREQUAL "RootDirectory")
  message(FATAL_ERROR "RootDirectory is not loaded :(")
endif()

include(RemoteURLRootDirectory)
if(NOT "${MODULE_NAME}" STREQUAL "GithubRemote")
  message(FATAL_ERROR "RemoteURLRootDirectory is not loaded :(")
endif()
