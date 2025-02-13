local _, addon = ...;
local Rob = LibStub("AceAddon-3.0"):GetAddon(addon.name);

function Rob:RaidProfileSwapper()
    if not self.db.profile.isRaidProfileSwapperEnabled then return end
    if InCombatLockdown() then return end
    if not IsInGroup() then return end

    local profile = "1-5"
    local groupSize = GetNumGroupMembers()

    if groupSize > 5 then
        profile = "6-10"
    end
    if groupSize > 10 then
        profile = "11-15"
    end
    if groupSize > 15 then
        profile = "16-20"
    end
    if groupSize > 20 then
        profile = "21-40"
    end

    if profile == CompactUnitFrameProfiles.selectedProfile then return end

    pcall(function()
        CompactUnitFrameProfiles_ActivateRaidProfile(profile)
    end)
end
