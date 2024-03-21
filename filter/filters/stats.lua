local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias StatTablePolyfill table<string, number>

---@type StatTablePolyfill
local statTable = {}

---@param itemLink string
local function UpdateItemStatTable(itemLink)
    table.wipe(statTable)
    statTable = C_Item.GetItemStats(itemLink) or {}
    return statTable
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Stats", {},
    "itemLink", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values
        local options = self.options
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local itemLink = itemData[itemDataKey] ---@type string
            UpdateItemStatTable(itemLink)
            for statKey, _ in pairs(statTable) do
                values[statKey] = true
            end
        end
        for _, option in ipairs(options) do
            option.show = false
        end
        for value, _ in pairs(values) do
            local option = self:GetOption(value)
            if not option then
                option = {} ---@diagnostic disable-line: missing-fields
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
    ---@param value string?
    ---@param itemValue StatTablePolyfill
    function(_, value, itemValue)
        for statKey, _ in pairs(itemValue) do
            if statKey == value then
                return false
            end
        end
        return true
    end,
    true
)

filter:Publish()
