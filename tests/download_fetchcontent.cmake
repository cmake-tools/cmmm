if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.11)
  include(FetchContent)

  cmmm_modules_list(URI "gh:cmake-tools/cmmm.test")

endif()
