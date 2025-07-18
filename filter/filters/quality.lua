local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

local ns = select(2, ...) ---@class CompactVendorNS
local ItemQualityColorToHexColor = ns.ItemQualityColorToHexColor

---@alias CompactVendorFilterDropDownQualityOptionValue number

---@class CompactVendorFilterDropDownQualityOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownQualityOptionValue

---@type CompactVendorFilterDropDownQualityOption[]
local options = {}
for i = 0, #ItemQualityColorToHexColor do
    local color = ItemQualityColorToHexColor[i]
    options[i + 1] = {
        value = i,
        text = color.name,
        colorCode = format("|c%s", color.hex),
    }
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Quality", {},
    "quality", options,
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownQualityOptionValue, boolean?>
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type CompactVendorFilterDropDownQualityOptionValue
            values[value] = true
        end
    end
)

filter:Publish()
