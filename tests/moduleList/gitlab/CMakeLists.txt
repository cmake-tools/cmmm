#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2026 flagarde
#
# SPDX-License-Identifier: MIT
#

if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.6) #SSL
  set(BASENAME "moduleList/gitlab")
  add_test(NAME ${BASENAME}/default COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/default.cmake)
  add_test(NAME ${BASENAME}/modules COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/modules.cmake)
  add_test(NAME ${BASENAME}/destination COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} -DCMMM_DIRECTORY=${CMAKE_SOURCE_DIR}/cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/destination.cmake)
endif()
