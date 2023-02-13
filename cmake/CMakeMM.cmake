if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

# Check updates
function(cmmm_check_updates)
  cmake_parse_arguments(CMMM "IGNORE_NEW_VERSION" "VERSION;DESTINATION" "" "${ARGN}")
  message("Parameters 2 : ${ARGN}")
endfunction()

# Empty cmmm_entry for testing
function(cmmm_entry)
  cmake_parse_arguments(CMMM "" "TAG" "" "${ARGN}")
  message("Parameters : ${ARGN}")
  # Skip if version == "latest"
  #if(NOT "${CMMM_VERSION}" STREQUAL "latest")
  cmmm_check_updates(VERSION ${CMMM_VERSION} DESTINATION ${CMMM_DESTINATION} "${CMMM_IGNORE_NEW_VERSION}")
  #endif()
  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")
endfunction()
