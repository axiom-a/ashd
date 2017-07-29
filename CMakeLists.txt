cmake_minimum_required(VERSION 2.8.1)

# Ensure the boilerplate code is in the module path....
set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}" )

#set (USE_DMD "yes")

# Default compiler is ldc2
set( CMAKE_D_COMPILER "ldc2" )
set( GLOBAL_D_DEFS "-w -wi -O2 -dw -m64 -D -Dd=documentation" )
if ( ${USE_DMD} )
    set( CMAKE_D_COMPILER "dmd" )
    set( GLOBAL_D_DEFS "-w -D -Dddocumentation" )
endif ( ${USE_DMD} )

# Ensure all required functions are available...
include( macros )


# Explicitly indicate we're using the D language in the project declaration.
# Listing other languages is fine.
PROJECT ( ashd D )
SET( GLOBAL_GCC_DEFS "-Wall -pedantic" )

# Don't use ADD_DEFINITIONS() with a mixed C + D project
# since that adds the same flags to both C and D builds.
# Also, the D linker preference is set to 40, which is
# higher than C++ (30) and C (10).  This causes CMAKE
# to use the D linker in mixed linking cases.
# Append our own definitions to the defaults.
SET( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${GLOBAL_GCC_DEFS}" )
SET( CMAKE_D_FLAGS "${CMAKE_D_FLAGS} ${GLOBAL_D_DEFS}" )

file( MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/dist/bin )
file( MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib )

set( DOC_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/documentation" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib" )
set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib" )
set( LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib" )

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/dist/bin)
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")

set( ptVERBOSITY 1 )


add_custom_target( check COMMAND ${CMAKE_CTEST_COMMAND} )

enable_testing()

include_directories( ${PROJECT_SOURCE_DIR} )

add_subdirectory(ashd)



