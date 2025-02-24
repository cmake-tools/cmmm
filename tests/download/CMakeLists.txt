#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2025 flagarde
#
# SPDX-License-Identifier: MIT
#

add_test(NAME download/fetchcontent COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${CMAKE_CURRENT_SOURCE_DIR}/FetchContent/)
add_test(NAME download/latest COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${PARAM} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/latest.cmake)
add_test(NAME download/v0 COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${PARAM} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/v0.cmake)
add_test(NAME download/check_parameters COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${PARAM} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/check_parameters.cmake)
add_test(NAME download/destination COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ${PARAM} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/destination.cmake)
