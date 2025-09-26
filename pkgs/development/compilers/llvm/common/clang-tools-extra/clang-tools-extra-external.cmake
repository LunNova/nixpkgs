# TODO(@LunNova): upstreamify
# Approach lifted from how LLVM subdirs that already support external builds worked
# Can probably be trimmed down

cmake_minimum_required(VERSION 3.20.0)
set(LLVM_SUBPROJECT_TITLE "Clang Tools Extra")
project(ClangToolsExtra)

if(NOT DEFINED LLVM_COMMON_CMAKE_UTILS)
  set(LLVM_COMMON_CMAKE_UTILS ${CMAKE_CURRENT_SOURCE_DIR}/../cmake)
endif()
include(${LLVM_COMMON_CMAKE_UTILS}/Modules/CMakePolicy.cmake
  NO_POLICY_SCOPE)

list(INSERT CMAKE_MODULE_PATH 0
    "${CMAKE_CURRENT_SOURCE_DIR}/../clang/cmake/modules"
    "${LLVM_COMMON_CMAKE_UTILS}"
    "${LLVM_COMMON_CMAKE_UTILS}/Modules"
    )

include(${LLVM_COMMON_CMAKE_UTILS}/Modules/CMakePolicy.cmake
  NO_POLICY_SCOPE)

include(GNUInstallDirs)
include(GetDarwinLinkerVersion)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard to conform to")
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

if(NOT MSVC_IDE)
set(LLVM_ENABLE_ASSERTIONS ${ENABLE_ASSERTIONS}
    CACHE BOOL "Enable assertions")
# Assertions should follow llvm-config's.
mark_as_advanced(LLVM_ENABLE_ASSERTIONS)
endif()

find_package(LLVM REQUIRED HINTS "${LLVM_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_DIR}")

find_package(Clang REQUIRED HINTS "${CLANG_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${CLANG_DIR}")

# Turn into CACHE PATHs for overwritting
set(LLVM_INCLUDE_DIRS ${LLVM_INCLUDE_DIRS} CACHE PATH "Path to llvm/include and any other header dirs needed")
set(LLVM_BINARY_DIR "${LLVM_BINARY_DIR}" CACHE PATH "Path to LLVM build tree")
set(LLVM_MAIN_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../llvm" CACHE PATH "Path to LLVM source tree")
set(LLVM_TOOLS_BINARY_DIR "${LLVM_TOOLS_BINARY_DIR}" CACHE PATH "Path to llvm/bin")
set(LLVM_LIBRARY_DIR "${LLVM_LIBRARY_DIR}" CACHE PATH "Path to llvm/lib")

find_program(LLVM_TABLEGEN_EXE "llvm-tblgen" ${LLVM_TOOLS_BINARY_DIR}
NO_DEFAULT_PATH)

# They are used as destination of target generators.
set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib${LLVM_LIBDIR_SUFFIX})
if(WIN32 OR CYGWIN)
# DLL platform -- put DLLs into bin.
set(LLVM_SHLIB_OUTPUT_INTDIR ${LLVM_RUNTIME_OUTPUT_INTDIR})
else()
set(LLVM_SHLIB_OUTPUT_INTDIR ${LLVM_LIBRARY_OUTPUT_INTDIR})
endif()

option(LLVM_INSTALL_TOOLCHAIN_ONLY
"Only include toolchain files in the 'install' target." OFF)

option(LLVM_FORCE_USE_OLD_TOOLCHAIN
"Set to ON to force using an old, unsupported host toolchain." OFF)
option(CLANG_ENABLE_BOOTSTRAP "Generate the clang bootstrap target" OFF)
option(LLVM_ENABLE_LIBXML2 "Use libxml2 if available." ON)

separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
add_definitions(${LLVM_DEFINITIONS_LIST})
list(APPEND CMAKE_REQUIRED_DEFINITIONS ${LLVM_DEFINITIONS_LIST})

include(AddLLVM)
include(TableGen)
include(HandleLLVMOptions)
include(VersionFromVCS)
include(CheckAtomic)
include(GetErrcMessages)
include(LLVMDistributionSupport)

if(CMAKE_CROSSCOMPILING)
set(LLVM_USE_HOST_TOOLS ON)
include(CrossCompile)
llvm_create_cross_target(Clang NATIVE "" Release)
endif()

set(PACKAGE_VERSION "${LLVM_PACKAGE_VERSION}")
set(BUG_REPORT_URL "${LLVM_PACKAGE_BUGREPORT}" CACHE STRING
"Default URL where bug reports are to be submitted.")

