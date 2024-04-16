#
# CMakeMM
# CMake's missing Module Manager.
#
# SPDX-FileCopyrightText: 2023-2024 flagarde
#
# SPDX-License-Identifier: MIT
#

# cmake-format: off
# Copyright 2023 flagarde

#[=======================================================================[.rst:
cmmm_modules_list
-----------------

Download a module list.

.. code-block:: cmake

  cmmm_modules_list(URL <url>)

  cmmm_modules_list(FILEPATH <path>)

Options
^^^^^^^

The options are:

``URL <url>``
  the URL in the form provider:foo/bar#tag

``FILEPATH <path>``
  the file to download

``NO_COLOR``
  **Optional** Disable the color on terminal.

``SHOW_PROGRESS``
  **Optional** Print progress information as status messages until the operation is complete.

``TLS_VERIFY <ON|OFF>``
  **Optional** Specify whether to verify the server certificate for ``https://`` URLs.
  The default is to *not* verify. If this option is not specified, the value of the `CMAKE_TLS_VERIFY <https://cmake.org/cmake/help/latest/variable/CMAKE_TLS_VERIFY.html>`_ variable will be used instead.

``TLS_CAINFO <file>``
  **Optional** Specify a custom Certificate Authority file for ``https://`` URLs.
  If this option is not specified, the value of the `CMAKE_TLS_CAINFO <https://cmake.org/cmake/help/latest/variable/CMAKE_TLS_CAINFO.html>`_ variable will be used instead.

``RETRIES <number/INFINITY>``
  **Optional** Specify the number of retries if download fails.

``INACTIVITY_TIMEOUT <seconds>``
  **Optional** Terminate the operation after a period of inactivity.

``TIMEOUT <seconds>``
  **Optional** Terminate the operation after a given total time has elapsed.

``DESTINATION <path>``
  **Optional** Path destination to install CMakeMM.

``USERPWD <username>:<password>``
  **Optional** Set username and password for operation.

``NETRC <level>``
  **Optional** Specify whether the .netrc file is to be used for operation. If this option is not specified, the value of the `CMAKE_NETRC <https://cmake.org/cmake/help/latest/variable/CMAKE_NETRC.html>`_ variable will be used instead.

  Valid levels are:

    ``IGNORED``
      The .netrc file is ignored. This is the default.

    ``OPTIONAL``
      The .netrc file is optional, and information in the URL is preferred. The file will be scanned to find which ever information is not specified in the URL.

    ``REQUIRED``
      The .netrc file is required, and information in the URL is ignored.

``NETRC_FILE <file>``
  **Optional** Specify an alternative .netrc file to the one in your home directory, if the ``NETRC`` level is **OPTIONAL** or **REQUIRED**.
  If this option is not specified, the value of the `CMAKE_NETRC_FILE <https://cmake.org/cmake/help/latest/variable/CMAKE_NETRC_FILE.html>`_ variable will be used instead.

``EXPECTED_HASH <algorithm>=<value>``
  **Optional** Verify that the downloaded content hash matches the expected value, where <algorithm> is one of the algorithms supported by <HASH>.
  If the file already exists and matches the hash, the download is skipped.
  If the file already exists and does not match the hash, the file is downloaded again.
  If after download the file does not match the hash, the operation fails with an error.
  It is an error to specify this option if **DOWNLOAD** is not given a <file>.

``HTTPHEADER <HTTP-header>``
  **Optional** HTTP header for **DOWNLOAD** operation. `HTTPHEADER` can be repeated for multiple options.

``ALWAYS_DOWNLOAD <bool>``
  **Optional** Always redownload the list file.

#]=======================================================================]

if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

# The cmmm_entry
function(cmmm_entry)
  cmake_parse_arguments(CMMM "NO_CHANGELOG;NO_COLOR;SHOW_PROGRESS" "VERSION;TAG;DESTINATION;INACTIVITY_TIMEOUT;TIMEOUT;TLS_VERIFY;TLS_CAINFO;RETRIES" "" "${ARGN}")
  cmmm_check_updates()
  cmmm_colors()
  set_property(GLOBAL PROPERTY CMMM_SHOW_PROGRESS "${CMMM_SHOW_PROGRESS}")
  set_property(GLOBAL PROPERTY CMMM_DESTINATION "${CMMM_DESTINATION}")
  set_property(GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT "${CMMM_INACTIVITY_TIMEOUT}")
  set_property(GLOBAL PROPERTY CMMM_TIMEOUT "${CMMM_TIMEOUT}")
  set_property(GLOBAL PROPERTY CMMM_TLS_VERIFY "${CMMM_TLS_VERIFY}")
  set_property(GLOBAL PROPERTY CMMM_TLS_CAINFO "${CMMM_TLS_CAINFO}")
  set_property(GLOBAL PROPERTY CMMM_RETRIES "${CMMM_RETRIES}")
  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")
