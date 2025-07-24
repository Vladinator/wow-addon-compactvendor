local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

local ns = select(2, ...) ---@class CompactVendorNS
local ItemRequirementType = ns.ItemRequirementType

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
    RenownExtraP = "Renown: %s (%s) and %s",
    RenownExtra = "Renown: %s and %s",
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
    if typeInfo == ItemRequirementType.Profession then
        text = format(requirementInfo.amount and Format.ProfessionP or Format.Profession, requirementInfo.requires, requirementInfo.amount)
    elseif typeInfo == ItemRequirementType.Level then
        text = format(Format.Level, requirementInfo.level)
    elseif typeInfo == ItemRequirementType.Rating then
        text = format(Format.Rating, requirementInfo.rating)
    elseif typeInfo == ItemRequirementType.Achievement then
        text = format(Format.Achievement, requirementInfo.achievement)
    elseif typeInfo == ItemRequirementType.Guild then
        text = format(requirementInfo.level and Format.GuildP or Format.Guild, requirementInfo.guild, requirementInfo.level)
    elseif typeInfo == ItemRequirementType.Reputation then
        text = format(Format.ReputationP, requirementInfo.reputation, requirementInfo.rank)
    elseif typeInfo == ItemRequirementType.Specialization then
        text = format(Format.Specialization, requirementInfo.specialization)
    elseif typeInfo == ItemRequirementType.Renown then
        text = format(requirementInfo.rank and Format.RenownP or Format.Renown, requirementInfo.renown, requirementInfo.rank)
    elseif typeInfo == ItemRequirementType.RenownAndExtra then
        text = requirementInfo.requires and format(Format.RenownExtraP, requirementInfo.renown, requirementInfo.rank, requirementInfo.requires) or format(Format.RenownExtra, requirementInfo.renown, requirementInfo.requires)
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
---@return table<string, number?>?
local function FilterItemValue(options, requirementsInfo)
    if not requirementsInfo then
        requirementsInfo = noRequirementValueTable
    end
    local count = 0
    local temp ---@type table<string, number?>?
    for _, requirementInfo in ipairs(requirementsInfo) do
        local text = getText(requirementInfo)
        for _, option in ipairs(options) do
            if option.show and not option.checked and option.text == text then
                if not temp then
                    temp = {}
                end
                if temp[text] == nil then
                    count = count + 1
                    temp[text] = 0
                end
                temp[text] = temp[text] + 1
            end
        end
    end
    if temp and count ~= #requirementsInfo then
        return
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
    ---@param itemValue table<string, number?>?
    function(_, value, itemValue)
        if not itemValue then
            return
        end
        local valueText = getText(value)
        local reqValue = itemValue[valueText]
        return not reqValue or reqValue ~= 0
    end,
    true
)

filter:Publish()
