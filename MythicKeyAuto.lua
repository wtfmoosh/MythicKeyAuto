local ADDON_NAME = "MythicKeyAuto"
local frame = CreateFrame("Frame")

-- Target item we're looking for
local TARGET_ITEM = "Mythic Keystone : Scarlet Monastery - Armory"
local NPC_NAME = "Mythic"

-- Addon state
local addonEnabled = true
local stopOnTarget = true

-- Function to check if target item is in inventory
local function CheckForTargetItem()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                if itemName and itemName == TARGET_ITEM then
                    return true
                end
            end
        end
    end
    return false
end

-- Main event handler
frame:RegisterEvent("GOSSIP_SHOW")
frame:SetScript("OnEvent", function(self, event, ...)
    if not addonEnabled then return end
    
    if event == "GOSSIP_SHOW" then
        local npcName = UnitName("npc")
        if npcName == NPC_NAME then
            -- Check if we already have the item and stopOnTarget is enabled
            if stopOnTarget and CheckForTargetItem() then
                CloseGossip()
                return
            end
            
            -- Try to find and click our option
            local options = {GetGossipOptions()}
            local foundOption = false
            
            for i = 1, #options do
                local optionText = options[i]
                if optionText and (
                   string.find(string.lower(optionText), "new mythic") or
                   string.find(string.lower(optionText), "mythic%+") or
                   string.find(string.lower(optionText), "give me")) then
                    SelectGossipOption(i)
                    foundOption = true
                    break
                end
            end
            
            -- If no specific option found, click first one as fallback
            if not foundOption and #options > 0 then
                SelectGossipOption(1)
            end
        end
    end
end)

-- Handle static popups
local function StaticPopupHook()
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsVisible() then
            local text = _G["StaticPopup" .. i .. "Text"]:GetText()
            if text and (string.find(string.lower(text), "mythic") or string.find(string.lower(text), "key")) then
                StaticPopup_OnClick(popup, 1)
                return true
            end
        end
    end
    return false
end

-- Hook into static popup show
hooksecurefunc("StaticPopup_Show", function(which, text, ...)
    if not addonEnabled then return end
    
    if text and (string.find(string.lower(text), "mythic") or string.find(string.lower(text), "key")) then
        C_Timer.After(0, function()
            StaticPopupHook()
        end)
    end
end)

-- Also check popups on gossip show
frame:SetScript("OnUpdate", function(self, elapsed)
    if not addonEnabled then return end
    
    if GossipFrame:IsVisible() then
        local npcName = UnitName("npc")
        if npcName == NPC_NAME then
            StaticPopupHook()
        end
    end
end)

-- Function to set target item
local function SetTargetItem(itemName, command)
    TARGET_ITEM = itemName
    print("|cFF00FF00MythicKeyAuto:|r Target set to: |cFFFFFF00" .. TARGET_ITEM .. "|r")
    print("|cFFFFFF00Command:|r /mka " .. command)
    
    -- Check current status
    local itemStatus = CheckForTargetItem() and "|cFF00FF00FOUND|r" or "|cFFFF0000NOT FOUND|r"
    print("|cFFFFFF00Status:|r " .. itemStatus)
end

