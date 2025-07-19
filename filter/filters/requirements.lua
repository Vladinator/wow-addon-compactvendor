local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias CompactVendorFilterDropDownRequirementOptionValue false|ItemRequirement

---@class CompactVendorFilterDropDownRequirementOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownRequirementOptionValue

local Format = {
    ProfessionP = "Profession: %s (%s)",
    Profession = "Profession: %s",
    Level = "Level: %s",
    Rating = "Rating: %s",
    Achievement = "Achievement: %s",
    GuildP = "Guild: %s (%s)",
    Guild = "Guild: %s",
    ReputationP = "Reputation: %s (%s)",
    Specialization = "Specialization: %s",
    RenownP = "Renown: %s (%s)",
    Renown = "Renown: %s",
}

local IconSize = 14

local Icon = {
    Check = CreateAtlasMarkup("common-icon-checkmark", IconSize, IconSize),
    RedX = CreateAtlasMarkup("common-icon-redx", IconSize, IconSize),
}

---@param requirement ItemRequirement
---@param noIcon? boolean
local function getRequirementText(requirement, noIcon)
    local text ---@type string?
    if requirement.type == 1 then
        text = format(requirement.amount and Format.ProfessionP or Format.Profession, requirement.requires, requirement.amount)
    elseif requirement.type == 2 then
        text = format(Format.Level, requirement.level)
    elseif requirement.type == 3 then
        text = format(Format.Rating, requirement.rating)
    elseif requirement.type == 4 then
        text = format(Format.Achievement, requirement.achievement)
    elseif requirement.type == 5 then
        text = format(requirement.level and Format.GuildP or Format.Guild, requirement.guild, requirement.level)
    elseif requirement.type == 6 then
        text = format(Format.ReputationP, requirement.reputation, requirement.rank)
    elseif requirement.type == 7 then
        text = format(Format.Specialization, requirement.specialization)
    elseif requirement.type == 8 then
        text = format(requirement.rank and Format.RenownP or Format.Renown, requirement.renown, requirement.rank)
    end
    if not text then
        text = requirement.raw
    end
    if noIcon then
        return text
    end
    if requirement.isRed then
        text = format("%s %s", Icon.RedX, text)
    else
        text = format("%s %s", Icon.Check, text)
    end
    return text
end

---@type table<ItemRequirement, string?>
local textCache = {}

---@param requirement ItemRequirement
local function getRequirementTextCached(requirement)
    local text = textCache[requirement]
    if text then
        return text
    end
    text = getRequirementText(requirement)
    textCache[requirement] = text
    return text
end

---@type CompactVendorFilterDropDownRequirementOption
local noRequirementOption = {
    value = false,
    text = "",
}

---@type CompactVendorFilterDropDownRequirementOptionValue[]
local noRequirementValueTable = {
    false,
}

local filter = CompactVendorFilterDropDownTemplate:New(
    "Requirements", {},
    "canLearnRequirement", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownRequirementOptionValue, boolean?>
        local options = self.options ---@type CompactVendorFilterDropDownRequirementOption[]
        table.wipe(values)
        table.wipe(textCache)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type ItemRequirement[]?
            if value then
                for _, requirement in pairs(value) do
                    values[requirement] = true
                end
            else
                values[false] = true
            end
        end
        for _, option in ipairs(options) do
            option.show = false
        end
        for value, _ in pairs(values) do
            local text ---@type string?
            if value == false then
                text = noRequirementOption.text
            else
                text = getRequirementTextCached(value)
            end
            ---@type CompactVendorFilterDropDownRequirementOption?
            local option = self:GetOption(text) ---@diagnostic disable-line: assign-type-mismatch
            if not option then
                option = { value = nil, text = nil } ---@diagnostic disable-line: assign-type-mismatch
                options[#options + 1] = option
            end
            option.value = value
            option.text = text
            option.show = true
            if option.checked == nil then
                option.checked = true
            end
        end
    end,
    ---@param value? CompactVendorFilterDropDownRequirementOptionValue[]
    function(_, value)
        return value or false
    end,
    ---@param value? CompactVendorFilterDropDownRequirementOptionValue
    ---@param itemValue? CompactVendorFilterDropDownRequirementOptionValue[]
    function(_, value, itemValue)
        local valueText ---@type string?
        if not value then
            valueText = noRequirementOption.text
        else
            valueText = getRequirementTextCached(value)
        end
        if not itemValue then
            itemValue = noRequirementValueTable
        end
        for _, requirement in pairs(itemValue) do
            local text ---@type string?
            if not requirement then
                text = noRequirementOption.text
            else
                text = getRequirementTextCached(requirement)
            end
            if valueText == text then
                return true
            end
        end
        return false
    end
)

filter:Publish()
