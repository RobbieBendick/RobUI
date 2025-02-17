local _, addon = ...
local Rob = _G.LibStub("AceAddon-3.0"):NewAddon("RobUI", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
addon.name = "RobUI"
Rob.name = "RobUI"
local FRAME_TEXTURE = [[Interface\AddOns\RobUI\Textures\UI-TargetingFrame]]

local TALL_HEALTHBAR_HEIGHT = 31

local defaults = {
    profile = {
        isRaidProfileSwapperEnabled = true,
        isClassColoredHealthbarsEnabled = true,
        isClassColoredNamesEnabled = true,
        isClassColoredTargetFrameNameBackgroundEnabled = true,
        isTallHealthbarEnabled = true,
    }
}

local options = {
    name = "RobUI Settings",
    type = "group",
    args = {
        isRaidProfileSwapperEnabled = {
            order = 1,
            type = "toggle",
            name = "RaidProfileSwapper",
            desc = "Enable or disable the RaidProfileSwapper feature\n\n|cffffd700Available Profiles|r:\n- 1-5\n- 6-10\n- 11-15\n- 16-20\n- 21-40\n\n|cffff0000You must create raid profiles with these exact names in the interface settings.|r",
            get = function() return Rob.db.profile.isRaidProfileSwapperEnabled end,
            set = function(_, value)
                Rob.db.profile.isRaidProfileSwapperEnabled = value
            end,
        },
        isClassColoredHealthbarsEnabled = {
            order = 2,
            type = "toggle",
            name = "Class Color Healthbars",
            desc = "Enable or disable class color healthbars",
            get = function() return Rob.db.profile.isClassColoredHealthbarsEnabled end,
            set = function(_, value)
                Rob.db.profile.isClassColoredHealthbarsEnabled = value
            end,
        },
        isClassColoredNamesEnabled = {
            order = 3,
            type = "toggle",
            name = "Class Color Names",
            desc = "Enable or disable class color names",
            get = function() return Rob.db.profile.isClassColoredNamesEnabled end,
            set = function(_, value)
                Rob.db.profile.isClassColoredNamesEnabled = value
            end,
        },
        isClassColoredTargetFrameNameBackgroundEnabled = {
            order = 4,
            type = "toggle",
            name = "Class Color Target Frame Background",
            desc = "Enable or disable class colored name background on the target frame",
            get = function() return Rob.db.profile.isClassColoredTargetFrameNameBackgroundEnabled end,
            set = function(_, value)
                Rob.db.profile.isClassColoredTargetFrameNameBackgroundEnabled = value
            end,
        },
        isTallHealthbarEnabled = {
            order = 5,
            type = "toggle",
            name = "Tall Healthbars",
            desc = "Enable or disable tall healthbars",
            get = function() return Rob.db.profile.isTallHealthbarEnabled end,
            set = function(_, value)
                Rob.db.profile.isTallHealthbarEnabled = value
            end,
        }
    },
}

function Rob:LoadSlashCommands()
    SLASH_ROBUI1 = "/rob"
    SLASH_ROBUI2 = "/rui"
    SLASH_ROBUI3 = "/robui"
    SlashCmdList["ROBUI"] = function(msg)
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory(addon.name)
        else
            InterfaceOptionsFrame_OpenToCategory(addon.name)
            InterfaceOptionsFrame_OpenToCategory(addon.name)
        end
    end
end

function Rob:ChangeShamanClassColor()
    RAID_CLASS_COLORS["SHAMAN"].r = 0
    RAID_CLASS_COLORS["SHAMAN"].g = 0.44
    RAID_CLASS_COLORS["SHAMAN"].b = 0.87
end

function Rob:HandleHealthbarAndNameColors()
    local function UpdateHealthBarColor(healthbar, unit)
        if not healthbar or not unit then return end

        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local color = RAID_CLASS_COLORS[class]
            if Rob.db.profile.isClassColoredHealthbarsEnabled then
                healthbar:SetStatusBarColor(color.r, color.g, color.b)
            end
        else
            if UnitIsTapDenied(unit) then
                healthbar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
                return
            end
            local r, g, b = UnitSelectionColor(unit)
            healthbar:SetStatusBarColor(r, g, b)
        end
    end
    
    local function UpdateNameColor(nameFrame, r, g, b)
        if not Rob.db.profile.isClassColoredNamesEnabled then return end

        if nameFrame then
            nameFrame:SetTextColor(r, g, b)
        end
    end
    
    -- 0.5 opacity if not class colored
    if not self.db.profile.isClassColoredTargetFrameNameBackgroundEnabled then
        hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
            self:SetVertexColor(0, 0, 0, 0.5)
        end)
    end

    -- Class Colored PlayerFrame Healthbar
    if self.db.profile.isClassColoredHealthbarsEnabled then
        hooksecurefunc(PlayerFrameHealthBar, "SetStatusBarColor", function(self) 
            local _, class = UnitClass(PLAYER)
            local color = RAID_CLASS_COLORS[class]
            self:SetStatusBarColor(color.r, color.g, color.b)
        end)
    end

    --  Class Colored/Unit Selection Color Target Healthbars
    if self.db.profile.isClassColoredHealthbarsEnabled then
        hooksecurefunc(TargetFrame.healthbar, "SetStatusBarColor", function(self, r, g, b)
            local unit = TargetFrame.unit
            if UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                local color = RAID_CLASS_COLORS[class]
                self:SetStatusBarColor(color.r, color.g, color.b)
            else
                if UnitIsTapDenied(unit) then
                    self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
                else
                    local r, g, b = UnitSelectionColor(unit)
                    self:SetStatusBarColor(r, g, b)
                end
            end
        end)
    end
    
    -- Tall Healthbars
    hooksecurefunc("PlayerFrame_ToPlayerArt", function()
        if not Rob.db.profile.isTallHealthbarEnabled then return end
        PlayerFrameTexture:SetTexture(FRAME_TEXTURE)

        PlayerFrameHealthBar:SetHeight(TALL_HEALTHBAR_HEIGHT)
    
        PlayerFrameHealthBar:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -22)

        PlayerFrameHealthBarText:ClearAllPoints()
        PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0)

        PlayerStatusTexture:Hide()
    end)

    local eliteIcon = TargetFrame:CreateTexture(nil, "OVERLAY")
    eliteIcon:SetPoint("RIGHT", TargetFrame, "RIGHT", 60, 0)
    eliteIcon:SetTexture("Interface\\AddOns\\RobUI\\Textures\\dragon.blp")
    eliteIcon:Hide()

    hooksecurefunc("TargetFrame_Update", function(self)
        TargetFrameTextureFrameTexture:SetTexture(FRAME_TEXTURE)

        if Rob.db.profile.isTallHealthbarEnabled then
            self.healthbar:SetHeight(TALL_HEALTHBAR_HEIGHT)
            self.healthbar:SetPoint("TOPLEFT", 7, -22)
            TargetFrameBackground:Hide()
        end

        if UnitExists(TARGET) and UnitClassification(TARGET) == "elite" then
            eliteIcon:Show()
        else
            eliteIcon:Hide()
        end
    end)


    -- Class Colored / Unit Selection Colored Target Name Background
    if Rob.db.profile.isClassColoredTargetFrameNameBackgroundEnabled then
        hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
            if UnitIsPlayer(TargetFrame.unit) then
                local _, class = UnitClass(TargetFrame.unit)
                local color = RAID_CLASS_COLORS[class]
                self:SetVertexColor(color.r, color.g, color.b)
            else
                local r, g, b = UnitSelectionColor(TargetFrame.unit)
                self:SetVertexColor(r, g, b)
            end
        end)
    end

    hooksecurefunc("TargetofTarget_Update", function(self)
        UpdateHealthBarColor(self.healthbar, self.unit)
    end)

    if Rob.db.profile.isClassColoredNamesEnabled then
        hooksecurefunc(PlayerName, "SetTextColor", function(self, r,g,b,a) 
            local _, class =  UnitClass(PLAYER)
            local color = RAID_CLASS_COLORS[class]
            self:SetTextColor(color.r, color.g, color.b)
        end)

        hooksecurefunc(TargetFrame.name, "SetTextColor", function(self, r,g,b,a) 
            local _, class =  UnitClass(TARGET)
            local color = RAID_CLASS_COLORS[class]
            self:SetTextColor(color.r, color.g, color.b)
        end)
    end
 

end

function Rob:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(self.name.."DB", defaults, true)

    AceConfig:RegisterOptionsTable(self.name, options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(self.name, self.name)

    self:LoadSlashCommands()

    self:ChangeShamanClassColor()

    if self.db.profile.isTallHealthbarEnabled then
        hooksecurefunc(TargetFrameNameBackground, "Show", function(self)
            self:Hide()
        end)
    end


    self:HandleHealthbarAndNameColors()


    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "RaidProfileSwapper")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "RaidProfileSwapper")
end