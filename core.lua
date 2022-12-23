local CreateDataProvider = CreateDataProvider ---@type fun()
local CreateScrollBoxListLinearView = CreateScrollBoxListLinearView ---@type fun(top?: number, bottom?: number, left?: number, right?: number, spacing?: number)
local BagSearch_OnChar = BagSearch_OnChar ---@type fun(self: EditBox)
local BagSearch_OnTextChanged = BagSearch_OnTextChanged ---@type fun(self: EditBox)
local SearchBoxTemplate_OnLoad = SearchBoxTemplate_OnLoad ---@type fun(self: EditBox)
local SearchBoxTemplate_OnTextChanged = SearchBoxTemplate_OnTextChanged ---@type fun(self: EditBox)
local GetBindingFromClick = GetBindingFromClick ---@type fun(key: string): string
local HandleModifiedItemClick = HandleModifiedItemClick ---@type fun(itemLink: string): boolean
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem ---@type fun()
local ShowInspectCursor = ShowInspectCursor ---@type fun()
local DressUpItemLink = DressUpItemLink ---@type fun(itemLink: string): boolean
local DressUpBattlePetLink = DressUpBattlePetLink ---@type fun(itemLink: string): boolean
local DressUpMountLink = DressUpMountLink ---@type fun(itemLink: string): boolean
local MerchantFrame_ConfirmExtendedItemCost = MerchantFrame_ConfirmExtendedItemCost ---@type fun(self: Region, quantity: number)
local StaticPopup_Visible = StaticPopup_Visible ---@type fun(name: string): any, any
local CreateObjectPool = CreateObjectPool ---@type ObjectPoolFunction
local CreateFramePool = CreateFramePool ---@type FramePoolFunction
local CallbackRegistryMixin = CallbackRegistryMixin ---@type CallbackRegistry
local FrameUtil = FrameUtil ---@type table<any, any>
local MathUtil = MathUtil ---@type table<any, any>
local ScrollUtil = ScrollUtil ---@type table<any, any>
local TooltipUtil = TooltipUtil ---@type table<any, any>
local MerchantBuyBackItem = MerchantBuyBackItem ---@type Button
local MerchantFrameInset = MerchantFrameInset ---@type Region
local MerchantItem11 = MerchantItem11 ---@type Button
local MerchantNextPageButton = MerchantNextPageButton ---@type Button
local MerchantPageText = MerchantPageText ---@type FontString
local MerchantPrevPageButton = MerchantPrevPageButton ---@type Button

---@class ItemSearch-1.3
---@field private Unusable table<number, boolean?>
---@field private Bangs table<number, boolean?>
---@field public Matches fun(self: ItemSearch-1.3, item: table|string|number, search: string): boolean?
---@field public IsUnusable fun(self: ItemSearch-1.3, id: number): isUnusable: boolean
---@field public IsQuestItem fun(self: ItemSearch-1.3, id: number): isQuestItem: boolean, isBang: boolean?
local LibItemSearch = LibStub("ItemSearch-1.3", true)

local addonName, ---@type string CompactVendor
    ns = ... ---@class CompactVendorNS

local CompactVendorDBDefaults
local ListItemScaleToFontObject
local GetListItemScaleFontObject do

    CompactVendorDBDefaults = {
        ListItemScale = 12,
    }

    local ListItemScaleFallbackFontObject = "CompactVendorFrameFont1"
    local ListItemScaleFallbackFontSize = 12

    -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/SharedXML/SharedFonts.xml
    ListItemScaleToFontObject = {
        { 8, "SystemFont_Tiny2" },
        { 9, "SystemFont_Tiny" },
        { 10, "SystemFont_Small" },
        { 11, "SystemFont_Small2" },
        { 12, "SystemFont_Med1" },
        { 13, "SystemFont_Med2" },
        { 14, "SystemFont_Med3" },
        { 15, "System15Font" },
        { 16, "SystemFont_Large" },
        { 17, "Game17Font_Shadow" },
        { 18, "SystemFont_Shadow_Large2" },
        { 20, "SystemFont_Shadow_Huge1" },
        { 22, "SystemFont22_Outline" },
        { 24, "SystemFont_Huge2" },
        { 25, "SystemFont_Shadow_Huge3" },
        { 27, "SystemFont_Huge4" },
        { 30, "Game30Font" },
        { 32, "Game32Font_Shadow2" },
        { 36, "SystemFont_WTF2" },
        { 40, "Game40Font_Shadow2" },
        { 46, "Game46Font_Shadow2" },
        { 52, "Game52Font_Shadow2" },
        { 58, "Game58Font_Shadow2" },
        { 64, "SystemFont_World" },
        { 69, "Game69Font_Shadow2" },
        { 72, "Game72Font" },
    }

    ListItemScaleToFontObject.minSize = 8
    ListItemScaleToFontObject.maxSize = 72

    ---@return string fontObject, number fontSize, boolean isExactSize, number defaultFontSize
    function GetListItemScaleFontObject()
        local listItemScale = CompactVendorDB.ListItemScale
        listItemScale = floor(listItemScale + 0.5)
        if listItemScale < ListItemScaleToFontObject.minSize then
            return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, false, ListItemScaleFallbackFontSize
        elseif listItemScale == ListItemScaleFallbackFontSize then
            return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, true, ListItemScaleFallbackFontSize
        end
        for _, font in ipairs(ListItemScaleToFontObject) do
            local size, fontObject = font[1], font[2]
            if size == listItemScale then
                return fontObject, size, true, ListItemScaleFallbackFontSize
            elseif size > listItemScale then
                return fontObject, size, false, ListItemScaleFallbackFontSize
            end
        end
        return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, false, ListItemScaleFallbackFontSize
    end

end

local ItemQualityColorToHexColor
local ItemHexColorToQualityIndex
local ColorPreset
local BackgroundColorPreset
local GetColorFromQuality
local GetQualityFromLink
local GetItemIDFromLink
local GetInfoFromGUID
local GetMoneyString
local ConvertToPattern do

    ---@class SimpleColor
    ---@field public r number
    ---@field public g number
    ---@field public b number
    ---@field public hex string

    ItemQualityColorToHexColor = {} ---@type table<number, SimpleColor>
    ItemHexColorToQualityIndex = {} ---@type table<string, number>
    ColorPreset = {} ---@type table<string|number, string|SimpleColor>

    for i = 0, 8 do

        local r, g, b, hex = GetItemQualityColor(i)

        ---@type SimpleColor
        local color = {
            r = r,
            g = g,
            b = b,
            hex = hex,
        }

        ItemQualityColorToHexColor[i] = color
        ItemHexColorToQualityIndex[hex] = i
        ColorPreset[i] = color
        ColorPreset[hex] = color

    end

    ItemHexColorToQualityIndex.None = ItemHexColorToQualityIndex[0]
    ColorPreset.None = ColorPreset[0]
    ColorPreset.Gray = ColorPreset[0]
    ColorPreset.White = ColorPreset[1]
    ColorPreset.Green = ColorPreset[2]
    ColorPreset.Blue = ColorPreset[3]
    ColorPreset.Purple = ColorPreset[4]
    ColorPreset.Legendary = ColorPreset[5]
    ColorPreset.Artifact = ColorPreset[6]
    ColorPreset.Heirloom = ColorPreset[7]

    BackgroundColorPreset = {}

    do
        BackgroundColorPreset.None   = { 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }
        BackgroundColorPreset.Red    = { 1.00, 0.00, 0.00, 0.75, 1.00, 0.00, 0.00, 0.00 }
        BackgroundColorPreset.Orange = { 1.00, 0.40, 0.00, 0.75, 1.00, 0.40, 0.00, 0.00 }
        BackgroundColorPreset.Yellow = { 1.00, 1.00, 0.00, 0.75, 1.00, 1.00, 0.00, 0.00 }
        BackgroundColorPreset.Gray      = { 0.62, 0.62, 0.62, 0.75, 0.62, 0.62, 0.62, 0.00 }
        BackgroundColorPreset.White     = { 1.00, 1.00, 1.00, 0.75, 1.00, 1.00, 1.00, 0.00 }
        BackgroundColorPreset.Green     = { 0.00, 1.00, 0.00, 0.75, 0.00, 1.00, 0.00, 0.00 }
        BackgroundColorPreset.Blue      = { 0.50, 0.50, 1.00, 1.00, 0.50, 0.50, 1.00, 0.00 }
        BackgroundColorPreset.Purple    = { 1.00, 0.00, 1.00, 0.75, 1.00, 0.00, 1.00, 0.00 }
        BackgroundColorPreset.Legendary = { 1.00, 0.50, 0.00, 0.75, 1.00, 0.50, 0.00, 0.00 }
        BackgroundColorPreset.Artifact  = { 0.90, 0.80, 0.50, 0.75, 0.90, 0.80, 0.50, 0.00 }
        BackgroundColorPreset.Heirloom  = { 1.00, 0.75, 0.50, 0.75, 1.00, 0.75, 0.50, 0.00 }
        BackgroundColorPreset[0] = BackgroundColorPreset.Gray
        BackgroundColorPreset[1] = BackgroundColorPreset.White
        BackgroundColorPreset[2] = BackgroundColorPreset.Green
        BackgroundColorPreset[3] = BackgroundColorPreset.Blue
        BackgroundColorPreset[4] = BackgroundColorPreset.Purple
        BackgroundColorPreset[5] = BackgroundColorPreset.Legendary
        BackgroundColorPreset[6] = BackgroundColorPreset.Artifact
        BackgroundColorPreset[7] = BackgroundColorPreset.Heirloom
    end

    ---@param quality? number
    ---@return SimpleColor? color
    function GetColorFromQuality(quality)
        if not quality then
            return
        end
        return ItemQualityColorToHexColor[quality]
    end

    ---@param itemLink string
    ---@return number? quality
    function GetQualityFromLink(itemLink)
        local hex = itemLink:match("|c([%x]+)|")
        return hex and ItemHexColorToQualityIndex[hex]
    end

    ---@param itemLink string
    ---@return number? itemID
    function GetItemIDFromLink(itemLink)
        local id = itemLink:match(":(%d+)")
        return id and tonumber(id)
    end

    ---@param guid? string
    ---@return string? npcType, number? npcID
    function GetInfoFromGUID(guid)
        if type(guid) ~= "string" then
            return
        end
        local npcType, _, _, _, _, npcID = strsplit("-", guid)
        return npcType, tonumber(npcID)
    end

    local MoneyFormat = {
        GOLD_TS = "%s" .. GOLD_AMOUNT_SYMBOL,
        GOLD = "%d" .. GOLD_AMOUNT_SYMBOL,
        SILVER = "%d" .. SILVER_AMOUNT_SYMBOL,
        COPPER = "%d" .. COPPER_AMOUNT_SYMBOL,
        S = "%s",
        D = "%d",
        GOLD_TS_T = GOLD_AMOUNT_TEXTURE_STRING,
        GOLD_T = GOLD_AMOUNT_TEXTURE,
        SILVER_T = SILVER_AMOUNT_TEXTURE,
        COPPER_T = COPPER_AMOUNT_TEXTURE,
    }

    ---@param money number
    ---@param separateThousands? boolean
    ---@param noIcons? boolean
    ---@param colorText? boolean
    ---@param noDenominator? boolean
    function GetMoneyString(money, separateThousands, noIcons, colorText, noDenominator)
        local goldInt = COPPER_PER_SILVER * SILVER_PER_GOLD
        local gold = floor(money / goldInt)
        local silver = floor((money - (gold * goldInt)) / COPPER_PER_SILVER)
        local copper = mod(money, COPPER_PER_SILVER)
        local goldFormat, silverFormat, copperFormat
        local colorBlind = ENABLE_COLORBLIND_MODE == "1"
        if noIcons or colorBlind then
            if not noDenominator or colorBlind then
                goldFormat, silverFormat, copperFormat = separateThousands and MoneyFormat.GOLD_TS or MoneyFormat.GOLD, MoneyFormat.SILVER, MoneyFormat.COPPER
            else
                goldFormat, silverFormat, copperFormat = separateThousands and MoneyFormat.S or MoneyFormat.D, MoneyFormat.D, MoneyFormat.D
            end
        else
            goldFormat, silverFormat, copperFormat = separateThousands and MoneyFormat.GOLD_TS_T or MoneyFormat.GOLD_T, MoneyFormat.SILVER_T, MoneyFormat.COPPER_T
        end
        local goldString
        if separateThousands then
            goldString = goldFormat:format(FormatLargeNumber(gold), 0, 0)
        else
            goldString = goldFormat:format(gold, 0, 0)
        end
        local silverString = silverFormat:format(silver, 0, 0)
        local copperString = copperFormat:format(copper, 0, 0)
        if colorText then
            if goldString then
                goldString = format("|cffffd700%s|r", goldString)
            end
            if silverString then
                silverString = format("|cffc7c7cf%s|r", silverString)
            end
            if copperString then
                copperString = format("|cffeda55f%s|r", copperString)
            end
        end
        local moneyString = ""
        local separator = ""
        if gold > 0 then
            moneyString = goldString
            separator = " "
        end
        if silver > 0 then
            moneyString = format("%s%s%s", moneyString, separator, silverString)
            separator = " "
        end
        if copper > 0 or moneyString == "" then
            moneyString = format("%s%s%s", moneyString, separator, copperString)
        end
        return moneyString
    end

    ---@param pattern string
    function ConvertToPattern(pattern)
        for i = 1, 20 do
            pattern = pattern:gsub("%%" .. i .. "$s", "%%s")
            pattern = pattern:gsub("%%" .. i .. "$d", "%%d")
            pattern = pattern:gsub("%%" .. i .. "$f", "%%f")
        end
        pattern = pattern:gsub("%%", "%%%%")
        pattern = pattern:gsub("%.", "%%%.")
        pattern = pattern:gsub("%?", "%%%?")
        pattern = pattern:gsub("%+", "%%%+")
        pattern = pattern:gsub("%-", "%%%-")
        pattern = pattern:gsub("%(", "%%%(")
        pattern = pattern:gsub("%)", "%%%)")
        pattern = pattern:gsub("%[", "%%%[")
        pattern = pattern:gsub("%]", "%%%]")
        pattern = pattern:gsub("%%%%s", "(.-)")
        pattern = pattern:gsub("%%%%d", "(%%d+)")
        pattern = pattern:gsub("%%%%%%[%d%.%,]+f", "([%%d%%.%%,]+)")
        return pattern
    end

end

