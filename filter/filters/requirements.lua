local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias CompactVendorFilterDropDownRequirementOptionValue false|string

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

---@param requirementInfo ItemRequirementInfo
---@param noIcon? boolean
local function getRequirementInfoText(requirementInfo, noIcon)
    local typeInfo = requirementInfo.type
    local text ---@type string?
    if typeInfo == 1 then
        text = format(requirementInfo.amount and Format.ProfessionP or Format.Profession, requirementInfo.requires, requirementInfo.amount)
    elseif typeInfo == 2 then
        text = format(Format.Level, requirementInfo.level)
    elseif typeInfo == 3 then
        text = format(Format.Rating, requirementInfo.rating)
    elseif typeInfo == 4 then
        text = format(Format.Achievement, requirementInfo.achievement)
    elseif typeInfo == 5 then
        text = format(requirementInfo.level and Format.GuildP or Format.Guild, requirementInfo.guild, requirementInfo.level)
    elseif typeInfo == 6 then
        text = format(Format.ReputationP, requirementInfo.reputation, requirementInfo.rank)
    elseif typeInfo == 7 then
        text = format(Format.Specialization, requirementInfo.specialization)
    elseif typeInfo == 8 then
        text = format(requirementInfo.rank and Format.RenownP or Format.Renown, requirementInfo.renown, requirementInfo.rank)
    end
    if not text then
        text = requirementInfo.raw
    end
    if noIcon then
        return text
    end
    if requirementInfo.isRed then
        text = format("%s %s", Icon.RedX, text)
    else
        text = format("%s %s", Icon.Check, text)
    end
    return text
end

---@type table<ItemRequirementInfo, string?>
local textCache = {}

---@param requirementInfo ItemRequirementInfo
local function getRequirementInfoTextCached(requirementInfo)
    local text = textCache[requirementInfo]
    if text then
        return text
    end
    text = getRequirementInfoText(requirementInfo)
    textCache[requirementInfo] = text
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

---@param value? false|string|ItemRequirementInfo
local function getText(value)
    if not value then
        return noRequirementOption.text
    end
    if type(value) == "string" then
        return value
    end
    return getRequirementInfoTextCached(value)
end

---@param options CompactVendorFilterDropDownRequirementOption[]
---@param requirementsInfo? CompactVendorFilterDropDownRequirementOptionValue[]
---@return table<string, boolean?> itemValue
local function FilterItemValue(options, requirementsInfo)
    if not requirementsInfo then
        requirementsInfo = noRequirementValueTable ---@type CompactVendorFilterDropDownRequirementOptionValue[]
    end
    local temp = {} ---@type table<string, boolean?>
    for _, option in ipairs(options) do
        if option.show and not option.checked then
            local key = option.text
            local found = false
            for _, requirementInfo in ipairs(requirementsInfo) do
                local text = getText(requirementInfo)
                if key == text then
                    found = true
                    break
                end
            end
            temp[key] = found
        end
    end
    return temp
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Requirements", {},
    "hasRequirementsInfo", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownRequirementOptionValue, boolean?>
        table.wipe(values)
        table.wipe(textCache)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type ItemRequirementInfo[]?
            if value then
                for _, requirementInfo in pairs(value) do
                    local text = getText(requirementInfo)
                    values[text] = true
                end
            else
                values[false] = true
            end
        end
        for value, _ in pairs(values) do
            ---@type CompactVendorFilterDropDownRequirementOption
            local option = self:GetOption(value, true) ---@diagnostic disable-line: assign-type-mismatch
            option.value = value
            option.text = getText(value)
            option.show = true
        end
    end,
    ---@param requirementsInfo? CompactVendorFilterDropDownRequirementOptionValue[]
    function(self, requirementsInfo)
        return FilterItemValue(self.options, requirementsInfo)
    end,
    ---@param value CompactVendorFilterDropDownRequirementOptionValue
    ---@param itemValue table<string, boolean?>
    function(_, value, itemValue)
        local valueText = getText(value)
        local reqValue = itemValue[valueText]
        return reqValue or reqValue == nil
    end,
    true
)

filter:Publish()
