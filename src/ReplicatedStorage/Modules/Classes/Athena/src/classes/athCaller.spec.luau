return function ()
    local ath = script.Parent.Parent;
    local athCallerClass = require(ath.classes.athCaller);
    local athTypes = require(ath.lib.athTypes);

    describe("athCaller", function()
        local athCaller = athCallerClass.new();
        local super = {};

        function super:_superDoInternal()

        end

        it("should allow callbacks to be safely called", function()
            expect(function()
                athCaller:athCall(super._superDoInternal, super);
            end).never.to.throw();
        end);
    end);
end