local CreateTooltipItem
local IsTooltipTextPending do

    ---@class TooltipItem
    ---@field public tooltipData TooltipDataArgs
    ---@field public index? number
    ---@field public hyperlink? string
    ---@field public optionalArg1? number
    ---@field public optionalArg2? number
    ---@field public hideVendorPrice? boolean
    ---@field public lastCalled number

    ---@class TooltipSimpleColor
    ---@field public r number
    ---@field public g number
    ---@field public b number

    ---@class TooltipDataArgs : TooltipData
    ---@field public lines TooltipItemLine[]
    ---@field public type TooltipDataArgsType
    ---@field public hyperlink? string
    ---@field public id? number
    ---@field public guid? string
    ---@field public healthGUID? string

    ---@class TooltipDataLineArgs : TooltipDataLine
    ---@field public type TooltipDataLineArgsType
    ---@field public leftText string
    ---@field public leftColor TooltipSimpleColor
    ---@field public rightText? string
    ---@field public rightColor? TooltipSimpleColor
    ---@field public bonding? number
    ---@field public maxPrice? number
    ---@field public price? number
    ---@field public wrapText? boolean
    ---@field public tooltipID? number
    ---@field public tooltipType? TooltipDataArgsType

    ---@enum TooltipDataArgsType
    local TooltipDataArgsType = {
        Item = 0,
    }

    ---@enum TooltipDataLineArgsType
    local TooltipDataLineArgsType = {
        Text = 0,
        Padding = 1,
        Price = 11,
        Embed = 19,
        Bonding = 20,
    }

    ---@class TooltipItemLine : TooltipDataLineArgs
    local TooltipItemLine = {}

    function TooltipItemLine:GetType()
        return self.type
    end

    function TooltipItemLine:IsTypeText()
        return self:GetType() == TooltipDataLineArgsType.Text
    end

    function TooltipItemLine:IsTypePadding()
        return self:GetType() == TooltipDataLineArgsType.Padding
    end

    function TooltipItemLine:IsTypePrice()
        return self:GetType() == TooltipDataLineArgsType.Price
    end

    function TooltipItemLine:IsTypeEmbed()
        return self:GetType() == TooltipDataLineArgsType.Embed
    end

    function TooltipItemLine:IsTypeBonding()
        return self:GetType() == TooltipDataLineArgsType.Bonding
    end

    function TooltipItemLine:GetLeftText()
        return self.leftText
    end

    function TooltipItemLine:GetLeftColor()
        return self.leftColor
    end

    function TooltipItemLine:GetRightText()
        return self.rightText
    end

    function TooltipItemLine:GetRightColor()
        return self.rightColor
    end

    ---@return string leftText, string rightText
    function TooltipItemLine:GetText()
        return self:GetLeftText(), self:GetRightText()
    end

    ---@return TooltipSimpleColor leftColor, TooltipSimpleColor rightColor
    function TooltipItemLine:GetColor()
        return self:GetLeftColor(), self:GetRightColor()
    end

    ---@class TooltipItem
    local TooltipItem = {}

    ---@param tooltipData TooltipDataArgs
    ---@param hyperlinkOrIndex string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    function TooltipItem:OnLoad(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        for _, line in ipairs(tooltipData.lines) do
            Mixin(line, TooltipItemLine)
        end
        self.tooltipData = tooltipData
        if type(hyperlinkOrIndex) == "string" then
            self.hyperlink = hyperlinkOrIndex
            self.optionalArg1 = optionalArg1
            self.optionalArg2 = optionalArg2
            self.hideVendorPrice = hideVendorPrice
        else
            self.index = hyperlinkOrIndex
        end
        self.lastCalled = GetTime()
    end

    ---@return (string|number)? hyperlinkOrIndex, number? optionalArg1, number? optionalArg2, boolean? hideVendorPrice, number lastCalled
    function TooltipItem:GetCallArgs()
        return self.hyperlink or self.index, self.optionalArg1, self.optionalArg2, self.hideVendorPrice, self.lastCalled
    end

    function TooltipItem:GetTooltipData()
        return self.tooltipData
    end

    ---@return TooltipDataArgsType type
    function TooltipItem:GetType()
        return self.tooltipData.type
    end

    function TooltipItem:IsTypeItem()
        return self:GetType() == TooltipDataArgsType.Item
    end

    ---@return number|string|nil idOrGUID
    function TooltipItem:GetID()
        return self.tooltipData.id or self.tooltipData.guid or self.tooltipData.healthGUID
    end

    function TooltipItem:GetName()
        return self.tooltipData.lines[1].leftText
    end

    ---@param text any
    ---@return boolean isPending
    function IsTooltipTextPending(text)
        return not text or text == "" or text == " " or text == RETRIEVING_ITEM_INFO
    end

    function TooltipItem:IsPending()
        local name = self:GetName()
        return IsTooltipTextPending(name)
    end

    ---@enum ItemRequirementType
    local ItemRequirementType = {
        Profession = 1,
        Level = 2,
        Rating = 3,
        Achievement = 4,
        Guild = 5,
        Reputation = 6,
        Specialization = 7,
        Renown = 8,
    }

    ---@class ItemRequirement : table
    ---@field public raw string
    ---@field public type ItemRequirementType
    ---@field public requires? string
    ---@field public amount? number
    ---@field public level? number
    ---@field public rating? string
    ---@field public achievement? string
    ---@field public guild? string
    ---@field public reputation? string
    ---@field public rank? number
    ---@field public specialization? string
    ---@field public renown? string

    local ItemRequirementFieldCount = 2

    local ItemRequirements = {
        { "Requires Renown Rank %d with the %s by a character on this account.", ItemRequirementType.Renown, "rank", "renown" }, -- TODO: localization
        { ITEM_MIN_SKILL, ItemRequirementType.Profession, "requires", "amount" },
        { ITEM_REQ_SKILL, ItemRequirementType.Profession, "requires" },
        { ITEM_MIN_LEVEL, ItemRequirementType.Level, "level" },
        { ITEM_REQ_ARENA_RATING, ItemRequirementType.Rating, "rating" },
        { ITEM_REQ_PURCHASE_ACHIEVEMENT, ItemRequirementType.Achievement, "achievement" },
        { ITEM_REQ_PURCHASE_GUILD, ItemRequirementType.Guild, "guild" },
        { ITEM_REQ_PURCHASE_GUILD_LEVEL, ItemRequirementType.Guild, "guild", "level" },
        { ITEM_REQ_REPUTATION, ItemRequirementType.Reputation, "reputation", "rank" },
        { ITEM_REQ_SPECIALIZATION, ItemRequirementType.Specialization, "specialization" },
    }

    for _, requirement in ipairs(ItemRequirements) do
        requirement[1] = format("^%s$", ConvertToPattern(requirement[1]))
    end

    ---@param text string
    ---@return ItemRequirement? itemRequirement
    local function GetItemRequirement(text)
        for _, requirement in ipairs(ItemRequirements) do
            local pattern = requirement[1]
            local requirementType = requirement[2]
            local count = #requirement - ItemRequirementFieldCount
            local temp = {text:match(pattern)}
            if temp[count] then
                for i = 1, count do
                    local key = requirement[i + ItemRequirementFieldCount]
                    temp[key] = temp[i]
                end
                temp.raw = text
                temp.type = requirementType
                return temp
            end
        end
    end

    ---@param color TooltipSimpleColor
    local function ColorIsRed(color)
        local r, g, b = floor(color.r*255), floor(color.g*255), floor(color.b*255)
        return r > 250 and g < 40 and b < 40 -- 255 32 32
    end

    ---@return boolean? canLearn, ItemRequirement? itemRequirement
    function TooltipItem:CanLearn()
        for _, line in ipairs(self.tooltipData.lines) do
            if line:IsTypeText() then
                local text = line:GetLeftText()
                local itemRequirement = GetItemRequirement(text)
                if itemRequirement then
                    local color = line:GetLeftColor()
                    local canLearn = true
                    if color then
                        canLearn = not ColorIsRed(color)
                    end
                    return canLearn, itemRequirement
                end
            end
        end
    end

    ---@return boolean? isLearned
    function TooltipItem:IsLearned()
        for _, line in ipairs(self.tooltipData.lines) do
            if line:IsTypeText() then
                local text = line:GetLeftText()
                if text == ITEM_SPELL_KNOWN then
                    local color = line:GetLeftColor()
                    return ColorIsRed(color)
                end
            end
        end
    end

    local ITEM_PET_KNOWN_PATTERN = format("^%s$", ConvertToPattern(ITEM_PET_KNOWN))

    ---@param text string
    ---@return number? numCollected, number? numCollectable
    local function GetItemCollected(text)
        local numCollected, numCollectable = text:match(ITEM_PET_KNOWN_PATTERN)
        if not numCollected then
            return
        end
        return tonumber(numCollected), tonumber(numCollectable)
    end

    ---@return boolean? isCollected, number? numCollected, number? numCollectable
    function TooltipItem:IsCollected()
        for _, line in ipairs(self.tooltipData.lines) do
            if line:IsTypeText() then
                local text = line:GetLeftText()
                local numCollected, numCollectable = GetItemCollected(text)
                if numCollected then
                    local isCollected = numCollected == numCollectable
                    return isCollected, numCollected, numCollectable
                end
            end
        end
    end

    ---@param tooltipData TooltipDataArgs
    ---@param hyperlinkOrIndex string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    ---@return TooltipItem itemData
    function CreateTooltipItem(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        local itemData = {} ---@type TooltipItem
        Mixin(itemData, TooltipItem)
        itemData:OnLoad(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        return itemData
    end

end

---@class TooltipScanner
local TooltipScanner do

    ---@alias TooltipScannerEvent "OnScanStart"|"OnScanStop"|"OnItemReady"

    ---@class TooltipScanner : CallbackRegistry
    ---@field public Event table<TooltipScannerEvent, number>
    ---@field public collection TooltipItem[]
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: TooltipScannerEvent[])

    ---@class TooltipScanner : Frame
    TooltipScanner = CreateFrame("Frame") ---@diagnostic disable-line: cast-local-type

    Mixin(TooltipScanner, CallbackRegistryMixin)
    CallbackRegistryMixin.OnLoad(TooltipScanner)

    TooltipScanner:GenerateCallbackEvents({
        "OnScanStart",
        "OnScanStop",
        "OnItemReady",
    })

    TooltipScanner.TOOLTIP_DATA_UPDATE = "TOOLTIP_DATA_UPDATE"
    TooltipScanner.TOOLTIP_REFRESH_INTERVAL = 0.25

    TooltipScanner.collection = {}

    local throttleHandle

    local function throttleHandleClear()
        if not throttleHandle then
            return
        end
        throttleHandle:Cancel()
        throttleHandle = nil
    end

    ---@param rawData TooltipData
    ---@return boolean? isPending
    local function IsPending(rawData)
        local args = rawData.lines[1].args
        for _, arg in ipairs(args) do
            if arg.field == "leftText" then
                return IsTooltipTextPending(arg.stringVal)
            end
        end
    end

    ---@param itemData TooltipItem
    ---@return TooltipItem? itemData, boolean isPending, boolean? isPendingThrottled
    function TooltipScanner:Refresh(itemData)
        local hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice, lastCalled = itemData:GetCallArgs()
        local now = GetTime()
        if now - lastCalled < self.TOOLTIP_REFRESH_INTERVAL then
            return nil, true, true
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        local hyperlink = type(hyperlinkOrIndex) == "string" and hyperlinkOrIndex or nil ---@type string|nil
        local index = type(hyperlinkOrIndex) == "number" and hyperlinkOrIndex or nil ---@type number|nil
        local tooltipData
        if hyperlink then
            tooltipData = C_TooltipInfo.GetHyperlink(hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
        elseif index then
            tooltipData = C_TooltipInfo.GetMerchantItem(index)
        end
        if not tooltipData or IsPending(tooltipData) then
            return nil, true
        end
        local newItemData = self:ConvertToTooltipItem(tooltipData, hyperlinkOrIndex) ---@diagnostic disable-line: param-type-mismatch
        Mixin(itemData, newItemData)
        itemData.lastCalled = now
        return itemData, false
    end

    ---@param itemData TooltipItem
    function TooltipScanner:AddPending(itemData)
        local collection = self.collection
        local index = #collection + 1
        collection[index] = itemData
    end

    function TooltipScanner:UpdatePending()
        local isScanning = self:IsEventRegistered(self.TOOLTIP_DATA_UPDATE)
        local collection = self.collection
        local hasPendingThrottled = false
        for i = #collection, 1, -1 do
            local itemData = collection[i]
            local isPending = itemData:IsPending()
            local isPendingThrottled
            if isPending then
                itemData, isPending, isPendingThrottled = self:Refresh(itemData) ---@diagnostic disable-line: cast-local-type
                if isPendingThrottled then
                    hasPendingThrottled = true
                end
            end
            if not isPending then
                table.remove(collection, i)
                self:TriggerEvent(self.Event.OnItemReady, itemData)
            end
        end
        local isPending = #collection ~= 0
        if isPending then
            if not isScanning then
                self:TriggerEvent(self.Event.OnScanStart)
            end
            self:RegisterEvent(self.TOOLTIP_DATA_UPDATE)
        else
            if isScanning then
                self:TriggerEvent(self.Event.OnScanStop)
            end
            self:UnregisterEvent(self.TOOLTIP_DATA_UPDATE)
        end
        if not hasPendingThrottled then
            return
        end
        throttleHandleClear()
        throttleHandle = C_Timer.NewTicker(self.TOOLTIP_REFRESH_INTERVAL, function()
            throttleHandleClear()
            self:UpdatePending()
        end)
    end

    ---@param tooltipData TooltipData
    ---@param hyperlinkOrIndex string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    ---@return TooltipItem itemData
    function TooltipScanner:ConvertToTooltipItem(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        TooltipUtil.SurfaceArgs(tooltipData)
        for _, line in ipairs(tooltipData.lines) do
            TooltipUtil.SurfaceArgs(line)
        end
        ---@type TooltipDataArgs
        local tooltipDataArgs = tooltipData ---@diagnostic disable-line: assign-type-mismatch
        return CreateTooltipItem(tooltipDataArgs, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
    end

    ---@param raw string|number
    ---@return string
    function TooltipScanner:SanitizeHyperlink(raw)
        if type(raw) == "string" then
            local id = raw:match("item:(%d+)")
            raw = id and tonumber(id) or raw
        end
        if type(raw) == "number" then
            return format("|cffffffff|Hitem:%d::::::::::::::::::|h[]|h|r", raw)
        end
        return raw
    end

    ---@param hyperlinkOrItemID string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    ---@return TooltipItem|boolean tooltipData, boolean isPending
    function TooltipScanner:ScanHyperlink(hyperlinkOrItemID, optionalArg1, optionalArg2, hideVendorPrice)
        local hyperlink = self:SanitizeHyperlink(hyperlinkOrItemID)
        if not hyperlink then
            return false, false
        end
        local itemID = GetItemInfoInstant(hyperlink)
        if not itemID then
            return false, false
        end
        local tooltipData = C_TooltipInfo.GetHyperlink(hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
        if not tooltipData then
            return false, false
        end
        local itemData = self:ConvertToTooltipItem(tooltipData, hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
        local isPending = itemData:IsPending()
        if isPending then
            self:AddPending(itemData)
            self:UpdatePending()
            return itemData, itemData:IsPending()
        end
        self:TriggerEvent(self.Event.OnItemReady, itemData)
        return itemData, isPending
    end

    ---@param index number
    ---@return TooltipItem|boolean tooltipData, boolean isPending
    function TooltipScanner:ScanMerchantItem(index)
        local tooltipData = C_TooltipInfo.GetMerchantItem(index)
        if not tooltipData then
            return false, false
        end
        local itemData = self:ConvertToTooltipItem(tooltipData, index)
        local isPending = itemData:IsPending()
        if isPending then
            self:AddPending(itemData)
            self:UpdatePending()
            return itemData, itemData:IsPending()
        end
        self:TriggerEvent(self.Event.OnItemReady, itemData)
        return itemData, isPending
    end

    function TooltipScanner:OnEvent(event, ...)
        if event == self.TOOLTIP_DATA_UPDATE then
            self:UpdatePending()
        end
    end

    TooltipScanner:SetScript("OnEvent", TooltipScanner.OnEvent)

end

---@class TooltipDataProvider
local TooltipDataProvider do

    ---@alias TooltipDataProviderEvent DataProviderEvent|TooltipScannerEvent|"OnItemReady"|"OnItemAdded"
    ---@alias TooltipDataProviderPredicate fun(itemData: TooltipItem): boolean?
    ---@alias TooltipDataProviderCallback fun(itemData: TooltipItem)
    ---@alias TooltipDataProviderCallbackKey string|number
    ---@alias TooltipDataProviderCallbackValue table<TooltipDataProviderCallback, boolean?>
    ---@alias TooltipDataProviderCallbackTable table<TooltipDataProviderCallbackKey, TooltipDataProviderCallbackValue>
    ---@alias TooltipDataProviderPendingTable table<TooltipDataProviderCallbackKey, boolean?>

    ---@class TooltipDataProvider : DataProvider
    ---@field public Event table<TooltipDataProviderEvent, number>
    ---@field public callbacks TooltipDataProviderCallbackTable
    ---@field public pending TooltipDataProviderPendingTable
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: TooltipDataProviderEvent[])
    ---@field public Init fun(self: DataProvider, tbl?: TooltipItem[])
    ---@field public InsertInternal fun(self: DataProvider, itemData: TooltipItem, hasSortComparator: boolean)
    ---@field public Insert fun(self: DataProvider, ...: TooltipItem)
    ---@field public InsertTable fun(self: DataProvider, tbl: TooltipItem[])
    ---@field public InsertTableRange fun(self: DataProvider, tbl: TooltipItem[], indexBegin: number, indexEnd: number)
    ---@field public Remove fun(self: DataProvider, ...: TooltipItem): removedIndex: number
    ---@field public Find fun(self: DataProvider, index: number): itemData: TooltipItem?
    ---@field public FindByPredicate fun(self: DataProvider, predicate: TooltipDataProviderPredicate): index: number?, itemData: TooltipItem?
    ---@field public FindElementDataByPredicate fun(self: DataProvider, predicate: TooltipDataProviderPredicate): itemData: TooltipItem?

    TooltipDataProvider = CreateDataProvider() ---@type TooltipDataProvider

    TooltipDataProvider:GenerateCallbackEvents({
        "OnScanStart",
        "OnScanStop",
        "OnItemReady",
        "OnItemAdded",
    })

    TooltipDataProvider.callbacks = {}
    TooltipDataProvider.pending = {}

    ---@param query TooltipDataProviderCallbackKey
    ---@param callback TooltipDataProviderCallback
    function TooltipDataProvider:RegisterCallback(query, callback)
        local callbacks = self.callbacks[query]
        if not callbacks then
            callbacks = {}
            self.callbacks[query] = callbacks
        end
        callbacks[callback] = true
    end

    ---@param itemData TooltipItem
    ---@param query? TooltipDataProviderCallbackKey
    local function TriggerCallback(itemData, query)
        if not query then
            return
        end
        local callbacks = TooltipDataProvider.callbacks[query]
        if not callbacks then
            return
        end
        for callback, _ in pairs(callbacks) do
            callback(itemData)
        end
        table.wipe(callbacks)
    end

    ---@param itemData TooltipItem
    function TooltipDataProvider:TriggerCallback(itemData)
        TriggerCallback(itemData, itemData.hyperlink or itemData.index)
    end

    ---@param hyperlinkOrIndex (string|number)?
    function TooltipDataProvider:IsPending(hyperlinkOrIndex)
        if not hyperlinkOrIndex then
            return
        end
        return self.pending[hyperlinkOrIndex] == true
    end

    ---@param hyperlinkOrIndex (string|number)?
    function TooltipDataProvider:SetPending(hyperlinkOrIndex)
        if not hyperlinkOrIndex then
            return
        end
        self.pending[hyperlinkOrIndex] = true
    end

    ---@param hyperlinkOrIndex (string|number)?
    function TooltipDataProvider:ClearPending(hyperlinkOrIndex)
        if not hyperlinkOrIndex then
            return
        end
        self.pending[hyperlinkOrIndex] = nil
    end

    ---@param query TooltipDataProviderCallbackKey?
    ---@return TooltipItem? itemData
    function TooltipDataProvider:GetHyperlinkOrIndex(query)
        if not query then
            return
        end
        local _, itemData = self:FindByPredicate(function(itemData)
            return itemData.hyperlink == query or itemData.index == query
        end)
        return itemData
    end

    ---@param query TooltipDataProviderCallbackKey
    ---@param callback? TooltipDataProviderCallback
    ---@param skipCallbackWhenInstant? boolean
    ---@return TooltipItem? itemData
    function TooltipDataProvider:ScanHyperlink(query, callback, skipCallbackWhenInstant)
        if type(callback) ~= "function" then
            callback = nil
        end
        local hyperlink = TooltipScanner:SanitizeHyperlink(query)
        local isPending = self:IsPending(hyperlink)
        if not isPending then
            local itemData = self:GetHyperlinkOrIndex(hyperlink)
            if itemData then
                if callback and not skipCallbackWhenInstant then
                    callback(itemData)
                end
                return itemData
            end
        end
        if callback then
            self:RegisterCallback(hyperlink, callback)
        end
        if isPending then
            return
        end
        self:SetPending(hyperlink)
        local tooltipData = TooltipScanner:ScanHyperlink(hyperlink)
        if tooltipData == false then
            self:ClearPending(hyperlink)
        end
    end

    ---@param index number
    ---@param callback? TooltipDataProviderCallback
    ---@param skipCallbackWhenInstant? boolean
    ---@return TooltipItem? itemData
    function TooltipDataProvider:ScanMerchantItem(index, callback, skipCallbackWhenInstant)
        if type(callback) ~= "function" then
            callback = nil
        end
        local isPending = self:IsPending(index)
        -- if not isPending then
        --     local itemData = self:GetHyperlinkOrIndex(index)
        --     if itemData then
        --         if callback and not skipCallbackWhenInstant then
        --             callback(itemData)
        --         end
        --         return itemData
        --     end
        -- end
        if callback then
            self:RegisterCallback(index, callback)
        end
        if isPending then
            return
        end
        self:SetPending(index)
        local tooltipData = TooltipScanner:ScanMerchantItem(index)
        if tooltipData == false then
            self:ClearPending(index)
        end
    end

    ---@param itemData TooltipItem
    local function OnItemReady(_, itemData)
        TooltipDataProvider:TriggerCallback(itemData)
        local hyperlinkOrIndex = itemData.hyperlink or itemData.index
        local oldItemData = TooltipDataProvider:GetHyperlinkOrIndex(hyperlinkOrIndex)
        TooltipDataProvider:ClearPending(hyperlinkOrIndex)
        if not oldItemData then
            TooltipDataProvider:Insert(itemData)
            TooltipDataProvider:TriggerEvent(TooltipDataProvider.Event.OnItemAdded, itemData)
        end
        TooltipDataProvider:TriggerEvent(TooltipDataProvider.Event.OnItemReady, oldItemData or itemData)
    end

    local function OnScanStart()
        TooltipDataProvider:TriggerEvent(TooltipDataProvider.Event.OnScanStart)
    end

    local function OnScanStop()
        TooltipDataProvider:TriggerEvent(TooltipDataProvider.Event.OnScanStop)
    end

    TooltipScanner:RegisterCallback(TooltipScanner.Event.OnItemReady, OnItemReady)
    TooltipScanner:RegisterCallback(TooltipScanner.Event.OnScanStart, OnScanStart)
    TooltipScanner:RegisterCallback(TooltipScanner.Event.OnScanStop, OnScanStop)

end

local CreateMerchantItem
local CreateMerchantItemButton
local UpdateMerchantItemButton do

    ---@enum MerchantItemCostType
    local MerchantItemCostType = {
        Gold = 1,
        Currency = 2,
        GoldAndCurrency = 3,
    }

    ---@enum MerchantItemAvailabilityType
    local MerchantItemAvailabilityType = {
        NotAvailable = 1,
        NotUsable = 2,
        NotAvailableNotUsable = 3,
        AvailableAndUsable = 4,
    }

    ---@param currencyID number
    ---@param numAvailable number
    ---@param name string
    ---@param texture number|string
    ---@param quality? number
    ---@return string name, number|string texture, number numItems, number? quality
    local function GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality)
        return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality) ---@diagnostic disable-line: undefined-global
    end

    ---@class MerchantItemCostItem
    ---@field public texture? number|string
    ---@field public count number
    ---@field public itemLink? string
    ---@field public name? string
    ---@field public quality? number
    ---@field public itemID? number

    ---@class MerchantItem
    ---@field public parent MerchantScanner
    ---@field public index number
    ---@field public name? string
    ---@field public texture number|string
    ---@field public price number
    ---@field public stackCount number
    ---@field public numAvailable number
    ---@field public isPurchasable boolean
    ---@field public isUsable boolean
    ---@field public extendedCost number
    ---@field public currencyID? number
    ---@field public spellID? number
    ---@field public canAfford boolean
    ---@field public costType MerchantItemCostType
    ---@field public itemLink? string
    ---@field public merchantItemID? number
    ---@field public itemLinkOrID? string|number
    ---@field public isHeirloom boolean
    ---@field public isKnownHeirloom boolean
    ---@field public showNonrefundablePrompt boolean
    ---@field public tintRed boolean
    ---@field public availabilityType MerchantItemAvailabilityType
    ---@field public extendedCostCount number
    ---@field public extendedCostItems MerchantItemCostItem[]
    ---@field public quality? number
    ---@field public itemID number
    ---@field public itemType string
    ---@field public itemSubType string
    ---@field public itemEquipLoc string
    ---@field public itemTexture number|string
    ---@field public itemClassID number
    ---@field public itemSubClassID number
    ---@field public maxStackCount? number
    ---@field public isLearnable? boolean
    ---@field public tooltipScannable? boolean
    ---@field public tooltipData? TooltipItem
    ---@field public canLearn? boolean
    ---@field public canLearnRequirement? ItemRequirement
    ---@field public isLearned? boolean
    ---@field public isCollected? boolean
    ---@field public isCollectedNum? number
    ---@field public isCollectedNumMax? number

    local MerchantItem = {} ---@class MerchantItem

    MerchantItem.ConfirmationRequirementForVendors = {
        [151950] = false, -- Mrrglrlr
        [151951] = false, -- Grrmrlg
        [151952] = false, -- Flrggrl
        [151953] = false, -- Hurlgrl
        [152084] = true, -- Mrrl
        [152593] = false, -- Murloco
    }

    ---@param parent MerchantScanner
    ---@param index number
    function MerchantItem:OnLoad(parent, index)
        self.parent = parent
        self.index = index
        self.extendedCostItems = {}
        self:Refresh()
    end

    ---@param tbl table
    local function ResetTableContents(tbl)
        for k, v in pairs(tbl) do
            if type(k) == "userdata" or type(v) == "function" then
            elseif type(v) ~= "table" then
                tbl[k] = nil
            end
        end
    end

    function MerchantItem:Reset()
        if self.extendedCostItems then
            for _, costItem in ipairs(self.extendedCostItems) do
                ResetTableContents(costItem)
            end
        end
        ResetTableContents(self)
        self.qualityColor = nil
        self.tooltipData = nil
        self.canLearnRequirement = nil
        self.extendedCostCount = 0
    end

    -- If dirty it means the index is not defined or the item has pending data.
    -- Performing a refresh call will force an update of the internal state.
    ---@param index number
    function MerchantItem:IsDirty(index)
        if self.index ~= index then
            self.index = index
            return true
        end
        if self:IsPending() then
            return true
        end
        if self.itemLink ~= GetMerchantItemLink(index) then
            return true
        end
        if self.merchantItemID ~= GetMerchantItemID(index) then
            return true
        end
        return false
    end

    -- If clean it means that the item has a valid index and has all its data loaded.
    function MerchantItem:IsClean()
        return self.index ~= 0 and not self:IsPending()
    end

    ---@return boolean isPending
    function MerchantItem:IsPending()
        if not self.name or not self.itemLink then
            return true
        end
        for i = 1, self.extendedCostCount do
            local costItem = self.extendedCostItems[i]
            if not costItem.name or not costItem.itemLink then
                return true
            end
        end
        if self.tooltipScannable and self.tooltipData == nil then
            return true
        end
        return false
    end

    function MerchantItem:Refresh()
        local index = self:GetIndex()
        self.name, self.texture, self.price, self.stackCount, self.numAvailable, self.isPurchasable, self.isUsable, self.extendedCost, self.currencyID, self.spellID = GetMerchantItemInfo(index) ---@diagnostic disable-line: assign-type-mismatch
        if self.currencyID then
            self.name, self.texture, self.numAvailable, self.quality = GetCurrencyContainerInfo(self.currencyID, self.numAvailable, self.name, self.texture, nil)
        end
        self.canAfford = CanAffordMerchantItem(index) ~= false
        if self.extendedCost and self.price <= 0 then
            self.costType = MerchantItemCostType.Currency
        elseif self.extendedCost and self.price > 0 then
            self.costType = MerchantItemCostType.GoldAndCurrency
        else
            self.costType = MerchantItemCostType.Gold
        end
        self.itemLink = GetMerchantItemLink(index)---@diagnostic disable-line: assign-type-mismatch
        self.merchantItemID = GetMerchantItemID(index)---@diagnostic disable-line: assign-type-mismatch
        self.itemLinkOrID = self.itemLink or self.merchantItemID
        self.isHeirloom = self.merchantItemID and C_Heirloom.IsItemHeirloom(self.merchantItemID)---@diagnostic disable-line: assign-type-mismatch
        self.isKnownHeirloom = self.isHeirloom and C_Heirloom.PlayerHasHeirloom(self.merchantItemID)---@diagnostic disable-line: assign-type-mismatch
        self.showNonrefundablePrompt = not C_MerchantFrame.IsMerchantItemRefundable(index)
        self.tintRed = not self.isPurchasable or (not self.isUsable and not self.isHeirloom)
        if self.numAvailable == 0 or self.isKnownHeirloom then
            if self.tintRed then
                self.availabilityType = MerchantItemAvailabilityType.NotAvailable
            else
                self.availabilityType = MerchantItemAvailabilityType.NotUsable
            end
        elseif self.tintRed then
            self.availabilityType = MerchantItemAvailabilityType.NotUsable
        else
            self.availabilityType = MerchantItemAvailabilityType.AvailableAndUsable
        end
        self.extendedCostCount = GetMerchantItemCostInfo(index)
        for i = 1, self.extendedCostCount do
            local costItem = self.extendedCostItems[i]
            if not costItem then
                costItem = {} ---@type MerchantItemCostItem
                self.extendedCostItems[i] = costItem
            end
            costItem.texture,
            costItem.count,
            costItem.itemLink,
            costItem.name = GetMerchantItemCostItem(index, i)
            if costItem.itemLink then
                if not costItem.name then
                    costItem.name = GetItemInfo(costItem.itemLink)
                end
                if not costItem.itemID then
                    costItem.itemID = GetItemIDFromLink(costItem.itemLink)
                end
                if not costItem.quality then
                    costItem.quality = GetQualityFromLink(costItem.itemLink)
                end
            end
        end
        if not self.quality and self.itemLink then
            self.quality = GetQualityFromLink(self.itemLink)
        end
        if self.quality then
            self.qualityColor = GetColorFromQuality(self.quality)
        end
        if not self.itemLinkOrID then
            return
        end
        self.itemID,
        self.itemType,
        self.itemSubType,
        self.itemEquipLoc,
        self.itemTexture,
        self.itemClassID,
        self.itemSubClassID = GetItemInfoInstant(self.itemLinkOrID)
        self.maxStackCount = select(8, GetItemInfo(self.itemLinkOrID))
        self.isLearnable = self:IsLearnable()
        self.tooltipScannable = self.isLearnable or true -- DEBUG: performance check by scanning all the items
        if not self.tooltipScannable then
            return
        end
        local tooltipData = self.tooltipData
        if tooltipData == true then
            return
        end
        local function ProcessTooltipData()
            if not tooltipData or tooltipData == true then
                return
            end
            if self.isLearnable then
                if self.canLearn == nil then
                    self.canLearn,
                    self.canLearnRequirement = tooltipData:CanLearn()
                end
                if self.isLearned == nil then
                    self.isLearned = tooltipData:IsLearned()
                end
                if self.isCollected == nil then
                    self.isCollected,
                    self.isCollectedNum,
                    self.isCollectedNumMax = tooltipData:IsCollected()
                end
            end
        end
        if tooltipData ~= nil then
            ProcessTooltipData()
            return
        end
        ---@param data TooltipItem
        local function HandleTooltipData(data)
            tooltipData = data
            self.tooltipData = data
            ProcessTooltipData()
        end
        tooltipData = TooltipDataProvider:ScanHyperlink(self.itemLinkOrID, HandleTooltipData, true)
        -- tooltipData = TooltipDataProvider:ScanMerchantItem(index, HandleTooltipData, true) -- TODO: WIP
        if tooltipData ~= nil then
            HandleTooltipData(tooltipData)
        end
    end

    ---@return number index
    function MerchantItem:GetIndex()
        return self.index
    end

    ---@param type MerchantItemCostType
    function MerchantItem:IsCost(type)
        return self.costType == type
    end

    function MerchantItem:IsCostGold()
        return self:IsCost(MerchantItemCostType.Gold)
    end

    function MerchantItem:IsCostCurrency()
        return self:IsCost(MerchantItemCostType.Currency)
    end

    function MerchantItem:IsCostGoldAndCurrency()
        return self:IsCost(MerchantItemCostType.GoldAndCurrency)
    end

    ---@param type MerchantItemAvailabilityType
    function MerchantItem:IsAvailability(type)
        return self.availabilityType == type
    end

    function MerchantItem:IsAvailabilityNotAvailable()
        return self:IsAvailability(MerchantItemAvailabilityType.NotAvailable)
    end

    function MerchantItem:IsAvailabilityNotUsable()
        return self:IsAvailability(MerchantItemAvailabilityType.NotUsable)
    end

    function MerchantItem:IsAvailabilityNotAvailableNotUsable()
        return self:IsAvailability(MerchantItemAvailabilityType.NotAvailableNotUsable)
    end

    function MerchantItem:IsAvailabilityAvailableAndUsable()
        return self:IsAvailability(MerchantItemAvailabilityType.AvailableAndUsable)
    end

    function MerchantItem:CanSpecifyQuantity()
        return self.canAfford
    end

    function MerchantItem:CanSkipConfirmation()
        local guid = self.parent:GetMerchantInfo()
        local npcType, npcID = GetInfoFromGUID(guid)
        if (npcType == "Creature" or npcType == "Vehicle" or npcType == "GameObject") and (npcID and self.ConfirmationRequirementForVendors[npcID]) then
            return false
        end
        if self.extendedCostCount ~= 0 or self:CanBeRefunded() then
            return self.price and self.price < MERCHANT_HIGH_PRICE_COST
        end
        return not self:HasRealExtendedCost()
    end

    function MerchantItem:CanBeRefunded()
        return not self.showNonrefundablePrompt
    end

    function MerchantItem:HasRealExtendedCost()
        if not self.extendedCost then
            return false
        end
        for i = 1, self.extendedCostCount do
            local costItem = self.extendedCostItems[i]
            if costItem.name then
                return true
            end
            if costItem.itemLink and costItem.quality < Enum.ItemQuality.Uncommon then
                return false
            end
        end
        return true
    end

    function MerchantItem:IsLearnable()
        local itemClassID = self.itemClassID
        if itemClassID == Enum.ItemClass.Recipe then
            return true
        elseif itemClassID == Enum.ItemClass.Glyph then
            return true
        elseif itemClassID == Enum.ItemClass.Miscellaneous then
            local itemSubClassID = self.itemSubClassID
            return itemSubClassID == Enum.ItemMiscellaneousSubclass.Mount
                or itemSubClassID == Enum.ItemMiscellaneousSubclass.CompanionPet
                or itemSubClassID == Enum.ItemMiscellaneousSubclass.Junk
                or itemSubClassID == Enum.ItemMiscellaneousSubclass.Other
        end
        return false
    end

    ---@param parent MerchantScanner
    ---@param index number
    ---@return MerchantItem itemData
    function CreateMerchantItem(parent, index)
        local itemData = Mixin({}, MerchantItem) ---@type MerchantItem
        itemData:OnLoad(parent, index)
        return itemData
    end

    ---@param merchantItem MerchantItem
    local function GetTextForItem(merchantItem)
        return format(
            "%s%s%s",
            merchantItem.numAvailable and merchantItem.numAvailable > -1 and format("|cffFFFF00[%d]|r ", merchantItem.numAvailable) or "",
            merchantItem.name or SEARCH_LOADING_TEXT,
            merchantItem.stackCount and merchantItem.stackCount > 1 and format(" |cffFFFF00x%d|r", merchantItem.stackCount) or ""
        )
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    ---@param merchantItem? MerchantItem
    function UpdateMerchantItemButton(button, merchantItem)
        button.merchantItem = merchantItem
        local index = merchantItem and merchantItem:GetIndex()
        if not merchantItem or not index then
            button:SetID(0)
            return
        end
        button:SetID(index)
        button.Icon:SetItem(merchantItem, true)
        local text = GetTextForItem(merchantItem)
        button.Name:SetText(text)
        button.Cost:Update()
        local backgroundColor = BackgroundColorPreset.None
        local textColor = merchantItem.qualityColor or ColorPreset.None
        local isPurchasable = not merchantItem.tintRed
        local isUsable = merchantItem.isUsable
        local canAfford = merchantItem.canAfford
        local canLearn = merchantItem.canLearn
        local canLearnRequirement = merchantItem.canLearnRequirement
        local isLearned = merchantItem.isLearned
        local isCollected = merchantItem.isCollected
        local isCollectedNum = merchantItem.isCollectedNum
        local isCollectedNumMax = merchantItem.isCollectedNumMax
        if not isPurchasable or not isUsable or not canAfford then
            backgroundColor = BackgroundColorPreset.Red
        end
        if isLearned or isCollected then
            backgroundColor = BackgroundColorPreset.None
            textColor = ColorPreset.Gray
        elseif canLearnRequirement and canLearnRequirement.type == 1 then -- Profession
            if canLearnRequirement.amount then
                backgroundColor = BackgroundColorPreset.Yellow
            else
                backgroundColor = BackgroundColorPreset.Orange
            end
        end
        if backgroundColor then
            button:SetBackgroundColor(backgroundColor)
        end
        if textColor then
            button:SetTextColor(textColor)
        end
        local canSelectQuantity = merchantItem:CanSpecifyQuantity()
        button.Quantity:SetShown(canSelectQuantity)
    end

    ---@param button? CompactVendorFrameMerchantButtonTemplate
    ---@param merchantItem? MerchantItem
    ---@return CompactVendorFrameMerchantButtonTemplate merchantButton
    function CreateMerchantItemButton(button, merchantItem)
        local merchantButton = button or CreateFrame("Button") ---@class CompactVendorFrameMerchantButtonTemplate
        if not merchantButton.isInitialized then
            merchantButton.isInitialized = true
        end
        UpdateMerchantItemButton(merchantButton, merchantItem)
        return merchantButton
    end

end

---@class MerchantScanner
local MerchantScanner do

    ---@alias CallbackRegistryCallbackFunction fun(owner: number, ...: any)
    ---@alias DataProviderItemData MerchantItem
    ---@alias DataProviderEnumerator fun(table: DataProviderItemData[], i?: number): number, DataProviderItemData
    ---@alias DataProviderPredicate fun(itemData: DataProviderItemData): boolean?
    ---@alias DataProviderSortComparator fun(a: DataProviderItemData, b: DataProviderItemData): boolean
    ---@alias DataProviderForEach fun(itemData: DataProviderItemData)
    ---@alias DataProviderEvent "OnSizeChanged"|"OnInsert"|"OnRemove"|"OnSort"

    ---@class CallbackRegistryCallbackHandle
    ---@field public Unregister fun()

    ---@class CallbackRegistry
    ---@field public OnLoad fun(self: CallbackRegistry)
    ---@field public SetUndefinedEventsAllowed fun(self: CallbackRegistry, allowed: boolean)
    ---@field public HasRegistrantsForEvent fun(self: CallbackRegistry, event: string|number): boolean
    ---@field public SecureInsertEvent fun(self: CallbackRegistry, event: string|number)
    ---@field public RegisterCallback fun(self: CallbackRegistry, event: string|number, func: CallbackRegistryCallbackFunction, owner: string|nil, ...: any)
    ---@field public RegisterCallbackWithHandle fun(self: CallbackRegistry, event: string|number, func: CallbackRegistryCallbackFunction, owner: string|nil, ...: any): CallbackRegistryCallbackHandle
    ---@field public TriggerEvent fun(self: CallbackRegistry, event: string|number, ...: any)
    ---@field public UnregisterCallback fun(self: CallbackRegistry, event: string|number, owner: string|number)
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: DataProviderEvent[])

    ---@class DataProvider : CallbackRegistry
    ---@field public Event table<DataProviderEvent, number>
    ---@field public collection DataProviderItemData[]
    ---@field public sortComparator? DataProviderSortComparator
    ---@field public Init fun(self: DataProvider, tbl?: DataProviderItemData[])
    ---@field public Enumerate fun(self: DataProvider, indexBegin?: number, indexEnd?: number): DataProviderEnumerator
    ---@field public GetSize fun(self: DataProvider): number
    ---@field public IsEmpty fun(self: DataProvider): boolean
    ---@field public InsertInternal fun(self: DataProvider, itemData: DataProviderItemData, hasSortComparator: boolean)
    ---@field public Insert fun(self: DataProvider, ...: DataProviderItemData)
    ---@field public InsertTable fun(self: DataProvider, tbl: DataProviderItemData[])
    ---@field public InsertTableRange fun(self: DataProvider, tbl: DataProviderItemData[], indexBegin: number, indexEnd: number)
    ---@field public Remove fun(self: DataProvider, ...: DataProviderItemData): removedIndex: number
    ---@field public RemoveByPredicate fun(self: DataProvider, predicate: DataProviderPredicate)
    ---@field public RemoveIndex fun(self: DataProvider, index: number)
    ---@field public RemoveIndexRange fun(self: DataProvider, indexBegin: number, indexEnd: number)
    ---@field public SetSortComparator fun(self: DataProvider, sortComparator: DataProviderSortComparator, skipSort: boolean)
    ---@field public HasSortComparator fun(self: DataProvider): boolean
    ---@field public Sort fun(self: DataProvider)
    ---@field public Find fun(self: DataProvider, index: number): itemData: DataProviderItemData?
    ---@field public FindIndex fun(self: DataProvider, itemData: DataProviderItemData): index: number?, itemDataIter: DataProviderEnumerator?
    ---@field public FindByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): index: number?, itemData: DataProviderItemData?
    ---@field public FindElementDataByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): itemData: DataProviderItemData?
    ---@field public FindIndexByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): index: number?
    ---@field public ContainsByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): boolean
    ---@field public ForEach fun(self: DataProvider, func: DataProviderForEach)
    ---@field public Flush fun(self: DataProvider)

    ---@alias MerchantScannerEvent "OnShow"|"OnHide"|"OnUpdate"|"OnReady"

    ---@class MerchantScanner
    ---@field public Event table<MerchantScannerEvent, number>
    ---@field public collection DataProviderItemData[]
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: MerchantScannerEvent[])

    ---@class MerchantScanner : Frame, CallbackRegistry
    MerchantScanner = CreateFrame("Frame") ---@diagnostic disable-line: cast-local-type

    Mixin(MerchantScanner, CallbackRegistryMixin)
    CallbackRegistryMixin.OnLoad(MerchantScanner)

    MerchantScanner:GenerateCallbackEvents({
        "OnShow",
        "OnHide",
        "OnUpdate",
        "OnReady",
    })

    MerchantScanner.collection = {}

    MerchantScanner.ITEM_REFRESH_INTERVAL = 0.25

    ---@alias ObjectPoolObject any
    ---@alias ObjectPoolCreate fun(pool: ObjectPool): ObjectPoolObject
    ---@alias ObjectPoolReset fun(pool: ObjectPool, self: ObjectPoolObject)
    ---@alias ObjectPoolFunction fun(creationFunc?: ObjectPoolCreate, resetterFunc?: ObjectPoolReset): ObjectPoolObject

    ---@class ObjectPool
    ---@field public OnLoad fun(self: ObjectPool, creationFunc?: ObjectPoolCreate, resetterFunc?: ObjectPoolReset)
    ---@field public Acquire fun(self: ObjectPool): ObjectPoolObject, boolean
    ---@field public Release fun(self: ObjectPool, object: ObjectPoolObject): boolean
    ---@field public ReleaseAll fun(self: ObjectPool)
    ---@field public SetResetDisallowedIfNew fun(self: ObjectPool, disallowed: boolean)
    ---@field public EnumerateActive fun(self: ObjectPool): fun(): ObjectPoolObject
    ---@field public GetNextActive fun(self: ObjectPool, current: ObjectPoolObject): fun(): ObjectPoolObject
    ---@field public GetNextInactive fun(self: ObjectPool, current: ObjectPoolObject): fun(): ObjectPoolObject
    ---@field public IsActive fun(self: ObjectPool, object: ObjectPoolObject): boolean
    ---@field public GetNumActive fun(self: ObjectPool): number
    ---@field public EnumerateInactive fun(self: ObjectPool): fun(): ObjectPoolObject

    ---@alias FramePoolObject CompactVendorFrameMerchantButtonTemplate
    ---@alias FramePoolCreate fun(pool: FramePool): FramePoolObject
    ---@alias FramePoolReset fun(pool: FramePool, self: FramePoolObject)
    ---@alias FramePoolFunction fun(frameType: FrameType, parent?: string|Region, frameTemplate?: string, resetterFunc?: FramePoolReset, forbidden?: boolean, frameInitFunc?: FramePoolCreate): FramePoolObject

    ---@class FramePool : ObjectPool
    ---@field public Acquire fun(self: FramePool): FramePoolObject, boolean
    ---@field public Release fun(self: FramePool, object: FramePoolObject): boolean
    ---@field public EnumerateActive fun(self: FramePool): fun(): FramePoolObject
    ---@field public GetNextActive fun(self: FramePool, current: FramePoolObject): fun(): FramePoolObject
    ---@field public GetNextInactive fun(self: FramePool, current: FramePoolObject): fun(): FramePoolObject
    ---@field public IsActive fun(self: FramePool, object: FramePoolObject): boolean
    ---@field public EnumerateInactive fun(self: FramePool): fun(): FramePoolObject
    ---@field public GetTemplate fun(self: FramePool): string?

    ---@class MerchantItemFramePool : FramePool

    ---@alias MerchantItemPoolObject MerchantItem
    ---@alias MerchantItemPoolCreate fun(pool: FramePool): MerchantItemPoolObject
    ---@alias MerchantItemPoolReset fun(pool: FramePool, self: MerchantItemPoolObject)
    ---@alias MerchantItemPoolFunction fun(frameType: FrameType, parent?: string|Region, frameTemplate?: string, resetterFunc?: MerchantItemPoolReset, forbidden?: boolean, frameInitFunc?: MerchantItemPoolCreate): MerchantItemPoolObject

    ---@class MerchantItemPool : ObjectPool
    ---@field public Acquire fun(self: MerchantItemPool): MerchantItemPoolObject, boolean
    ---@field public Release fun(self: MerchantItemPool, object: MerchantItemPoolObject): boolean
    ---@field public EnumerateActive fun(self: MerchantItemPool): fun(): MerchantItemPoolObject
    ---@field public GetNextActive fun(self: MerchantItemPool, current: MerchantItemPoolObject): fun(): MerchantItemPoolObject
    ---@field public GetNextInactive fun(self: MerchantItemPool, current: MerchantItemPoolObject): fun(): MerchantItemPoolObject
    ---@field public IsActive fun(self: MerchantItemPool, object: MerchantItemPoolObject): boolean
    ---@field public EnumerateInactive fun(self: MerchantItemPool): fun(): MerchantItemPoolObject

    ---@type MerchantItemPool
    MerchantScanner.itemPool = CreateObjectPool(
        ---@param pool MerchantItemPool
        function(pool)
            local index = pool:GetNumActive() + 1
            return CreateMerchantItem(MerchantScanner, index)
        end,
        ---@param pool MerchantItemPool
        ---@param self MerchantItemPoolObject
        function(pool, self)
            self:Reset()
        end
    )

    ---@type MerchantItemFramePool
    MerchantScanner.buttonPool = CreateFramePool("Button", nil, "CompactVendorFrameMerchantButtonTemplate") ---@diagnostic disable-line: assign-type-mismatch

    ---@return boolean merchantExists, boolean sameMerchant
    function MerchantScanner:UpdateMerchantInfo()
        local guid = self.guid
        self.guid = UnitGUID("npc")
        self.name = UnitName("npc")
        local merchantExists = not not self.guid
        local sameMerchant = self.guid == guid
        if merchantExists and not sameMerchant then
            self.isReady = false
            self:TriggerEvent(self.Event.OnShow)
        elseif not merchantExists then
            self.isReady = false
            self:TriggerEvent(self.Event.OnHide)
        end
        return merchantExists, sameMerchant
    end

    ---@return string guid, string name
    function MerchantScanner:GetMerchantInfo()
        return self.guid, self.name
    end

    ---@param a MerchantItem
    ---@param b MerchantItem
    local function SortCollectionByIndex(a, b)
        return a.index < b.index
    end

    local function GetActiveItems()
        local activeItems = {} ---@type MerchantItem[]
        local index = 0
        for activeItem in MerchantScanner.itemPool:EnumerateActive() do
            index = index + 1
            activeItems[index] = activeItem
        end
        if index > 1 then
            table.sort(activeItems, SortCollectionByIndex)
        end
        return activeItems
    end

    ---@param isFullUpdate? boolean
    ---@param predicate? fun(itemData: MerchantItem): boolean?
    function MerchantScanner:UpdateMerchant(isFullUpdate, predicate)
        local merchantExists = self:UpdateMerchantInfo()
        if not merchantExists then
            self.itemPool:ReleaseAll()
            self:UpdateCollection(true)
            return
        end
        if isFullUpdate == true then
            self.itemPool:ReleaseAll()
        end
        local numMerchantItems = GetMerchantNumItems()
        local activeItems = numMerchantItems > 0 and GetActiveItems()
        local pending = 0
        for index = 1, numMerchantItems do
            local itemData = activeItems and activeItems[index] or self.itemPool:Acquire()
            if itemData:IsDirty(index) or isFullUpdate == true or (predicate and predicate(itemData)) then
                pending = pending + 1
                itemData:Refresh()
                if not itemData:IsPending() then
                    pending = pending - 1
                end
            end
        end
        self:UpdateCollection()
        if pending == 0 and not self.isReady then
            self.isReady = true
            self:TriggerEvent(self.Event.OnReady, self.isReady)
        end
        self:TriggerEvent(self.Event.OnUpdate, self.isReady)
    end

    ---@param itemID number
    ---@param checkCostItems? boolean
    ---@param includePending? boolean
    function MerchantScanner:UpdateMerchantItemByID(itemID, checkCostItems, includePending)
        self:UpdateMerchant(false, function(itemData)
            if (not includePending) and (not itemData:IsPending()) then
                return false
            end
            if itemData.merchantItemID == itemID then
                return true
            elseif checkCostItems then
                for i = 1, itemData.extendedCostCount do
                    local costItem = itemData.extendedCostItems[i]
                    if costItem.itemID == itemID then
                        return true
                    end
                end
            end
            return false
        end)
    end

    local throttleHandle

    local function throttleHandleClear()
        if not throttleHandle then
            return
        end
        throttleHandle:Cancel()
        throttleHandle = nil
    end

    ---@param itemID number
    ---@param checkCostItems? boolean
    ---@param includePending? boolean
    function MerchantScanner:UpdateMerchantItemByIDThrottled(itemID, checkCostItems, includePending)
        throttleHandleClear()
        throttleHandle = C_Timer.NewTicker(self.ITEM_REFRESH_INTERVAL, function()
            throttleHandleClear()
            self:UpdateMerchantItemByID(itemID, checkCostItems, includePending)
        end)
    end

    ---@return DataProviderItemData[] merchantItems
    function MerchantScanner:GetMerchantItems()
        local collection = {} ---@type DataProviderItemData[]
        local index = 0
        for _, itemData in ipairs(self.collection) do
            if itemData:IsClean() then
                index = index + 1
                collection[index] = itemData
            end
        end
        return collection
    end

    ---@param isReset? boolean
    function MerchantScanner:UpdateCollection(isReset)
        local collection = self.collection
        table.wipe(collection)
        if isReset == true then
            return
        end
        local index = 0
        for itemData in self.itemPool:EnumerateActive() do
            index = index + 1
            collection[index] = itemData
        end
        if index > 1 then
            table.sort(collection, SortCollectionByIndex)
        end
    end

    local function UpdateMerchant()
        MerchantScanner:UpdateMerchant(true)
    end

    hooksecurefunc("SetMerchantFilter", UpdateMerchant)
    hooksecurefunc("ResetSetMerchantFilter", UpdateMerchant)

    ---@type WowEvent[]
    MerchantScanner.Events = {
        "MERCHANT_UPDATE",
        "MERCHANT_FILTER_ITEM_UPDATE",
        "HEIRLOOMS_UPDATED",
        "GET_ITEM_INFO_RECEIVED",
        "ITEM_DATA_LOAD_RESULT",
    }

    ---@param event WowEvent
    ---@param ... any
    function MerchantScanner:OnEvent(event, ...)
        if event == "MERCHANT_SHOW" then
            FrameUtil.RegisterFrameForEvents(self, self.Events)
            MerchantScanner:UpdateMerchant(true)
        elseif event == "MERCHANT_CLOSED" then
            FrameUtil.UnregisterFrameForEvents(self, self.Events)
            MerchantScanner:UpdateMerchant()
        elseif event == "UNIT_INVENTORY_CHANGED" then
            local unit = ...
            if unit == "player" then
                MerchantScanner:UpdateMerchant()
            end
        elseif event == "MERCHANT_UPDATE" then
            MerchantScanner:UpdateMerchant()
        elseif event == "MERCHANT_FILTER_ITEM_UPDATE" then
            local itemID = ...
            MerchantScanner:UpdateMerchantItemByID(itemID)
        elseif event == "HEIRLOOMS_UPDATED" then
            local itemID, updateReason = ...
            if itemID and updateReason == "NEW" then
                MerchantScanner:UpdateMerchantItemByID(itemID)
            end
        elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
            local itemID, success = ...
            if success then
                MerchantScanner:UpdateMerchantItemByIDThrottled(itemID, true, true)
            end
        end
    end

    MerchantScanner:SetScript("OnEvent", MerchantScanner.OnEvent)
    MerchantScanner:RegisterEvent("MERCHANT_SHOW")
    MerchantScanner:RegisterEvent("MERCHANT_CLOSED")
    MerchantScanner:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")

