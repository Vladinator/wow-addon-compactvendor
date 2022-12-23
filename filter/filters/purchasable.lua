local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate

local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
    "Purchasable",
    function(self, itemLink, itemData)
        return itemData.canAfford
    end,
    function(self, value)
        return value and YES or NO
    end,
    true
)

filter:Publish()
