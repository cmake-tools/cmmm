if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

# Check updates
function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "NO_CHANGELOG" "DESTINATION" "" "${ARGN}")
  message("Parameters cmmm_check_updates : ${ARGN}")
  if(NOT ${CMMM_NO_CHANGELOG})
    set(CMMM_CHANGELOG_FILE "${CMMM_DESTINATION}/Changelog.cmake")
    file(DOWNLOAD "https://github.com/cmake-tools/cmmm/releases/download/Changelog.cmake" "${CMMM_CHANGELOG_FILE}" STATUS CMMM_STATUS TIMEOUT "${CMMM_TIMEOUT}" INACTIVITY_TIMEOUT "${CMMM_INACTIVITY_TIMEOUT}")
  endif()
endfunction()

# Empty cmmm_entry for testing
function(cmmm_entry)
  cmake_parse_arguments(CMMM "NO_CHANGELOG" "VERSION;TAG;DESTINATION" "" "${ARGN}")
  message("Parameters cmmm_entry: ${ARGN}")
  cmmm_check_updates("${ARGN}")
  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")
endfunction()
