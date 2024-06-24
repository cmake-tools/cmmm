#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

add_subdirectory(download)
add_subdirectory(moduleList)
add_test(NAME two_module_lists COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/two_module_lists.cmake)
add_test(NAME filename COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/filename.cmake)
