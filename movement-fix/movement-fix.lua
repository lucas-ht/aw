local weapon_dt = {
    [1] = "hpistol",[2] = "pistol",[3] = "pistol",[4] = "pistol",[7] = "rifle",[8] = "rifle",[10] = "rifle",[11] = "asniper",[13] = "rifle",
    [14] = "lmg",[16] = "rifle",[17] = "smg",[19] = "smg",[23] = "smg",[24] = "smg",[25] = "shotgun",[26] = "smg",[28] = "lmg",[30] = "pistol",
    [32] = "pistol",[33] = "smg",[34] = "smg",[36] = "pistol",[38] = "asniper",[39] = "rifle",[60] = "rifle",[61] = "pistol",[63] = "pistol",
};
local curr_dt, hist_dt, lp, lp_wt = false, false, nil, nil;
callbacks.Register("CreateMove", "DT Movement Fix", function()
    lp = entities.GetLocalPlayer();
    lp_wt = lp:GetWeaponID();
    curr_dt = (weapon_dt[lp_wt] ~= nil and gui.GetValue("rbot.accuracy.weapon." .. weapon_dt[lp_wt] .. ".doublefire") ~= 0 or false);
    if curr_dt == true then
        hist_dt = true;
    elseif curr_dt == false and hist_dt == true then
        if math.sqrt(lp:GetPropFloat("localdata", "m_vecVelocity[0]")^2 + lp:GetPropFloat("localdata", "m_vecVelocity[1]")^2) == 0 then
            hist_dt = false;
        end;
    end;
    gui.SetValue("misc.fakelag.enable", not hist_dt);
end);
