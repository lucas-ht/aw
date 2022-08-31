local debug = false; -- you can set it to true for advanced features used in development or if you want to better control resources utilization

local ui_extra_ref = gui.Groupbox(gui.Reference("Visuals", "Local"), "Simple Penetration Crosshair", 328, 282, 296);

local ui_options = gui.Multibox(ui_extra_ref, "Options");
local ui_check = gui.Checkbox(ui_options, "penetrationcrosshair.crosshair", "Crosshair", true);
local ui_border = gui.Checkbox(ui_options, "penetrationcrosshair.border", "Border", true);

local ui_color = {
    gui.ColorPicker(ui_check, "clr.wallbangable", "Wallbangable", 16, 235, 16, 255),
    gui.ColorPicker(ui_check, "clr.unwallbangable", "Unwallbangable", 235, 16, 16, 255),
    gui.ColorPicker(ui_border, "clr", "Border", 16, 16, 16, 80),
};

local showdebug = false;
local ui_extra = {
    mode = gui.Combobox(ui_extra_ref, "penetrationcrosshair.mode", "Shape", "Circle", "Square", "Triangle"),
    size = gui.Slider(ui_extra_ref, "penetrationcrosshair.size", "Size", 2, 0.5, 20, 0.5),
    bsize = gui.Slider(ui_extra_ref, "penetrationcrosshair.bsize", "Border Size", 1, 0.5, 10, 0.5),
    showdebug = gui.Button(ui_extra_ref, "Show Advanced Features", function() showdebug = not showdebug; end),
    perf = gui.Slider(ui_extra_ref, "penetrationcrosshair.step", "Depth Calculation Step", 0.005, 0.0001, 0.01, 0.0001),
    threshold = gui.Slider(ui_extra_ref, "penetrationcrosshair.depththreshold", "Depth Calculation Threshold", 0.2, 0.005, 0.5, 0.005),
    maxdist = gui.Slider(ui_extra_ref, "penetrationcrosshair.maxdist", "Maximum Distance", 1000, 100, 5000, 100),
    wallbangthreshold = gui.Slider(ui_extra_ref, "penetrationcrosshair.wallbangthreshold", "Wallbangability Threshold", 250, 5, 1000, 5),
};
local ui_debug_multi = gui.Multibox(ui_extra_ref, "Debug Options");
local ui_debug = {
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.index", "Index", false),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.penetration", "Penetration", true),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.distance", "Distance", false),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.name", "Name", true),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.depth", "Depth", true),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.wallbang", "Wallbang", true),
    gui.Checkbox(ui_debug_multi, "penetrationcrosshair.debug.trace", "Draw Trace", false),
};

ui_options:SetDescription("Choose what to draw.");
ui_check:SetDescription("Draw a simple penetration crosshair.");
ui_border:SetDescription("Add a border to it.");
ui_extra.mode:SetDescription("Choose the form of the penetration crosshair.");
ui_extra.size:SetDescription("Scale the penetration crosshair.");
ui_extra.bsize:SetDescription("Scale the border of the penetration crosshair.");
ui_extra.perf:SetDescription("Select at which interval should the depth be calculed.");
ui_extra.threshold:SetDescription("Choose the maximum depth checked.");
ui_extra.maxdist:SetDescription("Set the maximum distance allowed.");
ui_extra.wallbangthreshold:SetDescription("Set the minimum value considered as wallbangable.");
ui_debug_multi:SetDescription("Various options used for debugging purpose.");

ui_extra.showdebug:SetWidth(266); ui_extra.showdebug:SetInvisible(not debug);

-- data from \Counter-Strike Global Offensive\csgo\scripts\surfaceproperties_cs.txt
local surface_penetration_modifier = {
    [0] = 0,0.27,0.4,0.4,0.4,0.4,0.4,0.4,0.95,0.5,0.27,0.4,0.95,0.6,0.5,0.6,0.6,0.6,0.6,0.6,
    0.6,0.7,0.7,0.7,0.9,0.9,0.9,0.9,0.9,0.85,0.8,0.9,0.9,0.5,0.3,0.3,0.3,0.3,0.2,0.3,0.4,
    0.9,0.99,0.99,0.4,0.4,0.5,0.55,0.5,0.95,0.47,0.47,0.5,0.5,0.99,0.99,0.9,0.9,0.9,0.5,
    0.75,0.75,0.75,0.7,0.85,0.95,0.7,0.75,0.75,0.75,0.3,0.85,0.85,0.85,0.85,0.85,0.85,0.85,
};

