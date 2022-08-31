local info = {
    v_loc = 1.05,
    v_onl = http.Get("https://raw.githubusercontent.com/zer420/Menu-Translator/master/version"),
    src = "https://raw.githubusercontent.com/zer420/Menu-Translator/master/core.lua",
    dir = "zerlib\\",
    sc_dir = "menutrsltr\\",
    name = GetScriptName(),
    updt_available = false,
};

UnloadScript(info.dir .. "reload.lua");
file.Delete(info.dir .. "reload.lua");

local function Updater()
    if info.v_loc < tonumber(info.v_onl) then
        file.Write(info.dir .. "reload.lua", [[local f=0;callbacks.Register("Draw",function()if f==0 then UnloadScript("]]..info.name..[[");elseif f==1 then LoadScript("]]..info.name..[[");end;f=f+1;end);]])
        file.Write(info.name, http.Get(info.src)); LoadScript(info.dir .. "reload.lua");
end; end; Updater(); --auto-updater + auto-reloader

local db = {
    prev = 1,
    lang_name = {"English", "中文",}, --"Русский", "Français", "Español", "Suomi", "Português", "Romana", "Deutsch", "Italiano",
    lang_checked = {false, false,},
    lang_outdated = {false, false,},
    ui = {[1] = {},[2] = {},[3] = {},[4] = {},[5] = {},[6] = {},[7] = {},}, --used to store og ui
    lang = {
        ["English"] = {},
        ["中文"] = {},
    },
    src = {
        [1] = "https://raw.githubusercontent.com/zer420/Menu-Translator/master/languages/English",
        [2] = "https://raw.githubusercontent.com/AimwarePasteLua/Chineseware/master/%E4%B8%AD%E6%96%87.lua",
    },
    v_onl = {
        [1] = "https://raw.githubusercontent.com/zer420/Menu-Translator/master/languages/English-version",
        [2] = "https://raw.githubusercontent.com/AimwarePasteLua/Chineseware/master/version",
    },
}; --database with every language inside

local ui_ref = gui.Reference("Settings", "Advanced", "Manage advanced settings");
local ui_select = gui.Combobox(ui_ref, "language", "Menu Language", unpack(db.lang_name)); ui_select:SetDescription("Translate the menu into various languages.");
local warning = gui.Text(ui_ref, ""); warning:SetInvisible(true);
--user interface
local function UnloadScripts(f)
    if f ~= info.name then
        UnloadScript(f:match(".*lua$") ~= nil and f or "");
    end;
end;
file.Enumerate(UnloadScripts); --unloads all your other luas

local function GetUIChildren(obj, level)
    if obj:GetName() ~= "" then
        table.insert(db.ui[level], obj);
    end;
	for child in obj:Children() do
		GetUIChildren(child, level + 1);
    end;
end;
GetUIChildren(gui.Reference("Menu"), 0); --credits to polak, gets every ui elements with their level of parent

local function LanguageUpdater(i)

    local curr_dir = (info.dir .. info.sc_dir .. db.lang_name[i] .. ".lua");
    local curr_db = db.lang[db.lang_name[i]];

    if db.lang_checked[i] == false then
        curr_db = RunScript(curr_dir);
        info.updt_available = false;
        if curr_db == nil then
            info.updt_available = true;
        elseif curr_db.v_loc == nil then
            info.updt_available = true;
        elseif curr_db.v_loc < tonumber(http.Get(db.v_onl[i])) then --checks for update
            info.updt_available = true;
        end;
        if info.updt_available == true then
            file.Write(curr_dir, http.Get(db.src[i])); curr_db = RunScript(curr_dir); --downloads it
        end;
        db.lang_checked[i] = true;

        db.lang[db.lang_name[i]] = curr_db;
        for j = 1, #db.ui do
            if #db.ui[j] ~= #curr_db[j] then --checks if outdated
                db.lang_outdated[i] = true;
            end;
        end; 
    end;
end;