end

---@class MerchantDataProvider
local MerchantDataProvider do

    ---@alias MerchantItemProviderEvent DataProviderEvent|MerchantScannerEvent|"OnPreUpdate"|"OnPostUpdate"

    ---The return value can be `true` (show), `false` (hide) or `nil` to indicate that the filter is irrelevant and can't be performed on the item.
    ---@alias MerchantItemProviderFilter fun(itemData: MerchantItem): boolean?

    ---@class MerchantDataProvider : DataProvider
    ---@field public Event table<MerchantItemProviderEvent, number>
    ---@field public filters table<MerchantItemProviderFilter, boolean?>
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: MerchantItemProviderEvent[])

    MerchantDataProvider = CreateDataProvider() ---@type MerchantDataProvider

    MerchantDataProvider:GenerateCallbackEvents({
        "OnShow",
        "OnHide",
        "OnPreUpdate",
        "OnUpdate",
        "OnPostUpdate",
        "OnReady",
    })

    MerchantDataProvider.filters = {}

    ---@param filter MerchantItemProviderFilter
    function MerchantDataProvider:AddFilter(filter)
        self.filters[filter] = true
    end

    ---@param filter MerchantItemProviderFilter
    function MerchantDataProvider:RemoveFilter(filter)
        self.filters[filter] = nil
    end

    ---@param items MerchantItem[]
    ---@return MerchantItem[] filteredItems, boolean allDisplayed
    function MerchantDataProvider:ApplyFilters(items)
        local filteredItems = {} ---@type MerchantItem[]
        local index = 0
        local allDisplayed = true
        for _, itemData in ipairs(items) do
            local filtered = false
            for filter, _ in pairs(self.filters) do
                if filter(itemData) == true then
                    filtered = true
                    break
                end
            end
            if filtered then
                allDisplayed = false
            else
                index = index + 1
                filteredItems[index] = itemData
            end
        end
        return filteredItems, allDisplayed
    end

    function MerchantDataProvider:GetMerchantItems()
        return MerchantScanner:GetMerchantItems()
    end

    function MerchantDataProvider:Refresh()
        local isReady = MerchantScanner.isReady
        local items = MerchantDataProvider:GetMerchantItems()
        local filteredItems = self:ApplyFilters(items)
        self:TriggerEvent(self.Event.OnPreUpdate, isReady)
        self:Flush()
        self:InsertTable(filteredItems)
        self:TriggerEvent(self.Event.OnUpdate, isReady)
        self:TriggerEvent(self.Event.OnPostUpdate, isReady)
    end

    local function OnShow()
        MerchantDataProvider:TriggerEvent(MerchantDataProvider.Event.OnShow)
    end

    local function OnHide()
        MerchantDataProvider:Flush()
        MerchantDataProvider:TriggerEvent(MerchantDataProvider.Event.OnHide)
    end

    ---@param isReady boolean
    local function OnUpdate(_, isReady)
        if isReady ~= true then
            return
        end
        MerchantDataProvider:Refresh()
    end

    local function OnReady()
        MerchantDataProvider:Refresh()
    end

    MerchantScanner:RegisterCallback(MerchantScanner.Event.OnShow, OnShow)
    MerchantScanner:RegisterCallback(MerchantScanner.Event.OnHide, OnHide)
    MerchantScanner:RegisterCallback(MerchantScanner.Event.OnUpdate, OnUpdate)
    MerchantScanner:RegisterCallback(MerchantScanner.Event.OnReady, OnReady)

