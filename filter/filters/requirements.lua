-- TODO: revamp this similar to the stats filter as we need to build the options based on what exists (for example professions have data about which profession, if we satisfy it or not, and we wish to build the dropdown using this information)

local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias CompactVendorFilterDropDownRequirementOptionValue ItemRequirementType

---@class CompactVendorFilterDropDownRequirementOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownRequirementOptionValue

---@type CompactVendorFilterDropDownRequirementOption[]
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

---@param requirement ItemRequirement
local function filterRedRequirement(requirement)
    return requirement.isRed
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Requirements", {},
    "canLearnRequirement", options,
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownRequirementOptionValue, boolean?>
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type ItemRequirement[]?
            if value then
                for _, requirement in pairs(value) do
                    if requirement.isRed then
                        values[requirement.type] = true
                    end
                end
            end
        end
    end,
    ---@param value? ItemRequirement[]
    function(_, value, itemData)
        if not value then
            return
        end
        local itemValue = itemData:GetLearnRequirements(filterRedRequirement)
        if not itemValue then
            return
        end
        return itemValue
    end,
    ---@param value? CompactVendorFilterDropDownRequirementOptionValue
    ---@param itemValue? ItemRequirement[]
    function(_, value, itemValue)
        if not value or not itemValue then
            return
        end
        for _, requirement in pairs(itemValue) do
            if requirement.type == value then
                return requirement.isRed == true
            end
        end
        return false
    end,
    true
)

filter:Publish()