endfunction()

# Store colors
function(cmmm_colors)
  if(DEFINED ENV{CLICOLOR_FORCE} AND NOT "$ENV{CLICOLOR_FORCE}" STREQUAL "0")
    set(CMMM_NO_COLOR FALSE)
  elseif(DEFINED ENV{CLICOLOR} AND "$ENV{CLICOLOR}" STREQUAL "0")
    set(CMMM_NO_COLOR TRUE)
  elseif(DEFINED ENV{CI} AND NOT CMMM_NO_COLOR)
    set(CMMM_NO_COLOR FALSE)
  elseif(WIN32 OR DEFINED ENV{DevEnvDir} OR DEFINED ENV{workspaceRoot} OR CMMM_NO_COLOR)
    set(CMMM_NO_COLOR TRUE)
  endif()
  string(ASCII 27 CMMM_ESC)
  set_property(GLOBAL PROPERTY CMMM_NO_COLOR "${CMMM_NO_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_DEFAULT_COLOR "${CMMM_ESC}${CMMM_DEFAULT_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_FATAL_ERROR_COLOR "${CMMM_ESC}${CMMM_FATAL_ERROR_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_ERROR_COLOR "${CMMM_ESC}${CMMM_ERROR_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_WARN_COLOR "${CMMM_ESC}${CMMM_WARN_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_INFO_COLOR "${CMMM_ESC}${CMMM_INFO_COLOR}")
  set_property(GLOBAL PROPERTY CMMM_RESET_COLOR "${CMMM_ESC}[0m")
endfunction()

# Do the update check
function(cmmm_changes CHANGELOG_VERSION)
  if(${CMMM_VERSION} VERSION_LESS ${CHANGELOG_VERSION})
    message(STATUS "${CMMM_INFO_COLOR}[cmmm] Changes in v${CHANGELOG_VERSION} :${CMMM_RESET_COLOR}")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message(STATUS "${CMMM_INFO_COLOR}[cmmm]  ${CMMM_CHANGE}${CMMM_RESET_COLOR}")
    endforeach()
  endif()
endfunction()

# Print the changelog
function(cmmm_print_changelog)
  if(${CMMM_VERSION} VERSION_LESS ${CMMM_LATEST_VERSION})
    message(STATUS "${CMMM_INFO_COLOR}[cmmm] Using CMakeMM v${CMMM_VERSION}. The latest is v${CMMM_LATEST_VERSION}.${CMMM_RESET_COLOR}")
    message(STATUS "${CMMM_INFO_COLOR}[cmmm] Changes since v${CMMM_VERSION} include the following :${CMMM_RESET_COLOR}")
    cmmm_changelog()
    message(STATUS "${CMMM_INFO_COLOR}[cmmm] To update, simply change the value of VERSION in cmmm function.${CMMM_RESET_COLOR}")
    message(STATUS "${CMMM_INFO_COLOR}[cmmm] You can disable these messages by setting NO_CHANGELOG in cmmm function.${CMMM_RESET_COLOR}")
  endif()
endfunction()

# Check updates
function(cmmm_check_updates)
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")
  if(NOT ${CMMM_NO_CHANGELOG} AND NOT ${CMMM_VERSION} STREQUAL "latest")
    set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")

    if(EXISTS "${CMMM_CHANGELOG_FILE}")
      file(SHA256 "${CMMM_CHANGELOG_FILE}" CMakeMMSHA256)
    endif()

    set(CMMM_RETRIES_DONE "0")
    while(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_CHANGELOG_FILE}" OR "${CMakeMMSHA256}" STREQUAL "${CMMM_EMPTY_FILE_SHA256}")

      if(${CMMM_RETRIES_DONE} STREQUAL "0")
        message(STATUS "${CMMM_DEFAULT_COLOR}[cmmm] Downloading Changelog.cmake to ${CMMM_CHANGELOG_FILE}.${CMMM_RESET_COLOR}")
      else()
        message(STATUS "${CMMM_WARN_COLOR}[cmmm] Retrying (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_RESET_COLOR}")
      endif()

      file(DOWNLOAD "https://cmake-tools.github.io/cmmm/latest/Changelog.cmake" "${CMMM_CHANGELOG_FILE}" ${CMMM_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS)
      list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
      list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
      if(NOT "${CMAKECM_CODE}" STREQUAL "0")
        message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading Changelog.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${CMMM_RESET_COLOR}")
      else()
        file(SHA256 "${CMMM_CHANGELOG_FILE}" CMakeMMSHA256)
        if(${CMakeMMSHA256} STREQUAL "${CMMM_EMPTY_FILE_SHA256}")
          file(REMOVE "${CMMM_CHANGELOG_FILE}")
          message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading Changelog.cmake : Empty file.${CMMM_RESET_COLOR}")
        else()
          break()
        endif()
      endif()
      if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
        message(STATUS "${CMMM_RESET_COLOR}[cmmm] Error downloading Changelog.cmake. Skipping !${CMMM_RESET_COLOR}")
        break()
      endif()
      math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
    endwhile()
    if(EXISTS "${CMMM_CHANGELOG_FILE}")
      include("${CMMM_CHANGELOG_FILE}")
      cmmm_print_changelog()
      file(WRITE "${CMMM_CHANGELOG_FILE}" "")
    endif()
  endif()
endfunction()

# Parse the argument in case a single one was provided and convert it to a list of arguments which can then be parsed idiomatically.
# For example gh:foo/bar#tag will be converted to: GITHUB_REPOSITORY;foo/bar;GIT_TAG;tag
function(cmmm_parse_single_arg arg outArgs)
  # Look for a scheme
  if("${arg}" MATCHES "^([a-zA-Z]+):(.+)$")
    string(TOLOWER "${CMAKE_MATCH_1}" scheme)
    set(url "${CMAKE_MATCH_2}")

    # Check for CPM-specific schemes
    if(scheme STREQUAL "gh")
      set(out "GITHUB_REPOSITORY;${url}")
      set(packageType "git")
    elseif(scheme STREQUAL "gl")
      set(out "GITLAB_REPOSITORY;${url}")
      set(packageType "git")
    elseif(scheme STREQUAL "bb")
      set(out "BITBUCKET_REPOSITORY;${url}")
      set(packageType "git")
    else()
      # Fall back to a URL
      set(out "URL;${arg}")
      set(packageType "archive")
    endif()
  else()
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] Can't determine type of '${arg}'.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "Can't determine type of '${arg}'.")
  endif()

  # Parse the rest according to package type
  if(packageType STREQUAL "git")
    # For git repos we interpret #... as a tag or branch or commit hash
    string(REGEX REPLACE "#([^#]+)$" ";GIT_TAG;\\1" out "${out}")
  endif()

  set(${outArgs} ${out} PARENT_SCOPE)
endfunction()

# Download the modules list
function(cmmm_modules_list)
  cmake_parse_arguments(CMMM
                        "NO_COLOR;SHOW_PROGRESS;ALWAYS_DOWNLOAD"
                        "URL;FILEPATH;DESTINATION;RETRIES;INACTIVITY_TIMEOUT;TIMEOUT;USERPWD;NETRC;NETRC_FILE;TLS_VERIFY;TLS_CAINFO;EXPECTED_HASH"
                        "HTTPHEADER"
                        "${ARGN}")

  set_property(GLOBAL PROPERTY CMMM_ALWAYS_DOWNLOAD "${CMMM_ALWAYS_DOWNLOAD}")
  if(NOT DEFINED CMMM_NO_COLOR)
    get_property(CMMM_NO_COLOR GLOBAL PROPERTY CMMM_NO_COLOR)
  endif()
  if(NOT CMMM_NO_COLOR)
    get_property(CMMM_DEFAULT_COLOR GLOBAL PROPERTY CMMM_DEFAULT_COLOR)
    get_property(CMMM_FATAL_ERROR_COLOR GLOBAL PROPERTY CMMM_FATAL_ERROR_COLOR)
    get_property(CMMM_ERROR_COLOR GLOBAL PROPERTY CMMM_ERROR_COLOR)
    get_property(CMMM_WARN_COLOR GLOBAL PROPERTY CMMM_WARN_COLOR)
    get_property(CMMM_INFO_COLOR GLOBAL PROPERTY CMMM_INFO_COLOR)
    get_property(CMMM_RESET_COLOR GLOBAL PROPERTY CMMM_RESET_COLOR)
  endif()
  if(NOT DEFINED CMMM_SHOW_PROGRESS)
    get_property(CMMM_SHOW_PROGRESS GLOBAL PROPERTY CMMM_SHOW_PROGRESS)
  endif()
  if(NOT DEFINED CMMM_DESTINATION)
    get_property(CMMM_DESTINATION GLOBAL PROPERTY CMMM_DESTINATION)
    # This can happen when fetching content
    if("${CMMM_DESTINATION}" STREQUAL "")
      set(CMMM_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/cmmm")
    endif()
    string(FIND ${CMMM_DESTINATION} "/" CMMM_FOUND REVERSE)
    string(LENGTH ${CMMM_DESTINATION} CMMM_SIZE)
    math(EXPR CMMM_SIZE "${CMMM_SIZE}-1")
    if("${CMMM_SIZE}" STREQUAL "${CMMM_FOUND}")
      string(SUBSTRING ${CMMM_DESTINATION} "0" "${CMMM_SIZE}" CMMM_DESTINATION)
    endif()
    set(CMMM_DESTINATION "${CMMM_DESTINATION}/modules_lists")
  else()
    string(FIND ${CMMM_DESTINATION} "/" CMMM_FOUND REVERSE)
    string(LENGTH ${CMMM_DESTINATION} CMMM_SIZE)
    math(EXPR CMMM_SIZE "${CMMM_SIZE}-1")
    if("${CMMM_SIZE}" STREQUAL "${CMMM_FOUND}")
      string(SUBSTRING ${CMMM_DESTINATION} "0" "${CMMM_SIZE}" CMMM_DESTINATION)
    endif()
  endif()

  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")

  if(NOT DEFINED CMMM_INACTIVITY_TIMEOUT)
    get_property(CMMM_INACTIVITY_TIMEOUT GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT)
  endif()
  if(NOT DEFINED CMMM_TIMEOUT)
    get_property(CMMM_TIMEOUT GLOBAL PROPERTY CMMM_TIMEOUT)
  endif()
  if(NOT DEFINED CMMM_TLS_VERIFY)
    get_property(CMMM_TLS_VERIFY GLOBAL PROPERTY CMMM_TLS_VERIFY)
  endif()
  if(NOT DEFINED CMMM_TLS_CAINFO)
    get_property(CMMM_TLS_CAINFO GLOBAL PROPERTY CMMM_TLS_CAINFO)
  endif()
  if(NOT DEFINED CMMM_RETRIES)
    get_property(CMMM_RETRIES GLOBAL PROPERTY CMMM_RETRIES)
  endif()

  if(NOT DEFINED CMMM_URL)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] URL must be present.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "URL must be present.")
  endif()

  cmmm_parse_single_arg(${CMMM_URL} CMMM_URL_RETURN)
  unset(CMMM_URL)
  cmake_parse_arguments(CMMM "" "URL;GITHUB_REPOSITORY;GITLAB_REPOSITORY;BITBUCKET_REPOSITORY;GIT_TAG" "" "${CMMM_URL_RETURN}")

  if(DEFINED CMMM_URL AND DEFINED CMMM_FILEPATH)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] FILEPATH is incompatible with an URL.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "FILEPATH is incompatible with an URL.")
  endif()

  if(NOT DEFINED CMMM_GIT_TAG)
    set(CMMM_GIT_TAG "main")
  endif()
  if(NOT DEFINED CMMM_FILEPATH)
    set(CMMM_FILEPATH "ModulesList.cmake")
  else()
    string(FIND ${CMMM_FILEPATH} "/" CMMM_FOUND)
    if("${CMMM_FOUND}" STREQUAL "0")
      string(SUBSTRING ${CMMM_FILEPATH} "1" "-1" CMMM_FILEPATH)
    endif()
  endif()
  if(DEFINED CMMM_GITHUB_REPOSITORY)
    set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_GITHUB_REPOSITORY}/${CMMM_GIT_TAG}")
  elseif(DEFINED CMMM_GITLAB_REPOSITORY)
    set(CMMM_URL "https://gitlab.com/${CMMM_GITLAB_REPOSITORY}/-/raw/${CMMM_GIT_TAG}")
  elseif(DEFINED CMMM_BITBUCKET_REPOSITORY)
    set(CMMM_URL "https://bitbucket.org/${CMMM_BITBUCKET_REPOSITORY}/raw/${CMMM_GIT_TAG}")
  endif()

  string(FIND "${CMMM_URL}/${CMMM_FILEPATH}" "/" CMMM_FOUND REVERSE)
  math(EXPR CMMM_FOUND "${CMMM_FOUND}+1")
  string(SUBSTRING "${CMMM_URL}/${CMMM_FILEPATH}" "${CMMM_FOUND}" "-1" CMMM_FILE)

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${CMMM_DESTINATION}/${CMMM_FILE}.lock" RELEASE)
    endif()
  endfunction()

  if(EXISTS "${CMMM_DESTINATION}/${CMMM_FILE}")
    file(SHA256 "${CMMM_DESTINATION}/${CMMM_FILE}" CMakeMMSHA256)
  endif()

  set(ARGUMENTS "")
  set(CMMM_COMMAND "")
  list(APPEND ARGUMENTS INACTIVITY_TIMEOUT TIMEOUT USERPWD NETRC NETRC_FILE TLS_VERIFY TLS_CAINFO EXPECTED_HASH)
  foreach(ARG IN LISTS ARGUMENTS)
    if(DEFINED CMMM_${ARG} AND NOT "${CMMM_${ARG}}" STREQUAL "")
      set(CMMM_COMMAND "${CMMM_COMMAND};${ARG};${CMMM_${ARG}}")
    endif()
  endforeach()

  if(CMMM_SHOW_PROGRESS)
    set(CMMM_COMMAND "${CMMM_COMMAND};SHOW_PROGRESS")
  endif()

  if(NOT "${CMMM_HTTPHEADER}" STREQUAL "")
    set(CMMM_COMMAND "${CMMM_COMMAND};HTTPHEADER;${CMMM_HTTPHEADER}")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${CMMM_DESTINATION}/${CMMM_FILE}.lock")
  endif()

  if(DEFINED "CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}" AND NOT "${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}" STREQUAL "${CMMM_URL}")
    message(STATUS
            "${CMMM_FATAL_ERROR_COLOR}[cmmm] It already exists ${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}.
            Impossible to download the one from ${CMMM_URL}/${CMMM_FILEPATH}.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR
            "It already exists ${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}.
            Impossible to download the one from ${CMMM_URL}/${CMMM_FILEPATH}.")
  endif()

  set(CMMM_RETRIES_DONE "0")
  while(NOT DEFINED "CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}" OR NOT EXISTS "${CMMM_DESTINATION}/${CMMM_FILE}" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" OR CMMM_ALWAYS_DOWNLOAD)
    if(${CMMM_RETRIES_DONE} STREQUAL "0")
      message(STATUS "${CMMM_DEFAULT_COLOR}[cmmm] Downloading ${CMMM_URL} to ${CMMM_DESTINATION}/${CMMM_FILE}${CMMM_RESET_COLOR}")
    else()
      message(STATUS "${CMMM_INFO_COLOR}[cmmm] Retry downloading ${CMMM_URL} (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_RESET_COLOR}")
    endif()

    file(DOWNLOAD "${CMMM_URL}/${CMMM_FILEPATH}" "${CMMM_DESTINATION}/${CMMM_FILE}" ${CMMM_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS)
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(NOT "${CMAKECM_CODE}" STREQUAL "0")
      message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading ${CMMM_URL} : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${CMMM_RESET_COLOR}")
    else()
      file(SHA256 "${CMMM_DESTINATION}/${CMMM_FILE}" CMakeMMSHA256)
      if("${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${CMMM_DESTINATION}/${CMMM_FILE}")
        message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading ${CMMM_URL} : Empty file.${CMMM_RESET_COLOR}")
      else()
        break()
      endif()
    endif()
    if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
      unlock()
      message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] Error downloading ${CMMM_URL}.${CMMM_RESET_COLOR}")
      message(FATAL_ERROR "Error downloading ${CMMM_URL}.")
    endif()
    math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
  endwhile()

  include("${CMMM_DESTINATION}/${CMMM_FILE}")
  unlock()

  list(APPEND CMAKE_MODULE_PATH "${CMMM_DESTINATION}/premodules")
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  set(CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE} "${CMMM_URL}" CACHE INTERNAL "${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMMM_URL}.")
endfunction()

# Module definition
function(cmmm_define_module NAME)
  cmake_parse_arguments(ARG "" "REMOTE;LOCAL;EXPECTED_HASH;DESCRIPTION;VERSION;FILEPATH;TAG" "" "${ARGN}")

  if(NOT ARG_REMOTE AND NOT ARG_LOCAL)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] Either LOCAL or REMOTE is required as cmmm_define_module argument.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "Either LOCAL or REMOTE is required as cmmm_define_module argument.")
  elseif(ARG_REMOTE AND ARG_LOCAL)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] LOCAL and REMOTE can't be used simultaneously as cmmm_define_module argument.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "LOCAL and REMOTE can't be used simultaneously as cmmm_define_module argument.")
  endif()

  set(CMMM_DESTINATION_PREMODULES "${CMMM_DESTINATION}/premodules")
  get_filename_component(CMMM_DESTINATION_PREMODULES "${CMMM_DESTINATION_PREMODULES}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_PREMODULES}")

  set(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION}/modules")
  get_filename_component(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION_MODULES}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_MODULES}")

  set(CMMM_COMMAND "")
  list(APPEND CMMM_COMMAND "NAME" "${NAME}" "DESTINATION" "${CMMM_DESTINATION_MODULES}/${NAME}.cmake")
  if(DEFINED ARG_REMOTE)
    cmmm_parse_single_arg(${ARG_REMOTE} ARG_REMOTE_RETURN)
    cmake_parse_arguments(CMMM "" "URL;GITHUB_REPOSITORY;GITLAB_REPOSITORY;BITBUCKET_REPOSITORY;GIT_TAG" "" "${ARG_REMOTE_RETURN}")
    if(NOT DEFINED CMMM_GIT_TAG)
      set(CMMM_GIT_TAG "main")
    endif()
    if(DEFINED CMMM_GITHUB_REPOSITORY)
      set(CMMM_URL "https://raw.githubusercontent.com/${CMMM_GITHUB_REPOSITORY}/${CMMM_GIT_TAG}/${ARG_FILEPATH}")
    elseif(DEFINED CMMM_GITLAB_REPOSITORY)
      set(CMMM_URL "https://gitlab.com/${CMMM_GITLAB_REPOSITORY}/-/raw/${CMMM_GIT_TAG}/${ARG_FILEPATH}")
    elseif(DEFINED CMMM_BITBUCKET_REPOSITORY)
      set(CMMM_URL "https://bitbucket.org/${CMMM_BITBUCKET_REPOSITORY}/raw/${CMMM_GIT_TAG}/${ARG_FILEPATH}")
    endif()
    list(APPEND CMMM_COMMAND "URL" "${CMMM_URL}")
  else()
    string(FIND ${ARG_LOCAL} "/" CMMM_FOUND)
    if("${CMMM_FOUND}" STREQUAL "0")
      string(SUBSTRING ${ARG_LOCAL} "1" "-1" ARG_LOCAL)
    endif()

    list(APPEND CMMM_COMMAND "URL" "${CMMM_URL}/${ARG_LOCAL}")
  endif()
  set(COMMAND "")
  list(APPEND COMMAND EXPECTED_HASH DESCRIPTION VERSION RETRIES)
  foreach(ARG IN LISTS COMMAND)
    if(DEFINED ARG_${ARG} AND NOT "${ARG_${ARG}}" STREQUAL "")
      list(APPEND CMMM_COMMAND "${ARG}" "${ARG_${ARG}}")
    endif()
  endforeach()

  file(WRITE "${CMMM_DESTINATION_PREMODULES}/${NAME}.cmake" "cmmm_include_module(${CMMM_COMMAND})")
