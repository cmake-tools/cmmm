#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2025 flagarde
#
# SPDX-License-Identifier: MIT
#

include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest)

cmmm_modules_list(URL "gh:cmake-tools/cmmm.test")

cmmm_modules_list(URL "gh:cmake-tools/cmmm.test" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/modulesList2")

message(STATUS "CMAKE_MODULE_PATH : ${CMAKE_MODULE_PATH}")
