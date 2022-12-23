local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@type { value: ItemRequirementType, text: string }[]
local options = {
    { value = 1, text = "Profession" },
    { value = 2, text = "Level" },
    { value = 3, text = "Rating" },
    { value = 4, text = "Achievement" },
    { value = 5, text = "Guild" },
    { value = 6, text = "Reputation" },
    { value = 7, text = "Specialization" },
    { value = 8, text = "Renown" },
}

local filter = CompactVendorFilterDropDownTemplate:New(
    "Requirements", {},
    "canLearnRequirement", options,
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type ItemRequirement?
            if value then
                values[value.type] = true
            end
        end
    end
)

filter:Publish()
