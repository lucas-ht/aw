local weapon_type_var = {"pistol", "hpistol", "smg", "rifle", "shotgun", "scout", "asniper", "sniper", "lmg",};
local weapon_type_string = {"Pistol", "Heavy Pistol", "Submachine Gun", "Rifle", "Shotgun", "Scout", "Auto Sniper", "Sniper", "Light Machine Gun",} 

local ui_ref = gui.Groupbox(gui.Reference("Ragebot", "Hitscan"), "Safepoints", 328, 362, 296);
local ui_select = gui.Combobox(ui_ref, "safepoint.wep", "Weapon Selector", unpack(weapon_type_string));
ui_select:SetDescription("Choose a weapon to configure its safepoint options.");

local ui = {
    sliders = {},
    options = {
        ref = {},
        head = {},
        body = {},
        limbs = {},
    },
    baim = {},
    cache = {
        head = {},
        body = {},
        limbs = {},
        baim = {},
    },
};

local function SetupUI()
    for i = 1, 9 do
        ui.sliders[i] = gui.Slider(ui_ref, "safepoint.misses." .. weapon_type_var[i], "Safepoints After X Misses", 1, 0, 10, 1);
        ui.sliders[i]:SetDescription("Set safepoint after X misses for " .. weapon_type_string[i] .. "s. (0 = disable)");
        ui.sliders[i]:SetInvisible(true);
        ui.options.ref[i] = gui.Multibox(ui_ref, "Options");
        ui.options.ref[i]:SetDescription("Which hitbox will safepoint applies to for " .. weapon_type_string[i] .. "s.");
        ui.options.ref[i]:SetInvisible(true);
        ui.options.head[i] = gui.Checkbox(ui.options.ref[i], "safepoint.options.head." .. weapon_type_var[i], "Head", true);
        ui.options.body[i] = gui.Checkbox(ui.options.ref[i], "safepoint.options.body." .. weapon_type_var[i], "Body", true);
        ui.options.limbs[i] = gui.Checkbox(ui.options.ref[i], "safepoint.options.limbs." .. weapon_type_var[i], "Limbs", true);
        ui.baim[i] = gui.Combobox(ui_ref, "safepoint.bodyaim." .. weapon_type_var[i], "Bodyaim", "Disable", "Off", "Priority", "Lethal");
        ui.baim[i]:SetDescription("Which bodyaim option will be used with safepoint.");
        ui.baim[i]:SetInvisible(true);
    end;
    ui.sliders[1]:SetInvisible(false);
    ui.options.ref[1]:SetInvisible(false);
    ui.baim[1]:SetInvisible(false);
end;
SetupUI();

local t = {
    shots = 0,
    target = nil,
    oldtarget = 0,
    wep_id = 0,
    wep_id_old = 2,
    override = false,
    ui_cache = 0,
    ui_override = false,
    ui_set = false,
};

local weapon_info = {
    [1] = 2,[2] = 1,[3] = 1,[4] = 1,[7] = 4,[8] = 4, [9] = 8, [10] = 4,[11] = 7,[13] = 4, [14] = 9, [16] = 4,
    [17] = 3,[19] = 3,[23] = 3,[24] = 3,[25] = 5,[26] = 3, [27] = 5, [28] = 9,[29] = 5, [30] = 1, [32] = 1,[33] = 3,
    [34] = 3, [35] = 5, [36] = 1,[38] = 7,[39] = 4, [40] = 6, [60] = 4,[61] = 1,[63] = 1, [64] = 2,
};

callbacks.Register("Draw", "UI Handler", function()
    if t.ui_cache ~= ui_select:GetValue() then
        ui.sliders[t.ui_cache + 1]:SetInvisible(true);
        ui.options.ref[t.ui_cache + 1]:SetInvisible(true);
        ui.baim[t.ui_cache + 1]:SetInvisible(true);
        t.ui_cache = ui_select:GetValue();  
        ui.sliders[t.ui_cache + 1]:SetInvisible(false);
        ui.options.ref[t.ui_cache + 1]:SetInvisible(false);
        ui.baim[t.ui_cache + 1]:SetInvisible(false);
    end;
end);