end

---@class CompactVendorFrame
local Frame do

    ---@class CompactVendorFrame : Frame
    Frame = CreateFrame("Frame", addonName .. "Frame", MerchantBuyBackItem) ---@diagnostic disable-line: cast-local-type

    ---@type WowEvent[]
    Frame.Events = {
        "ADDON_LOADED",
    }

    ---@param event WowEvent
    ---@param ... any
    function Frame:OnEvent(event, ...)
        if event == "ADDON_LOADED" then
            local name = ... ---@type string
            if name == addonName then
                self:UnregisterEvent(event)
                self:OnLoaded()
            end
        end
    end

    function Frame:ModifyMerchantFrame()

        MerchantBuyBackItem:ClearAllPoints()
        MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", -7, 33)

        for i = 1, 10 do
            _G["MerchantItem" .. i]:SetParent(MerchantItem11)
        end

        ---@param ... Region
        local function ForceHidden(...)
            local frames = {...}
            for _, frame in pairs(frames) do
                frame.Show = frame.Hide
                frame:Hide()
            end
        end

        ForceHidden(MerchantNextPageButton, MerchantPrevPageButton, MerchantPageText)

    end

    function Frame:CreateSearchBox()

        ---@type string?
        local searchText

        ---@param text? string
        local function SetSearchText(text)
            if not text or type(text) ~= "string" then
                text = ""
            end
            text = text:lower()
            text = text:trim() ---@diagnostic disable-line: undefined-field
            searchText = text
            MerchantDataProvider:Refresh()
        end

        MerchantDataProvider:AddFilter(function(itemData)
            if not searchText or searchText == "" then
                return
            end
            local name = itemData.name
            if not name then
                return
            end
            if LibItemSearch then
                return LibItemSearch:Matches(itemData.itemLinkOrID, searchText) ~= true
            end
            local index = name:lower():find(searchText, nil, true)
            return index == nil
        end)

        ---@class CompactVendorFrameSearchBox : EditBox
        ---@field public clearButton Button

        ---@diagnostic disable-next-line: assign-type-mismatch
        self.Search = CreateFrame("EditBox", nil, self, "SearchBoxTemplate") ---@type CompactVendorFrameSearchBox
        self.Search:SetSize(102, 32)
        self.Search:SetMultiLine(false)
        self.Search:SetMaxLetters(255)
        self.Search:SetCountInvisibleLetters(true)
        self.Search:SetAutoFocus(false)

        SearchBoxTemplate_OnLoad(self.Search)

        if MerchantFrameLootFilter then
            self.Search:SetPoint("RIGHT", MerchantFrameLootFilter, "LEFT", 14, 3)
        else
            self.Search:SetPoint("LEFT", MerchantFramePortrait, "RIGHT", 12, -19)
            self.Search:SetPoint("RIGHT", MerchantFrame, "RIGHT", -12, 0)
        end

        function self.Search:OnHide()
            self.clearButton:Click()
            BagSearch_OnTextChanged(self)
        end

        function self.Search:OnTextChanged()
            SearchBoxTemplate_OnTextChanged(self)
            SetSearchText(self:GetText())
        end

        function self.Search:OnChar()
            BagSearch_OnChar(self)
        end

        function self.Search:OnEnter()
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
            GameTooltip:AddLine("Enter an item name to search")
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("Type search:", "bop   bou   boe", nil, nil, nil, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "boa  quest", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "l:120  lvl:<120  level:>=120", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "q:epic   q:4", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "t:leather   t:shield", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "n:water   name:water", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "s:heal   set:heal", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "tt:binds   tip:binds   tooltip:binds", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine("Modifiers:", "&   Match both", nil, nil, nil, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "|   Match either", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "!   Do not match", 255, 255, 255, 255, 255, 255)
            GameTooltip:AddDoubleLine(" ", "> < <= >=   Numerical comparisons", 255, 255, 255, 255, 255, 255)
            GameTooltip:Show()
        end

        function self.Search:OnLeave()
            GameTooltip:Hide()
        end

        self.Search:SetScript("OnHide", self.Search.OnHide)
        self.Search:SetScript("OnTextChanged", self.Search.OnTextChanged)
        self.Search:SetScript("OnChar", self.Search.OnChar)
        self.Search:SetScript("OnEnter", self.Search.OnEnter)
        self.Search:SetScript("OnLeave", self.Search.OnLeave)

    end

    function Frame:CreateScrollBox()

        ---@alias ViewScrollBoxFrame Frame
        ---@alias ViewScrollBoxScrollTarget EventFrame
        ---@alias ViewScrollBox CompactVendorFrameScrollBox
        ---@alias ViewScrollBoxElement CompactVendorFrameMerchantButtonTemplate
        ---@alias ViewScrollBoxElementData MerchantItem
        ---@alias ViewPolyfillLayoutFunction fun(index: number, frame: ViewScrollBoxFrame, offset: number, scrollTarget: ViewScrollBoxScrollTarget): any
        ---@alias ViewPolyfillElementInitializerFunction fun(self: ViewScrollBoxElement, elementData: ViewScrollBoxElementData)
        ---@alias ViewPolyfillElementFactoryFunction fun(factory: fun(), elementData: ViewScrollBoxElementData)

        ---@class ViewPolyfill
        ---@field public templateInfos table<string, table<string, any>>
        ---@field public SetPadding fun(self: ViewPolyfill, top?: number, bottom?: number, left?: number, right?: number, spacing?: number)
        ---@field public GetSpacing fun(self: ViewPolyfill): number
        ---@field public GetStride fun(self: ViewPolyfill): number
        ---@field public LayoutInternal fun(self: ViewPolyfill, layoutFunction: ViewPolyfillLayoutFunction): number
        ---@field public SetElementIndentCalculator fun(self: ViewPolyfill, elementIndentCalculator: number)
        ---@field public GetElementIndent fun(self: ViewPolyfill, frame: ViewScrollBoxFrame): number
        ---@field public GetLayoutFunction fun(self, ViewPolyfill): ViewPolyfillLayoutFunction
        ---@field public Layout fun(self, ViewPolyfill): number
        ---@field public Init fun(self: ViewPolyfill, top?: number, bottom?: number, left?: number, right?: number, spacing?: number)
        ---@field public CalculateDataIndices fun(self: ViewPolyfill, scrollBox: ViewScrollBox): number
        ---@field public GetExtent fun(self: ViewPolyfill, scrollBox: ViewScrollBox): any
        ---@field public RecalculateExtent fun(self: ViewPolyfill, scrollBox: ViewScrollBox): any
        ---@field public GetExtentUntil fun(self: ViewPolyfill, scrollBox: ViewScrollBox, dataIndex: number): any
        ---@field public GetPanExtent fun(self: ViewPolyfill): boolean
        ---@field public SetElementInitializer fun(self: ViewPolyfill, frameTemplateOrFrameType: string, initializer: ViewPolyfillElementInitializerFunction)

        ---@alias ScrollBoxElementData MerchantItem
        ---@alias ScrollBoxView ViewPolyfill
        ---@alias ScrollBoxTarget Frame
        ---@alias ScrollBoxDataProvider MerchantDataProvider
        ---@alias ScrollBoxFrameData any
        ---@alias ScrollBoxFrame Frame
        ---@alias ScrollBoxBaseEvents "OnAllowScrollChanged"|"OnSizeChanged"|"OnScroll"|"OnLayout"
        ---@alias ScrollBoxListEvents ScrollBoxBaseEvents|"OnAcquiredFrame"|"OnInitializedFrame"|"OnReleasedFrame"|"OnDataRangeChanged"|"OnUpdate"
        ---@alias ScrollBoxForEachFunction fun(elementData: ScrollBoxElementData)
        ---@alias ScrollBoxPredicateFunction fun(elementData: ScrollBoxElementData): boolean?

        ---@enum ScrollBoxViewAlignment
        local ScrollBoxViewAlignment = {
            AlignBegin = 0,
            AlignCenter = 0.5,
            AlignEnd = 1,
            AlignNearest = -1,
        }

        local MathUtilEpsilon = MathUtil.Epsilon

        ---@enum ScrollBoxScrollDirection
        local ScrollBoxScrollDirection = {
            ScrollBegin = MathUtilEpsilon,
            ScrollEnd = 1 - MathUtilEpsilon,
        }

        ---@class ScrollBoxBase
        ---@field public Event table<ScrollBoxBaseEvents, number>
        ---@field public SetView fun(self: ScrollBoxBase, view: ScrollBoxView)
        ---@field public Update fun(self: ScrollBoxBase, forceLayout?: boolean)

        ---@class ScrollBoxMixin : ScrollBoxBase, CallbackRegistry
        ---@field public OnLoad fun(self: ScrollBoxMixin)
        ---@field public Init fun(self: ScrollBoxMixin, view: ScrollBoxView)
        ---@field public SetView fun(self: ScrollBoxMixin, view: ScrollBoxView)
        ---@field public GetView fun(self: ScrollBoxMixin): ScrollBoxView
        ---@field public GetScrollTarget fun(self: ScrollBoxMixin): ScrollBoxTarget
        ---@field public OnScrollTargetSizeChanged fun(self: ScrollBoxMixin, width: number, height: number)
        ---@field public OnSizeChanged fun(self: ScrollBoxMixin, width: number, height: number)
        ---@field public FullUpdate fun(self: ScrollBoxMixin, immediately?: boolean)
        ---@field public SetUpdateLocked fun(self: ScrollBoxMixin, locked?: boolean)
        ---@field public IsUpdateLocked fun(self: ScrollBoxMixin): boolean
        ---@field public FullUpdateInternal fun(self: ScrollBoxMixin)
        ---@field public Layout fun(self: ScrollBoxMixin)
        ---@field public SetScrollTargetOffset fun(self: ScrollBoxMixin, offset: number)
        ---@field public ScrollInDirection fun(self: ScrollBoxMixin, scrollPercentage: number, direction: ScrollBoxScrollDirection)
        ---@field public ScrollToBegin fun(self: ScrollBoxMixin, noInterpolation?: boolean)
        ---@field public ScrollToEnd fun(self: ScrollBoxMixin, noInterpolation?: boolean)
        ---@field public IsAtBegin fun(self: ScrollBoxMixin): boolean
        ---@field public IsAtEnd fun(self: ScrollBoxMixin): boolean
        ---@field public SetScrollPercentage fun(self: ScrollBoxMixin, scrollPercentage: number, noInterpolation?: boolean)
        ---@field public SetScrollPercentageInternal fun(self: ScrollBoxMixin, scrollPercentage: number)
        ---@field public GetVisibleExtentPercentage fun(self: ScrollBoxMixin): number
        ---@field public GetPanExtent fun(self: ScrollBoxMixin)
        ---@field public SetPanExtent fun(self: ScrollBoxMixin, panExtent: any)
        ---@field public GetExtent fun(self: ScrollBoxMixin): any
        ---@field public GetVisibleExtent fun(self: ScrollBoxMixin): any
        ---@field public GetFrames fun(self: ScrollBoxMixin): ScrollBoxFrame[]
        ---@field public GetFrameCount fun(self: ScrollBoxMixin): number
        ---@field public FindFrame fun(self: ScrollBoxMixin, elementData: ScrollBoxFrameData): ScrollBoxFrame
        ---@field public FindFrameByPredicate fun(self: ScrollBoxMixin, predicate: ScrollBoxPredicateFunction): ScrollBoxFrame?
        ---@field public ScrollToFrame fun(self: ScrollBoxMixin, frame: ScrollBoxFrame, alignment?: ScrollBoxViewAlignment, noInterpolation?: boolean)
        ---@field public CalculatePanExtentPercentage fun(self: ScrollBoxMixin): number
        ---@field public CalculateScrollPercentage fun(self: ScrollBoxMixin): number
        ---@field public HasScrollableExtent fun(self: ScrollBoxMixin): boolean
        ---@field public SetScrollAllowed fun(self: ScrollBoxMixin, allowScroll: boolean)
        ---@field public GetDerivedScrollRange fun(self: ScrollBoxMixin): number
        ---@field public GetDerivedScrollOffset fun(self: ScrollBoxMixin): number
        ---@field public SetAlignmentOverlapIgnored fun(self: ScrollBoxMixin, ignored: boolean)
        ---@field public IsAlignmentOverlapIgnored fun(self: ScrollBoxMixin): boolean
        ---@field public SanitizeAlignment fun(self: ScrollBoxMixin, alignment: ScrollBoxViewAlignment, extent: any): ScrollBoxViewAlignment
        ---@field public ScrollToOffset fun(self: ScrollBoxMixin, offset: number, frameExtent?: any, alignment?: ScrollBoxViewAlignment, noInterpolation?: boolean)
        ---@field public RecalculateDerivedExtent fun(self: ScrollBoxMixin)
        ---@field public GetDerivedExtent fun(self: ScrollBoxMixin): number
        ---@field public SetPadding fun(self: ScrollBoxMixin, padding: number)
        ---@field public GetPadding fun(self: ScrollBoxMixin): number
        ---@field public GetLeftPadding fun(self: ScrollBoxMixin): number
        ---@field public GetTopPadding fun(self: ScrollBoxMixin): number
        ---@field public GetRightPadding fun(self: ScrollBoxMixin): number
        ---@field public GetBottomPadding fun(self: ScrollBoxMixin): number
        ---@field public GetUpperPadding fun(self: ScrollBoxMixin): number
        ---@field public GetLowerPadding fun(self: ScrollBoxMixin): number

        ---@class ScrollBoxListMixin : ScrollBoxMixin
        ---@field public Event table<ScrollBoxListEvents, number>
        ---@field public Init fun(self: ScrollBoxListMixin)
        ---@field public Flush fun(self: ScrollBoxListMixin)
        ---@field public ForEachFrame fun(self: ScrollBoxListMixin, func: ScrollBoxForEachFunction)
        ---@field public EnumerateFrames fun(self: ScrollBoxListMixin): fun(): fun(): number, ScrollBoxElementData
        ---@field public FindElementDataByPredicate fun(self: ScrollBoxListMixin, predicate: ScrollBoxPredicateFunction): ScrollBoxElementData?
        ---@field public FindElementDataIndexByPredicate fun(self: ScrollBoxListMixin, predicate: ScrollBoxPredicateFunction): ScrollBoxElementData?
        ---@field public FindByPredicate fun(self: ScrollBoxListMixin, predicate: ScrollBoxPredicateFunction): ScrollBoxElementData?
        ---@field public Find fun(self: ScrollBoxListMixin, index: number): ScrollBoxElementData
        ---@field public FindIndex fun(self: ScrollBoxListMixin, elementData: ScrollBoxElementData): number?
        ---@field public InsertElementData fun(self: ScrollBoxListMixin, ...: ScrollBoxElementData)
        ---@field public InsertElementDataTable fun(self: ScrollBoxListMixin, tbl: ScrollBoxElementData[])
        ---@field public InsertElementDataTableRange fun(self: ScrollBoxListMixin, tbl: ScrollBoxElementData[], indexBegin: number, indexEnd: number)
        ---@field public ContainsElementDataByPredicate fun(self: ScrollBoxListMixin, predicate: ScrollBoxPredicateFunction): boolean
        ---@field public GetDataProvider fun(self: ScrollBoxListMixin): ScrollBoxDataProvider
        ---@field public HasDataProvider fun(self: ScrollBoxListMixin): boolean
        ---@field public ClearDataProvider fun(self: ScrollBoxListMixin)
        ---@field public GetDataIndexBegin fun(self: ScrollBoxListMixin): number
        ---@field public GetDataIndexEnd fun(self: ScrollBoxListMixin): number
        ---@field public IsVirtualized fun(self: ScrollBoxListMixin): boolean
        ---@field public GetElementExtent fun(self: ScrollBoxListMixin, dataIndex: number): ScrollBoxElementData
        ---@field public GetExtentUntil fun(self: ScrollBoxListMixin, dataIndex: number): ScrollBoxElementData[]
        ---@field public SetDataProvider fun(self: ScrollBoxListMixin, dataProvider: ScrollBoxDataProvider, retainScrollPosition?: boolean)
        ---@field public GetDataProviderSize fun(self: ScrollBoxListMixin): number
        ---@field public OnViewDataChanged fun(self: ScrollBoxListMixin)
        ---@field public Rebuild fun(self: ScrollBoxListMixin)
        ---@field public OnViewAcquiredFrame fun(self: ScrollBoxListMixin, frame: Region, elementData: ScrollBoxElementData, new: boolean)
        ---@field public OnViewInitializedFrame fun(self: ScrollBoxListMixin, frame: Region, elementData: ScrollBoxElementData)
        ---@field public OnViewReleasedFrame fun(self: ScrollBoxListMixin, frame: Region, oldElementData: ScrollBoxElementData)
        ---@field public IsAcquireLocked fun(self: ScrollBoxListMixin): boolean
        ---@field public FullUpdateInternal fun(self: ScrollBoxListMixin)
        ---@field public ScrollToNearest fun(self: ScrollBoxListMixin, dataIndex: number, noInterpolation?: boolean): number
        ---@field public ScrollToElementDataIndex fun(self: ScrollBoxListMixin, dataIndex: number, alignment?: ScrollBoxViewAlignment, noInterpolation?: boolean)
        ---@field public ScrollToElementData fun(self: ScrollBoxListMixin, elementData: ScrollBoxElementData, alignment?: ScrollBoxViewAlignment, noInterpolation?: boolean)
        ---@field public ScrollToElementDataByPredicate fun(self: ScrollBoxListMixin, predicate: ScrollBoxPredicateFunction, alignment?: ScrollBoxViewAlignment, noInterpolation?: boolean)

        ---@class WowScrollBoxList : ScrollBoxListMixin, Frame
        ---@field public canInterpolateScroll boolean false
        ---@field public ScrollTarget EventFrame
        ---@field public Shadows Frame

        ---@class CompactVendorFrameScrollBox : WowScrollBoxList

        self.ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList") ---@class CompactVendorFrameScrollBox
        self.ScrollBox:SetSize(466, 386)
        self.ScrollBox:SetPoint("TOPLEFT", 7, -64)
        self.ScrollBox:SetAllPoints()

        ---@class EventFrame : Frame
        ---@field public Event table<"OnHide"|"OnShow"|"OnSizeChanged", number>
        ---@field public OnLoad_Intrinsic fun(self: EventFrame)
        ---@field public OnHide_Intrinsic fun(self: EventFrame)
        ---@field public OnShow_Intrinsic fun(self: EventFrame)
        ---@field public OnSizeChanged_Intrinsic fun(self: EventFrame, width: number, height: number)

        ---@class WowTrimScrollBar : Frame
        ---@field public minThumbExtent number 23
        ---@field public Backplate Texture
        ---@field public Background Frame
        ---@field public Track Frame
        ---@field public Back Button
        ---@field public Forward Button
        ---@field public OnLoad fun(self: WowTrimScrollBar)

        ---@class CompactVendorFrameScrollBar : EventFrame, WowTrimScrollBar

        self.ScrollBar = CreateFrame("EventFrame", nil, self, "WowTrimScrollBar") ---@class CompactVendorFrameScrollBar
        self.ScrollBar:SetPoint("TOPLEFT", self.ScrollBox, "TOPRIGHT", -1, 2)
        self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollBox, "BOTTOMRIGHT", -1, -3)

        local view = CreateScrollBoxListLinearView() ---@type ViewPolyfill
        view.templateInfos["CompactVendorFrameMerchantButtonTemplate"] = { type = "Button", width = 300, height = 24, keyValues = {} }
        view:SetElementInitializer("CompactVendorFrameMerchantButtonTemplate", CreateMerchantItemButton)
        view:SetPadding(2, 2, 2, 2, 0)
        ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

        self.ScrollBox:SetDataProvider(MerchantDataProvider)

        local scrollPercentage

        local function OnPreUpdate()
            if scrollPercentage then
                return
            end
            scrollPercentage = self.ScrollBox:CalculateScrollPercentage()
        end

        local function OnPostUpdate()
            if not scrollPercentage then
                return
            end
            self.ScrollBox:SetScrollPercentage(scrollPercentage)
            scrollPercentage = nil
        end

        MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnPreUpdate, OnPreUpdate)
        MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnPostUpdate, OnPostUpdate)

        -- TODO: the code below is a bandaid fix that only resolves odd behavior when the frame is shown for the first time
        -- and the events fire as they should, but once the UI is drawn and ready, the buttons themselves behave like they aren't interractable, but
        -- the hover animation works, quantity button works, but the icon isn't being updated (OnUpdate might be disabled?) and this is fixed if we
        -- manually refresh the data provider one more time... but why?

        hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function() C_Timer.After(0.25, function() MerchantDataProvider:Refresh() end) end)

    end

    function Frame:CreateSettings()

        ---@alias SettingsTextContainerPolyfillGetDataFunc fun(self: SettingsControlTextContainerPolyfill): SettingsSliderOptionsPolyfill[]

        ---@class SettingsPolyfill
        ---@field public RegisterVerticalLayoutCategory fun(name: string): SettingsCategoryPolyfill
        ---@field public RegisterProxySetting fun(category: SettingsCategoryPolyfill, variable: string, db: table, defaultValueType: type, name: string, defaultValue: any): SettingsProxySettingPolyfill
        ---@field public CreateCheckBox fun(category: SettingsCategoryPolyfill, setting: SettingsProxySettingPolyfill, tooltip: string)
        ---@field public CreateSliderOptions fun(minValue: number, maxValue: number, step: number): SettingsSliderOptionsPolyfill
        ---@field public CreateSlider fun(category: SettingsCategoryPolyfill, setting: SettingsProxySettingPolyfill, options: SettingsSliderOptionsPolyfill, tooltip: string)
        ---@field public CreateControlTextContainer fun(): SettingsControlTextContainerPolyfill
        ---@field public CreateDropDown fun(category: SettingsCategoryPolyfill, setting: SettingsProxySettingPolyfill, GetOptions: SettingsTextContainerPolyfillGetDataFunc, tooltip: string)
        ---@field public RegisterAddOnCategory fun(category: SettingsCategoryPolyfill)

        ---@class SettingsCategoryPolyfill

        ---@class SettingsProxySettingPolyfill

        ---@class SettingsSliderOptionsPolyfill
        ---@field public SetLabelFormatter fun(self: SettingsSliderOptionsPolyfill, labelFormatter: any)

        ---@class SettingsControlTextContainerPolyfill
        ---@field public Add fun(self: SettingsControlTextContainerPolyfill, index: number, label: string)
        ---@field public GetData SettingsTextContainerPolyfillGetDataFunc

        local Settings = Settings ---@type SettingsPolyfill

        local category = Settings.RegisterVerticalLayoutCategory(addonName)

        do
            local name = "Merchant Item Size (px)"
            local tooltip = "Specify the font text size used in the merchant item buttons."
            local variable = "ListItemScale"
            local defaultValue = CompactVendorDBDefaults[variable]
            local minValue, maxValue, step = ListItemScaleToFontObject.minSize, ListItemScaleToFontObject.maxSize, 1
            local setting = Settings.RegisterProxySetting(category, variable, CompactVendorDB, type(defaultValue), name, defaultValue)
            local options = Settings.CreateSliderOptions(minValue, maxValue, step)
            options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
            Settings.CreateSlider(category, setting, options, tooltip)
        end

        Settings.RegisterAddOnCategory(category)

    end

    function Frame:CreateFilters()

        local CompactVendorFilterFrameTemplate = CompactVendorFilterFrameTemplate ---@type CompactVendorFilterFrameTemplate

        if not CompactVendorFilterFrameTemplate then
            return
        end

        ---@type CompactVendorFilterFrameTemplate
        local frame = CreateFrame("Frame", addonName .. "FilterFrame") ---@diagnostic disable-line: assign-type-mismatch
        Mixin(frame, CompactVendorFilterFrameTemplate)

        frame:OnLoad()
        frame:SetScript("OnEvent", frame.OnEvent)

    end

    function Frame:OnLoad()

        self:SetFrameStrata("HIGH")

        self:SetPoint("TOPLEFT", MerchantFrameInset, "TOPLEFT", 3, -2)
        self:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOMRIGHT", -20, 55)

        self:SetScript("OnEvent", self.OnEvent)
        FrameUtil.RegisterFrameForEvents(self, self.Events)

        hooksecurefunc("MerchantFrame_Update", function() self:SetShown(MerchantFrame.selectedTab == 1) end)

    end

    function Frame:OnLoaded()

        CompactVendorDB = type(CompactVendorDB) == "table" and CompactVendorDB or {}
        setmetatable(CompactVendorDB, { __index = CompactVendorDBDefaults })

        self:ModifyMerchantFrame()
        self:CreateSearchBox()
        self:CreateScrollBox()
        self:CreateSettings()
        self:CreateFilters()

    end

    Frame:OnLoad()

