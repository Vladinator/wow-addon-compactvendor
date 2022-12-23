local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

local options = {}
for i = 0, 8 do
    local _, _, _, hex = GetItemQualityColor(i)
    options[i + 1] = {
        index = i,
        value = i,
        text = _G[format("ITEM_QUALITY%d_DESC", i)],
        colorCode = format("|c%s", hex),
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
