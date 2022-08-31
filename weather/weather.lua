local ui_ref = gui.Groupbox(gui.Reference("Misc", "Enhancement"), "Weather Info", 328, 312, 296);
local ui_enable = gui.Checkbox(ui_ref, "weather.enable", "Enable Weather Hud", true);

local ui_options_ref = gui.Multibox(ui_ref, "Options");
local ui_options = {
    gui.Checkbox(ui_options_ref, "weather.city", "City", true),
    gui.Checkbox(ui_options_ref, "weather.time", "Time", true),
    gui.Checkbox(ui_options_ref, "weather.weather", "Weather", true),
    gui.Checkbox(ui_options_ref, "weather.icon", "Icon", true),
    gui.Checkbox(ui_options_ref, "weather.temperature", "Temperature", true),
    gui.Checkbox(ui_options_ref, "weather.precipitation", "Precipitation", true),
    gui.Checkbox(ui_options_ref, "weather.humidity", "Humidity", true),
    gui.Checkbox(ui_options_ref, "weather.wind", "Wind", true),
};
local ui_temp_mode = gui.Combobox(ui_ref, "weather.temperature.mode", "Temperature Mode", "Celsius", "Fahrenheit");

local t_lang = {
    {"Local Language","English", "Chinese", "Hindi", "Spanish", "French", "Arabic", "Russian", "Portuguese", "German"},
    {"en", "zh-CN", "hi", "es", "fr", "ar", "ru", "pt", "de",},
}
local ui_lang = gui.Combobox(ui_ref, "weather.language", "Force Language", unpack(t_lang[1]));

local ui_update = gui.Combobox(ui_ref, "weather.update", "Update Rate", "15 minutes", "30 minutes", "45 minutes", "1 hour");

local ui_colors = {
    gui.ColorPicker(ui_enable, "background", "background", 25, 25, 25, 180),
    gui.ColorPicker(ui_enable, "border", "border", 200, 40, 40, 120),
    gui.ColorPicker(ui_enable, "text", "text", 255, 255, 255, 255),
    gui.ColorPicker(ui_options[4], "clr", "icon", 255, 255, 255, 255),
};

local fonts = {
    small = draw.CreateFont("Bahnschrift", 18),
    medium = draw.CreateFont("Bahnschrift", 30),
    big = draw.CreateFont("Bahnschrift", 50),
};

local cache = {city, time, weather, icon, temp, prec, hum, wind, nextupdt,};
local function GetData()
    local data = (ui_lang:GetValue() == 0 and http.Get("https://www.google.com/search?q=weather") or http.Get("https://www.google.com/search?q=weather&hl=" .. t_lang[2][ui_lang:GetValue()]) );
    cache.city = string.match(data, [[id="wob_loc">(.-)<]]);
    cache.time = string.match(data, [[id="wob_dts">(.-)<]]);      
    cache.weather = string.match(data, [[id="wob_dc">(.-)<]]);
    cache.icon = http.Get("ssl.gstatic.com/onebox/weather/64/" .. string.match(data, [[src="//ssl.gstatic.com/onebox/weather/64/(.-).png" id="wob_tci"]]) ..".png")
    cache.temp = (ui_temp_mode:GetValue() == 0 and string.match(data, [[id="wob_tm" style="display:%a+">(.-)<]]) .. "°C" or string.match(data, [[id="wob_ttm" style="display:%a+">(.-)<]]) .. "°F");
    cache.prec = string.match(data, [[id="wob_pp">(.-)<]]);
    cache.hum = string.match(data, [[id="wob_hm">(.-)<]]);
    cache.wind = string.match(data, [[id="wob_ws">(.-)<]]);
    cache.nextupdt = math.floor(common.Time()) + (900 * (ui_update:GetValue() + 1));
end;
GetData();

local customposx, customposy, indic_bool, indic_force, indic_grab, sizex, sizey = 0, 0, true, false, false, 154, 70;

local ui_force_apply = gui.Button(ui_ref, "Force Update", GetData);
ui_force_apply:SetWidth(82);

local ui_indic_resetpos = gui.Button(ui_ref, "Reset Position", function() indic_force = true; customposx, customposy = 0, 450; end);
ui_indic_resetpos:SetWidth(82); ui_indic_resetpos:SetPosY(260); ui_indic_resetpos:SetPosX(92);

