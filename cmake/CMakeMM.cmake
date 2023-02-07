if(${CMAKE_VERSION} VERSION_GREATER "3.9.6")
  include_guard(GLOBAL)
endif()

# Empty cmmm_entry for testing
function(cmmm_entry)
  cmake_parse_arguments(CMMM "" "TAG" "" "${ARGN}")
  set(CMAKEMM_INITIALIZED_${CMMM_TAG} TRUE CACHE INTERNAL "CMakeMM ${CMMM_TAG} is initialized.")
  message("Parameters : ${ARGN}")
endfunction()