endfunction()

# Module download
macro(CMMM_INCLUDE_MODULE)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()
  cmake_parse_arguments(ARG "" "NAME;URL;EXPECTED_HASH;DESCRIPTION;VERSION;DESTINATION" "" "${ARGN}")
  get_property(CMMM_DEFAULT_COLOR GLOBAL PROPERTY CMMM_DEFAULT_COLOR)
  get_property(CMMM_FATAL_ERROR_COLOR GLOBAL PROPERTY CMMM_FATAL_ERROR_COLOR)
  get_property(CMMM_ERROR_COLOR GLOBAL PROPERTY CMMM_ERROR_COLOR)
  get_property(CMMM_WARN_COLOR GLOBAL PROPERTY CMMM_WARN_COLOR)
  get_property(CMMM_INFO_COLOR GLOBAL PROPERTY CMMM_INFO_COLOR)
  get_property(CMMM_RESET_COLOR GLOBAL PROPERTY CMMM_RESET_COLOR)

  get_property(CMMM_RETRIES GLOBAL PROPERTY CMMM_RETRIES)

  set(CMMM_COMMAND "")
  list(APPEND PROPERTIES "CMMM_INACTIVITY_TIMEOUT" "CMMM_TIMEOUT" "CMMM_TLS_VERIFY" "CMMM_TLS_CAINFO" "CMMM_NETRC" "CMMM_NETRC_FILE")
  foreach(PROPERTY IN LISTS PROPERTIES)
    get_property(${PROPERTY} GLOBAL PROPERTY ${PROPERTY})
    if(NOT "${${PROPERTY}}" STREQUAL "")
      list(APPEND CMMM_COMMAND "${PROPERTY}" "${${PROPERTY}}")
    endif()
  endforeach()

  get_property(CMMM_SHOW_PROGRESS GLOBAL PROPERTY CMMM_SHOW_PROGRESS)
  if(CMMM_SHOW_PROGRESS)
    list(APPEND CMMM_COMMAND "SHOW_PROGRESS")
  endif()

  get_property(CMMM_ALWAYS_DOWNLOAD GLOBAL PROPERTY CMMM_ALWAYS_DOWNLOAD)

  if(DEFINED ARG_EXPECTED_HASH)
    set(CMMM_EXPECTED_HASH_COMMAND "EXPECTED_HASH;${ARG_EXPECTED_HASH}")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${ARG_DESTINATION}.lock")
  endif()

  if(EXISTS "${ARG_DESTINATION}")
    file(SHA256 "${ARG_DESTINATION}" CMakeMMSHA256)
  endif()

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${ARG_DESTINATION}.lock" RELEASE)
    endif()
  endfunction()

  set(CMMM_RETRIES_DONE "0")
  while(NOT EXISTS "${ARG_DESTINATION}" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" OR CMMM_ALWAYS_DOWNLOAD)
    if(${CMMM_RETRIES_DONE} STREQUAL "0")
      message(STATUS "${CMMM_DEFAULT_COLOR}[cmmm] Downloading ${ARG_URL} to ${ARG_DESTINATION}${CMMM_RESET_COLOR}")
    else()
      message(STATUS "${CMMM_INFO_COLOR}[cmmm] Retry downloading ${ARG_URL} (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_RESET_COLOR}")
    endif()

    file(DOWNLOAD "${ARG_URL}" "${ARG_DESTINATION}" LOG CMMM_LOG STATUS CMAKECM_STATUS ${CMMM_COMMAND})
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(NOT "${CMAKECM_CODE}" STREQUAL "0")
      message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading ${ARG_URL} : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${CMMM_RESET_COLOR}")
    else()
      file(SHA256 "${ARG_DESTINATION}" CMakeMMSHA256)
      if("${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${ARG_DESTINATION}")
        message(STATUS "${CMMM_ERROR_COLOR}[cmmm] Error downloading ${ARG_URL} : Empty file.${CMMM_RESET_COLOR}")
      else()
        break()
      endif()
    endif()
    if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
      unlock()
      message(STATUS "${CMMM_FATAL_ERROR_COLOR}[cmmm] Error downloading ${ARG_NAME}.${CMMM_RESET_COLOR}")
      message(FATAL_ERROR "Error downloading ${ARG_NAME}.")
    endif()
    math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
  endwhile()

  unlock()
  include("${ARG_DESTINATION}")

  set(DESCRIPTION "${ARG_NAME}")
  if(DEFINED ARG_VERSION)
    set(DESCRIPTION "${DESCRIPTION} (v${ARG_VERSION})")
  endif()
  if(DEFINED ARG_DESCRIPTION)
    set(DESCRIPTION "${DESCRIPTION} (v${ARG_VERSION}) : ${ARG_DESCRIPTION}.")
  endif()
  set(CMAKEMM_MODULE_${ARG_NAME} "${ARG_URL}" CACHE INTERNAL "${DESCRIPTION}")
endmacro()