end

---@class CompactVendorFrameAutoSizeTemplate
local CompactVendorFrameAutoSizeTemplate do

    ---@class CompactVendorFrameAutoSizeTemplate : Frame
    ---@field public isIconTextTemplate? boolean

    CompactVendorFrameAutoSizeTemplate = {} ---@class CompactVendorFrameAutoSizeTemplate
    _G.CompactVendorFrameAutoSizeTemplate = CompactVendorFrameAutoSizeTemplate

    ---@param frames CompactVendorFrameAutoSizeTemplate[]
    local function AutoSize(frames)
        for _, frame in ipairs(frames) do
            if frame.AutoSize and frame:IsShown() then
                frame:AutoSize()
            end
        end
    end

    function CompactVendorFrameAutoSizeTemplate:AutoSize()
        self:Show()
        self:SetWidth(1)
        AutoSize({ self:GetChildren() })
        local _, _, width = self:GetBoundsRect()
        if not width then
            return
        end
        if self.isIconTextTemplate then
            ---@diagnostic disable-next-line: assign-type-mismatch
            local cost = self ---@type CompactVendorFrameMerchantIconTemplate
            if not cost.mode then
                width = width - cost.Texture:GetWidth()
            end
        end
        self:SetWidth(width)
    end

end

---@class CompactVendorFrameMerchantStackSplitTemplate
local CompactVendorFrameMerchantStackSplitTemplate do

    ---@class CompactVendorFrameMerchantStackSplitTemplate : Frame
    ---@field public owner? CompactVendorFrameMerchantButtonQuantityTemplate
    ---@field public SingleItemSplitBackground Texture
    ---@field public MultiItemSplitBackground Texture
    ---@field public StackSplitText FontString
    ---@field public StackItemCountText FontString
    ---@field public LeftButton Button
    ---@field public RightButton Button
    ---@field public OkayButton Button
    ---@field public CancelButton Button

    CompactVendorFrameMerchantStackSplitTemplate = {} ---@class CompactVendorFrameMerchantStackSplitTemplate
    _G.CompactVendorFrameMerchantStackSplitTemplate = CompactVendorFrameMerchantStackSplitTemplate

    function CompactVendorFrameMerchantStackSplitTemplate:OnLoad()
        self.down = {} ---@type table<string, boolean?>
        self.isMultiStack = false
        self.maxStack = 0
        self.minSplit = 0
        self.typing = 0
        self.split = 0
        self:Hide()
        self:SetParent(UIParent)
        self:SetFrameStrata("HIGH")
        self:SetClampedToScreen(true)
        self:SetToplevel(true)
        self:EnableMouse(true)
        self:EnableKeyboard(true)
    end

    function CompactVendorFrameMerchantStackSplitTemplate:OnHide()
        table.wipe(self.down)
        if self.owner then
            self.owner.hasStackSplit = 0
        end
    end

    ---@param text number
    function CompactVendorFrameMerchantStackSplitTemplate:OnChar(text)
        if self.isMultiStack and self.maxStack < self.minSplit * text then
            return
        elseif text < "0" or text > "9" then
            return
        end
        if self.typing == 0 then
            self.typing = self.minSplit
            self.split = 0
        end
        local split = (self.split * 10) + (text * self.minSplit)
        if split == self.split then
            if self.split == 0 then
                self.split = self.minSplit
            end
            return
        end
        if split <= self.maxStack then
            self.RightButton:SetEnabled(split ~= self.maxStack)
            self.LeftButton:SetEnabled(split ~= self.minSplit)
            self.split = split
            self:UpdateStackText()
        elseif split == 0 then
            self.split = 1
        end
    end

    ---@param key string
    function CompactVendorFrameMerchantStackSplitTemplate:OnKeyDown(key)
        if key == "BACKSPACE" or key == "DELETE" then
            if self.typing == 0 or self.split == self.minSplit then
                return
            end
            self.split = floor(self.split / 10)
            if self.split <= self.minSplit then
                self.split = self.minSplit
                self.typing = 0
                self.LeftButton:Disable()
            else
                self.LeftButton:Enable()
            end
            self:UpdateStackText()
            self.RightButton:SetEnabled(self.split ~= self.maxStack)
        elseif key == "ENTER" then
            self:OkayButtonOnClick()
        elseif GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
            self:CancelButtonOnClick()
        elseif key == "LEFT" or key == "DOWN" then
            self:LeftButtonOnClick()
        elseif key == "RIGHT" or key == "UP" then
            self:RightButtonOnClick()
        end
        table.wipe(self.down)
        self.down[key] = true
    end

    ---@param key string
    function CompactVendorFrameMerchantStackSplitTemplate:OnKeyUp(key)
        self.down[key] = nil
    end

    function CompactVendorFrameMerchantStackSplitTemplate:LeftButtonOnClick()
        if self.split == self.minSplit then
            return
        end
        self.split = self.split - self.minSplit
        self:UpdateStackText()
        if self.split == self.minSplit then
            self.LeftButton:Disable()
        end
        self.RightButton:Enable()
    end

    function CompactVendorFrameMerchantStackSplitTemplate:RightButtonOnClick()
        if self.split == self.maxStack then
            return
        end
        self.split = self.split + self.minSplit
        self:UpdateStackText()
        if self.split == self.maxStack then
            self.RightButton:Disable()
        end
        self.LeftButton:Enable()
    end

    function CompactVendorFrameMerchantStackSplitTemplate:OkayButtonOnClick()
        self:Hide()
        if self.owner then
            self.owner.SplitStack(self.owner, self.split)
        end
    end

    function CompactVendorFrameMerchantStackSplitTemplate:CancelButtonOnClick()
        self:Hide()
    end

    ---@param maxStack number
    ---@param owner CompactVendorFrameMerchantButtonQuantityTemplate
    ---@param anchor AnchorPoint
    ---@param anchorTo AnchorPoint
    ---@param stackCount? number
    function CompactVendorFrameMerchantStackSplitTemplate:OpenStackSplitFrame(maxStack, owner, anchor, anchorTo, stackCount)
        if self.owner then
            self.owner.hasStackSplit = 0
        end
        if not maxStack or maxStack < 1 then
            self:Hide()
            return
        end
        self.maxStack = maxStack
        self.owner = owner
        owner.hasStackSplit = 1
        self.minSplit = stackCount or 1
        self.split = self.minSplit
        self.typing = 0
        self.StackSplitText:SetText(self.split)
        self.LeftButton:Disable()
        self.RightButton:Enable()
        self:ClearAllPoints()
        self:SetPoint(anchor, owner, anchorTo, 0, 0)
        self:Show()
        self:ChooseFrameType(self.minSplit)
    end

    ---@param splitAmount number
    function CompactVendorFrameMerchantStackSplitTemplate:ChooseFrameType(splitAmount)
        if splitAmount == 1 then
            self:SetSize(172, 96)
            self.isMultiStack = false
            self.SingleItemSplitBackground:Show()
            self.MultiItemSplitBackground:Hide()
            self.StackItemCountText:Hide()
            self.StackSplitText:ClearAllPoints()
            self.StackSplitText:SetPoint("RIGHT", self, "RIGHT", -50, 18)
            self.OkayButton:ClearAllPoints()
            self.OkayButton:SetPoint("RIGHT", self, "BOTTOM", -3, 32)
            self.CancelButton:ClearAllPoints()
            self.CancelButton:SetPoint("LEFT", self, "BOTTOM", 5, 32)
        else
            self.isMultiStack = true
            self:SetSize(172, 120)
            self.SingleItemSplitBackground:Hide()
            self.MultiItemSplitBackground:Show()
            self.StackSplitText:ClearAllPoints()
            self.StackSplitText:SetPoint("CENTER", self, "CENTER", 5, 30)
            self.StackItemCountText:Show()
            self.OkayButton:ClearAllPoints()
            self.OkayButton:SetPoint("RIGHT", self, "BOTTOM", -3, 40)
            self.CancelButton:ClearAllPoints()
            self.CancelButton:SetPoint("LEFT", self, "BOTTOM", 5, 40)
        end
        self:UpdateStackText()
    end

    function CompactVendorFrameMerchantStackSplitTemplate:UpdateStackText()
        if self.isMultiStack then
            self.StackSplitText:SetText(STACKS:format(self.split/self.minSplit))
            self.StackItemCountText:SetText(TOTAL_STACKS:format(self.split))
        else
            self.StackSplitText:SetText(self.split)
        end
    end

    ---@param maxStack number
    function CompactVendorFrameMerchantStackSplitTemplate:UpdateStackSplitFrame(maxStack)
        self.maxStack = maxStack
        if self.maxStack < 2 then
            if self.owner then
                self.owner.hasStackSplit = 0
            end
            self:Hide()
            return
        end
        if self.split > self.maxStack then
            self.split = self.maxStack
            self.StackSplitText:SetText(self.split)
        end
        self.RightButton:SetEnabled(self.split ~= self.maxStack)
        self.LeftButton:SetEnabled(self.split ~= 1)
    end