if (NOT DEFINED LLVM_INCLUDE_TESTS)
set(LLVM_INCLUDE_TESTS ON)
endif()

include_directories(${LLVM_INCLUDE_DIRS})
link_directories("${LLVM_LIBRARY_DIR}")

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib${LLVM_LIBDIR_SUFFIX} )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib${LLVM_LIBDIR_SUFFIX} )

find_package(Python3 ${LLVM_MINIMUM_PYTHON_VERSION} REQUIRED
COMPONENTS Interpreter)

if(LLVM_INCLUDE_TESTS)
    # Check prebuilt llvm/utils.
    if(EXISTS ${LLVM_TOOLS_BINARY_DIR}/FileCheck${CMAKE_EXECUTABLE_SUFFIX}
        AND EXISTS ${LLVM_TOOLS_BINARY_DIR}/count${CMAKE_EXECUTABLE_SUFFIX}
        AND EXISTS ${LLVM_TOOLS_BINARY_DIR}/not${CMAKE_EXECUTABLE_SUFFIX})
        set(LLVM_UTILS_PROVIDED ON)
    endif()

    # Seek installed Lit.
    find_program(LLVM_LIT
                    NAMES llvm-lit lit.py lit
                    PATHS "${LLVM_MAIN_SRC_DIR}/utils/lit"
                    DOC "Path to lit.py")

    if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py)
        # Note: path not really used, except for checking if lit was found
        if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/llvm-lit)
        add_subdirectory(${LLVM_MAIN_SRC_DIR}/utils/llvm-lit utils/llvm-lit)
        endif()
        if(NOT LLVM_UTILS_PROVIDED)
        add_subdirectory(${LLVM_MAIN_SRC_DIR}/utils/FileCheck utils/FileCheck)
        add_subdirectory(${LLVM_MAIN_SRC_DIR}/utils/count utils/count)
        add_subdirectory(${LLVM_MAIN_SRC_DIR}/utils/not utils/not)
        set(LLVM_UTILS_PROVIDED ON)
        set(CLANG_TEST_DEPS FileCheck count not)
        endif()
    endif()

    if (NOT TARGET llvm_gtest)
        message(FATAL_ERROR "llvm-gtest not found. Please install llvm-gtest or disable tests with -DLLVM_INCLUDE_TESTS=OFF")
    endif()

    if(LLVM_LIT)
        # Define the default arguments to use with 'lit', and an option for the user
        # to override.
        set(LIT_ARGS_DEFAULT "-sv")
        if (MSVC OR XCODE)
        set(LIT_ARGS_DEFAULT "${LIT_ARGS_DEFAULT} --no-progress-bar")
        endif()
        set(LLVM_LIT_ARGS "${LIT_ARGS_DEFAULT}" CACHE STRING "Default options for lit")

        get_errc_messages(LLVM_LIT_ERRC_MESSAGES)

        # On Win32 hosts, provide an option to specify the path to the GnuWin32 tools.
        if( WIN32 AND NOT CYGWIN )
        set(LLVM_LIT_TOOLS_DIR "" CACHE PATH "Path to GnuWin32 tools")
        endif()
    else()
        set(LLVM_INCLUDE_TESTS OFF)
    endif()

    umbrella_lit_testsuite_begin(check-all)

    # If LLVM was built with Z3, check if we still have the headers around.
    # They are used by a few tests.
    if (LLVM_WITH_Z3)
        find_package(Z3 4.8.9)
    endif()
endif() # LLVM_INCLUDE_TESTS

set(CLANG_BUILT_STANDALONE YES)
set(CLANG_BUILD_TOOLS YES)

include(AddClang)

add_subdirectory(../clang/include ./cl-include)


if (NOT TARGET clang-resource-headers)
  # TODO(@LunNova): submit fix for get_clang_resource_dir with a prefix
  # concatenating the prefix to an absolute path that's already set
  include(GetClangResourceDir)
  get_clang_resource_dir(EXTERNAL_CLANG_RESOURCE_DIR)

  if (NOT EXISTS ${EXTERNAL_CLANG_RESOURCE_DIR})
    message(FATAL_ERROR "Expected directory for clang-resource-headers not found: ${EXTERNAL_CLANG_RESOURCE_DIR}")
  endif()

  # Create the target and point it at the found resource dir so existing clang-tidy code using the target
  # doesn't need conditionalized
  add_library(clang-resource-headers INTERFACE
    ${EXTERNAL_CLANG_RESOURCE_DIR}
    )
endif()