local function EntryIsValid(i, j, k, type)
    if db.lang[db.lang_name[i]][j][k] == nil or db.ui[j][k] == nil then return false; end;
    if type == 1 then return db.lang[db.lang_name[i]][j][k][type] ~= nil;
    elseif db.lang[db.lang_name[i]][j][k][2] == nil then return false; end;
    return db.lang[db.lang_name[i]][j][k][2][type - 1] ~= nil;
end; --double checks if anything is wrong

local function SetLanguage(i)    
    if db.lang_outdated[i] == false then
        warning:SetInvisible(true);
        for j = 1, #db.ui do -- loops thru each level of ui
            for k, obj in pairs(db.ui[j]) do -- loops thru each elements
                if EntryIsValid(i, j, k, 1) == true then
                    obj:SetName(db.lang[db.lang_name[i]][j][k][1]);
                end;
                if EntryIsValid(i, j, k, 2) == true then
                    obj:SetDescription(db.lang[db.lang_name[i]][j][k][2][1]);
                end;
                if EntryIsValid(i, j, k, 3) == true then
                    obj:SetOptions(unpack(db.lang[db.lang_name[i]][j][k][2][2]));
                end;
            end;
        end;
    else
        warning:SetInvisible(false); warning:SetText(db.lang[db.lang_name[i]].otdt_msg); -- draws outdated text
    end;
    db.prev = i;
end;

local function SetupUI()
    for i = 1, #db.lang_name do
        LanguageUpdater(i);
    end;
    SetLanguage(1);
end; SetupUI();

callbacks.Register("Draw", function()
    if (ui_select:GetValue() + 1) ~= db.prev then
        SetLanguage(ui_select:GetValue() + 1);        
    end;
end);

callbacks.Register("Unload", function()
    SetLanguage(1);
end);

MenuTranslator = {
    objectTranslation = {pos = {}, translated = {},},
    newTranslation = function(object, description, ...)
        return MenuTranslator.objectTranslation:new(object, description, ...);
    end,
    GetLang = function() return db.prev; end,   
    GetReference = function(...)
        local arg, output = {...}, {};
        for i, ref in pairs(arg) do
            for j = 1, #db.lang["English"] do
                for k, obj in pairs(db.lang["English"][j]) do
                    if obj[1] == ref then                    
                        table.insert(output, db.lang[db.lang_name[db.prev]][j][k][1] );
                        break;
                    end;
                end;
            end;
        end;
        return gui.Reference(unpack(output));
    end,
    Refresh = function() SetLanguage(db.prev); end,
};

function MenuTranslator.objectTranslation:new(object, description, ...)
    GetUIChildren(gui.Reference("Menu"), 0);
    for j = 1, #db.ui do
        for k, obj in pairs(db.ui[j]) do            
            if obj:GetName() == object:GetName() then                
                local tempName = obj:GetName();
                obj:SetName("MenuTranslationCheck"); object:SetName("MenuTranslationCheck");
                if obj:GetName() == object:GetName() then
                    obj:SetName(tempName); object:SetName(tempName);

                    table.insert(db.lang["English"][j], k, {[1] = object:GetName(), [2] = {[1] = description, [2] = {...},},});
                    o = {};
                    setmetatable(o, self);
                    self.__index = self;
                    self.pos = {j, k};
                    self.translated = {1,};
                    return o

                end;
                obj:SetName(tempName); object:SetName(tempName);
            end;
        end;    
    end;    
end;

function MenuTranslator.objectTranslation:SetTranslation(language, name, description, ...)
    table.insert(
        db.lang[db.lang_name[language]][self.pos[1]],
        self.pos[2],
        {[1] = name, [2] = {[1] = description, [2] = {...},},}
    );
    table.insert(self.translated, language);
end;

function MenuTranslator.objectTranslation:Remove()
    for __, lg in pairs(self.translated) do
        table.remove(db.lang[db.lang_name[lg]][self.pos[1]], self.pos[2]);
    end;
end;

function MenuTranslator.objectTranslation:Update(language, name, description, ...)
    db.lang[db.lang_name[language]][self.pos[1]][self.pos[2]] = {[1] = name, [2] = {[1] = description, [2] = {...},},};
end;
