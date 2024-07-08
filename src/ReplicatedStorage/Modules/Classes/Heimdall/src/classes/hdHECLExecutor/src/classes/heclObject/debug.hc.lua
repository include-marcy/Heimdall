return [[
hecl(int f):
    include "heclComponents.hc";

    declare c1 as component main->VirtualTestComponent;

    declare e1 as entity:
        with:
            c1;

    c1->prop1 = "component2AssignmentTest";

    f = 2;

    print f;
    f = 1;

    print e1->prop1;

    declare es as queryEntities(struct[component]
        with: c1
    );

    for (entity e in es) {
        print e->name;
    }

    return e1;
endhecl;
]]