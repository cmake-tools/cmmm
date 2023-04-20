include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.2)

  cmmm(VERSION latest TIMEOUT 30 INACTIVITY_TIMEOUT 30 TLS_VERIFY OFF RETRIES 2)

  cmmm_modules_list(URI "gl:cmake-tools/cmmm.test")

endif()
