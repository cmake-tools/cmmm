# Copyright 2023 flagarde
#[[[ @module
#]]

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.10")
  include_guard(GLOBAL)
endif()

set(GETCMMM_FILE_VERSION "1.0.0")

if("${GETCMMM_FILE_VERSION}" VERSION_LESS_EQUAL "${CURRENT_GETCMMM_FILE_VERSION}" AND COMMAND cmmm)
  return()
endif()

set(CURRENT_GETCMMM_FILE_VERSION "${GETCMMM_FILE_VERSION}" CACHE INTERNAL "GetCMakeMM version.")


#[[[
# Download and Load CMakeMM
#]]
function(cmmm)
  if(${CMAKE_VERSION} VERSION_LESS "3.5")
    include(CMakeParseArguments)
  endif()
endfunction()
