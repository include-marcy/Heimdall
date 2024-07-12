return function ()
    local athHostClass = require(script.Parent.athHost);

    describe("athHost", function ()
        local athHost = athHostClass.new();
        local exampleProject;

        it ("should host a project", function ()
            exampleProject = athHost:athHostProject();
        end);

        it ("should allow decomposition of a project", function ()
            athHost:athDecomposeProject(exampleProject);
        end);

        it ("should expose configuration of a project", function ()
            local projectSettings = {

            };

            exampleProject:athSetProjectSettings(projectSettings);
        end);

        it ("should allow quick solution deployment", function ()
            local solution = {}; -- stored in solution file like example.sln.luau

            local exampleProject = athHost:athRun(solution);
        end);

        it ("should facilitate access to the project and its components", function ()
            local athProjectTypes = exampleProject.athGetProjectTypes();
            local athProjectClasses = exampleProject.athGetProjectClasses();
            local athProjectSingletons = exampleProject.athGetProjectSingletons();

            expect(athProjectTypes).to.be.a("table");
            expect(athProjectClasses).to.be.a("table");
            expect(athProjectSingletons).to.be.a("table");
        end);

        it ("should provide complete overview of the project and the performance of individual components", function ()
            local athProjectBench = exampleProject.athGetProjectBench();
            local athProjectAccountant = exampleProject.athGetProjectAccountant();
        end);

        it ("should allow for build modes", function()
            local buildMode = exampleProject.athGetBuildMode();

            expect(buildMode).to.be.a("string");
        end);
    end);
end