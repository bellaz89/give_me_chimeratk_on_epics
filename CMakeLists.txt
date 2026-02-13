cmake_minimum_required(VERSION 3.28)
project(give_me_chimeratk_on_epics)

include(ExternalProject)

include(CheckCXXSourceCompiles)

set(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)
set(CMAKE_REQUIRED_STANDARD 20)
set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -std=c++20")

check_cxx_source_compiles("
    #include <concepts>
    template<typename T>
    concept C = std::integral<T>;
    int main() {
        static_assert(C<int>);
        return 0;
    }
" HAS_CXX20_CONCEPTS)

if(NOT HAS_CXX20_CONCEPTS)
    message(FATAL_ERROR "Your compiler does not support C++20 concepts")
endif()

check_cxx_source_compiles("
    #include <format>
    int main() {
        auto s = std::format(\"{}\", 42);
        return 0;
    }
" HAS_STD_FORMAT)

if(NOT HAS_STD_FORMAT)
    message(FATAL_ERROR "Your C++ standard library does not support std::format")
endif()

find_package(Boost 1.78 REQUIRED
    COMPONENTS
        thread
        chrono
        system
        filesystem
        unit_test_framework
)

find_package(LibXml2 2.9 REQUIRED)
find_package(Python3 3.9 REQUIRED
    COMPONENTS
        Interpreter
        Development
)
find_package(pybind11 2.10 REQUIRED CONFIG)
find_program(STUBGEN_EXECUTABLE stubgen)
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Network Widgets Gui Charts)
find_package(Qt${QT_VERSION_MAJOR} 5.10 REQUIRED COMPONENTS Core Network Widgets Gui Charts)
find_package(Perl REQUIRED)

message(INFO "Perl executable: ${PERL_EXECUTABLE}")

execute_process(
    COMMAND ${PERL_EXECUTABLE} -MFindBin -e "print \$INC{\"FindBin.pm\"}"
    RESULT_VARIABLE PERL_FINDBIN_RESULT
    OUTPUT_VARIABLE PERL_FINDBIN_PATH
    ERROR_VARIABLE PERL_FINDBIN_ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(PERL_FINDBIN_RESULT EQUAL 0)
    message(STATUS "FindBin.pm found at: ${PERL_FINDBIN_PATH}")
else()
    message(FATAL_ERROR "FindBin.pm not found")
endif()

include(CheckLibraryExists)

find_package(PkgConfig REQUIRED)

pkg_check_modules(LIBXMLPP REQUIRED libxml++-2.6)

if(NOT STUBGEN_EXECUTABLE)
    message(FATAL_ERROR "stubgen not found. Please install mypy.")
endif()

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
    PATCH_COMMAND
        sed -i "/enable_testing()/d" CMakeLists.txt
    DEPENDS ${ARG_DEPENDS}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DBUILD_DOC=OFF
               -DBUILD_TESTING=OFF -DJSON_BuildTests=OFF -DBUILD_TESTS=OFF
               -DCMAKE_CXX_STANDARD=20 -DCMAKE_CXX_STANDARD_REQUIRED=ON)
endfunction()

ExternalProject_Add(
    libmodbus
    GIT_REPOSITORY https://github.com/stephane/libmodbus.git
    GIT_TAG v3.1.11

    PREFIX ${CMAKE_BINARY_DIR}/libmodbus

    PATCH_COMMAND
        ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./autogen.sh

    CONFIGURE_COMMAND
        <SOURCE_DIR>/configure
            --prefix=<INSTALL_DIR>
            --disable-shared
            --enable-static
            CFLAGS=-fPIC
            CC=${CMAKE_C_COMPILER}

    BUILD_COMMAND make -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND make install

    BUILD_IN_SOURCE 0
)

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

fetch_project(chimeratk-epics 
              GIT_URL https://github.com/ChimeraTK/EPICS-Interface.git 
              GIT_TAG 01.01.01
              DEPENDS libyajl)

fetch_project(chimeratk-virtuallab 
              GIT_URL https://github.com/ChimeraTK/VirtualLab.git 
              GIT_TAG 01.01.04
              DEPENDS chimeratk-deviceaccess)

# fetch_project(chimeratk-deviceaccess-modbusbackend 
#               GIT_URL https://github.com/ChimeraTK/DeviceAccess-ModbusBackend.git 
#               GIT_TAG 01.06.01
#               DEPENDS chimeratk-deviceaccess libmodbus)

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

# fetch_project(chimeratk-controlsystemadapter 
#               GIT_URL https://github.com/ChimeraTK/ControlSystemAdapter.git 
#               GIT_TAG 02.13.02
#               DEPENDS chimeratk-deviceaccess)
# 
# fetch_project(chimeratk-controlsystemadapter-epics-ioc-adapter 
#               GIT_URL https://github.com/ChimeraTK/ControlSystemAdapter-EPICS-IOC-Adapter.git
#               GIT_TAG 02.02.01
#               DEPENDS chimeratk-epics chimeratk-controlsystemadapter)
# 
# fetch_project(chimeratk-applicationcore 
#               GIT_URL https://github.com/ChimeraTK/ApplicationCore.git 
#               GIT_TAG 04.07.01
#               DEPENDS chimeratk-deviceaccess chimeratk-controlsystemadapter)
# 
# fetch_project(chimeratk-applicationcore-microdaq 
#               GIT_URL https://github.com/ChimeraTK/ApplicationCore-MicroDAQ.git 
#               GIT_TAG 03.03.02
#               DEPENDS chimeratk-applicationcore)
# 
# fetch_project(chimeratk-applicationcore-microdaq-tools 
#               GIT_URL https://github.com/ChimeraTK/ApplicationCore-MicroDAQ-Tools.git 
#               GIT_TAG 01.06.04
#               DEPENDS chimeratk-applicationcore-microdaq)
# 
# fetch_project(chimeratk-applicationcore-loggingmodule 
#               GIT_URL https://github.com/ChimeraTK/ApplicationCore-LoggingModule.git 
#               GIT_TAG 01.01.01
#               DEPENDS chimeratk-applicationcore)
# 
# fetch_project(chimeratk-applicationcore-serverhistorymodule 
#               GIT_URL https://github.com/ChimeraTK/ApplicationCore-ServerHistoryModule.git 
#               GIT_TAG 01.02.00
#               DEPENDS chimeratk-applicationcore)
# 
# fetch_project(chimeratk-generic-device-server 
#               GIT_URL https://github.com/ChimeraTK/GenericDeviceServer 
#               GIT_TAG 02.02.00
#               DEPENDS chimeratk-applicationcore chimeratk-controlsystemadapter-epics-ioc-adapter)

fetch_project(qthardmon 
              GIT_URL https://github.com/ChimeraTK/QtHardMon.git
              GIT_TAG 01.08.03
              DEPENDS chimeratk-deviceaccess)

fetch_project(chimeratk-deviceaccess-pythonbindings 
              GIT_URL https://github.com/ChimeraTK/DeviceAccess-PythonBindings.git 
              GIT_TAG 04.01.01
              DEPENDS chimeratk-deviceaccess)
