if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

# Do the update check
function(cmmm_changes CHANGELOG_VERSION)
  if(${CMMM_VERSION} VERSION_LESS ${CHANGELOG_VERSION})
    message(STATUS "Changes in v${CHANGELOG_VERSION} :")
    foreach(CMMM_CHANGE IN LISTS ARGN)
      message(STATUS "  ${CMMM_CHANGE}")
    endforeach()
  endif()
endfunction()

# Print the changelog
function(cmmm_print_changelog)
  message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] Using CMakeMM v${CMMM_VERSION}. The latest is v${CMMM_LATEST_VERSION}.${Esc}${CMMM_RESET_COLOR}")
  message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] Changes since v${CMMM_VERSION} include the following :${Esc}${CMMM_RESET_COLOR}")
  cmmm_changelog()
  message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] To update, simply change the value of VERSION in cmmm function.${Esc}${CMMM_RESET_COLOR}")
  message(STATUS "${Esc}${CMMM_INFO_COLOR}[ CMMM ] You can disable these messages by setting NO_CHANGELOG in cmmm function.${Esc}${CMMM_RESET_COLOR}")
endfunction()

# Check updates
function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "NO_CHANGELOG" "DESTINATION;VERSION" "" "${ARGN}")

  if(NOT ${CMMM_NO_CHANGELOG} AND NOT ${CMMM_VERSION} STREQUAL "latest")
    set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")

    if(EXISTS "${CMMM_CHANGELOG_FILE}")
      file(SHA256 "${CMMM_CHANGELOG_FILE}" CMakeMMSHA256)
    endif()

    set(CMMM_RETRIES_DONE "0")
    while(NOT CMAKEMM_INITIALIZED_${CMMM_TAG} OR NOT EXISTS "${CMMM_CHANGELOG_FILE}" OR "${CMakeMMSHA256}" STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

      if(${CMMM_RETRIES_DONE} STREQUAL "0")
        message(STATUS "${Esc}${CMMM_DEFAULT_COLOR}[ CMMM ] Downloading Changelog.cmake to ${CMMM_CHANGELOG_FILE}.${Esc}${CMMM_RESET_COLOR}")
      else()
        message(STATUS "${Esc}${CMMM_WARN_COLOR}[ CMMM ] Retrying (${CMMM_RETRIES_DONE}/${CMMM_RETRIES}).${Esc}${CMMM_RESET_COLOR}")
      endif()

      file(
        DOWNLOAD "https://cmake-tools.github.io/cmmm/_static/latest/Changelog.cmake" "${CMMM_CHANGELOG_FILE}"
        ${CMMM_INACTIVITY_TIMEOUT_COMMAND} ${CMMM_TIMEOUT_COMMAND} ${CMMM_TLS_VERIFY_COMMAND} ${CMMM_TLS_CAINFO_COMMAND} LOG CMMM_LOG STATUS CMAKECM_STATUS ${CMMM_SHOW_PROGRESS_COMMAND}
      )
      list(GET CMAKECM_STATUS 0 CMAKECM_CODE)
      list(GET CMAKECM_STATUS 1 CMAKECM_MESSAGE)
      if(${CMAKECM_CODE})
        message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading Changelog.cmake : ${CMAKECM_MESSAGE} (${CMAKECM_CODE}).${Esc}${CMMM_RESET_COLOR}")
      else()
        file(SHA256 "${CMMM_CHANGELOG_FILE}" CMakeMMSHA256)
        if(${CMakeMMSHA256} STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
          file(REMOVE "${CMMM_CHANGELOG_FILE}")
          message(STATUS "${Esc}${CMMM_ERROR_COLOR}[ CMMM ] Error downloading Changelog.cmake : Empty file.${Esc}${CMMM_RESET_COLOR}")
        else()
          break()
        endif()
      endif()
      if("${CMMM_RETRIES_DONE}" STREQUAL "${CMMM_RETRIES}")
        message(STATUS "${Esc}${CMMM_RESET_COLOR}[ CMMM ] Error downloading Changelog.cmake. Skipping !${Esc}${CMMM_RESET_COLOR}")
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

# Empty cmmm_entry for testing
function(cmmm_entry)
  cmake_parse_arguments(CMMM "NO_CHANGELOG" "VERSION;TAG;DESTINATION" "" "${ARGN}")
  cmmm_check_updates("${ARGN}")
  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")
endfunction()
