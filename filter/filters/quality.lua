local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

local ns = select(2, ...) ---@class CompactVendorNS
local ItemQualityColorToHexColor = ns.ItemQualityColorToHexColor

local options = {}
for i = 0, #ItemQualityColorToHexColor do
    local color = ItemQualityColorToHexColor[i]
    options[i + 1] = {
        index = i,
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
        local values = self.values
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type number
            values[value] = true
        end
    end
)

filter:Publish()
