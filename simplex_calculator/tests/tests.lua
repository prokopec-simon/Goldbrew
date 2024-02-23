package.path = package.path .. ";../?.lua"

local simplexCore = require("core")
local helpers = require("helpers")

local tableau_example_1 = require("tableau_example_1")
local tableau_example_2 = require("tableau_example_2")
local tableau_example_3 = require("tableau_example_3")

local function run_basic_test_suite()
    local success, error_message
    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(tableau_example_1)
        print("Test 1 Result:", helpers.getResultFromTableau(tableau_example_1) == 33 and "Passed" or "Failed")
    end)
    if not success then
        print("Test 1 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(tableau_example_2)
        print("Test 2 Result:", helpers.getResultFromTableau(tableau_example_2) == 400 and "Passed" or "Failed")
    end)
    if not success then
        print("Test 2 Error:", error_message)
    end

    success, error_message = pcall(function()
        simplexCore.solve_simplex_task(tableau_example_3)
        print("Test 3 Result:", "No exception thrown")
    end)
    if not success then
        print("Test 3 Error:", error_message)
    end
end

run_basic_test_suite()
