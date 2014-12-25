
add_component( ashd-core component.d entity.d entitylist.d node.d nodelist.d 
             ifamily.d iengine.d system.d systemlist.d engine.d 
             nodepool.d componentMatchingFamily.d )

add_unittest( componentMatchingFamily_test ashd-core )
add_unittest( engine_test ashd-core )
add_unittest( engineFamilyIntegration_test ashd-core )
add_unittest( entity_test ashd-core )
add_unittest( nodelist_test ashd-core )
add_unittest( system_test ashd-core )


