include("${CMMM_DIRECTORY}/GetCMakeMM.cmake")

cmmm(VERSION latest TIMEOUT 30 INACTIVITY_TIMEOUT 30 TLS_VERIFY OFF RETRIES 2)

cmmm_modules_list(URI "gl:cmake-tools/cmmm.test")
