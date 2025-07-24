local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@type table<string, string?>
local statTextMap = {
    ITEM_MOD_HOLY_RESISTANCE_SHORT = "RESISTANCE1_NAME",
    ITEM_MOD_FIRE_RESISTANCE_SHORT = "RESISTANCE2_NAME",
    ITEM_MOD_NATURE_RESISTANCE_SHORT = "RESISTANCE3_NAME",
    ITEM_MOD_FROST_RESISTANCE_SHORT = "RESISTANCE4_NAME",
    ITEM_MOD_SHADOW_RESISTANCE_SHORT = "RESISTANCE5_NAME",
    ITEM_MOD_ARCANE_RESISTANCE_SHORT = "RESISTANCE6_NAME",
}

---@param stat string
local function GetStatText(stat)
    if not stat then
        return tostring(stat)
    end
    local text = _G[stat] ---@type string?
    if text then
        return text
    end
    text = statTextMap[stat]
    if not text then
        return stat
    end
    text = _G[text] ---@type string?
    if text then
        return text
    end
    return stat
end

---@alias StatTablePolyfill table<string, number?>

---@type StatTablePolyfill
local statTable = {}

local function ReMapStatTable()
    local remap ---@type table<string, string>?
    for stat, _ in pairs(statTable) do
        local newStat = statTextMap[stat]
        if newStat then
            if not remap then
                remap = {}
            end
            remap[stat] = newStat
        end
    end
    if not remap then
        return
    end
    for stat, newStat in pairs(remap) do
        local value = statTable[stat]
        statTable[stat] = nil
        statTable[newStat] = value
    end
end

---@param itemLink string
---@return StatTablePolyfill? statTable
local function UpdateItemStatTable(itemLink)
    if C_Item.GetItemStats then
        statTable = C_Item.GetItemStats(itemLink)
        statTable = statTable or {}
        ReMapStatTable()
        return statTable
    end
    local GetItemStats = GetItemStats ---@diagnostic disable-line: undefined-global
    if GetItemStats then
        statTable = statTable or {}
        table.wipe(statTable)
        statTable = GetItemStats(itemLink, statTable)
        statTable = statTable or {}
    end
    ReMapStatTable()
    return statTable
end

---@alias CompactVendorFilterDropDownStatsOptionValue string

---@class CompactVendorFilterDropDownStatsOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownStatsOptionValue

---@param options CompactVendorFilterDropDownStatsOption[]
---@param itemValue StatTablePolyfill
---@return StatTablePolyfill statTable
local function FilterItemValue(options, itemValue)
    local temp = {} ---@type StatTablePolyfill
    for _, option in ipairs(options) do
        if option.show and option.checked then
            local key = option.value
            local value = itemValue[key]
            temp[key] = value
        end
    end
    return temp
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Stats", {},
    "itemLink", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownStatsOptionValue, boolean?>
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local itemLink = itemData[itemDataKey] ---@type string
            if UpdateItemStatTable(itemLink) then
                for statKey, _ in pairs(statTable) do
                    values[statKey] = true
                end
            end
        end
        for value, _ in pairs(values) do
            ---@type CompactVendorFilterDropDownStatsOption
            local option = self:GetOption(value, true) ---@diagnostic disable-line: assign-type-mismatch
            option.value = value
            option.text = GetStatText(value)
            option.show = true
        end
    end,
    function(self, itemLink)
        local itemValue = UpdateItemStatTable(itemLink)
        if not itemValue then
            return
        end
        return FilterItemValue(self.options, itemValue)
    end,
    ---@param value? CompactVendorFilterDropDownStatsOptionValue
    ---@param itemValue? StatTablePolyfill?
    function(_, value, itemValue)
        if not value or not itemValue then
            return
        end
        local statValue = itemValue[value]
        return statValue == nil
    end,
    true
)

filter:Publish()