end

---@class CompactVendorFrameMerchantButtonQuantityTemplate
local CompactVendorFrameMerchantButtonQuantityTemplate do

    ---@class CompactVendorFrameMerchantButtonQuantityTemplate : Button
    ---@field public Bg Texture
    ---@field public Name FontString
    ---@field public StackSplitFrameOwnedBy? CompactVendorFrameMerchantButtonTemplate

    CompactVendorFrameMerchantButtonQuantityTemplate = {} ---@class CompactVendorFrameMerchantButtonQuantityTemplate
    _G.CompactVendorFrameMerchantButtonQuantityTemplate = CompactVendorFrameMerchantButtonQuantityTemplate

    C_Timer.After(0.01, function()
        --[[ global ]] CompactVendorFrameMerchantButtonQuantityTemplate.StackSplitFrame = CompactVendorFrameMerchantStackSplitFrame ---@type CompactVendorFrameMerchantStackSplitTemplate
    end)

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnLoad()
        self:RegisterForClicks("LeftButtonUp")
        self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
        self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)
        -- required by StackSplitFrame
        self.hasStackSplit = 0
        self.SplitStack = self.StackSplitFrameCallback
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnShow()
        self.StackSplitFrame:Hide()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnHide()
        self.StackSplitFrame:Hide()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnClick()
        if self.StackSplitFrame:IsShown() and self == self.StackSplitFrame.owner then
            self.StackSplitFrame:Hide()
        else
            self.StackSplitFrame:OpenStackSplitFrame(250, self, "TOPLEFT", "TOPRIGHT")
            ---@diagnostic disable-next-line: assign-type-mismatch
            self.StackSplitFrameOwnedBy = self:GetParent() ---@type CompactVendorFrameMerchantButtonTemplate?
        end
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:StackSplitFrameCallback(quantity)
        if not self.StackSplitFrameOwnedBy or not quantity then
            return
        end
        self.StackSplitFrameOwnedBy:Purchase(quantity)
    end

