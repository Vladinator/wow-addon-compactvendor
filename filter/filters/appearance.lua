local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local IsCollected do

    local Model = CreateFrame("DressUpModel")

    local InventorySlots = {
        ["INVTYPE_HEAD"] = 1,
        ["INVTYPE_NECK"] = 2,
        ["INVTYPE_SHOULDER"] = 3,
        ["INVTYPE_BODY"] = 4,
        ["INVTYPE_CHEST"] = 5,
        ["INVTYPE_ROBE"] = 5,
        ["INVTYPE_WAIST"] = 6,
        ["INVTYPE_LEGS"] = 7,
        ["INVTYPE_FEET"] = 8,
        ["INVTYPE_WRIST"] = 9,
        ["INVTYPE_HAND"] = 10,
        ["INVTYPE_CLOAK"] = 15,
        ["INVTYPE_WEAPON"] = 16,
        ["INVTYPE_SHIELD"] = 17,
        ["INVTYPE_2HWEAPON"] = 16,
        ["INVTYPE_WEAPONMAINHAND"] = 16,
        ["INVTYPE_RANGED"] = 16,
        ["INVTYPE_RANGEDRIGHT"] = 16,
        ["INVTYPE_WEAPONOFFHAND"] = 17,
        ["INVTYPE_HOLDABLE"] = 17,
        ["INVTYPE_TABARD"] = 19,
    }

    ---@param itemLinkOrID any
    ---@return boolean canCollect, boolean? isCollected
    function IsCollected(itemLinkOrID)
        local itemID, _, _, slotName = GetItemInfoInstant(itemLinkOrID)
        if not slotName then
            return false
        end
        local slot = InventorySlots[slotName]
        if not slot then
            return false
        end
        if itemLinkOrID == itemID then
            itemLinkOrID = format("item:%d", itemID)
        end
        if not C_Item.IsDressableItemByID(itemLinkOrID) then
            return false
        end
        Model:SetUnit("player")
        Model:Undress()
        Model:TryOn(itemLinkOrID, slot) ---@diagnostic disable-line: redundant-parameter
        local sourceID ---@type number?
        ---@diagnostic disable-next-line: undefined-field
        if Model.GetItemTransmogInfo then
            local sourceInfo = Model:GetItemTransmogInfo(slot) ---@diagnostic disable-line: undefined-field
            sourceID = sourceInfo and sourceInfo.appearanceID
        else
            sourceID = Model:GetSlotTransmogSources(slot)
        end
        if not sourceID then
            return false
        end
        local categoryID, appearanceID, canEnchant, texture, isCollected, itemLink = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
        return true, isCollected
    end

end

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Appearance",
    function(self, itemLink)
        local canCollect, isCollected = IsCollected(itemLink)
        if not canCollect then
            return true
        end
        return isCollected
    end,
    function(self, value)
        return value and TRANSMOG_COLLECTED or NOT_COLLECTED
    end
)

filter:Publish()
