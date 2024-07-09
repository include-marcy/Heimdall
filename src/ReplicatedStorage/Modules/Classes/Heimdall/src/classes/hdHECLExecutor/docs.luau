--[==[
	Heimdall Entity Composition Language (HECL) is a high level composition language that compiles to Luau.
	It is contained in strings and can be executed using the hdHECLExecutor class.
	
	An example of a HECL instruction:
	```luau
	local HECLInstructions = [[
		return make:
			type : "entity";
			with :
				   component : "character";
				   component : "assembly";
				   component : "inventory";
			in   : "entities";
	]]
	
	local hdEntity = hdInstance:hdExecuteHECL(HECLInstructions);
	```
	
	HECL Instructions using arguments:
	```luau
	local HECLInstructions = [[
		hecl:
			declare name, age;
			as string, number;

			return make:
				type : "entity";
				with :
					   component : "character" {
						   name = name;
						   age = age;
					   };
					   component : "assembly";
					   component : "inventory";
				in   : "entities";
		endhecl;
	]]
	
	local hdEntity = hdInstance:hdExecuteHECL(HECLInstructions, "Bob", 25)
	```
	The above example will create a new entity with a character component, an assembly component, and an inventory component.
	The character component will have the name "Bob" and the age of 25.
	```
]==]

return nil;