end

---@class CompactVendorFrameMerchantIconTemplate
local CompactVendorFrameMerchantIconTemplate do

    ---@class CompactVendorFrameMerchantIconTemplate : CompactVendorFrameAutoSizeTemplate
    ---@field public Texture Texture
    ---@field public TextureMask Texture #MaskTexture
    ---@field public Border Texture
    ---@field public BorderMask Texture #MaskTexture
    ---@field public Count FontString
    ---@field public Text FontString
    ---@field public mode? boolean

    CompactVendorFrameMerchantIconTemplate = {} ---@class CompactVendorFrameMerchantIconTemplate
    _G.CompactVendorFrameMerchantIconTemplate = CompactVendorFrameMerchantIconTemplate

    function CompactVendorFrameMerchantIconTemplate:OnLoad()
        self.isIconTextTemplate = true
    end

    ---@param texture? string|number
    function CompactVendorFrameMerchantIconTemplate:SetTexture(texture)
        self.Texture:SetTexture(texture or 0)
    end

    ---@param quality? number|SimpleColor|nil
    function CompactVendorFrameMerchantIconTemplate:SetQuality(quality)
        if type(quality) == "number" then
            quality = ColorPreset[quality]
        end
        if type(quality) == "table" then
            self.Border:SetVertexColor(quality.r, quality.g, quality.b, 1)
        else
            self.Border:SetVertexColor(1, 1, 1, 0)
        end
    end

    ---@param count? number|string
    function CompactVendorFrameMerchantIconTemplate:SetCount(count)
        self.Count:SetText(count)
    end

    ---@param merchantItem MerchantItem
    ---@param hideCount? boolean
    ---@param hideQuality? boolean
    function CompactVendorFrameMerchantIconTemplate:SetItem(merchantItem, hideCount, hideQuality)
        local count = merchantItem.stackCount
        self:SetTexture(merchantItem.texture)
        self:SetQuality(hideQuality ~= true and merchantItem.qualityColor or nil)
        self:SetCount(hideCount ~= true and count and count > 1 and count or "")
        self:SetMode(true)
    end

    ---@param texture? number|string
    ---@param quality? number|SimpleColor
    ---@param count? number|string
    function CompactVendorFrameMerchantIconTemplate:SetItemInfo(texture, quality, count)
        self:SetTexture(texture)
        self:SetQuality(quality)
        self:SetCount(count)
        self:SetMode(true)
    end

    ---@param text? string|number
    function CompactVendorFrameMerchantIconTemplate:SetText(text)
        self.Text:SetText(text or "")
        self:SetMode(false)
    end

    ---@param asIcon boolean
    function CompactVendorFrameMerchantIconTemplate:SetMode(asIcon)
        self.mode = asIcon
        self.Texture:SetShown(asIcon)
        self.Border:SetShown(asIcon)
        self.Count:SetShown(asIcon)
        self.Text:SetShown(not asIcon)
    end