local weapon_info = {
    [1] = {gp = 2, pen = 2, dmg = 63,}, [2] = {gp = 1, pen = 1, dmg = 38,}, [3] = {gp = 1, pen = 1, dmg = 32,},
    [4] = {gp = 1, pen = 1, dmg = 30,}, [7] = {gp = 4, pen = 2, dmg = 36,}, [8] = {gp = 4, pen = 2, dmg = 28,},
    [9] = {gp = 8, pen = 2.5, dmg = 115,}, [10] = {gp = 4, pen = 2, dmg = 30,}, [11] = {gp = 7, pen = 2.5, dmg = 80,},
    [13] = {gp = 4, pen = 2, dmg = 30,}, [14] = {gp = 9, pen = 2, dmg = 32,}, [16] = {gp = 4, pen = 2, dmg = 33,},
    [17] = {gp = 3, pen = 1, dmg = 29,}, [19] = {gp = 3, pen = 1, dmg = 26,}, [23] = {gp = 3, pen = 1, dmg = 27,},
    [24] = {gp = 3, pen = 1, dmg = 35,}, [25] = {gp = 5, pen = 1, dmg = 20,}, [26] = {gp = 3, pen = 1, dmg = 27,},
    [27] = {gp = 5, pen = 1, dmg = 30,}, [28] = {gp = 9, pen = 2, dmg = 35,}, [29] = {gp = 5, pen = 1, dmg = 32,},
    [30] = {gp = 1, pen = 1, dmg = 33,}, [32] = {gp = 1, pen = 1, dmg = 35,}, [33] = {gp = 3, pen = 1, dmg = 29,},
    [34] = {gp = 3, pen = 1, dmg = 26,}, [35] = {gp = 5, pen = 1, dmg = 26,}, [36] = {gp = 1, pen = 1, dmg = 38,},
    [38] = {gp = 7, pen = 2.5, dmg = 80,}, [39] = {gp = 4, pen = 2, dmg = 30,}, [40] = {gp = 6, pen = 2.5, dmg = 88,},
    [60] = {gp = 4, pen = 2, dmg = 33,}, [61] = {gp = 1, pen = 1, dmg = 35,}, [63] = {gp = 1, pen = 1, dmg = 31,},
    [64] = {gp = 2, pen = 2, dmg = 86,}, gp = {"pistol", "hpistol", "smg", "rifle", "shotgun", "scout", "asniper", "sniper", "lmg",},
};

local t = {
    lp = nil,
    lp_pos = nil,
    vec_dir = Vector3(0, 0, 0),

    surfaceProps = 0,
    fraction = 0,
    name = "",
    depth = 0,
    wallbangable = false,
    wallbangability = 0,
    wallbangthreshold = 250,

    step = 0.005,
    threshold = 0.2,
    maxdist = 1000,

    drawmode = 1,
    drawsize = 2,
    drawbsize = 1,
};

callbacks.Register("Draw", "UIHandler", function()
    ui_extra_ref:SetPosY(gui.GetValue("esp.local.outofview") ~= 0 and 282 or 220);

    ui_debug_multi:SetInvisible(not showdebug);
    ui_extra.perf:SetInvisible(not showdebug);
    ui_extra.threshold:SetInvisible(not showdebug);
    ui_extra.maxdist:SetInvisible(not showdebug);
    ui_extra.wallbangthreshold:SetInvisible(not showdebug);
end);

-- doesn't return an value with proper unit (ghetto)
local function GetDepth()
    local depth = t.step;
    -- checks if the location of (closest wall + step) is empty, doesn't check is the location is a "valid" part of the map since it would be tedious & resource-intensive
    while engine.GetPointContents(t.lp_pos + (t.vec_dir * t.fraction) + (t.vec_dir * depth)) ~= 0 do
        depth = depth + t.step;
        -- threshold needed to avoid heavy lags / crashes on some spots
        if depth > t.threshold then return -1; end;
    end;
   return depth;
end;

local function CanWallbang()
    local wep_info = weapon_info[t.lp:GetWeaponID()];
    if wep_info == nil or t.depth == -1 or surface_penetration_modifier[t.surfaceProps] == nil or t.surfaceProps == 0 then return -1; end;
    -- it's not a very precise way to get the wallbangability but kinda good enough for this purpose (also ghetto)
    return (((surface_penetration_modifier[t.surfaceProps] ^ 3) / (t.depth * 0.05)) * wep_info.pen);
end;

local function CanDraw(condition)
    local lp = entities.GetLocalPlayer();
    if lp == nil or condition == false then
        return false;
    elseif lp:IsAlive() == false then
        return false;
    end;
    return true;
end;

