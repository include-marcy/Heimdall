return [[
--// hecl entrance function includes possiblity for var args declared in the hecl function
hecl (string name, int age, Instance rootPart):
	include "heclComponents.hc";

	declare e1 as entity:
        with:
            component main->VirtualTestComponent:
				name = name;
				age = age;
        in:
            namespace: main->entities;

	return e1;
endhecl;
]]