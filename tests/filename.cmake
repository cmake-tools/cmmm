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

cmmm_modules_list(URL "gh:cmake-tools/cmmm.test" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/filename" FILEPATH /child/ChildDirectory.cmake)
