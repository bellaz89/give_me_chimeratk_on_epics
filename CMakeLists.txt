cmake_minimum_required(VERSION 3.16)
project(give_me_chimeratk_on_epics)

include(ExternalProject)

set(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

function(fetch_project NAME)
  set(options "")
  set(oneValueArgs GIT_URL GIT_TAG)
  set(multiValueArgs DEPENDS)

  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  ExternalProject_Add(
    ${NAME}
    GIT_REPOSITORY ${ARG_GIT_URL}
    GIT_TAG ${ARG_GIT_TAG}
    GIT_SUBMODULES_RECURSE 1
    GIT_SHALLOW 1
    GIT_PROGRESS 1
    DEPENDS ${ARG_DEPENDS}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DBUILD_DOC=OFF
               -DBUILD_TESTING=OFF -DJSON_BuildTests=OFF)
endfunction()

fetch_project(nlohmann_json 
              GIT_URL https://github.com/nlohmann/json.git
              GIT_TAG v3.12.0)

fetch_project(libyajl
              GIT_URL https://github.com/lloyd/yajl.git
              GIT_TAG 2.1.0)

fetch_project(chimeratk-cppext 
              GIT_URL https://github.com/ChimeraTK/cppext.git
              GIT_TAG 01.07.01)

fetch_project(exprtk
              GIT_URL https://github.com/ChimeraTK/exprtk-interface.git
              GIT_TAG 01.05.00)

fetch_project(chimeratk-deviceaccess 
              GIT_URL https://github.com/ChimeraTK/DeviceAccess.git 
              GIT_TAG 03.26.00
      	      DEPENDS nlohmann_json chimeratk-cppext exprtk)

fetch_project(chimeratk-controlsystemadapter 
              GIT_URL https://github.com/ChimeraTK/ControlSystemAdapter.git 
              GIT_TAG 02.13.02
      	      DEPENDS chimeratk-deviceaccess)

fetch_project(chimeratk-epics 
              GIT_URL https://github.com/ChimeraTK/EPICS-Interface.git 
              GIT_TAG 01.01.01
      	      DEPENDS libyajl)

fetch_project(chimeratk-controlsystemadapter-epics-ioc-adapter 
              GIT_URL https://github.com/ChimeraTK/ControlSystemAdapter-EPICS-IOC-Adapter.git
              GIT_TAG 02.02.01
	      DEPENDS chimeratk-epics chimeratk-controlsystemadapter)

fetch_project(chimeratk-virtuallab 
              GIT_URL https://github.com/ChimeraTK/VirtualLab.git 
              GIT_TAG 01.01.04
      	      DEPENDS chimeratk-deviceaccess)

# fetch_project(chimeratk-deviceaccess-modbusbackend 
#               GIT_URL https://github.com/ChimeraTK/DeviceAccess-ModbusBackend.git 
#               GIT_TAG 01.06.01
#       	      DEPENDS chimeratk-deviceaccess)

fetch_project(chimeratk-deviceaccess-epicsbackend 
              GIT_URL https://github.com/ChimeraTK/DeviceAccess-EpicsBackend.git 
              GIT_TAG 01.00.02
      	      DEPENDS chimeratk-deviceaccess chimeratk-epics)

fetch_project(inja 
              GIT_URL https://github.com/pantor/inja.git 
              GIT_TAG v3.5.0
      	      DEPENDS nlohmann_json)

fetch_project(chimeratk-devicess-commandbasedbackend 
              GIT_URL https://github.com/ChimeraTK/DeviceAccess-CommandBasedBackend.git 
              GIT_TAG 00.01.04
	      DEPENDS chimeratk-deviceaccess inja)

fetch_project(chimeratk-applicationcore 
              GIT_URL https://github.com/ChimeraTK/ApplicationCore.git 
              GIT_TAG 04.07.01
      	      DEPENDS chimeratk-deviceaccess chimeratk-controlsystemadapter)

fetch_project(chimeratk-applicationcore-microdaq 
              GIT_URL https://github.com/ChimeraTK/ApplicationCore-MicroDAQ.git 
              GIT_TAG 03.03.02
      	      DEPENDS chimeratk-applicationcore)

fetch_project(chimeratk-applicationcore-microdaq-tools 
              GIT_URL https://github.com/ChimeraTK/ApplicationCore-MicroDAQ-Tools.git 
              GIT_TAG 01.06.04
      	      DEPENDS chimeratk-applicationcore-microdaq)

fetch_project(chimeratk-applicationcore-loggingmodule 
              GIT_URL https://github.com/ChimeraTK/ApplicationCore-LoggingModule.git 
              GIT_TAG 01.01.01
      	      DEPENDS chimeratk-applicationcore)

fetch_project(chimeratk-applicationcore-serverhistorymodule 
              GIT_URL https://github.com/ChimeraTK/ApplicationCore-ServerHistoryModule.git 
              GIT_TAG 01.02.00
      	      DEPENDS chimeratk-applicationcore)

fetch_project(chimeratk-generic-device-server 
              GIT_URL https://github.com/ChimeraTK/GenericDeviceServer 
              GIT_TAG 02.02.00
      	      DEPENDS chimeratk-applicationcore chimeratk-controlsystemadapter-epics-ioc-adapter)

fetch_project(qthardmon 
              GIT_URL https://github.com/ChimeraTK/QtHardMon.git
              GIT_TAG 03.03.02
      	      DEPENDS chimeratk-deviceaccess)

fetch_project(chimeratk-deviceaccess-pythonbindings 
              GIT_URL https://github.com/ChimeraTK/DeviceAccess-PythonBindings.git 
              GIT_TAG 04.01.01
      	      DEPENDS chimeratk-deviceaccess)
