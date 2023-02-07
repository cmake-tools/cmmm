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
#
#  Download and Load CMakeMM
#
#  :param NO_COLOR: Disable colors.
#  :param SHOW_PROGRESS: Print progress information as status messages until the operation is complete.
#  :keyword VERSION: Version of CMakeMM to download (use one of the versions in https://github.com/cmake-tools/cmmm/releases or 'latest' for the last version).
#  :type VERSION: string.
#]]
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()
  cmake_parse_arguments(CMMM "NO_COLOR;SHOW_PROGRESS" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO" "" "${ARGN}")

  if(WIN32 OR DEFINED ENV{CLION_IDE} OR DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot})
    set(CMMM_NO_COLOR TRUE)
  endif()

  if(NOT DEFINED CMMM_VERSION OR CMMM_VERSION STREQUAL "latest")
    set(CMMM_URL "https://cmake-tools.github.io/cmmm/_static")
    set(CMMM_TAG "${CMMM_VERSION}")
  else()
    set(CMMM_URL "https://github.com/cmake-tools/cmmm/releases/download")
    set(CMMM_TAG "v${CMMM_VERSION}")
  endif()

  if(NOT DEFINED CMMM_DESTINATION)
    set(CMMM_DESTINATION "${CMAKE_BINARY_DIR}/cmmm")
  endif()
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT_COMMAND "")
  else()
    set(CMMM_INACTIVITY_TIMEOUT_COMMAND "INACTIVITY_TIMEOUT;${CMMM_INACTIVITY_TIMEOUT}")
  endif()

  if(NOT DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT_COMMAND "")
  else()
    set(CMMM_TIMEOUT_COMMAND "TIMEOUT;${CMMM_TIMEOUT}")
  endif()

  if(CMMM_SHOW_PROGRESS)
    set(CMMM_SHOW_PROGRESS_COMMAND "SHOW_PROGRESS")
  else()
    set(CMMM_SHOW_PROGRESS_COMMAND "")
  endif()

  string(ASCII 27 Esc)

  if(NOT DEFINED CMMM_TLS_VERIFY)
    set(CMMM_TLS_VERIFY_COMMAND "")
  elseif(${CMMM_TLS_VERIFY} STREQUAL "ON" OR ${CMMM_TLS_VERIFY} STREQUAL "OFF")
    set(CMMM_TLS_VERIFY_COMMAND "TLS_VERIFY;${CMMM_TLS_VERIFY}")
  else()
    if(CMMM_NO_COLOR OR (CMAKE_VERSION VERSION_GREATER 3.20.6))
      message(FATAL_ERROR "[CMMM] TLS_VERIFY must have value ON or OFF")
    else()
      message(FATAL_ERROR "${Esc}[31m[CMMM] TLS_VERIFY must have value ON or OFF${Esc}[m")
    endif()
  endif()

  if(NOT DEFINED CMMM_TLS_CAINFO)
    set(CMMM_TLS_CAINFO_COMMAND "")
  else()
    set(CMMM_TLS_CAINFO_COMMAND "TLS_CAINFO;${CMMM_TLS_CAINFO}")
  endif()

  if(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")

    if(CMMM_NO_COLOR)
      message("-- [CMMM] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
    else()
      message("${Esc}[1;35m-- [CMMM] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake${Esc}[m")
    endif()

    file(DOWNLOAD "${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake"
          ${CMMM_INACTIVITY_TIMEOUT_COMMAND}
          ${CMMM_TIMEOUT_COMMAND}
          ${CMMM_TLS_VERIFY_COMMAND}
          ${CMMM_TLS_CAINFO_COMMAND}
          LOG CMMM_LOG
          STATUS CMAKECM_STATUS
          ${CMMM_SHOW_PROGRESS_COMMAND})
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      if(CMMM_NO_COLOR OR (CMAKE_VERSION VERSION_GREATER 3.20.6))
        message(FATAL_ERROR "[CMMM] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE}")
      else()
        message(FATAL_ERROR "${Esc}[31m[CMMM] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE}${Esc}[m")
      endif()
    endif()
  endif()

  include("${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")

  set(ARGN "DESTINATION;${CMMM_DESTINATION};TAG;${CMMM_TAG};${ARGN}")

  cmmm_entry("${ARGN}")
endfunction()
