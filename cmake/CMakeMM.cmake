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
    message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] Changes in v${CHANGELOG_VERSION} :${CMMM_ESC}${CMMM_RESET_COLOR}")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ]  ${CMMM_CHANGE}${CMMM_ESC}${CMMM_RESET_COLOR}")
    endforeach()
  endif()
endfunction()

# Print the changelog
function(cmmm_print_changelog)
  message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] Using CMakeMM v${CMMM_VERSION}. The latest is v${CMMM_LATEST_VERSION}.${CMMM_ESC}${CMMM_RESET_COLOR}")
  message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] Changes since v${CMMM_VERSION} include the following :${CMMM_ESC}${CMMM_RESET_COLOR}")
  cmmm_changelog()
  message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] To update, simply change the value of VERSION in cmmm function.${CMMM_ESC}${CMMM_RESET_COLOR}")
  message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] You can disable these messages by setting NO_CHANGELOG in cmmm function.${CMMM_ESC}${CMMM_RESET_COLOR}")
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
        message(STATUS "${CMMM_ESC}${CMMM_DEFAULT_COLOR}[ CMMM ] Downloading Changelog.cmake to ${CMMM_CHANGELOG_FILE}.${CMMM_ESC}${CMMM_RESET_COLOR}")
      else()
        message(STATUS "${CMMM_ESC}${CMMM_WARN_COLOR}[ CMMM ] Retrying (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_ESC}${CMMM_RESET_COLOR}")
      endif()

      file(DOWNLOAD "https://cmake-tools.github.io/cmmm/_static/latest/Changelog.cmake" "${CMMM_CHANGELOG_FILE}" ${CMMM_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS)
      list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
      list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
      if(${CMAKECM_CODE})
        message(STATUS "${CMMM_ESC}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading Changelog.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${CMMM_ESC}${CMMM_RESET_COLOR}")
      else()
        file(SHA256 "${CMMM_CHANGELOG_FILE}" CMakeMMSHA256)
        if(${CMakeMMSHA256} STREQUAL "${CMMM_EMPTY_FILE_SHA256}")
          file(REMOVE "${CMMM_CHANGELOG_FILE}")
          message(STATUS "${CMMM_ESC}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading Changelog.cmake : Empty file.${CMMM_ESC}${CMMM_RESET_COLOR}")
        else()
          break()
        endif()
      endif()
      if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
        message(STATUS "${CMMM_ESC}${CMMM_RESET_COLOR}[ CMMM ] Error downloading Changelog.cmake. Skipping !${CMMM_ESC}${CMMM_RESET_COLOR}")
        break()
      endif()
      math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
    endwhile()
    if(EXISTS "${CMMM_CHANGELOG_FILE}")
      include("${CMMM_CHANGELOG_FILE}")
      cmmm_print_changelog()
    endif()
  endif()
endfunction()

# Parse the argument in case a single one was provided and convert it to a list of arguments which can then be parsed idiomatically.
# For example gh:foo/bar#tag will be converted to: GITHUB_REPOSITORY;foo/bar;GIT_TAG;tag
function(cmmm_parse_single_arg arg outArgs)
  # Look for a scheme
  if("${arg}" MATCHES "^([a-zA-Z]+):(.+)$")
    string(TOLOWER "${CMAKE_MATCH_1}" scheme)
    set(uri "${CMAKE_MATCH_2}")

    # Check for CPM-specific schemes
    if(scheme STREQUAL "gh")
      set(out "GITHUB_REPOSITORY;${uri}")
      set(packageType "git")
    elseif(scheme STREQUAL "gl")
      set(out "GITLAB_REPOSITORY;${uri}")
      set(packageType "git")
    elseif(scheme STREQUAL "bb")
      set(out "BITBUCKET_REPOSITORY;${uri}")
      set(packageType "git")
    else()
      # Fall back to a URL
      set(out "URL;${arg}")
      set(packageType "archive")
    endif()
  else()
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[ CMMM ] Can't determine type of '${arg}'.${CMMM_RESET_COLOR}")
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
                        "URI;FILEPATH;DESTINATION;RETRIES;INACTIVITY_TIMEOUT;TIMEOUT;USERPWD;NETRC;NETRC_FILE;TLS_VERIFY;TLS_CAINFO;EXPECTED_HASH"
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
  get_filename_component(CMMM_DESTINATION "${CMMM_DESTINATION}" ABSOLUTE BASE_DIR "${CMAKE_BINARY_DIR}")

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
    message(STATUS "NOT DEFINED RETRIE")
    get_property(CMMM_RETRIES GLOBAL PROPERTY CMMM_RETRIES)
  endif()

  if(NOT DEFINED CMMM_URI)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[ CMMM ] URI must be present.${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "URI must be present.")
  endif()

  cmmm_parse_single_arg(${CMMM_URI} CMMM_URI)
  cmake_parse_arguments(CMMM "" "URL;GITHUB_REPOSITORY;GITLAB_REPOSITORY;BITBUCKET_REPOSITORY;GIT_TAG" "" "${CMMM_URI}")

  if(DEFINED CMMM_URL AND DEFINED CMMM_FILEPATH)
    message(STATUS "${CMMM_FATAL_ERROR_COLOR}[ CMMM ] FILEPATH is incompatible with an URL.${CMMM_RESET_COLOR}")
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

  set(COMMAND "")
  set(CMMM_COMMAND "")
  list(APPEND COMMAND INACTIVITY_TIMEOUT TIMEOUT USERPWD NETRC NETRC_FILE TLS_VERIFY TLS_CAINFO EXPECTED_HASH)
  foreach(X IN LISTS COMMAND)
    if(DEFINED CMMM_${X} AND NOT "${CMMM_${X}}" STREQUAL "")
      set(CMMM_COMMAND "${X};${CMMM_${X}}")
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

  if(DEFINED "CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}" AND NOT "${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}" STREQUAL "${CMMM_URL}/${CMMM_FILEPATH}")
    message(STATUS
            "${CMMM_ESC}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] It already exists ${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}.
            Impossible to download the one from ${CMMM_URL}/${CMMM_FILEPATH}.${CMMM_ESC}${CMMM_RESET_COLOR}")
    message(FATAL_ERROR
            "It already exists ${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}}.
            Impossible to download the one from ${CMMM_URL}/${CMMM_FILEPATH}.")
  endif()

  set(CMMM_RETRIES_DONE "0")
  while(NOT DEFINED "CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE}" OR NOT EXISTS "${CMMM_DESTINATION}/${CMMM_FILE}" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" OR CMMM_ALWAYS_DOWNLOAD)
    if(${CMMM_RETRIES_DONE} STREQUAL "0")
      message(STATUS "${CMMM_ESC}${CMMM_DEFAULT_COLOR}[ CMMM ] Downloading ${CMMM_URL}/${CMMM_FILEPATH} to ${CMMM_DESTINATION}/${CMMM_FILE}${CMMM_ESC}${CMMM_RESET_COLOR}")
    else()
      message(STATUS "${CMMM_ESC}${CMMM_INFO_COLOR}[ CMMM ] Retry downloading ${CMMM_URL}/${CMMM_FILEPATH} (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${CMMM_ESC}${CMMM_RESET_COLOR}")
    endif()

    file(DOWNLOAD "${CMMM_URL}/${CMMM_FILEPATH}" "${CMMM_DESTINATION}/${CMMM_FILE}" ${CMMM_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS)
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading CMakeMM.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${Esc}${CMMM_RESET_COLOR}")
    else()
      file(SHA256 "${CMMM_DESTINATION}/${CMMM_FILE}" CMakeMMSHA256)
      if("${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${CMMM_DESTINATION}/${CMMM_FILE}")
        message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading ${CMMM_FILE} : Empty file.${Esc}${CMMM_RESET_COLOR}")
      else()
        break()
      endif()
    endif()
    if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
      unlock()
      message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] Error downloading ${CMMM_FILE}.${Esc}${CMMM_RESET_COLOR}")
      message(FATAL_ERROR "Error downloading ${CMMM_FILE}.")
    endif()
    math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
  endwhile()

  include("${CMMM_DESTINATION}/${CMMM_FILE}")
  unlock()

  list(APPEND CMAKE_MODULE_PATH "${CMMM_DESTINATION}/premodules")
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  set(CMAKEMM_INITIALIZED_${CMMM_DESTINATION}_${CMMM_FILE} "${CMMM_URL}/${CMMM_FILEPATH}" CACHE INTERNAL "${CMMM_DESTINATION}/${CMMM_FILE} downloaded from ${CMMM_URL}/${CMMM_FILEPATH}.")
endfunction()

# Module definition
function(cmmm_define_module NAME)
  cmake_parse_arguments(ARG "" "REMOTE;LOCAL;EXPECTED_HASH" "" "${ARGN}")

  if(NOT ARG_REMOTE AND NOT ARG_LOCAL)
    message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] Either LOCAL or REMOTE is required as cmmm_define_module argument.${Esc}${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "Either LOCAL or REMOTE is required as cmmm_define_module argument.")
  elseif(ARG_REMOTE AND ARG_LOCAL)
    message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] LOCAL and REMOTE can't be used simultaneously as cmmm_define_module argument.${Esc}${CMMM_RESET_COLOR}")
    message(FATAL_ERROR "LOCAL and REMOTE can't be used simultaneously as cmmm_define_module argument.")
  endif()

  set(CMMM_DESTINATION_PREMODULES "${CMAKE_CURRENT_LIST_DIR}/premodules")
  get_filename_component(CMMM_DESTINATION_PREMODULES "${CMMM_DESTINATION_PREMODULES}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_PREMODULES}")

  set(CMMM_DESTINATION_MODULES "${CMAKE_CURRENT_LIST_DIR}/modules")
  get_filename_component(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION_MODULES}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_MODULES}")

  list(APPEND CMAKE_MODULE_PATH "${CMMM_DESTINATION_PREMODULES}")
  set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

  string(FIND ${ARG_LOCAL} "/" CMMM_FOUND)
  if("${CMMM_FOUND}" STREQUAL "0")
    string(SUBSTRING ${ARG_LOCAL} "1" "-1" ARG_LOCAL)
  endif()

  if(ARG_EXPECTED_HASH)
    set(EXPECTED_HASH_COMMAND "EXPECTED_HASH;${ARG_EXPECTED_HASH}")
  endif()

  if(ARG_REMOTE)
    file(WRITE "${CMMM_DESTINATION_PREMODULES}/${NAME}.cmake" "cmmm_include_module(NAME [[${NAME}]] DESTINATION [[]] URL [[${ARG_REMOTE}]]
                                                              ${EXPECTED_HASH_COMMAND} DESCRIPTION [[${ARG_DESCRIPTION}]] VERSION [[${ARG_VERSION}]] RETRIES [[${CMMM_RETRIES}]])")
  else()
    file(WRITE "${CMMM_DESTINATION_PREMODULES}/${NAME}.cmake" "cmmm_include_module(NAME [[${NAME}]] URL [[${CMMM_URL}/${ARG_LOCAL}]]
                                                              ${EXPECTED_HASH_COMMAND} DESCRIPTION  [[${ARG_DESCRIPTION}]] VERSION [[${ARG_VERSION}]] RETRIES [[${CMMM_RETRIES}]])")
  endif()
endfunction()

# Module download
macro(CMMM_INCLUDE_MODULE)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()
  cmake_parse_arguments(ARG "" "NAME;URL;EXPECTED_HASH;DESCRIPTION;VERSION;RETRIES" "" "${ARGN}")
  get_property(CMMM_DEFAULT_COLOR GLOBAL PROPERTY CMMM_DEFAULT_COLOR)
  get_property(CMMM_FATAL_ERROR_COLOR GLOBAL PROPERTY CMMM_FATAL_ERROR_COLOR)
  get_property(CMMM_ERROR_COLOR GLOBAL PROPERTY CMMM_ERROR_COLOR)
  get_property(CMMM_WARN_COLOR GLOBAL PROPERTY CMMM_WARN_COLOR)
  get_property(CMMM_INFO_COLOR GLOBAL PROPERTY CMMM_INFO_COLOR)
  get_property(CMMM_RESET_COLOR GLOBAL PROPERTY CMMM_RESET_COLOR)

  get_property(CMMM_INACTIVITY_TIMEOUT GLOBAL PROPERTY CMMM_INACTIVITY_TIMEOUT)
  if(NOT "${CMMM_INACTIVITY_TIMEOUT}" STREQUAL "")
    set(CMMM_INACTIVITY_TIMEOUT_COMMAND "INACTIVITY_TIMEOUT;${CMMM_INACTIVITY_TIMEOUT}")
  endif()
  get_property(CMMM_TIMEOUT GLOBAL PROPERTY CMMM_TIMEOUT)
  if(NOT "${CMMM_TIMEOUT}" STREQUAL "")
    set(CMMM_TIMEOUT_COMMAND "TIMEOUT;${CMMM_TIMEOUT}")
  endif()
  get_property(CMMM_TLS_VERIFY GLOBAL PROPERTY CMMM_TLS_VERIFY)
  if(NOT "${CMMM_TLS_VERIFY}" STREQUAL "")
    set(CMMM_TLS_VERIFY_COMMAND "TLS_VERIFY;${CMMM_TLS_VERIFY}")
  endif()
  get_property(CMMM_TLS_CAINFO GLOBAL PROPERTY CMMM_TLS_CAINFO)
  if(NOT "${CMMM_TLS_CAINFO}" STREQUAL "")
    set(CMMM_TLS_CAINFO_COMMAND "TLS_CAINFO;${CMMM_TLS_CAINFO}")
  endif()
  get_property(CMMM_NETRC GLOBAL PROPERTY CMMM_NETRC)
  if(NOT "${CMMM_NETRC}" STREQUAL "")
    set(CMMM_NETRC_COMMAND "NETRC;${CMMM_NETRC}")
  endif()
  get_property(CMMM_NETRC_FILE GLOBAL PROPERTY CMMM_NETRC_FILE)
  if(NOT "${CMMM_NETRC_FILE}" STREQUAL "")
    set(CMMM_NETRC_FILE_COMMAND "NETRC_FILE;${CMMM_NETRC_FILE}")
  endif()
  get_property(CMMM_SHOW_PROGRESS GLOBAL PROPERTY CMMM_SHOW_PROGRESS)
  if(CMMM_SHOW_PROGRESS)
    set(CMMM_SHOW_PROGRESS_COMMAND "SHOW_PROGRESS")
  endif()

  get_property(CMMM_ALWAYS_DOWNLOAD GLOBAL PROPERTY CMMM_ALWAYS_DOWNLOAD)

  get_property(CMMM_DESTINATION_MODULES GLOBAL PROPERTY CMMM_DESTINATION)
  string(FIND ${CMMM_DESTINATION_MODULES} "/" CMMM_FOUND REVERSE)
  string(LENGTH ${CMMM_DESTINATION_MODULES} CMMM_SIZE)
  math(EXPR CMMM_SIZE "${CMMM_SIZE}-1")
  if("${CMMM_SIZE}" STREQUAL "${CMMM_FOUND}")
    string(SUBSTRING ${CMMM_DESTINATION_MODULES} "0" "${CMMM_SIZE}" CMMM_DESTINATION_MODULES)
  endif()
  set(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION_MODULES}/modules")
  get_filename_component(CMMM_DESTINATION_MODULES "${CMMM_DESTINATION_MODULES}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
  file(MAKE_DIRECTORY "${CMMM_DESTINATION_MODULES}")

  if(DEFINED ARG_EXPECTED_HASH)
    set(CMMM_EXPECTED_HASH_COMMAND "EXPECTED_HASH;${ARG_EXPECTED_HASH}")
  endif()

  if(NOT CMAKE_VERSION VERSION_LESS 3.2)
    file(LOCK "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.lock")
  endif()

  if(EXISTS "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake")
    file(SHA256 "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake" CMakeMMSHA256)
  endif()

  # Unlock file
  function(unlock)
    if(NOT CMAKE_VERSION VERSION_LESS 3.2)
      file(LOCK "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.lock" RELEASE)
    endif()
  endfunction()

  set(CMMM_RETRIES_DONE "0")
  while(NOT EXISTS "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" OR CMMM_ALWAYS_DOWNLOAD)
    if(${CMMM_RETRIES_DONE} STREQUAL "0")
      message(STATUS "${Esc}${CMMM_DEFAULT_COLOR}[ CMMM ] Downloading ${ARG_URL} to ${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake${Esc}${CMMM_RESET_COLOR}")
    else()
      message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] Retry downloading ${ARG_URL} (${CMMM_RETRIES_DONE}/${ARG_RETRIES}).${Esc}${CMMM_RESET_COLOR}")
    endif()

    file(
      DOWNLOAD "${ARG_URL}" "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake" LOG CMMM_LOG STATUS CMAKECM_STATUS
      ${CMMM_INACTIVITY_TIMEOUT_COMMAND} ${CMMM_TIMEOUT_COMMAND} ${CMMM_TLS_VERIFY_COMMAND}
      ${CMMM_TLS_CAINFO_COMMAND} ${CMMM_NETRC_COMMAND} ${CMMM_NETRC_FILE_COMMAND} ${CMMM_EXPECTED_HASH_COMMAND} ${CMMM_SHOW_PROGRESS_COMMAND}
    )
    list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
    list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
    if(${CMAKECM_CODE})
      message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading ${ARG_URL} : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${Esc}${CMMM_RESET_COLOR}")
    else()
      file(SHA256 "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake" CMakeMMSHA256)
      if("${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        file(REMOVE "${CMMM_DESTINATION_MODULES}/${ARG_NAME}.cmake")
        message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading ${ARG_URL} : Empty file.${Esc}${CMMM_RESET_COLOR}")
      else()
        break()
      endif()
    endif()
    if("${CMMM_RETRIES_DONE}" STREQUAL "${ARG_RETRIES}")
      unlock()
      message(STATUS "${Esc}${CMMM_FATAL_ERROR_COLOR}[ CMMM ] Error downloading ${ARG_NAME}.${Esc}${CMMM_RESET_COLOR}")
      message(FATAL_ERROR "Error downloading ${ARG_NAME}.")
    endif()
    math(EXPR CMMM_RETRIES_DONE "${CMMM_RETRIES_DONE}+1")
  endwhile()

  include("${CMMM_DESTINATION_MODULES}/${ARG_NAME}")
  unlock()
  set(DESCRIPTION "${ARG_NAME}")
  if(DEFINED ARG_VERSION)
    set(DESCRIPTION "${DESCRIPTION} (v${ARG_VERSION})")
  endif()
  if(DEFINED ARG_DESCRIPTION)
    set(DESCRIPTION "${DESCRIPTION} (v${ARG_VERSION}) : ${ARG_DESCRIPTION}.")
  endif()
  set(CMAKEMM_MODULE_${ARG_NAME} "${ARG_URL}" CACHE INTERNAL "${DESCRIPTION}")
  unset(DESCRIPTION)
  unset(CMMM_RETRIES_DONE)
  unset(CMakeMMSHA256)
  unset(CMMM_EXPECTED_HASH_COMMAND)
  unset(CMMM_DESTINATION_MODULES)
endmacro()
