local menu_ref = gui.Reference("Settings", "Advanced")
local ui_ref = gui.Groupbox(menu_ref, "Theme General", 328, 16, 296);
local ui_enable = gui.Checkbox(ui_ref, "theme.enable", "Enable", false);
ui_enable:SetDescription("Enable theme customization.");

local ui_selector = gui.Combobox(ui_ref, "theme.selector", "Selection", "Header", "Footer", "Tabs Selection");
ui_selector:SetDescription("Select which part of the menu you want to customize.");

local ui_color_ref = {
    gui.Groupbox(menu_ref, "Header Colors", 328, 204, 296),
    gui.Groupbox(menu_ref, "Footer Colors", 328, 204, 296),
    gui.Groupbox(menu_ref, "Tabs Selection Colors", 328, 204, 296),
};

local ui_colors = {
    gui.ColorPicker(ui_color_ref[1], "theme.clr.bg.head", "Background", 200,40,40,255),
    gui.ColorPicker(ui_color_ref[2], "theme.clr.bg.foot", "Background", 200,40,40,255),
    gui.ColorPicker(ui_color_ref[3], "theme.clr.bg.tabs", "Background", 15,15,15,255),

    gui.ColorPicker(ui_color_ref[1], "theme.clr.tab.head.idle", "Tabs", 170,30,30,255),
    gui.ColorPicker(ui_color_ref[1], "theme.clr.tab.head.selected", "Selected Tab", 220,60,40,255),
    gui.ColorPicker(ui_color_ref[1], "theme.clr.tab.head.name", "Tabs Name", 255,255,255,255),

    gui.ColorPicker(ui_color_ref[3], "theme.clr.tab.tabs.selected", "Selected Tab Background", 42,42,42,255),
    gui.ColorPicker(ui_color_ref[3], "theme.clr.tab.tabs.accent", "Selected Tab Accent", 220,40,40,255),
    gui.ColorPicker(ui_color_ref[3], "theme.clr.tabs.name.head", "Tabs Name", 255,255,255,255),
    gui.ColorPicker(ui_color_ref[1], "theme.clr.tabs.icon.head", "Tabs Icon", 255,255,255,255),

    gui.ColorPicker(ui_color_ref[1], "theme.clr.logo.head", "Logo", 255,255,255,255),
    gui.ColorPicker(ui_color_ref[3], "theme.clr.master.tabs", "Master Switch Text", 255,255,255,255),

    gui.ColorPicker(ui_color_ref[2], "theme.clr.ver.foot", "Version", 255,255,255,255),
    gui.ColorPicker(ui_color_ref[2], "theme.clr.pro.foot", "Website", 255,255,255,255),
};

local version, version_string = gui.Combobox(ui_color_ref[2], "theme.version", "Version", "Standard", "Beta", "Debug"), {"", "BETA ", "DEBUG "};

local icon = {};
local function setup_icon()
    for i = 0, 5 do
        icon[i] = draw.CreateTexture(common.DecodePNG(http.Get("https://raw.githubusercontent.com/zer420/Menu-Theme/master/icon/" .. i .. ".png")));
    end;
end; setup_icon();

local dpi, dpi_scale, dpi_h, f = 1, {0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,}, 0, draw.CreateFont("", 14);
local tab_pos, ui_tab_ref, ui_custom, master_ref = {58,161,264,367,470,}, {"Legitbot", "Ragebot", "Visuals", "Misc", "Settings",}, {}, {"lbot", "rbot", "esp", "misc",};

callbacks.Register("Draw", function()
    dpi = dpi_scale[gui.GetValue("adv.dpi") + 1];

    if dpi_h ~= dpi then
        dpi_h = dpi;
        f =  draw.CreateFont("", 14 * dpi, 1000);
    end;

    ui_selector:SetDisabled(not ui_enable:GetValue());

    for i = 1, #ui_color_ref do
        ui_color_ref[i]:SetInvisible(not ((ui_selector:GetValue() + 1) == i));
        ui_color_ref[i]:SetDisabled(not ui_enable:GetValue());
    end;
end);

local function SetColor(i)
    local temp = {ui_colors[i]:GetValue()};
    if i <= 3 then
        draw.Color(temp[1], temp[2], temp[3], 255);
    else
        draw.Color(temp[1], temp[2], temp[3], temp[4]);
    end;
end;


