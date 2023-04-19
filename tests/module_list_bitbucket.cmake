include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.2)

  cmmm(VERSION 0 TIMEOUT 30 INACTIVITY_TIMEOUT 30 TLS_VERIFY OFF RETRIES 2)

  cmmm_modules_list(URI "bb:cmake-tools/cmmm.test")

endif()
