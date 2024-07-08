return [[
hecl:
	declare name, age, rootPart;
	as string, number, Instance;

	return make:
		type: "entity";
		with:
			component:
				name: "component1";
				details:
					name: name;
					age: age;
			component:
				name: "bodyMover";
				details:
					parent: rootPart;
		in: "entities";
endhecl;
]]