local ui_setup_check, ui_custom2, function_table2, ui_selected2 = {false, false, false, false, false,}, {}, {}, {0,0};

local function ui_setup2(i, tab)
    if ui_setup_check[i] == false then
        ui_custom2[i] = {};
        function_table2[i] = {};
        for j = 1, #tab do
            function_table2[i][j] = function(x1, y1, x2, y2, active) ui_selected2 = {i, j} end;
            ui_custom2[i][j] = gui.Custom(gui.Reference(ui_tab_ref[i], tab[j]), "custom" .. i .. j, 0, 0, 0, 0, function_table2[i][j]);
        end;
        ui_setup_check[i] = true;
    end;
end;

local mx, my, xtxt, ytxt, master, subtab_yoffset = 0, 0, 0, 0, false, 0;

local function custom_ui(x1, y1, x2, y2, i, tab)
    draw.SetFont(f);
    mx, my = input.GetMousePos();

    ui_setup2(i, tab);
    if ui_enable:GetValue() == false then return; end;

    SetColor(1);
    draw.FilledRect(x1, y1, x2 + (596 * dpi), y2 - (48 * dpi));
    draw.FilledRect(x1 + (596 * dpi), y1, x2 + (800 * dpi), y2 - (14 * dpi));
    draw.FilledRect(x1 + (596 * dpi), y1 - (48 * dpi), x2 + (800 * dpi), y2 - (34 * dpi) )
    draw.FilledRect(x1 + (784 * dpi), y1, x2 + (800 * dpi), y2 - (34 * dpi));

    SetColor(11);
    draw.SetTexture(icon[0]);
    draw.FilledRect(x1 + (5 * dpi), y1 - (43 * dpi), x1 + (45 * dpi), y2 - (3 * dpi));
    draw.SetTexture(nil)

    SetColor(3);
    if i ~= 5 then
        draw.FilledRect(x1, y1, x2 + (160 * dpi), y2 + (490 * dpi));
        draw.FilledRect(x1, y1 + (504 * dpi), x2 + (160 * dpi), y2 + (528 * dpi));
        draw.FilledRect(x1, y1 + (490 * dpi), x2 + (22 * dpi), y2 + (504 * dpi));
        draw.FilledRect(x1 + (36 * dpi), y1 + (490 * dpi), x2 + (160 * dpi), y2 + (504 * dpi));
    else
        draw.FilledRect(x1, y1, x2 + (160 * dpi), y2 + (528 * dpi));
    end;

    SetColor(4);
    draw.FilledRect(x1 + (58 * dpi), y1 - (2 * dpi), x2 + (569 * dpi), y2 - (38 * dpi));
    for j = 1, 5 do
        if i ~= j then
            SetColor(4);
            draw.FilledRect(x1 + (tab_pos[j] * dpi), y1 - (2 * dpi), x2 + ((tab_pos[j] + 99) * dpi), y2 - (38 * dpi));
        end;
        if mx > (x1 + (tab_pos[j] * dpi)) and mx < x2 + ((tab_pos[j] + 99) * dpi) and my >= y2 - (38 * dpi) and my < y1 - (2 * dpi)  then
            draw.Color(255,255,255,40);
            draw.FilledRect(x1 + (tab_pos[j] * dpi), y1 - (2 * dpi), x2 + ((tab_pos[j] + 99) * dpi), y2 - (38 * dpi));
        end;
    end;

    SetColor(5);
    draw.FilledRect(x1 + ((tab_pos[i] - 3) * dpi), y1 - (2 * dpi), x2 + ((tab_pos[i] + 102) * dpi), y2 - (40 * dpi));

    for j = 1, 5 do
        SetColor(6);
        if i ~= j then
            xtxt, ytxt = draw.GetTextSize(ui_tab_ref[j]);
            draw.Text(x1 + ((tab_pos[j] + 54) * dpi) - (xtxt / 2), y1 - (20 * dpi) - (ytxt / 2), ui_tab_ref[j]);

            SetColor(10);
            draw.SetTexture(icon[j]);
            draw.FilledRect(x1 + ((tab_pos[j] + 5) * dpi), y1 - (32 * dpi), x1 + ((tab_pos[j] + 30) * dpi), y1 - (8 * dpi));
            draw.SetTexture(nil);
        else
            xtxt, ytxt = draw.GetTextSize(ui_tab_ref[j]);
            draw.Text(x1 + ((tab_pos[j] + 58) * dpi) - (xtxt / 2), y1 - (20 * dpi) - (ytxt / 2), ui_tab_ref[j]);

            SetColor(10);
            draw.SetTexture(icon[j]);
            draw.FilledRect(x1 + ((tab_pos[j] + 2) * dpi), y1 - (35 * dpi), x1 + ((tab_pos[j] + 33) * dpi), y1 - (5 * dpi));
            draw.SetTexture(nil);
        end;
    end;

    master = false;
    if i ~= 5 then
        SetColor(12);
        if gui.GetValue(master_ref[i] .. ".master") == true then
            master = true;
        end;
        SetColor(12);
        xtxt, ytxt = draw.GetTextSize("Master Switch");
        draw.Text(x1 + (46 * dpi), y1 + (497 * dpi) - (ytxt / 2) , "Master Switch" )
    end;
    subtab_yoffset = 40;
    for j = 1, #tab do
        if master == true or i == 5 then
            if mx >= x1 and mx < x2 + (160 * dpi) and my >= y1 + ((subtab_yoffset - 40) * dpi) and my < y1 + ((subtab_yoffset - 8) * dpi)  then
                draw.Color(255,255,255,20);
                draw.FilledRect(x1, y1 + ((subtab_yoffset - 40) * dpi), x2 + (160 * dpi), y2 + ((subtab_yoffset - 8) * dpi));
            end;
            if ui_selected2[1] == i and ui_selected2[2] == j then
                SetColor(7);
                draw.FilledRect(x1, y1 + ((subtab_yoffset - 40) * dpi), x2 + (160 * dpi), y2 + ((subtab_yoffset - 8) * dpi));
                SetColor(8);
                draw.FilledRect(x1, y1 + ((subtab_yoffset - 40) * dpi), x2 + (4 * dpi), y2 + ((subtab_yoffset - 8) * dpi));
            end;
            if ui_selected2[1] ~= i or ui_selected2[2] ~= j then
                SetColor(9);
            end;
        end;
        xtxt, ytxt = draw.GetTextSize(tab[j]);
        draw.Text(x1 + (10 * dpi), y1 + ((subtab_yoffset - 24) * dpi) - (ytxt / 2) , tab[j]);
        subtab_yoffset = subtab_yoffset + 40;
    end;
    if master == false and i ~= 5 then
        draw.Color(15,15,15,120);
        draw.FilledRect(x1, y1, x2 + (160 * dpi), y2 + (528 * dpi));
    end;
    SetColor(2);
    draw.FilledRect(x1, y1 + (528 * dpi), x2 + (800 * dpi), y2 + (552 * dpi));
    xtxt, ytxt = draw.GetTextSize("V5 " .. version_string[version:GetValue() + 1] .. "for Counter-Strike: Global Offensive");
    SetColor(13);
    draw.Text(x1 + (5 * dpi), y1 + (540 * dpi) - (ytxt / 2), "V5 " .. version_string[version:GetValue() + 1] .. "for Counter-Strike: Global Offensive");
    SetColor(14);
    xtxt, ytxt = draw.GetTextSize("aimware.net");
    draw.Text(x2 + (795 * dpi) - xtxt, y1 + (540 * dpi) - (ytxt / 2), "aimware.net");
end;

local function_table = {
    function(x1, y1, x2, y2, active) custom_ui(x1, y1, x2, y2, 1, {"Aimbot", "Triggerbot", "Weapon", "Other", "Semirage",}) end,
    function(x1, y1, x2, y2, active) custom_ui(x1, y1, x2, y2, 2, {"Aimbot", "Accuracy", "Hitscan", "Anti-Aim",}) end,
    function(x1, y1, x2, y2, active) custom_ui(x1, y1, x2, y2, 3, {"Overlay", "Local", "World", "Chams", "Skins", "Other",}) end,
    function(x1, y1, x2, y2, active) custom_ui(x1, y1, x2, y2, 4, {"General", "Movement", "Enhancement",}) end,
    function(x1, y1, x2, y2, active) custom_ui(x1, y1, x2, y2, 5, {"Configurations", "Lua Scripts", "Theme", "Advanced",}) end,
};

local function ui_setup()
    for i = 1, 5 do
        ui_custom[i] = gui.Custom(gui.Reference(ui_tab_ref[i]), "custom" .. i, 0, 0, 0, 0, function_table[i]);
    end;
end; ui_setup();
