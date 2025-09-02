-- StageBan v1.0.3
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- == Config/Loading == --

local function Shuffle(t)
    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end

mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
mods["SmoothSpatula-TomlHelper"].auto()
params = {}
params = Toml.config_update(_ENV["!guid"], params)

local current_stage_pool = 1
local stages = {}
local MAX_STAGES = 6

__post_initialize = function() -- Called after all custom stages are loaded

    local order = Array.wrap(gm.variable_global_get("stage_progression_order"))

    -- Get all stages orders
    for a, i in ipairs(order) do
        stages[a] = {}
        MAX_STAGES = a
        local list = List.wrap(i)
        for n, s in ipairs(list) do
            stages[a][n] = s
        end
    end

    gui.add_to_menu_bar(function()
        ImGui.TextColored(1, 0.5, 1, 1, "-- Banned Stages --")
        for i=1, #stages do
            ImGui.TextColored(0, 1, 1, 1, "Stage level "..i)
            for j=1, #stages[i] do
                
                local stage = Stage.wrap(stages[i][j])
                local stage_str = stage.namespace.."-"..stage.identifier

                if not params[stage_str..''] then params[stage_str..''] = false end
                local c = ((params[stage_str..'']) and {"Banned"} or {"  "})[1] 

                if ImGui.Button("["..c.."]  ".. Language.translate_token("stage."..stage.identifier..".name")) then
                    params[stage_str..''] = not params[stage_str..'']
                    Toml.save_cfg(_ENV["!guid"], params)
                end
            end
        end
    end)

    -- Replaces the way stages are rolled
    gm.post_script_hook(gm.constants.stage_roll_next, function(self, other, result, args)
        if args[1].value == MAX_STAGES then return end
        local chosen_stage = nil
        while chosen_stage == nil do
            if current_stage_pool > MAX_STAGES then current_stage_pool = 1 end
            local stages_permutation = Shuffle(stages[current_stage_pool])
            for _, stage_id in pairs(stages_permutation) do
                local stage = Stage.wrap(stage_id)
                if not params[stage.namespace.."-"..stage.identifier] then 
                    chosen_stage = stage_id
                end
            end
            current_stage_pool = current_stage_pool + 1
        end

        result.value = chosen_stage
    end)

    Callback.add("onGameStart", "StageBannerOnGameStart", function() current_stage_pool = 1 end)
end
