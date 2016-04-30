set( LIBS ashd-fsm ashd-core )

add_unittest( entityState_test                  ${LIBS} )
add_unittest( entityStateMachine_test           ${LIBS} )
add_unittest( componentInstanceProvider_test    ${LIBS} )
add_unittest( componentSingletonProvider_test   ${LIBS} )
add_unittest( componentTypeProvider_test        ${LIBS} )
add_unittest( dynamicComponentProvider_test     ${LIBS} )
add_unittest( systemInstanceProvider_test       ${LIBS} )
add_unittest( systemSingletonProvider_test      ${LIBS} )
add_unittest( systemMethodProvider_test         ${LIBS} )
add_unittest( systemState_test                  ${LIBS} )
add_unittest( engineStateMachine_test           ${LIBS} )