callbacks.Register("CreateMove", "GetData", function()
    if CanDraw(true) == false then return; end;

    t.lp = entities.GetLocalPlayer();
    t.lp_pos = t.lp:GetAbsOrigin() + t.lp:GetPropVector("localdata", "m_vecViewOffset[0]");
    t.vec_dir = engine.GetViewAngles():Forward() * t.maxdist;

    -- get infos about the closest wall to crosshair, tho the mask used is probably not the best
    local trace = engine.TraceLine(t.lp_pos, t.lp_pos + t.vec_dir, 0x4600400B);
    
    t.surfaceProps = trace.surface.surfaceProps;
    t.fraction = trace.fraction;
    t.name = trace.surface.name;
    t.depth = GetDepth();
    t.wallbangability = CanWallbang();
    t.wallbangable = (t.wallbangability >= t.wallbangthreshold - 1 and true or false);
end);

callbacks.Register("Draw", "Crosshair", function()
    if CanDraw(ui_check:GetValue()) == false then return; end;

    local sx, sy = draw.GetScreenSize();
    local sx2, sy2 = sx / 2 + 0.5, sy / 2 + 0.5;

    t.drawmode = (ui_extra.mode:GetValue() + 1);
    t.drawsize = ui_extra.size:GetValue();
    t.drawbsize = ui_extra.bsize:GetValue();

    if ui_border:GetValue() == true then
        draw.Color(ui_color[3]:GetValue());
        if t.drawmode == 1 then
            draw.FilledCircle(sx2, sy2, t.drawsize + t.drawbsize);
        elseif t.drawmode == 2 then
            draw.FilledRect(sx2 - t.drawsize - t.drawbsize, sy2 - t.drawsize - t.drawbsize, sx2 + t.drawsize + t.drawbsize, sy2 + t.drawsize + t.drawbsize);
        elseif t.drawmode == 3 then
            draw.Triangle(sx2 - t.drawsize - (t.drawbsize * 2),  sy2 + t.drawsize + t.drawbsize, sx2 + t.drawsize + (t.drawbsize * 2), sy2 + t.drawsize + t.drawbsize, sx2, sy2 - t.drawsize - (t.drawbsize * 2));
        end;
    end;
    
    if t.wallbangable == true then
        draw.Color(ui_color[1]:GetValue());
    else
        draw.Color(ui_color[2]:GetValue());
    end;
    
    if t.drawmode == 1 then
        draw.FilledCircle(sx2, sy2, t.drawsize);
    elseif t.drawmode == 2 then
        draw.FilledRect(sx2 - t.drawsize, sy2 - t.drawsize, sx2 + t.drawsize, sy2 + t.drawsize);
    elseif t.drawmode == 3 then
        draw.Triangle(sx2 - t.drawsize,  sy2 + t.drawsize, sx2 + t.drawsize, sy2 + t.drawsize, sx2, sy2 - t.drawsize);
    end;
end);

callbacks.Register("Draw", "Debug", function()
    if CanDraw(debug) == false or showdebug == false then return; end;

    local debug_indic = {
        {"index", t.surfaceProps,},
        {"penetration", surface_penetration_modifier[t.surfaceProps],},
        {"distance", t.fraction,},
        {"name", t.name,},
        {"depth", t.depth,},
        {"wallbang", t.wallbangability,},
    };

    -- some sliders aren't returing proper values
    t.step = (math.ceil(ui_extra.perf:GetValue() * 10000) * 0.0001);
    t.threshold = (math.ceil(ui_extra.threshold:GetValue() * 1000) * 0.001);
    t.maxdist = ui_extra.maxdist:GetValue();
    t.wallbangthreshold = ui_extra.wallbangthreshold:GetValue();

    local sx, sy = draw.GetScreenSize();
    local sx2, sy2, offset = sx / 2, sy / 2, 15;

    draw.Color(255, 255, 255, 255);

    for i = 1, 6 do
        if ui_debug[i]:GetValue() then
            if debug_indic[i][2] ~= nil then
                draw.Text(sx2, sy2 + offset, debug_indic[i][1] .. ": " .. debug_indic[i][2]);
                offset = offset + 15;
            end;
        end;
    end;
    
    if ui_debug[7]:GetValue() then
        local scposx_lp_pos, scposy_lp_pos = client.WorldToScreen(t.lp_pos);
        local scposx_vec_dir, scposy_vec_dir = client.WorldToScreen(t.lp_pos + t.vec_dir);
        if scposx_lp_pos ~= 0 and scposx_lp_pos ~= nil and scposx_vec_dir ~= 0 and scposx_vec_dir ~= nil then
            draw.Line(scposx_lp_pos, scposy_lp_pos, scposx_vec_dir, scposy_vec_dir);
        end;
    end;
end);
