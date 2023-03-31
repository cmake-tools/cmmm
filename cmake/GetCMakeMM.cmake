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
#  :param NO_CHANGELOG: Disable changelog download.
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
#  :keyword RETRIES: Specify the number of retries if download fails.
#  :type RETRIES: int>=0 or INFINITY
#]]
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()

  cmake_parse_arguments(CMMM "NO_COLOR;SHOW_PROGRESS" "VERSION;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO;RETRIES" "" "${ARGN}")

  if(DEFINED ENV{CLICOLOR_FORCE} AND NOT "$ENV{CLICOLOR_FORCE}" STREQUAL "0")
    set(CMMM_NO_COLOR FALSE)
  elseif(DEFINED ENV{CI} AND NOT CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  elseif(WIN32 OR DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot} OR CMMM_NO_COLOR)
    set(CMMM_NO_COLOR TRUE)
  endif()

  if(NOT CMMM_NO_COLOR)
    string(ASCII 27 Esc)
    if(NOT DEFINED CMMM_DEFAULT_COLOR)
      set(CMMM_DEFAULT_COLOR "[0;35m")
    endif()
    if(NOT DEFINED CMMM_FATAL_ERROR_COLOR)
      set(CMMM_FATAL_ERROR_COLOR "[1;31m")
    endif()
    if(NOT DEFINED CMMM_ERROR_COLOR)
      set(CMMM_ERROR_COLOR "[0;31m")
    endif()
    if(NOT DEFINED CMMM_WARN_COLOR)
      set(CMMM_WARN_COLOR "[0;33m")
    endif()
    if(NOT DEFINED CMMM_INFO_COLOR)
      set(CMMM_INFO_COLOR "[0;32m")
    endif()
    set(CMMM_RESET_COLOR "[0m")
  endif()

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock" RELEASE)
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

  if(DEFINED CMMM_INACTIVITY_TIMEOUT)
    set(CMMM_INACTIVITY_TIMEOUT_COMMAND "INACTIVITY_TIMEOUT;${CMMM_INACTIVITY_TIMEOUT}")
  endif()

  if(DEFINED CMMM_TIMEOUT)
    set(CMMM_TIMEOUT_COMMAND "TIMEOUT;${CMMM_TIMEOUT}")
  endif()

  if(CMMM_SHOW_PROGRESS)
    set(CMMM_SHOW_PROGRESS_COMMAND "SHOW_PROGRESS")
  endif()

  if(${CMMM_TLS_VERIFY} STREQUAL "ON" OR ${CMMM_TLS_VERIFY} STREQUAL "OFF")
    set(CMMM_TLS_VERIFY_COMMAND "TLS_VERIFY;${CMMM_TLS_VERIFY}")
  else()
    message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] TLS_VERIFY must have value ON or OFF.${Esc}${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "TLS_VERIFY must have value ON or OFF.")
  endif()

  if(DEFINED CMMM_TLS_CAINFO)
    set(CMMM_TLS_CAINFO_COMMAND "TLS_CAINFO;${CMMM_TLS_CAINFO}")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${CMMM_DESTINATION}/CMakeMM.cmake.lock")
  endif()

  if(NOT DEFINED CMMM_RETRIES)
    set(CMMM_RETRIES "0")
  endif()

  if(EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
    file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
  endif()

  set(CMMM_RETRIES_DONE "0")
  while(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

    if(${CMMM_RETRIES_DONE} STREQUAL "0")
      message(STATUS "${Esc}${CMMM_DEFAULT_COLOR}[ CMMM ] Downloading CMakeMM.cmake@${CMMM_VERSION} (${CMMM_TAG}) to ${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake${Esc}${CMMM_RESET_COLOR}")
    else()
      message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] Retry downloading CMakeMM.cmake (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${Esc}${CMMM_RESET_COLOR}")
    endif()

    file(
      DOWNLOAD "${CMMM_URL}/${CMMM_TAG}/CMakeMM.cmake" "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake"
      ${CMMM_INACTIVITY_TIMEOUT_COMMAND} ${CMMM_TIMEOUT_COMMAND} ${CMMM_TLS_VERIFY_COMMAND} ${CMMM_TLS_CAINFO_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS ${CMMM_SHOW_PROGRESS_COMMAND}
    )
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${Esc}${CMMM_RESET_COLOR}")
    else()
      file(SHA256 "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake" CMakeMMSHA256)
      if(${CMakeMMSHA256} STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
        message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading CMakeMM.cmake : Empty file.${Esc}${CMMM_RESET_COLOR}")
      else()
        break()
      endif()
    endif()
    if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
      unlock()
      message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] Error downloading CMakeMM.cmake.${Esc}${CMMM_RESET_COLOR}")
      message(FATAL_ERROR "Error downloading CMakeMM.cmake.")
    endif()
    math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
  endwhile()

  include("${CMMM_DESTINATION}/CMakeMM-${CMMM_TAG}.cmake")
  cmmm_entry("DESTINATION;${CMMM_DESTINATION};TAG;${CMMM_TAG};${ARGN};RETRIES;${CMMM_RETRIES}")
  unlock()

endfunction()
# cmake-format: on
