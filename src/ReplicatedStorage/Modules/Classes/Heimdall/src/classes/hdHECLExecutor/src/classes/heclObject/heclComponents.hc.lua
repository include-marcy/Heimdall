return [[
hecl:
    namespace main: --// The namespace main is declared, creating a new namespace. Namespaces are global instances accessible by any hc file including this hc file.
    --// the "with" keyword is used to define the member variables of any indexable type.
        with:
            struct[component] components;
            struct[entity] entities;

    --// declare keyword creates a new instance of type n
    --// type n "component" keyword is a built-in type that accepts indentation markers afterwards to describe the component.
    --// because declare accepts indentation markers, we use with to define the member variables
    declare component:
        with:
            string name: "VirtualTestComponent"; --// components must have a name variable declared
            struct[] default: --// components must have a default struct declared
                string prop1 = "TestProperty";
                [any] arrayProp = {
                
                };
        in:
            namespace: main->components;

    --// "declare" followed by an alphanumeric string of characters creates a variable and assigns it to an instance with the type defined after the as keyword.
    --// again, indentation is used to describe the instance to be created and assigned to the variable.
    declare e1 as entity:
        with:
            component main->VirtualTestComponent;
        in:
            namespace: main->entities;

    --// function declaration begins with the return type, followed by the name of the function, then a list of the parameters in parentheses.
    --// within the curly brackets is the body of the function.
    boolean hasComponents(entity entity, struct[component] components) {
        for (component c in entity.components) {
            declare c1 as component entity->c;
            if (not c1) {
                return false;
            }
        }

        return true;
    }

    --// struct is a built in data type which allows for key-value pairs to be stored inside it.
    declare t1 as struct[int]:
        with: 
            ["a"] = 1;
    --// by default, a struct is an immutable fixed size array. To achieve a dynamic array that reallocates itself, you can use a dynamic struct:
    declare t2 as dynamic struct[]:

    print t1->a; --// prints the number stored at "a" in the struct, in this case 1

    --// The following function expects a struct composed of components.
    --// It then returns a list of entities bearing the constituent components.
    struct[entity] queryEntities(struct[component] components) {
        declare t1 as struct[entity];

        for (entity e in main.entities) {
            if hasComponents(e, components) {
                insert(t1, e);
            }
        }

        return t1;
    }

    return main;
endhecl
]]