-- Slash command
SLASH_MYTHICKEYAUTO1 = "/mka"
SLASH_MYTHICKEYAUTO2 = "/mythickeyauto"
SlashCmdList["MYTHICKEYAUTO"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "off" or msg == "disable" or msg == "0" then
        addonEnabled = false
        print("|cFF00FF00MythicKeyAuto:|r |cFFFF0000DISABLED|r - Will not automate NPC interactions")
        
    elseif msg == "on" or msg == "enable" or msg == "1" then
        addonEnabled = true
        print("|cFF00FF00MythicKeyAuto:|r |cFF00FF00ENABLED|r - Will automate NPC interactions")
        
    elseif msg == "stop" or msg == "armory" then
        stopOnTarget = not stopOnTarget
        local stopStatus = stopOnTarget and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"
        print("|cFF00FF00MythicKeyAuto:|r Stop on target key: " .. stopStatus)
        if not stopOnTarget then
            print("|cFFFFFF00Note:|r Addon will continue cycling even when target key is in inventory")
        end
        
    -- Scarlet Monastery Keys
    elseif msg == "armory" then
        SetTargetItem("Mythic Keystone : Scarlet Monastery - Armory", "ARMORY")
    elseif msg == "gy" then
        SetTargetItem("Mythic Keystone : Scarlet Monastery - Graveyard", "GY")
    elseif msg == "cath" then
        SetTargetItem("Mythic Keystone : Scarlet Monastery - Cathedral", "CATH")
    elseif msg == "lib" then
        SetTargetItem("Mythic Keystone : Scarlet Monastery - Library", "LIB")
        
    -- Other Dungeons
    elseif msg == "rfc" then
        SetTargetItem("Mythic Keystone : Ragefire Chasm", "RFC")
    elseif msg == "rfk" then
        SetTargetItem("Mythic Keystone : Razorfen Kraul", "RFK")
    elseif msg == "zf" then
        SetTargetItem("Mythic Keystone : Zul'Farrak (ZF)", "ZF")
    elseif msg == "bfd" then
        SetTargetItem("Mythic Keystone : Blackfathom Deeps", "BFD")
        
    -- Dire Maul
    elseif msg == "dmn" then
        SetTargetItem("Mythic Keystone : Dire Maul - North", "DMN")
    elseif msg == "dmw" then
        SetTargetItem("Mythic Keystone : Dire Maul - West", "DMW")
    elseif msg == "dme" then
        SetTargetItem("Mythic Keystone : Dire Maul - East", "DME")
        
    -- Maraudon
    elseif msg == "purple" then
        SetTargetItem("Mythic Keystone : Maraudon - Purple Crystals", "PURPLE")
    elseif msg == "orange" then
        SetTargetItem("Mythic Keystone : Maraudon - Orange Crystals", "ORANGE")
    elseif msg == "pristine" then
        SetTargetItem("Mythic Keystone : Maraudon - Pristine Waters", "PRISTINE")
        
    -- More Dungeons
    elseif msg == "uldaman" then
        SetTargetItem("Mythic Keystone : Uldaman", "ULDAMAN")
    elseif msg == "scholo" then
        SetTargetItem("Mythic Keystone : Scholomance", "SCHOLO")
    elseif msg == "dm" then
        SetTargetItem("Mythic Keystone : Deadmines (DM)", "DM")
    elseif msg == "gnomeregan" then
        SetTargetItem("Mythic Keystone : Gnomeregan", "GNOMEREGAN")
    elseif msg == "brd" then
        SetTargetItem("Mythic Keystone : Blackrock Depths - Prison", "BRD")
    elseif msg == "sfk" then
        SetTargetItem("Mythic Keystone : Shadowfang Keep", "SFK")
    elseif msg == "stockades" then
        SetTargetItem("Mythic Keystone : Stormwind Stockades", "STOCKADES")
        
    elseif msg == "status" or msg == "" then
        local status = addonEnabled and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"
        local itemStatus = CheckForTargetItem() and "|cFF00FF00FOUND|r" or "|cFFFF0000NOT FOUND|r"
        local stopStatus = stopOnTarget and "|cFF00FF00ENABLED|r" or "|cFFFF0000DISABLED|r"
        
        print("|cFF00FF00MythicKeyAuto Status:|r")
        print("Addon: " .. status)
        print("Stop on target: " .. stopStatus)
        print("Target Item: " .. itemStatus .. " (" .. TARGET_ITEM .. ")")
        
    elseif msg == "debug" then
        -- Hidden debug command for troubleshooting
        if GossipFrame:IsVisible() then
            local options = {GetGossipOptions()}
            print("|cFFFFFF00MythicKeyAuto Debug - Available Options:|r")
            for i, option in ipairs(options) do
                print(i .. ": " .. tostring(option))
            end
        else
            print("|cFFFFFF00MythicKeyAuto:|r No gossip frame visible")
        end
        
    else
        print("|cFF00FF00MythicKeyAuto Commands:|r")
        print("|cFFFFFF00/mka on|r - Enable automation")
        print("|cFFFFFF00/mka off|r - Disable automation")
        print("|cFFFFFF00/mka stop|r - Toggle stop on target key")
        print("|cFFFFFF00/mka status|r - Check current status")
        print("")
        print("|cFFFFFF00Scarlet Monastery Keys:|r")
        print("|cFFFFFF00/mka ARMORY|r - Scarlet Monastery - Armory")
        print("|cFFFFFF00/mka GY|r - Scarlet Monastery - Graveyard")
        print("|cFFFFFF00/mka CATH|r - Scarlet Monastery - Cathedral")
        print("|cFFFFFF00/mka LIB|r - Scarlet Monastery - Library")
        print("")
        print("|cFFFFFF00Other Dungeons:|r")
        print("|cFFFFFF00/mka RFC|r - Ragefire Chasm")
        print("|cFFFFFF00/mka RFK|r - Razorfen Kraul")
        print("|cFFFFFF00/mka ZF|r - Zul'Farrak")
        print("|cFFFFFF00/mka BFD|r - Blackfathom Deeps")
        print("|cFFFFFF00/mka DMN|r - Dire Maul North")
        print("|cFFFFFF00/mka DMW|r - Dire Maul West")
        print("|cFFFFFF00/mka DME|r - Dire Maul East")
        print("|cFFFFFF00/mka PURPLE|r - Maraudon Purple")
        print("|cFFFFFF00/mka ORANGE|r - Maraudon Orange")
        print("|cFFFFFF00/mka PRISTINE|r - Maraudon Pristine")
        print("|cFFFFFF00/mka ULDAMAN|r - Uldaman")
        print("|cFFFFFF00/mka SCHOLO|r - Scholomance")
        print("|cFFFFFF00/mka DM|r - Deadmines")
        print("|cFFFFFF00/mka GNOMEREGAN|r - Gnomeregan")
        print("|cFFFFFF00/mka BRD|r - Blackrock Depths")
        print("|cFFFFFF00/mka SFK|r - Shadowfang Keep")
        print("|cFFFFFF00/mka STOCKADES|r - Stockades")
        print("")
        print("|cFFFFFF00/mka debug|r - Show debug info (hidden command)")
    end
end

print("|cFF00FF00MythicKeyAuto loaded!|r Use |cFFFFFF00/mka|r for commands.")
print("Current target: |cFFFFFF00" .. TARGET_ITEM .. "|r")