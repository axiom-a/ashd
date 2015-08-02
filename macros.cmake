# Still very beta quality

# Custom 'docs' target to make documentation...
add_custom_target( docs )

# add a component
function( add_component _name _src)

    # source files are the _src and any others provided on command line
    set( srcfiles ${_src} ${ARGN} )

    if ( ${ptVERBOSITY} GREATER 5 )
        message( STATUS "Component: ${_name} using ${srcfiles}" )
    endif ( ${ptVERBOSITY} GREATER 5 )

    # Component library
    add_library( ${_name} ${srcfiles} )

    # Documentation
    add_ddoc( ${_name}-doc TARGETS ${_name} OUTPUT_DIRECTORY ${DOC_OUTPUT_DIRECTORY} EXCLUDE_FROM_ALL )
    add_dependencies( docs ${_name}-doc )
    #MACROS "${DOC_OUTPUT_DIRECTORY}/candydoc/candy" )

    # Utilities

endfunction()

# Unit Tests
function( add_unittest _target )

    add_executable( ${_target} "${_target}.d" )
    set_target_properties( ${_target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/unittest" )
    target_link_libraries( ${_target} ${ARGN} )
    add_test( NAME ${_target} COMMAND ${_target} )
    add_dependencies( check ${_target} )

endfunction()


# Private executable
function( add_privexe _target )
    add_executable( ${_target} "util/${_target}.d" )
    set_target_properties( ${_target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/priv/bin" )
    target_link_libraries( ${_target} ${ARGN} )

endfunction()

# Add package
function( add_package _pkg )
    set( packages ${_pkg} ${ARGN} )  # collect all arguments handed over

    if ( ${ptVERBOSITY} GREATER 6 )
        message( STATUS "Packages: " ${packages} )
    endif ( ${ptVERBOSITY} GREATER 6 )

    foreach( p ${packages} )
        add_subdirectory( ${p} )
    endforeach(p)
endfunction()
