local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias StatTablePolyfill table<string, number?>

---@type StatTablePolyfill
local statTable = {}

---@param itemLink string
---@return StatTablePolyfill? statTable
local function UpdateItemStatTable(itemLink)
    if C_Item.GetItemStats then
        statTable = C_Item.GetItemStats(itemLink)
        return statTable
    end
    local GetItemStats = GetItemStats ---@diagnostic disable-line: undefined-global
    if GetItemStats then
        if statTable then
            table.wipe(statTable)
        end
        statTable = GetItemStats(itemLink, statTable)
    end
    return statTable
end

---@alias CompactVendorFilterDropDownStatsOptionValue string

---@class CompactVendorFilterDropDownStatsOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownStatsOptionValue

local filter = CompactVendorFilterDropDownTemplate:New(
    "Stats", {},
    "itemLink", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownStatsOptionValue, boolean?>
        local options = self.options ---@type CompactVendorFilterDropDownStatsOption[]
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local itemLink = itemData[itemDataKey] ---@type string
            if UpdateItemStatTable(itemLink) then
                for statKey, _ in pairs(statTable) do
                    values[statKey] = true
                end
            end
        end
        for _, option in ipairs(options) do
            option.show = false
        end
        for value, _ in pairs(values) do
            ---@type CompactVendorFilterDropDownStatsOption?
            local option = self:GetOption(value) ---@diagnostic disable-line: assign-type-mismatch
            if not option then
                option = { value = nil, text = nil } ---@diagnostic disable-line: assign-type-mismatch
                options[#options + 1] = option
            end
            option.value = value
            option.text = tostring(_G[value])
            option.show = true
            if option.checked == nil then
                option.checked = true
            end
        end
    end,
    function(_, itemLink)
        return UpdateItemStatTable(itemLink)
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
