#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest NO_COLOR SHOW_PROGRESS INACTIVITY_TIMEOUT 42 TIMEOUT 24 TLS_VERIFY OFF RETRIES 4224)

get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
if(NOT CMMM_NO_COLOR)
  message("CMMM_NO_COLOR should be TRUE")
endif()

get_property(CMMM_SHOW_PROGRESS GLOBAL PROPERTY CMMM_SHOW_PROGRESS)
if(NOT CMMM_SHOW_PROGRESS)
  message("CMMM_SHOW_PROGRESS should be TRUE")
endif()

get_property(CMMM_INACTIVITY_TIMEOUT GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT)
if(NOT "${CMMM_INACTIVITY_TIMEOUT}" STREQUAL "42")
  message("CMMM_INACTIVITY_TIMEOUT should be 42")
endif()

get_property(CMMM_TIMEOUT GLOBAL PROPERTY CMMM_TIMEOUT)
if(NOT "${CMMM_TIMEOUT}" STREQUAL "24")
  message("CMMM_TIMEOUT should be 24")
endif()

get_property(CMMM_TLS_VERIFY GLOBAL PROPERTY CMMM_TLS_VERIFY)
if(NOT "${CMMM_TLS_VERIFY}" STREQUAL "ON")
  message("CMMM_TLS_VERIFY should be ON")
endif()

get_property(CMMM_RETRIES GLOBAL PROPERTY CMMM_RETRIES)
if(NOT "${CMMM_RETRIES}" STREQUAL "4224")
  message("CMMM_RETRIES should be 4224")
endif()