callbacks.Register("AimbotTarget", function(e)
    t.target = e;
end);

callbacks.Register("FireGameEvent", "Count Misses", function(e)
    if e:GetName() == "weapon_fire" and t.target ~= nil and input.IsButtonDown(1) ~= true then
        if client.GetPlayerIndexByUserID(e:GetInt("userid")) == client.GetLocalPlayerIndex() then
            if t.oldtarget ~= t.target:GetIndex() then
                t.oldtarget = t.target:GetIndex();
                t.shots = 0;
            end;
            t.shots = t.shots + 1;
        end;
    elseif e:GetName() == "player_hurt" and t.target ~= nil then
        if client.GetPlayerIndexByUserID(e:GetInt("userid")) == t.target:GetIndex() then
            t.shots = 0;
        end;
    end;
end);
client.AllowListener("weapon_fire");
client.AllowListener("player_hurt");

local function ApplySafepoint(i, bool)
    if bool == true then
        ui.cache.head[i] = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshot", weapon_type_var[i]));
        ui.cache.body[i] = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", weapon_type_var[i]));
        ui.cache.limbs[i] = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", weapon_type_var[i]));
        ui.cache.baim[i] = gui.GetValue(string.format("rbot.hitscan.mode.%s.bodyaim", weapon_type_var[i]));
        if ui.options.head[i]:GetValue() == true then        
            gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshot", weapon_type_var[i]), 1);
        end;
        if ui.options.body[i]:GetValue() == true then  
            gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", weapon_type_var[i]), 1);
        end;
        if ui.options.limbs[i]:GetValue() == true then          
            gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", weapon_type_var[i]), 1);
        end;
        if ui.baim[i]:GetValue() ~= 0 then
            gui.SetValue(string.format("rbot.hitscan.mode.%s.bodyaim", weapon_type_var[i]), ui.baim[i]:GetValue() - 1);
        end;
    else
        gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshot", weapon_type_var[i]), ui.cache.head[i]);
        gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", weapon_type_var[i]), ui.cache.body[i]);
        gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", weapon_type_var[i]), ui.cache.limbs[i]);
        gui.SetValue(string.format("rbot.hitscan.mode.%s.bodyaim", weapon_type_var[i]), ui.cache.baim[i]);
    end;
end;

callbacks.Register("CreateMove", function()
    t.wep_id = entities.GetLocalPlayer():GetWeaponID();
    if t.wep_id_old ~= t.wep_id then
        if t.override == true then
            ApplySafepoint(weapon_info[t.wep_id_old], false);
            t.override = false;
        end;
        if weapon_info[t.wep_id] ~= nil then
            t.wep_id_old = t.wep_id;
            t.ui_set = false;
        end;
        t.shots = 0;
    end;
    if weapon_info[t.wep_id] ~= nil then
        if ui.sliders[weapon_info[t.wep_id]]:GetValue() ~= nil then
            if ui.sliders[weapon_info[t.wep_id]]:GetValue() > 0 then
                if t.shots >= ui.sliders[weapon_info[t.wep_id]]:GetValue() and t.override == false then
                    t.override = true;
                    ApplySafepoint(weapon_info[t.wep_id], true);
                elseif t.override == true and t.shots == 0 then
                    t.override = false;
                    ApplySafepoint(weapon_info[t.wep_id], false);
                end;
            end;
        end;
        if gui.Reference("Menu"):IsActive() == false then t.ui_override = false; end;
        if t.ui_override == false and t.ui_set == false then ui_select:SetValue(weapon_info[t.wep_id] - 1); t.ui_set = true; end;
        if t.ui_set == true and ui_select:GetValue() ~= (weapon_info[t.wep_id] - 1) then t.ui_override = true; end;
    end;
end);
