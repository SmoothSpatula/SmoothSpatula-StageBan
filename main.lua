-- StageBan v1.0.0
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- == Config/Loading == --

mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Callback = m.Callback break end end end)

params = {
    ['0'] = false,
    ['1'] = false,
    ['2'] = false,
    ['3'] = false,
    ['4'] = false,
    ['5'] = false,
    ['6'] = false,
    ['7'] = false,
    ['8'] = false
}
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = Toml.config_update(_ENV["!guid"], params)
end)

-- ========== ImGui ==========
local stages = {}
gui.add_to_menu_bar(function()
    ImGui.TextColored(1, 0.5, 1, 1, "-- Banned Stages --")
    for i=1, 9 do 
        local c = ((params[(i-1)..'']) and {"Banned"} or {"  "})[1] 
        if ImGui.Button("["..c.."]  ".. stages[i]) then
            params[(i-1)..''] = not params[(i-1)..'']
            Toml.save_cfg(_ENV["!guid"], params)
        end
    end
end)

-- == Init == --

function __initialize() -- Called by RoRR_Modding_Toolkit
    local CLASS_STAGE = gm.variable_global_get("class_stage")
    local lang_map = gm.variable_global_get("_language_map")
    for i = 1, #CLASS_STAGE do
        stages[i] = gm.ds_map_find_value(lang_map, "stage."..CLASS_STAGE[i][2]..".name")
    end
    Callback.add("onGameStart", "StageBannerOnGameStart", function() current_stage_level = 0 end)
end

-- == Hook == --

current_stage_level = 0
gm.pre_script_hook(gm.constants.stage_goto, function(self, other, result, args)
    if args[1].value > 8.0 then return end

    -- In case you ban everything, go to final stage
    local total_bans = 0
    for i=0, 8 do
        total_bans = total_bans + (params[i..''] and {1} or {0})[1]
    end
    if total_bans == 9 then
        args[1].value = 9.0
        return
    end

    if current_stage_level > 4 then current_stage_level = 0 end
    local stage_switch = math.random(0, 1)
    repeat
        if current_stage_level == 4 then
            if not params[(current_stage_level * 2)..''] then 
            stage_switch = 0 
            break end
        else
            if not params[(current_stage_level * 2 + stage_switch)..''] then 
                break end
            stage_switch = 1 - stage_switch
            if not params[(current_stage_level * 2 + stage_switch)..''] then 
                break end
        end
        if current_stage_level < 4 then
            current_stage_level = current_stage_level +1
        else 
            current_stage_level = 0
        end
    until false
    args[1].value = current_stage_level*2 + stage_switch
    current_stage_level = current_stage_level + 1
end)
