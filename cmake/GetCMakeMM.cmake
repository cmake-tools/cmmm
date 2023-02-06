# Copyright 2023 flagarde
#[[[ @module
#]]

if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

set(GETCMMM_FILE_VERSION "1.0.0")

if(("${GETCMMM_FILE_VERSION}" VERSION_LESS "${CURRENT_GETCMMM_FILE_VERSION}" OR "${GETCMMM_FILE_VERSION}" VERSION_EQUAL "${CURRENT_GETCMMM_FILE_VERSION}") AND COMMAND cmmm)
  return()
endif()

set(CURRENT_GETCMMM_FILE_VERSION "${GETCMMM_FILE_VERSION}" CACHE INTERNAL "GetCMakeMM version.")

#[[[
  Download and Load CMakeMM
#]]
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()
  cmake_parse_arguments(CMMM "NO_COLOR;SHOW_PROGRESS" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO" "" "${ARGN}")

  if(WIN32 OR DEFINED ENV{CLION_IDE} OR DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot})
    set(CMMM_NO_COLOR TRUE)
  elseif(NOT DEFINED CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  endif()
  set_property(GLOBAL PROPERTY CMMM_NO_COLOR ${CMMM_NO_COLOR})

  if(NOT DEFINED CMMM_VERSION OR CMMM_VERSION STREQUAL "latest")
    set(CMMM_URL "https://cmake-tools.github.io/cmmm/")
    set(CMMM_TAG "_static/")
  else()
    set(CMMM_URL "https://github.com/cmake-tools/cmmm/releases/download/")
    set(CMMM_TAG "v${CMMM_VERSION}/")
  endif()

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_BINARY_DIR}/cmmm")
  endif()
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT "5")
  endif()

  if(NOT DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT "10")
  endif()

  message("-- [CMakeMM] Downloading CMakeMM (${CMMM_TAG}) from ${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake --")

endfunction()
