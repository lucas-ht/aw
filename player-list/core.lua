local info = {
    v_loc = 1.03,
    v_onl = http.Get("https://raw.githubusercontent.com/zer420/Player-List/master/version"),
    src = "https://raw.githubusercontent.com/zer420/Player-List/master/core.lua",
    dir = "zerlib\\",
    name = GetScriptName(),
    updt_available = false,
};
UnloadScript(info.dir .. "reload.lua")

local function Updater()
    if info.v_loc < tonumber(info.v_onl) then
        local reload = file.Open(info.dir .. "reload.lua", "w");
        reload:Write([[local f = 0;callbacks.Register("Draw",function()if f == 0 then UnloadScript("]]..info.name..[[");end;if f == 1 then LoadScript("]]..info.name..[[");end;f=f+1;end);]]);
        reload:Close(); info.updt_available = true;
end; end; Updater();

local ui_enable = gui.Checkbox(gui.Reference("Misc", "General", "Extra"), "playerlist.enable", "Player List", true);
local ui_win = gui.Window("playerlist", "Player List", 150, 150, 766, 536);

local ui_tab = {
    {"Player", gui.Groupbox(ui_win, "Player Selection", 16, 56, 234), gui.Groupbox(ui_win, "Options", 266, 56, 234),
    gui.Groupbox(ui_win, "Informations", 266, 224, 234), gui.Groupbox(ui_win, "Visuals", 516, 56, 234),},
    {"Misc", gui.Groupbox(ui_win, "Playstyle", 16, 56, 234), gui.Groupbox(ui_win, "Priority Settings", 266, 56, 234),
    gui.Groupbox(ui_win, "Visuals Settings", 16, 190, 234), gui.Groupbox(ui_win, "Updater", 266, 236, 234),},
    {1, {170,30,30,255}, {220,60,40,255}, {255,255,255,255}, {255,255,255,40}, f, f2, dpi, dpi_scale = {0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,},},
};
local ntab = (#ui_tab - 1); local function ui_setup() for i = 1, ntab do if i ~= ui_tab[ntab + 1][1] then for j = 2, #ui_tab[i] do ui_tab[i][j]:SetInvisible(true); end; end; end; end;
ui_setup(); local function ui_tab_selector(x1, y1, x2, y2, active)
    if ui_tab[ntab + 1].dpi ~= ui_tab[ntab + 1].dpi_scale[gui.GetValue("adv.dpi") + 1] then ui_tab[ntab + 1].dpi = ui_tab[ntab + 1].dpi_scale[gui.GetValue("adv.dpi") + 1];
    ui_tab[ntab + 1].f = draw.CreateFont("Calibri Bold", 20 * ui_tab[ntab + 1].dpi); ui_tab[ntab + 1].f2 = draw.CreateFont("Bahnschrift", 12 * ui_tab[ntab + 1].dpi); end;
    draw.SetFont(ui_tab[ntab + 1].f); local mx, my = input.GetMousePos(); local size = ((x2 - x1) / (ntab)); local offset = x1;
    for i = 1, (ntab) do
        if i == ui_tab[ntab + 1][1] then draw.Color(unpack(ui_tab[ntab + 1][3])) else draw.Color(unpack(ui_tab[ntab + 1][2])) end;
        draw.FilledRect(offset, y1, offset + size, y2); local xtxt, ytxt = draw.GetTextSize(ui_tab[i][1]);
        draw.Color(unpack(ui_tab[ntab + 1][4])); draw.Text((offset + (size / 2) - (xtxt / 2)), (y1 + ((y2 - y1) / 2) - (ytxt / 2)), ui_tab[i][1]);
        if mx >= offset and mx < offset + size and my >= y1 and my < y2 then
            draw.Color(unpack(ui_tab[ntab + 1][5])); draw.FilledRect(offset, y1, offset + size, y2);
            if input.IsButtonPressed("mouse1") then
                for j = 2, #ui_tab[ui_tab[ntab + 1][1]] do ui_tab[ui_tab[ntab + 1][1]][j]:SetInvisible(true); end; ui_tab[ntab + 1][1] = i;
                for j = 2, #ui_tab[i] do ui_tab[i][j]:SetInvisible(false); end;
end; end; offset = offset + size; end; end;
local ui_tab_select = gui.Custom(ui_win, "tab", 0, 0, 766, 40, ui_tab_selector); -- way cleaner than buttons

ui_tab_select:SetWidth(516);
local ui_plist = gui.Listbox(ui_tab[1][2], "players", 370);
ui_plist:SetWidth(202);

local ui_misc = {
    gui.Combobox(ui_tab[2][2], "playstyle.mode", "Mode", "Rage", "Semirage"),
    gui.Checkbox(ui_tab[2][3], "priority.enable", "Enable Priority", false),
    gui.Slider(ui_tab[2][3], "priority.fov", "FOV Override", 2, 1, 10, 1),
    gui.Checkbox(ui_tab[2][4], "visuals.enable", "Enable Individual Visuals", false),
};

local ui_visuals_ref = gui.Multibox(ui_tab[1][5], "Options");
local ui_visuals = {
    gui.Checkbox(ui_visuals_ref, "visuals.box", "Box", false),
    gui.Checkbox(ui_visuals_ref, "visuals.name", "Name", false),
    gui.Checkbox(ui_visuals_ref, "visuals.health", "Health", false),
    gui.Combobox(ui_tab[1][5], "visuals.chamsvis", "Visible Chams", "Off", "Flat", "Color", "Metallic", "Pearlescent", "Bubble"),
    gui.Combobox(ui_tab[1][5], "visuals.chamsinv", "Invisible Chams", "Off", "Flat", "Color", "Metallic", "Pearlescent", "Bubble"),
    gui.Checkbox(ui_visuals_ref, "visuals.radar", "Reveal on Radar", false),
};

local ui_visuals_color = {
    gui.ColorPicker(ui_visuals[1], "clr", "Box", 255, 255, 255, 80),
    gui.ColorPicker(ui_visuals[2], "clr", "Name", 255, 255, 255, 255),
    gui.ColorPicker(ui_visuals[3], "clr", "Health", 255, 255, 255, 255),
    gui.ColorPicker(ui_visuals[4], "clrvis", "Chams", 0, 175, 255, 255),
    gui.ColorPicker(ui_visuals[5], "clrinv", "Chams", 230, 155, 230, 255),
};
ui_visuals_ref:SetPosY(203);

local semi_rbot = gui.Checkbox(ui_tab[1][3], "ragebot", "Use Ragebot", false);
local priority_order = gui.Slider(ui_tab[1][3], "priority", "Priority Order", 10, 1, 10, 1);
local ui_option_multi_ref = gui.Multibox(ui_tab[1][3], "Additional Features");
local ui_player_option = {
    gui.Checkbox(ui_option_multi_ref, "bodyaim", "Force Bodyaim", false),
    gui.Checkbox(ui_option_multi_ref, "safepoint", "Force Safepoint", false),
};

ui_enable:SetDescription("Show the player list window.");
ui_misc[1]:SetDescription("Select your playstyle for suiting features.");
ui_misc[2]:SetDescription("It will cause a lock so be aware.");
ui_misc[3]:SetDescription("The priority will be set using this value.");
ui_misc[4]:SetDescription("Show features to set visuals per player.");
semi_rbot:SetDescription("Use the ragebot instead of legitbot.");
priority_order:SetDescription("Lower is higher priority, 10 is disabled.");
ui_option_multi_ref:SetDescription("Features to control the ragebot per player.");
ui_visuals_ref:SetDescription("Select what you want to see.");

--vis = {box = {false, clr}, name = {false, clr}, health = {false, clr}, chams = {false, clr},}
local p_list = {
    temp = {},
    p = {}, -- settings
    ref = { -- used in various places
        name = {},
        uid = {},
        index = {},
    },
};

local function CreateMat(uid, vis, type)
    if type == 0 then return nil; end;
    local clr = vis == 0 and unpack({p_list.p[uid].vis["chams"]["clrvis"]}) or unpack({p_list.p[uid].vis["chams"]["clrinv"]});
    local type_b = type == 1 and "UnlitGeneric" or "VertexLitGeneric";
    local addon = {
        [1] = "",
        [2] = "",
        [3] = [["$envmap" "env_cubemap"]],
        [4] = [["$phong" "1" "$basemapalphaphongmask" "1" "$pearlescent" "1"]],
        [5] = [["$additive" "1"]],
    };
    local vmt = [["]] .. type_b .. [[" {
            "$basetexture" "vgui/white_additive"
            "$color" "[]] .. clr[1] / 255 .. " " .. clr[2] / 255 .. " " .. clr[3] / 255 .. [[]"
            "$alpha" "]] .. clr[4] / 255 .. [["
            "$ignorez" "]] .. vis .. [["
            ]] .. addon[type] .. [[
        }]];
    return materials.Create("Chams", vmt);
end;

local cache_chams = {};
local function SaveCfg(uid)
    p_list.p[uid].rbot = semi_rbot:GetValue();
    p_list.p[uid].prio = priority_order:GetValue();
    p_list.p[uid].bodyaim = ui_player_option[1]:GetValue();
    p_list.p[uid].safepoint = ui_player_option[2]:GetValue();

    p_list.p[uid].vis["box"][1] = ui_visuals[1]:GetValue();
    p_list.p[uid].vis["box"].clr = {ui_visuals_color[1]:GetValue()};

    p_list.p[uid].vis["name"][1] = ui_visuals[2]:GetValue();
    p_list.p[uid].vis["name"].clr = {ui_visuals_color[2]:GetValue()};

    p_list.p[uid].vis["health"][1] = ui_visuals[3]:GetValue();
    p_list.p[uid].vis["health"].clr = {ui_visuals_color[3]:GetValue()};

    local temp = {{ui_visuals_color[4]:GetValue()}, {ui_visuals_color[5]:GetValue()}, ref = {{"clrvis", "matvis",}, {"clrinv", "matinv",},},};    
    for j = 1, 2 do
        p_list.p[uid].vis["chams"][j] = ui_visuals[3 + j]:GetValue();
        for i = 1, 4 do
            if unpack({p_list.p[uid].vis["chams"][temp.ref[j][1]]})[i] ~= temp[j][i] then
                p_list.p[uid].vis["chams"][temp.ref[j][1]] = temp[j];
                p_list.p[uid].vis["chams"][temp.ref[j][2]] = CreateMat(uid, (j - 1), p_list.p[uid].vis["chams"][j]);
            end;
        end;
    end;
    if cache_chams[uid] == nil then
        cache_chams[uid] = {0,0,};
    end;
    for i = 1, 2 do
        if cache_chams[uid][i] ~= ui_visuals[3 + i]:GetValue() then
            p_list.p[uid].vis["chams"][temp.ref[i][2]] = CreateMat(uid, i - 1, p_list.p[uid].vis["chams"][i]);
            cache_chams[uid][i] = ui_visuals[3 + i]:GetValue();
        end;
    end;

    p_list.p[uid].vis["radar"][1] = ui_visuals[6]:GetValue();

end;

local function LoadCfg(uid)
    semi_rbot:SetValue(p_list.p[uid].rbot);
    priority_order:SetValue(p_list.p[uid].prio);
    ui_player_option[1]:SetValue(p_list.p[uid].bodyaim);
    ui_player_option[2]:SetValue(p_list.p[uid].safepoint);

    ui_visuals[1]:SetValue(p_list.p[uid].vis["box"][1]);
    ui_visuals_color[1]:SetValue(unpack(unpack({p_list.p[uid].vis["box"].clr})));
    
    ui_visuals[2]:SetValue(p_list.p[uid].vis["name"][1]);
    ui_visuals_color[2]:SetValue(unpack(unpack({p_list.p[uid].vis["name"].clr})));

    ui_visuals[3]:SetValue(p_list.p[uid].vis["health"][1]);
    ui_visuals_color[3]:SetValue(unpack(unpack({p_list.p[uid].vis["health"].clr})));

    ui_visuals[4]:SetValue(p_list.p[uid].vis["chams"][1]);
    ui_visuals[5]:SetValue(p_list.p[uid].vis["chams"][2]);
    ui_visuals_color[4]:SetValue(unpack(unpack({p_list.p[uid].vis["chams"]["clrvis"]})));
    ui_visuals_color[5]:SetValue(unpack(unpack({p_list.p[uid].vis["chams"]["clrinv"]})));

    ui_visuals[6]:SetValue(p_list.p[uid].vis["radar"][1]);

end;

local ui_allow_updt = false;

local silentbool, ogname = false, "";
local silentname = gui.Button(ui_tab[1][4], "Silent Name", function()
    if ui_allow_updt == false then return; end;
    if silentbool == false then
        ogname = "­" .. client.GetConVar("name");
        client.SetConVar("name", "\n\xAD\xAD\xAD\xAD");
    else
        client.SetConVar("name", ogname);
    end;
end);
silentname:SetWidth(93);

local kdr = gui.Text(ui_tab[1][4], "Kill/Death Ratio");

local function Reset()
    ui_allow_updt = false;
    ui_plist:SetOptions();
    kdr:SetText("Kill/Death Ratio");
    p_list.p = {};
    p_list.temp = {};
    p_list.ref = {name = {},uid = {},index = {},};
end;

callbacks.Register("FireGameEvent", "ResetOnEnd", function(e)
    if e:GetName() == "cs_win_panel_match" then
        Reset();
    end;
end);
client.AllowListener("cs_win_panel_match");

local ui_cache = {opti, list, map,};
callbacks.Register("Draw", "UIHandler", function()
    ui_cache.opti = ui_enable:GetValue() and gui.Reference("Menu"):IsActive()
    ui_win:SetActive(ui_cache.opti);

    if ui_cache.opti == false then return; end;

    ui_win:SetHeight(ui_tab[3][1] == 1 and 536 or 376);

    ui_cache.opti = ui_tab[3][1] == 1 and ui_misc[4]:GetValue() == true;

    ui_win:SetWidth(ui_cache.opti == true and 766 or 516);
    ui_tab_select:SetWidth(ui_cache.opti == true and 766 or 516);
    ui_tab[1][5]:SetInvisible(not ui_cache.opti)

    ui_misc[3]:SetDisabled(not ui_misc[2]:GetValue());

    if ui_misc[1]:GetValue() == 0 then ui_cache.opti = true; else ui_cache.opti = false; end;
    semi_rbot:SetInvisible(ui_cache.opti);
    ui_option_multi_ref:SetInvisible(not ui_cache.opti);
    priority_order:SetDisabled(ui_cache.opti == false and semi_rbot:GetValue() == false or ui_misc[2]:GetValue() == false);
    ui_tab[1][4]:SetPosY(ui_cache.opti == true and 252 or 236);

    -- reset ui while not in game or new game
    if engine.GetMapName() == "" or engine.GetMapName() ~= ui_cache.map then 
        ui_cache.map = engine.GetMapName();
        Reset();
    end;

    -- update ui for the selected player
    if ui_allow_updt == true then
        if ui_cache.list ~= (ui_plist:GetValue() + 1) then
            ui_cache.list = (ui_plist:GetValue() + 1);
            LoadCfg(p_list.ref.uid[ui_cache.list]);
        end;
        SaveCfg(p_list.ref.uid[ui_cache.list]);
        local temp_kdr = {
            k = tonumber(entities.GetPlayerResources():GetPropInt("m_iKills", entities.GetByUserID(p_list.ref.uid[ui_cache.list]):GetIndex())),
            d = tonumber(entities.GetPlayerResources():GetPropInt("m_iDeaths", entities.GetByUserID(p_list.ref.uid[ui_cache.list]):GetIndex())),
        };
        kdr:SetText(temp_kdr.d > 0 and "Kill/Death Ratio = " .. (math.ceil((temp_kdr.k / temp_kdr.d) * 10) * 0.1) or "Kill/Death Ratio = " ..  temp_kdr.k);

        local name = client.GetConVar("name");
        silentbool = (name == "\n\xAD\xAD\xAD\xAD" or name:sub(1, 2) == "­");
        silentname:SetName(silentbool == false and "Silent Name" or "Reset Name");
    end;
end);


local update = gui.Button(ui_tab[2][5], info.updt_available == true and "   Update to v." .. info.v_onl or "No Update", function()
    local file = file.Open(info.name, "w"); file:Write(http.Get(info.src)); file:Close(); LoadScript(info.dir .. "reload.lua");
end);
update:SetWidth(93);
update:SetDisabled(not info.updt_available);
local changelog = gui.Button(ui_tab[2][5], "Changelog", function()
	panorama.RunScript([[SteamOverlayAPI.OpenExternalBrowserURL("https://github.com/zer420/Player-List/blob/master/changelog.md")]]);
end)
changelog:SetWidth(93);
changelog:SetPosX(109);
changelog:SetPosY(0);

local t_model = draw.CreateTexture(common.DecodePNG(http.Get("https://raw.githubusercontent.com/zer420/Player-List/master/t_model.png")));
local ct_model = draw.CreateTexture(common.DecodePNG(http.Get("https://raw.githubusercontent.com/zer420/Player-List/master/ct_model.png")));

local function ui_visual_previewer(x1, y1, x2, y2, active)
    if ui_visuals[1]:GetValue() then -- box
        draw.Color(ui_visuals_color[1]:GetValue());
        draw.FilledRect(x1, y1, x2, y1 - 1);
        draw.FilledRect(x1, y2, x2, y2 + 1);
        draw.FilledRect(x1, y1, x1 + 1, y2);
        draw.FilledRect(x2, y1, x2 - 1, y2);
    end;  
    if ui_tab[ntab + 1].f2 ~= nil then -- will throw some random errors if not check somewhy
        draw.SetFont(ui_tab[ntab + 1].f2);
    end;
    if ui_visuals[2]:GetValue() then -- name
        draw.Color(ui_visuals_color[2]:GetValue());
        local string = ui_allow_updt == true and p_list.ref.name[ui_plist:GetValue() + 1] or "Larry";
        local xtxt, ytxt = draw.GetTextSize(string);
        draw.Text(x1 + ((x2 - x1) / 2) - (xtxt / 2) , y1 - ytxt - 5, string);
    end;
    if ui_visuals[3]:GetValue() then -- health num
        draw.Color(ui_visuals_color[3]:GetValue());
        local string = ui_allow_updt == true and entities.GetByIndex(p_list.ref.index[ui_plist:GetValue() + 1]):GetHealth() or "100";
        local xtxt, ytxt = draw.GetTextSize(string); 
        draw.Text(x1 - xtxt - 2 , y1, string);
    end;
    if ui_visuals[4]:GetValue() ~= 0 then -- textured chams
        draw.Color(ui_visuals_color[4]:GetValue());
    else
        draw.Color(255,255,255,255);
    end;
    draw.SetTexture(t_model);
    if ui_allow_updt == true then 
        if entities.GetByIndex(p_list.ref.index[ui_plist:GetValue() + 1]):GetTeamNumber() == 3 then
            draw.SetTexture(ct_model);
        end;
    end;
    draw.FilledRect(x1 + 2, y1 + 2, x2 - 2, y2 - 2);
    draw.SetTexture(nil);
end;
local ui_visual_preview = gui.Custom(ui_tab[1][5], "visualpreview", 56, 0, 90, 187, ui_visual_previewer); -- I may add more features in the future

local espfont = draw.CreateFont("Bahnschrift", 12);
callbacks.Register("DrawESP", function(b)
    if ui_misc[4]:GetValue() == false then return; end;
    local p_ent = b:GetEntity();
    if p_ent == nil or p_ent:IsPlayer() ~= true then return; end;
    local uid = client.GetPlayerInfo(p_ent:GetIndex())["UserID"];
    if p_list.p[uid] == nil then return; end;

    local x1, y1, x2, y2 = b:GetRect();
    if p_list.p[uid].vis["box"][1] == true then
        draw.Color(unpack(unpack({p_list.p[uid].vis["box"].clr})));
        draw.FilledRect(x1, y1, x2, y1 - 1);
        draw.FilledRect(x1, y2, x2, y2 + 1);
        draw.FilledRect(x1, y1, x1 + 1, y2);
        draw.FilledRect(x2, y1, x2 - 1, y2);
    end;
    if espfont ~= nil then
        draw.SetFont(espfont);
    end;
    if p_list.p[uid].vis["name"][1] == true then
        draw.Color(unpack(unpack({p_list.p[uid].vis["name"].clr})));
        local string = p_ent:GetName();
        local xtxt, ytxt = draw.GetTextSize(string);
        draw.Text(x1 + ((x2 - x1) / 2) - (xtxt / 2) , y1 - ytxt - 5, string);
    end;
    if p_list.p[uid].vis["health"][1] == true then
        draw.Color(unpack(unpack({p_list.p[uid].vis["health"].clr})));
        local string = p_ent:GetHealth();
        local xtxt, ytxt = draw.GetTextSize(string);
        draw.Text(x1 - xtxt - 2 , y1, string);
    end;
end);

callbacks.Register("DrawModel", function(b)
    if ui_misc[4]:GetValue() == false then return; end;
    local p_ent = b:GetEntity();
    if p_ent == nil or p_ent:IsPlayer() ~= true then return; end;
    local uid = client.GetPlayerInfo(p_ent:GetIndex())["UserID"];
    if p_list.p[uid] == nil then return; end;
    local ref = {"matinv", "matvis",};
    for i = 1, 2 do
        local matref = i == 1 and 2 or 1;
        if p_list.p[uid].vis["chams"][matref] ~= 0 then
            if p_list.p[uid].vis["chams"][ref[i]] ~= nil then
                b:ForcedMaterialOverride(p_list.p[uid].vis["chams"][ref[i]]);
                b:DrawExtraPass();
            else
                p_list.p[uid].vis["chams"][ref[i]] = CreateMat(uid, i == 1 and 1 or 0, p_list.p[uid].vis["chams"][i]);
            end;
        end;
    end;
     
end);

local openprofile = gui.Button(ui_tab[1][4], "Open Steam Profile In Overlay", function()
    if ui_allow_updt == true then
        if client.GetPlayerInfo(p_list.ref.index[ui_cache.list])["IsBot"] == false then
            -- clean af way to get profile
            local link = [[("http://steamcommunity.com/profiles/765611]] .. 97960265728 + client.GetPlayerInfo(p_list.ref.index[ui_cache.list])["SteamID"] .. [[/")]];
            panorama.RunScript("SteamOverlayAPI.OpenURL" .. link);
end; end; end);
openprofile:SetWidth(202);

local stealname = gui.Button(ui_tab[1][4], "Steal Name", function()
    if ui_allow_updt == false then return; end;
    client.SetConVar("name", "­" .. p_list.ref.name[ui_plist:GetValue() + 1]); -- ALT + 0173
end);
stealname:SetWidth(93);
stealname:SetPosX(109);
stealname:SetPosY(0);

callbacks.Register("CreateMove", "UpdatePlayerList", function()
    p_list.temp = {};
    p_list.ref = {name = {},uid = {},index = {},};
    p_list.temp = entities.FindByClass("CCSPlayer");
    for i, j in pairs(p_list.temp) do
        local uid = client.GetPlayerInfo(j:GetIndex())["UserID"];
        -- create an entry in the table
        if p_list.p[uid] == nil then
            p_list.p[uid] = {rbot = false, prio = 10, bodyaim = false, safepoint = false, 
                vis = {["box"] = {false, clr = {255,255,255,80},}, ["name"] = {false, clr = {255,255,255,255},},["health"] = {false, clr = {255,255,255,255}},
                ["chams"] = {0, 0, ["clrinv"] = {230,155,230,255}, ["clrvis"] = {0,175,255,255}, ["matvis"] = nil, ["matinv"] = nil,},
                ["radar"] = {false},},
            };
        end;
        p_list.ref.name[i] = j:GetName();
        p_list.ref.uid[i] = uid;
        p_list.ref.index[i] = j:GetIndex();
    end;
    ui_plist:SetOptions(unpack(p_list.ref.name));
    ui_allow_updt = true;
end);

callbacks.Register("Draw", "EngineRadar", function()
    for i, p in pairs(entities.FindByClass("CCSPlayer")) do
        local uid = client.GetPlayerInfo(p:GetIndex())["UserID"];
        if p_list.p[uid] == nil then return; end;
        if p_list.p[uid].vis["radar"][1] == true then
            p:SetProp("m_bSpotted", 1);
        end;
	end
end);

local weapon_info = {
    [1] = "hpistol",[2] = "pistol",[3] = "pistol",[4] = "pistol",[7] = "rifle",[8] = "rifle", [9] = "sniper", [10] = "rifle",[11] = "asniper",[13] = "rifle", [14] = "lmg", [16] = "rifle",
    [17] = "smg",[19] = "smg",[23] = "smg",[24] = "smg",[25] = "shotgun",[26] = "smg", [27] = "shotgun", [28] = "lmg",[29] = "shotgun", [30] = "pistol", [32] = "pistol",[33] = "smg",
    [34] = "smg", [35] = "shotgun", [36] = "pistol",[38] = "asniper",[39] = "rifle", [40] = "scout", [60] = "rifle",[61] = "pistol",[63] = "pistol", [64] = "hpistol",
};

local target_i = nil; callbacks.Register("AimbotTarget", function(e) target_i = e:GetIndex(); end);

local aimbot_cache = {target_c, wep_type, applied = false, bodyaim, sphead, spbody, splimbs};

local function ResetCfg()
    gui.SetValue(string.format("rbot.hitscan.mode.%s.bodyaim", aimbot_cache.wep_type), aimbot_cache.bodyaim);
    gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshot", aimbot_cache.wep_type), aimbot_cache.sphead);
    gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", aimbot_cache.wep_type), aimbot_cache.spbody);
    gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", aimbot_cache.wep_type), aimbot_cache.splimbs);

    aimbot_cache.applied = false;
end;

local ent_vis, vis_next_check = {}, 1;
callbacks.Register("CreateMove", "GetVisiblePlayers", function(ucmd)
    -- check every 6 ticks for every visible enemies
    if vis_next_check < ucmd.tick_count then
        local lp = entities.GetLocalPlayer();
        for i, p in pairs(p_list.temp) do
            if p:GetTeamNumber() ~= lp:GetTeamNumber() and p:IsAlive() == true then
                local vis = engine.TraceLine(lp:GetAbsOrigin() + lp:GetPropVector("localdata", "m_vecViewOffset[0]"), p:GetHitboxPosition(3), 0x1).contents == 0;
                ent_vis[client.GetPlayerInfo(p:GetIndex())["UserID"]] = vis;
            else
                ent_vis[client.GetPlayerInfo(p:GetIndex())["UserID"]] = false;
            end;
        end;
        vis_next_check = ucmd.tick_count + 6;
    end;
end);

local priority_set, priority_toset, prev_fov = false, false, 180;

local function ResetPrio()
    gui.SetValue("rbot.aim.target.fov", prev_fov);
    priority_set = false;
end;

callbacks.Register("CreateMove", "Apply", function()
    -- get highest priority target which is visible
    local prio_vis = {10, nil, allowed,};
    for i, p in pairs(ent_vis) do
        if  p_list.p[i] ~= nil then
            if ui_misc[1]:GetValue() == 1 and p_list.p[i].rbot == true then
                prio_vis.allowed = true;
            elseif ui_misc[1]:GetValue() == 0 then
                prio_vis.allowed = true;
            end;
            if prio_vis.allowed == true then
                if p == true then
                    if prio_vis[1] > p_list.p[i].prio then
                        prio_vis[1] = p_list.p[i].prio;
                        prio_vis[2] = i;
                    end;
                end;
            end;
        end;
    end;

    local wep, lp = weapon_info[entities.GetLocalPlayer():GetWeaponID()], entities.GetLocalPlayer();

    if ui_misc[1]:GetValue() == 0 and gui.GetValue("rbot.master") == true then

        if target_i ~= nil and wep ~= nil and aimbot_cache.applied == false then
            -- cache then apply per target corrections 
            aimbot_cache.target_c = target_i;
            aimbot_cache.wep_type = wep;
            aimbot_cache.bodyaim = gui.GetValue(string.format("rbot.hitscan.mode.%s.bodyaim", wep));
            aimbot_cache.sphead = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshot", wep));
            aimbot_cache.spbody = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", wep));
            aimbot_cache.splimbs = gui.GetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", wep));

            if p_list.p[client.GetPlayerInfo(target_i)["UserID"]].bodyaim == true then
                gui.SetValue(string.format("rbot.hitscan.mode.%s.bodyaim", wep), 1);
            end;
            if p_list.p[client.GetPlayerInfo(target_i)["UserID"]].safepoint == true then
                gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshot", wep), 1);
                gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotbody", wep), 1);
                gui.SetValue(string.format("rbot.hitscan.mode.%s.delayshotlimbs", wep), 1);
            end;

            aimbot_cache.applied = true;

        elseif aimbot_cache.applied == true then
            if target_i == nil or wep == nil then
                ResetCfg();
            elseif target_i ~= aimbot_cache.target_c or wep ~= aimbot_cache.wep_type then
                ResetCfg();
            end;
        end;    

    elseif ui_misc[1]:GetValue() == 1 then
        -- per players ragebot
        if prio_vis[2] ~= nil and entities.GetByUserID(prio_vis[2]):IsAlive() and prio_vis.allowed == true and wep ~= nil then
            gui.SetValue("rbot.master", true);
        else
            gui.SetValue("lbot.master", true);
        end;    
    end;

    if gui.GetValue("rbot.aim.target.fov") ~= ui_misc[3]:GetValue() then
        prev_fov = gui.GetValue("rbot.aim.target.fov");
    end;

    if ui_misc[2]:GetValue() == true then
        -- flicks to the target, set FOV to 3 & enable lock while checking if it's the right one
        if prio_vis[1] < 10 and wep ~= nil then
            if entities.GetByUserID(prio_vis[2]):IsAlive() == false then
                ResetPrio();
                return;
            end;

            if priority_toset == true then
                local lp_pos = (lp:GetAbsOrigin() + lp:GetPropVector("localdata", "m_vecViewOffset[0]"));
                local t_pos = entities.GetByUserID(prio_vis[2]):GetHitboxPosition(5);

                engine.SetViewAngles((t_pos - lp_pos):Angles());
                gui.SetValue("rbot.aim.target.fov", ui_misc[3]:GetValue());
                gui.SetValue("rbot.aim.target.lock", true);

                priority_set = true;
                priority_toset = false;
            end;

            if target_i == entities.GetByUserID(prio_vis[2]):GetIndex() then
                priority_toset = false
                ResetPrio()
            else
                priority_toset = true
            end;

        elseif priority_set == true then
            ResetPrio();
        end;
    end;
end);
