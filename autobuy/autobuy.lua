local ui_ref = gui.Groupbox( gui.Reference("Misc", "Enhancement"), "Fast Autobuy", 328, 312, 296);
local autobuy_list = {
    {"g3sg1", "awp", "ssg08", "ak47", "sg556",},
    {"deagle", "elite",},
    {"vest", "vesthelm", "taser", "defuser", "molotov", "hegrenade", "smokegrenade", "flashbang", "flashbang", "decoy",},
};
local ui_autobuy = {
    gui.Combobox(ui_ref, "autobuy.primary", "Primary", "Off", "Autosniper", "AWP", "Scout", "Rifle", "Scoped Rifle"),
    gui.Combobox(ui_ref, "autobuy.secondary", "Secondary", "Off", "HP", "Dual Berretas"),
    extra_ref = gui.Multibox(ui_ref, "Extra"),
    ping = gui.Slider(ui_ref, "autobuy.ping", "Latency Difference", 0, -100, 100, 1),
};
ui_autobuy.ping:SetDescription("The difference between the scoreboard and the real.")
local ui_autobuy_extra = {
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.vest", "Vest", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.helmet", "Helmet", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.taser", "Taser", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.kit", "Defuse Kit", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.inc", "Incendiary", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.he", "Explosif", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.smoke", "Smoke", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.flash", "Flash", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.flash2", "Second Flash", false),
    gui.Checkbox(ui_autobuy.extra_ref, "autobuy.extra.decoy", "Decoy", false),
};
local info_autobuy = {
    buy = false,
    prediction = 0,
    temp = {
        primary,
        secondary,
        extra,
    },
    string,
};
local function GetPing()
    local temp = ((entities.GetPlayerResources():GetPropInt("m_iPing", client.GetLocalPlayerIndex()) + ui_autobuy.ping:GetValue()) / 1000);
    temp = (gui.GetValue("misc.fakelatency.enable") and (temp - gui.GetValue("misc.fakelatency.amount")) or temp);
    return temp;
end;
callbacks.Register("FireGameEvent", "autobuy setup", function(e)
    if e:GetName() == "round_end" then
        info_autobuy.prediction = (globals.CurTime() + client.GetConVar("mp_round_restart_delay"));
        info_autobuy.temp.primary = (ui_autobuy[1]:GetValue() ~= 0 and "buy " .. autobuy_list[1][ui_autobuy[1]:GetValue()] .. ";" or "");
        info_autobuy.temp.secondary = (ui_autobuy[2]:GetValue() ~= 0 and "buy " .. autobuy_list[2][ui_autobuy[2]:GetValue()] .. ";" or "");
        info_autobuy.temp.extra = "";
        for i = 1, #ui_autobuy_extra do
            info_autobuy.temp.extra = info_autobuy.temp.extra .. (ui_autobuy_extra[i]:GetValue() and "buy " .. autobuy_list[3][i] .. ";" or "");
        end;
        info_autobuy.string = (info_autobuy.temp.primary .. info_autobuy.temp.secondary .. info_autobuy.temp.extra);
        info_autobuy.buy = true;
    end;
end);
client.AllowListener("round_end");
callbacks.Register("Draw", "autobuy", function()
    if entities.GetLocalPlayer() == nil then return; end;
    if info_autobuy.buy == true and (globals.CurTime() + GetPing()) >= info_autobuy.prediction then
        client.Command(info_autobuy.string, true);
        info_autobuy.buy = false;
    end;
end);