local ui_indic_manualpos = gui.Button(ui_ref, "Manual Position", function() indic_bool = not indic_bool; end);
ui_indic_manualpos:SetWidth(82); ui_indic_manualpos:SetPosY(260); ui_indic_manualpos:SetPosX(184);

local ui_indic_pos = {
    x = gui.Slider(ui_ref, "indic.posx", "Position X", 0, -2560, 2560, 1),
    y = gui.Slider(ui_ref, "indic.posy", "Position Y", 450, -1080, 1080, 1),
};
callbacks.Register("Draw", "Reset Pos & Slider Gestion", function()
    ui_indic_pos.x:SetInvisible(indic_bool); ui_indic_pos.y:SetInvisible(indic_bool);
    if indic_force == false then
        customposx, customposy = ui_indic_pos.x:GetValue(), ui_indic_pos.y:GetValue();
    else
        ui_indic_pos.x:SetValue(customposx);
        ui_indic_pos.y:SetValue(customposy);
        indic_force = false;
    end;
end);

callbacks.Register("Draw", "Weather Hud", function()
    if ui_enable:GetValue() == false then return; end;

    local scrx, scry = draw.GetScreenSize();
    local posx, posy = (scrx / 2), ((scry / 2));
    local fposx, fposy = posx - customposx, posy - customposy;
    local mx, my = input.GetMousePos();

    draw.Color(ui_colors[1]:GetValue());
    draw.FilledRect(fposx - sizex, fposy - sizey, fposx + sizex, fposy + sizey);

    draw.Color(ui_colors[2]:GetValue());
    draw.FilledRect(fposx - sizex - 2, fposy - sizey - 2, fposx - sizex, fposy + sizey + 2);
    draw.FilledRect(fposx + sizex + 2, fposy - sizey - 2, fposx + sizex, fposy + sizey + 2);
    draw.FilledRect(fposx - sizex, fposy - sizey, fposx + sizex, fposy - sizey - 2);
    draw.FilledRect(fposx - sizex, fposy + sizey, fposx + sizex, fposy + sizey + 2);

    draw.Color(ui_colors[3]:GetValue());
    if ui_options[1]:GetValue() then
        draw.SetFont(fonts.medium);
        draw.Text(fposx - sizex + 5, fposy - sizey + 5, cache.city);
    end;
    draw.SetFont(fonts.small);
    if ui_options[2]:GetValue() then
        draw.Text(fposx - sizex + 5, fposy - sizey + 32, cache.time);
    end;
    if ui_options[3]:GetValue() then
        draw.Text(fposx - sizex + 5, fposy - sizey + 51, cache.weather);
    end;
    if ui_options[6]:GetValue() then
        draw.Text(fposx - sizex + 180, fposy - sizey + 32, "Precipitation: " .. cache.prec);
    end;
    if ui_options[7]:GetValue() then
        draw.Text(fposx - sizex + 180, fposy - sizey + 51, "Humidity: " .. cache.hum);
    end;
    if ui_options[8]:GetValue() then
        draw.Text(fposx - sizex + 180, fposy - sizey + 70, "Wind: " .. cache.wind);
    end;
    if ui_options[5]:GetValue() then
        draw.SetFont(fonts.big);
        draw.Text(fposx - sizex + 69, fposy - sizey + 82, cache.temp);
    end;
    if ui_options[4]:GetValue() then
        draw.Color(ui_colors[4]:GetValue());
        draw.SetTexture(draw.CreateTexture(common.DecodePNG(cache.icon)));
        draw.FilledRect(fposx - sizex, fposy - sizey + 72, fposx - sizex + 64, fposy - sizey + 64 + 64);
        draw.SetTexture(nil);
    end;
    if input.IsButtonDown(1) and gui.Reference("Menu"):IsActive() then 
        if mx >= fposx-sizex and mx < fposx+sizex and my >= fposy-sizey and my < fposy+sizey then
            indic_grab = true;
        end;
        if indic_grab == true then
            customposx, customposy = (posx - mx), (posy - my);
            ui_indic_pos.x:SetValue(customposx);
            ui_indic_pos.y:SetValue(customposy);
            draw.Color(255,255,255,80); draw.FilledRect(fposx-sizex, fposy-sizey, fposx+sizex, fposy+sizey);
        end;        
    else
        indic_grab = false;
    end;
end);

callbacks.Register("Draw", "Auto Update", function()

  if common.Time() > cache.nextupdt then
    GetData();
  end;

end);
