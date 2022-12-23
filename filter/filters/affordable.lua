local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Affordable",
    function(self, itemLink, itemData)
        if not itemData.price or itemData.price <= 0 then
            return
        end
        local money = GetMoney() - itemData.price
        return money >= 0
    end,
    function(self, value)
        return value and YES or NO
    end,
    true
)

filter:Publish()
