# cmake-format: off
# Copyright 2023 flagarde

if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

set(GETCMMM_FILE_VERSION "1.0.0")

if((NOT "${GETCMMM_FILE_VERSION}" VERSION_GREATER "${CURRENT_GETCMMM_FILE_VERSION}") AND COMMAND cmmm)
  return()
endif()

set(CURRENT_GETCMMM_FILE_VERSION "${GETCMMM_FILE_VERSION}" CACHE INTERNAL "GetCMakeMM version.")
unset(GETCMMM_FILE_VERSION)

#[[[
#  Download and Load CMakeMM
#
#  :param NO_COLOR: Disable colors.
#  :param SHOW_PROGRESS: Print progress information as status messages until the operation is complete.
#  :keyword VERSION: Version of CMakeMM to download (use one of the versions in https://github.com/cmake-tools/cmmm/releases or 'latest' for the last version. Only for testing !).
#  :type VERSION: string
#  :keyword DESTINATION: Where to install files.
#  :type DESTINATION: path
#  :keyword INACTIVITY_TIMEOUT: Terminate the operation after a period of inactivity.
#  :type INACTIVITY_TIMEOUT: seconds
#  :keyword TIMEOUT: Terminate the operation after a given total time has elapsed.
#  :type TIMEOUT: seconds
#  :keyword TLS_VERIFY: Specify whether to verify the server certificate for https:// URLs. The default is to not verify. If this option is not specified, the value of the CMAKE_TLS_VERIFY variable will be used instead.
#  :type TLS_VERIFY: ON/OFF
#  :keyword TLS_CAINFO: Specify a custom Certificate Authority file for https:// URLs. If this option is not specified, the value of the CMAKE_TLS_CAINFO variable will be used instead.
#  :type TLS_CAINFO: file
#]]
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()

  cmake_parse_arguments(CMMM "NO_COLOR;SHOW_PROGRESS" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO" "" "${ARGN}")

  if(WIN32 OR DEFINED ENV{CLION_IDE} OR DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot})
    set(CMMM_NO_COLOR TRUE)
  endif()
  if(ENV{CI} AND NOT NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  endif()

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock" RELEASE)
    endif()
  endfunction()

  string(ASCII 27 Esc)

  # Colorize fatal errors
  function(fatal_error MESSAGE)
    if(CMMM_NO_COLOR)
      message(FATAL_ERROR "${MESSAGE}")
    elseif(DEFINED ENV{GITHUB_ACTIONS} OR DEFINED ENV{TRAVIS} OR DEFINED ENV{CIRCLECI} OR DEFINED ENV{GITLAB_CI} OR DEFINED ENV{CI})
      message(FATAL_ERROR "${Esc}[1;31m[CMMM]${Esc}[m ${MESSAGE}")
    elseif(CMAKE_VERSION VERSION_GREATER 3.20.6)
      message(FATAL_ERROR "${Esc}[1;31m[CMMM] ${MESSAGE}${Esc}[0;31m")
    else()
      message(FATAL_ERROR "${Esc}[1;31m[CMMM] ${MESSAGE}${Esc}[m")
    endif()
  endfunction()

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
  endif()

  if(NOT DEFINED CMMM_TLS_VERIFY)
    set(CMMM_TLS_VERIFY_COMMAND "")
  elseif(${CMMM_TLS_VERIFY} STREQUAL "ON" OR ${CMMM_TLS_VERIFY} STREQUAL "OFF")
    set(CMMM_TLS_VERIFY_COMMAND "TLS_VERIFY;${CMMM_TLS_VERIFY}")
  else()
    fatal_error("TLS_VERIFY must have value ON or OFF.")
  endif()

  if(NOT DEFINED CMMM_TLS_CAINFO)
    set(CMMM_TLS_CAINFO_COMMAND "")
  else()
    set(CMMM_TLS_CAINFO_COMMAND "TLS_CAINFO;${CMMM_TLS_CAINFO}")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock")
  endif()

  if(EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
    file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
  endif()
  if(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

    if(CMMM_NO_COLOR)
      message("-- [CMMM] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
    else()
      message("${Esc}[1;35m-- [CMMM] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake${Esc}[m")
    endif()

    file(
      DOWNLOAD "${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake"
      ${CMMM_INACTIVITY_TIMEOUT_COMMAND} ${CMMM_TIMEOUT_COMMAND} ${CMMM_TLS_VERIFY_COMMAND} ${CMMM_TLS_CAINFO_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS ${CMMM_SHOW_PROGRESS_COMMAND}
    )

    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      unlock()
      fatal_error("Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE}. (${CMAKECM_CODE})")
    else()
      file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
      if(${CMakeMMSHA256} STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
        unlock()
        fatal_error("Error downloading CMakeMM.cmake : Empty file.")
      endif()
      unlock()
    endif()
  endif()

  include("${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
  cmmm_entry("DESTINATION;${CMMM_DESTINATION};TAG;${CMMM_TAG};${ARGN}")
  unlock()

endfunction()
# cmake-format: on