end

---@class CompactVendorFrameMerchantButtonCostButtonTemplate
local CompactVendorFrameMerchantButtonCostButtonTemplate do

    ---@param itemLink string
    ---@return number
    local function CountAvailableItems(itemLink)
        local count = GetItemCount(itemLink, true, false)
        if count and count > 0 then
            return count
        end
        local currencyID
        if C_CurrencyInfo.GetCurrencyIDFromLink then
            currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(itemLink)
        end
        if not currencyID or currencyID < 1 then
            return 0
        end
        if C_CurrencyInfo.GetCurrencyInfo then
            count = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity
        elseif GetCurrencyInfo then
            count = select(2, GetCurrencyInfo(currencyID))
        end
        return count or 0
    end

    local PRICE_FORMAT = "€ %.2f"
    local TOKEN_COST = 20
    local PRICE_THRESHOLD = 0.1
    local function GetCopperPerUnit()
        C_WowTokenPublic.UpdateMarketPrice()
        local price = C_WowTokenPublic.GetCurrentMarketPrice()
        if not price then return end
        return TOKEN_COST / price
    end

    ---@alias CompactVendorFrameMerchantButtonCostButtonCostType "Item"|"Money"

    ---@class CompactVendorFrameMerchantButtonCostButtonTemplate : Button, CompactVendorFrameAutoSizeTemplate
    ---@field public parent CompactVendorFrameMerchantButtonCostTemplate
    ---@field public costType? CompactVendorFrameMerchantButtonCostButtonCostType
    ---@field public link? string
    ---@field public price? number
    ---@field public Icon CompactVendorFrameMerchantIconTemplate

    CompactVendorFrameMerchantButtonCostButtonTemplate = {} ---@class CompactVendorFrameMerchantButtonCostButtonTemplate
    _G.CompactVendorFrameMerchantButtonCostButtonTemplate = CompactVendorFrameMerchantButtonCostButtonTemplate

    function CompactVendorFrameMerchantButtonCostButtonTemplate:OnLoad()
        self.parent = self:GetParent() ---@diagnostic disable-line: assign-type-mismatch
        self.costType = "Money"
        self.link = nil
        self.price = nil
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self:Hide()
    end

    function CompactVendorFrameMerchantButtonCostButtonTemplate:OnEnter()
        if self.costType == "Item" and self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        elseif self.costType == "Money" and self.price then
            local copperPerUnit = GetCopperPerUnit()
            if copperPerUnit then
                local realMoney = copperPerUnit * self.price ---@type string|number|nil
                if realMoney > PRICE_THRESHOLD then
                    realMoney = format(PRICE_FORMAT, realMoney)
                else
                    realMoney = nil
                end
                if realMoney then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(realMoney, 1, 1, 1, false)
                    GameTooltip:Show()
                end
            end
        end
    end

    function CompactVendorFrameMerchantButtonCostButtonTemplate:OnLeave()
        GameTooltip:Hide()
    end

    function CompactVendorFrameMerchantButtonCostButtonTemplate:OnClick()
        if not self.link then
            return
        end
        HandleModifiedItemClick(self.link)
    end

    function CompactVendorFrameMerchantButtonCostButtonTemplate:Reset()
        self:Hide()
        self:SetWidth(16)
        self.Icon:SetText()
    end

    ---@param costType CompactVendorFrameMerchantButtonCostButtonCostType
    ---@param canAfford boolean
    ---@param text string|number
    ---@param texture? number|string
    ---@param price? number
    ---@param link? string
    ---@param quality? number
    ---@param name? string
    function CompactVendorFrameMerchantButtonCostButtonTemplate:Update(costType, canAfford, text, texture, price, link, quality, name)
        self:Reset()
        if costType == "Item" then
            self.Icon:SetItemInfo(texture, quality, text)
        elseif costType == "Money" then
            self.Icon:SetText(text)
        end
        if canAfford then
            self.Icon.Texture:SetVertexColor(1, 1, 1)
        else
            self.Icon.Texture:SetVertexColor(1, 0, 0)
        end
        self.costType = costType
        self.link = link
        self.price = price
        self:Show()
        if costType == "Money" then
            self:SetWidth(max(16, self.Icon.Text:GetStringWidth() + (text:find("GoldIcon") and 6 or 0) + (text:find("SilverIcon") and 6 or 0) + (text:find("CopperIcon") and 6 or 0)))
        end
    end

    ---@param merchantItem MerchantItem
    ---@param costType CompactVendorFrameMerchantButtonCostButtonCostType
    ---@param pool CompactVendorFrameMerchantButtonCostTemplatePool
    ---@return boolean? success
    function CompactVendorFrameMerchantButtonCostButtonTemplate:Set(merchantItem, costType, pool)
        local cost = self
        if costType == "Item" then
            local count = merchantItem.extendedCostCount
            if count == 0 then
                return
            end
            for i = 1, count do
                local costItem = merchantItem.extendedCostItems[i]
                if costItem.texture then
                    if i ~= 1 then
                        cost = pool:Acquire() ---@diagnostic disable-line: cast-local-type
                        if not cost then
                            return false
                        end
                    end
                    local itemNumAvailable = CountAvailableItems(costItem.itemLink)
                    local canAfford = itemNumAvailable - costItem.count >= 0
                    local text = costItem.count > 1 and costItem.count or "" -- FormatLargeNumber(costItem.count)
                    cost:Update(costType, canAfford, text, costItem.texture, costItem.count, costItem.itemLink, costItem.quality,costItem.name)
                else
                    return false
                end
            end
            return true
        elseif costType == "Money" then
            if not merchantItem.price or merchantItem.price < 0 then
                return
            end
            local canAfford = GetMoney() - merchantItem.price >= 0
            local text = GetMoneyString(merchantItem.price, true, true, true, true)
            cost:Update(costType, canAfford, text, nil, merchantItem.price)
            return true
        end
        return false
    end

end

---@class CompactVendorFrameMerchantButtonCostTemplate
local CompactVendorFrameMerchantButtonCostTemplate do

    ---@class CompactVendorFrameMerchantButtonCostTemplate : Button, CompactVendorFrameAutoSizeTemplate
    ---@field public parent CompactVendorFrameMerchantButtonTemplate

    CompactVendorFrameMerchantButtonCostTemplate = {} ---@class CompactVendorFrameMerchantButtonCostTemplate
    _G.CompactVendorFrameMerchantButtonCostTemplate = CompactVendorFrameMerchantButtonCostTemplate

    function CompactVendorFrameMerchantButtonCostTemplate:OnLoad()
        self.parent = self:GetParent() ---@diagnostic disable-line: assign-type-mismatch
        self.Costs = {} ---@type CompactVendorFrameMerchantButtonCostButtonTemplate[]
        local prevCost ---@type CompactVendorFrameMerchantButtonCostButtonTemplate?
        for i = 1, 6 do -- hardcoded comfortable amount of frames
            ---@diagnostic disable-next-line: assign-type-mismatch
            local cost = CreateFrame("Button", nil, self, "CompactVendorFrameMerchantButtonCostButtonTemplate") ---@type CompactVendorFrameMerchantButtonCostButtonTemplate
            if prevCost then
                cost:SetPoint("RIGHT", prevCost, "LEFT", 0, 0)
            else
                cost:SetPoint("RIGHT", self, "RIGHT", 0, 0)
            end
            prevCost = cost
            self.Costs[i] = cost
        end
    end

    function CompactVendorFrameMerchantButtonCostTemplate:Update()
        ---@diagnostic disable-next-line: assign-type-mismatch
        local merchantItem = self.parent.merchantItem
        if not merchantItem then
            return
        end
        local pool ---@type CompactVendorFrameMerchantButtonCostTemplatePool?
        ---@param costType CompactVendorFrameMerchantButtonCostButtonCostType
        local function UpdateType(costType)
            if not pool then
                pool = self:CreateCostPool()
            end
            local cost = pool:Acquire()
            if cost then
                local success = cost:Set(merchantItem, costType, pool)
                if not success then
                    pool:Release(cost)
                end
            end
        end
        if merchantItem.extendedCost then
            UpdateType("Item")
        end
        if merchantItem.price and merchantItem.price > 0 then
            UpdateType("Money")
        end
        if not pool then
            self:Hide()
            return
        end
        pool:ResetUnused()
        self:Show()
        self:AutoSize()
    end

    ---@param pool CompactVendorFrameMerchantButtonCostButtonTemplate[]
    ---@return CompactVendorFrameMerchantButtonCostButtonTemplate? cost
    local function PoolAcquire(pool)
        local count = #pool
        if count < 1 then
            return
        end
        return table.remove(pool, count)
    end

    ---@param pool CompactVendorFrameMerchantButtonCostButtonTemplate[]
    ---@param cost CompactVendorFrameMerchantButtonCostButtonTemplate
    local function PoolRelease(pool, cost)
        table.insert(pool, cost)
    end

    ---@param pool CompactVendorFrameMerchantButtonCostButtonTemplate[]
    local function PoolResetUnused(pool)
        for _, cost in ipairs(pool) do
            cost:Reset()
        end
    end

    function CompactVendorFrameMerchantButtonCostTemplate:CreateCostPool()
        ---@class CompactVendorFrameMerchantButtonCostTemplatePool
        local pool = {
            parent = self,
            Acquire = PoolAcquire,
            Release = PoolRelease,
            ResetUnused = PoolResetUnused,
        }
        local index = 0
        for i = #self.Costs, 1, -1 do
            index = index + 1
            local cost = self.Costs[i]
            cost.Icon:SetText()
            cost:Hide()
            pool[index] = cost
        end
        return pool
    end

end

---@class CompactVendorFrameMerchantButtonTemplate
local CompactVendorFrameMerchantButtonTemplate do

    ---@class CompactVendorFrameMerchantButtonTemplate : Button
    ---@field public merchantItem? MerchantItem
    ---@field public backgroundColor? number[]
    ---@field public textColor? SimpleColor
    ---@field public hovering? boolean
    ---@field public Bg Texture
    ---@field public Name FontString
    ---@field public Icon CompactVendorFrameMerchantIconTemplate
    ---@field public Quantity CompactVendorFrameMerchantButtonQuantityTemplate
    ---@field public Cost CompactVendorFrameMerchantButtonCostTemplate

    CompactVendorFrameMerchantButtonTemplate = {} ---@class CompactVendorFrameMerchantButtonTemplate
    _G.CompactVendorFrameMerchantButtonTemplate = CompactVendorFrameMerchantButtonTemplate

    function CompactVendorFrameMerchantButtonTemplate:OnLoad()
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end

    function CompactVendorFrameMerchantButtonTemplate:OnShow()
        UpdateMerchantItemButton(self, self.merchantItem)
        self:UpdateTextSize()
    end

    function CompactVendorFrameMerchantButtonTemplate:OnHide()
        self.merchantItem = nil
    end

    function CompactVendorFrameMerchantButtonTemplate:OnEvent()
    end

    function CompactVendorFrameMerchantButtonTemplate:OnEnter()
        local merchantItem = self.merchantItem
        if not merchantItem then
            return
        end
        local index = merchantItem:GetIndex()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetMerchantItem(index)
        GameTooltip_ShowCompareItem()
        MerchantFrame.itemHover = index
        self.hovering = true
    end

    function CompactVendorFrameMerchantButtonTemplate:OnLeave()
        GameTooltip:Hide()
        ResetCursor()
        MerchantFrame.itemHover = nil
        self.hovering = false
    end

    function CompactVendorFrameMerchantButtonTemplate:OnUpdate()
        if not self.hovering then
            return
        end
        local merchantItem = self.merchantItem
        if not merchantItem then
            return
        end
        if self ~= GameTooltip:GetOwner() then
            return
        end
        if IsModifiedClick("DRESSUP") then
            ShowInspectCursor()
        elseif not merchantItem.canAfford then
            SetCursor("BUY_ERROR_CURSOR")
        else
            SetCursor("BUY_CURSOR")
        end
    end

    ---@param button string
    function CompactVendorFrameMerchantButtonTemplate:OnClick(button)
        local merchantItem = self.merchantItem
        if not merchantItem then
            return
        end
        local itemLink = merchantItem.itemLink
        if not itemLink then
            return
        end
        if HandleModifiedItemClick(itemLink) then
            return
        end
        if button == "LeftButton" then
            if IsModifiedClick("DRESSUP") then
                if DressUpItemLink(itemLink) then
                elseif DressUpBattlePetLink(itemLink) then
                elseif DressUpMountLink(itemLink) then
                end
            elseif IsModifiedClick("SHIFT") then
                if self.Quantity:IsShown() then
                    self.Quantity:Click()
                end
            end
        elseif button == "RightButton" then
            if IsModifiedClick("ALT") then
                self:Purchase(merchantItem.maxStackCount)
            else
                self:Purchase()
            end
        end
    end

    ---@param color number[]
    function CompactVendorFrameMerchantButtonTemplate:SetBackgroundColor(color)
        self.backgroundColor = color
        self.Bg:SetGradient("HORIZONTAL", { r = color[1], g = color[2], b = color[3], a = color[4] }, { r = color[5], g = color[6], b = color[7], a = color[8] })
    end

    ---@param color SimpleColor
    function CompactVendorFrameMerchantButtonTemplate:SetTextColor(color)
        self.textColor = color
        self.Name:SetTextColor(color.r, color.g, color.b)
    end

    ---@param quantity? number
    ---@param isCalledFromStackSplitFrame? boolean
    function CompactVendorFrameMerchantButtonTemplate:Purchase(quantity, isCalledFromStackSplitFrame)
        local merchantItem = self.merchantItem
        if not merchantItem then
            return
        end
        local index = merchantItem:GetIndex()
        local stackCount = merchantItem.stackCount or 1
        local maxStackCount = merchantItem.maxStackCount or 1
        quantity = quantity or stackCount
        local requiresConfirmation = not merchantItem:CanSkipConfirmation()
        local canBeRefunded = merchantItem:CanBeRefunded()
        if requiresConfirmation and (isCalledFromStackSplitFrame ~= true or not canBeRefunded) then
            self:SetID(index)
            self.showNonrefundablePrompt = not canBeRefunded
            self.count = quantity
            self.link = merchantItem.itemLink
            self.price = merchantItem.price and merchantItem.price > 0 and merchantItem.price or nil
            self.color = { merchantItem.qualityColor.r, merchantItem.qualityColor.g, merchantItem.qualityColor.b }
            self.name = merchantItem.name
            self.texture = merchantItem.texture
            MerchantFrame_ConfirmExtendedItemCost(self, quantity)
            if self.showNonrefundablePrompt then
                local _, frame = StaticPopup_Visible("CONFIRM_PURCHASE_NONREFUNDABLE_ITEM")
                if frame then
                    local textString = frame.text:GetText()
                    frame.text:SetFormattedText("%s\r\n%s", textString, "|cffFF0000Your purchase is not refundable.|r")
                end
            end
            return
        end
        if quantity > 1 and quantity ~= stackCount then
            local maxSize = max(stackCount, maxStackCount)
            local remaining = quantity
            repeat
                local maxCount = floor(remaining / maxSize)
                if maxCount > 0 then
                    BuyMerchantItem(index, maxSize)
                    remaining = remaining - maxSize
                else
                    BuyMerchantItem(index, remaining)
                    remaining = 0
                end
            until remaining < 1
            return
        end
        BuyMerchantItem(index, quantity)
    end

    function CompactVendorFrameMerchantButtonTemplate:UpdateTextSize()
        local fontObject, fontSize, _, defaultFontSize = GetListItemScaleFontObject()
        local costCountScale = fontSize/defaultFontSize
        self.Name:SetFontObject(fontObject) ---@diagnostic disable-line: param-type-mismatch
        for _, cost in pairs(self.Cost.Costs) do
            cost.Icon.Count:SetScale(costCountScale)
            cost.Icon.Text:SetScale(costCountScale)
        end
    end

end
