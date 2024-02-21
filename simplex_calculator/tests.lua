local simplexCore = require("core")
local helpers = require("helpers")

local initialTableauOne = {{2, 1, 1, 0, 0, 18}, {2, 3, 0, 1, 0, 42}, {3, 1, 0, 0, 1, 24}, {-3, -2, 0, 0, 0, 0}}
local initialTableauTwo = {{1, 1, 1, 0, 0, 12}, {2, 1, 0, 1, 0, 16}, {-40, -30, 0, 0, 1, 0}}
local initialTableauFour = {{2, 3, 1, 1, 0, 0, 0, 0, 8}, {1, 2, 4, 0, 1, 0, 0, 0, 6}, {0, 0, 0, 0, 0, 0, 0, 1, 10},
                            {-10, -15, 0, 0, 0, 0, 0, 0, 0, 0}}
local initialTableauThree = {{0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 40},
                             {0, 0, 0, 0, 0, 1, 3, 0, 1, 0, 0, 0, 0, 0, 0, 55},
                             {0, 0, 1, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 120},
                             {0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 40},
                             {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 130},
                             {3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 21},
                             {0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 110},
                             {-3, -2, -3, -1, -4, -1, -1, 0, 0, 0, 0, 0, 0, 0, 1, 0}}

local initialTableauTwo = {{1, 1, 1, 0, 0, 12}, {2, 1, 0, 1, 0, 16}, {-40, -30, 0, 0, 1, 0}}

local realExampleTableau = {{1, 0, 0, 2, 1, 0, 0, 20}, {0, 0, 1, 1, 0, 1, 0, 19}, {1, 2, 2, 0, 0, 0, 1, 43},
                            {-30, -15, -25, -20, -10, -5, -5, 0}}

local function solveBasicOptimizations()
    local success, error_message
    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(initialTableauOne)
        print("Test 1 Result:", helpers.getResultFromTableau(initialTableauOne) == 33 and "Passed" or "Failed")
    end)
    if not success then
        print("Test 1 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(initialTableauTwo)
        print("Test 2 Result:", helpers.getResultFromTableau(initialTableauTwo) == 400 and "Passed" or "Failed")
    end)
    if not success then
        print("Test 2 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(realExampleTableau)
        print("Real test:", helpers.getResultFromTableau(realExampleTableau) == 925 and "Passed" or "Failed")
    end)
    if not success then
        print("Real test error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(initialTableauThree)
        print("Test 3 Result:", "No exception thrown")
    end)
    if not success then
        print("Test 3 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(initialTableauFour)
        print("Test 4 Result:", "No exception thrown")
    end)
    if not success then
        print("Test 4 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(parsedUserInput)
        print("Test 5 Result:", helpers.getResultFromTableau(parsedUserInput) == 400 and "Passed" or "Failed")
    end)
end
solveBasicOptimizations()
return {
    solveBasicOptimizations = solveBasicOptimizations
}
