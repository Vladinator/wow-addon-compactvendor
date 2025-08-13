---@diagnostic disable: deprecated

local BagSearch_OnChar = BagSearch_OnChar ---@type fun(self: EditBox)
local BagSearch_OnTextChanged = BagSearch_OnTextChanged ---@type fun(self: EditBox)
local CreateDataProvider = CreateDataProvider ---@type fun()
local CreateFramePool = CreateFramePool ---@type FramePoolFunction
local CreateObjectPool = CreateObjectPool ---@type ObjectPoolFunction
local CreateScrollBoxListLinearView = CreateScrollBoxListLinearView ---@type fun(top?: number, bottom?: number, left?: number, right?: number, spacing?: number)
local DressUpBattlePetLink = DressUpBattlePetLink ---@type fun(itemLink: string): boolean
local DressUpItemLink = DressUpItemLink ---@type fun(itemLink: string): boolean
local DressUpMountLink = DressUpMountLink ---@type fun(itemLink: string): boolean
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem ---@type fun()
local GetBindingFromClick = GetBindingFromClick ---@type fun(key: string): string
local GetCurrencyInfo = GetCurrencyInfo ---@type fun(item: string|number): string?, number, string, number, number, number, boolean, number
local GetItemCount = GetItemCount or C_Item.GetItemCount ---@type fun(itemInfo: ItemInfo, includeBank?: boolean, includeUses?: boolean, includeReagentBank?: boolean, includeAccountBank?: boolean): count: number
local GetItemInfo = GetItemInfo or C_Item.GetItemInfo ---@type fun(itemInfo: ItemInfo): itemName: string, itemLink: string, itemQuality: Enum.ItemQuality, itemLevel: number, itemMinLevel: number, itemType: string, itemSubType: string, itemStackCount: number, itemEquipLoc: string, itemTexture: fileID, sellPrice: number, classID: number, subclassID: number, bindType: number, expansionID: number, setID: number?, isCraftingReagent: boolean
local GetItemInfoInstant = GetItemInfoInstant or C_Item.GetItemInfoInstant  ---@type fun(itemInfo: ItemInfo): itemID: number, itemType: string, itemSubType: string, itemEquipLoc: string, icon: fileID, classID: number, subClassID: number
-- local GetItemQualityColor = GetItemQualityColor or C_Item.GetItemQualityColor ---@type fun(quality: number): r: number, g: number, b: number, hex: string
local GetMerchantItemInfo = GetMerchantItemInfo or C_MerchantFrame.GetItemInfo ---@type fun(index: number): MerchantItemInfo|string|nil
local HandleModifiedItemClick = HandleModifiedItemClick ---@type fun(itemLink: string): boolean
local IsCosmeticItem = IsCosmeticItem or C_Item.IsCosmeticItem ---@type fun(item: string|number): boolean
local IsDressableItemByID = IsDressableItem or C_Item.IsDressableItemByID ---@type fun(item: string|number): boolean
local MerchantFrame_ConfirmExtendedItemCost = MerchantFrame_ConfirmExtendedItemCost ---@type fun(self: Region, quantity: number)
local PlayerHasToy = PlayerHasToy ---@type fun(item: string|number): boolean
local SearchBoxTemplate_OnLoad = SearchBoxTemplate_OnLoad ---@type fun(self: EditBox)
local SearchBoxTemplate_OnTextChanged = SearchBoxTemplate_OnTextChanged ---@type fun(self: EditBox)
local ShowInspectCursor = ShowInspectCursor ---@type fun()
local StaticPopup_Visible = StaticPopup_Visible ---@type fun(name: string): any, any
local CallbackRegistryMixin = CallbackRegistryMixin ---@class CallbackRegistryMixinPolyfill : CallbackRegistry, CallbackRegistryMixin
local MathUtil = MathUtil ---@type table<any, any>
local ScrollUtil = ScrollUtil ---@type table<any, any>
local MerchantBuyBackItem = MerchantBuyBackItem ---@type Button
local MerchantFrameInset = MerchantFrameInset ---@type Region
local MerchantItem11 = MerchantItem11 ---@type Button
local MerchantNextPageButton = MerchantNextPageButton ---@type Button
local MerchantPageText = MerchantPageText ---@type FontString
local MerchantPrevPageButton = MerchantPrevPageButton ---@type Button

local addonName, ---@type string CompactVendor
    ns = ... ---@class CompactVendorNS

local IS_TWW = select(4, GetBuildInfo()) >= 110000

local FrameUtil
do

    ---@class CompactVendorFrameUtil
    FrameUtil = {}
    ns.FrameUtil = FrameUtil

    ---@param self Frame
    ---@param events WowEvent[]
    function FrameUtil.RegisterFrameForEvents(self, events)
        for _, event in ipairs(events) do
            pcall(self.RegisterEvent, self, event)
        end
    end

    ---@param self Frame
    ---@param events WowEvent[]
    function FrameUtil.UnregisterFrameForEvents(self, events)
        for _, event in ipairs(events) do
            pcall(self.UnregisterEvent, self, event)
        end
    end

end

local CompactVendorDBDefaults ---@class CompactVendorDBDefaults
local ListItemScaleToFontObject
local GetListItemScaleFontObject
local GetIconShape do

    ---@class CompactVendorDBDefaults
    ---@field public ListItemScale number
    ---@field public IconShape IconShape

    ---@class CompactVendorDBDefaults
    CompactVendorDBDefaults = {
        ListItemScale = 13,
        IconShape = 1,
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

    ---@return string fontObject, number fontSize, boolean isExactSize, number defaultFontSize, boolean isDefaultFontObject
    function GetListItemScaleFontObject()
        local listItemScale = CompactVendorDB.ListItemScale
        listItemScale = floor(listItemScale + 0.5)
        if listItemScale < ListItemScaleToFontObject.minSize then
            return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, false, ListItemScaleFallbackFontSize, true
        elseif listItemScale == ListItemScaleFallbackFontSize then
            return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, true, ListItemScaleFallbackFontSize, true
        end
        for _, font in ipairs(ListItemScaleToFontObject) do
            local size, fontObject = font[1], font[2]
            if size == listItemScale then
                return fontObject, size, true, ListItemScaleFallbackFontSize, false
            elseif size > listItemScale then
                return fontObject, size, false, ListItemScaleFallbackFontSize, false
            end
        end
        return ListItemScaleFallbackFontObject, ListItemScaleFallbackFontSize, false, ListItemScaleFallbackFontSize, true
    end

    function GetIconShape()
        local shape = CompactVendorDB.IconShape ---@type IconShape?
        if type(shape) ~= "number" or shape < 0 or shape > 5 then
            shape = CompactVendorDBDefaults.IconShape
        end
        return shape
    end

end

local ItemQualityColorToHexColor
local ItemHexColorToQualityIndex
local ColorPreset
local BackgroundColorPreset
local ItemCraftedStars
local GetColorFromQuality
local GetQualityFromLink
local GetCraftedStarsFromLink
local GetItemIDFromLink
local GetInfoFromGUID
local GetMoneyString
local ConvertToPattern do

    ---@class SimpleColor
    ---@field public r number
    ---@field public g number
    ---@field public b number
    ---@field public hex string
    ---@field public name string

    ItemQualityColorToHexColor = {} ---@type table<number, SimpleColor>
    ItemHexColorToQualityIndex = {} ---@type table<string, number>
    ColorPreset = {} ---@type table<string|number, SimpleColor>

    local HardcodedQualityColors = {
        [0] = { r = 0.62, g = 0.62, b = 0.62, hex = "ff9d9d9d" },
        [1] = { r = 1.00, g = 1.00, b = 1.00, hex = "ffffffff" },
        [2] = { r = 0.12, g = 1.00, b = 0.00, hex = "ff1eff00" },
        [3] = { r = 0.00, g = 0.44, b = 0.87, hex = "ff0070dd" },
        [4] = { r = 0.64, g = 0.21, b = 0.93, hex = "ffa335ee" },
        [5] = { r = 1.00, g = 0.50, b = 0.00, hex = "ffff8000" },
        [6] = { r = 0.90, g = 0.80, b = 0.50, hex = "ffe6cc80" },
        [7] = { r = 0.00, g = 0.80, b = 1.00, hex = "ff00ccff" },
        [8] = { r = 0.00, g = 0.80, b = 1.00, hex = "ff00ccff" },
    }

    for i = 0, 8 do

        -- ---@type any, number, number, string
        -- local r, g, b, hex = GetItemQualityColor(i)

        -- if IS_TWW then
        --     local color = r ---@type ColorMixin
        --     r, g, b = color.r, color.g, color.b
        --     hex = color:GenerateHexColor()
        -- end

        local colorInfo = HardcodedQualityColors[i]
        local r, g, b, hex = colorInfo.r, colorInfo.g, colorInfo.b, colorInfo.hex

        ---@type SimpleColor
        local color = {
            r = r,
            g = g,
            b = b,
            hex = hex,
            name = _G[format("ITEM_QUALITY%d_DESC", i)],
        }

        ItemQualityColorToHexColor[i] = color
        ItemHexColorToQualityIndex[hex] = i
        ColorPreset[i] = color
        ColorPreset[hex] = color

    end

    ---@param key string
    ---@param hex string|SimpleColor
    ---@param r number?
    ---@param g number?
    ---@param b number?
    ---@return SimpleColor? color
    local function AppendColor(key, hex, r, g, b)

        local color ---@type SimpleColor?

        if type(hex) == "table" then

            color = hex
            hex = color.hex
            r = color.r or r
            g = color.g or g
            b = color.b or b
            color.name = color.name or key

        elseif type(hex) == "string" then

            color = {
                r = r, ---@diagnostic disable-line: assign-type-mismatch
                g = g, ---@diagnostic disable-line: assign-type-mismatch
                b = b, ---@diagnostic disable-line: assign-type-mismatch
                hex = hex,
                name = key,
            }

        end

        if not r or not g or not b then

            r = tonumber(hex:sub(3, 4), 16) ---@diagnostic disable-line: param-type-mismatch
            g = tonumber(hex:sub(5, 6), 16) ---@diagnostic disable-line: param-type-mismatch
            b = tonumber(hex:sub(7, 8), 16) ---@diagnostic disable-line: param-type-mismatch

            if r and g and b then

                r = r/255
                g = g/255
                b = b/255

                color.r = r
                color.g = g
                color.b = b

            end

        end

        if not color or not r or not g or not b then
            return
        end

        local index = #ItemQualityColorToHexColor + 1
        ItemQualityColorToHexColor[index] = color
        ItemHexColorToQualityIndex[key] = color ---@diagnostic disable-line: assign-type-mismatch
        ItemHexColorToQualityIndex[color.hex] = index
        ColorPreset[key] = color
        ColorPreset[index] = color
        ColorPreset[color.hex] = color
        return color

    end

    AppendColor("System", "ffffff00")
    AppendColor("Spell", "ff71d5ff")

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

    ---@class ItemCraftedStarsInfo
    ---@field public rank number
    ---@field public name string
    ---@field public markup string

    ---@type table<number, ItemCraftedStarsInfo>
    ItemCraftedStars = {}

    for i = 1, 5 do

        local name = format("Professions-ChatIcon-Quality-Tier%d", i)
        local info = C_Texture.GetAtlasInfo(name)

        if not info then
            break
        end

        local width = info.width
        local height = info.height
        local ratio = width/height

        ItemCraftedStars[i] = {
            rank = i,
            name = name,
            markup = CreateAtlasMarkup(name, ratio * 16, 16, info.leftTexCoord, info.topTexCoord),
        }

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
        local id = itemLink:match("|cnIQ(%d+):|")
        if id then return tonumber(id) end
        local hex = itemLink:match("|c([a-fA-F0-9]+)|")
        return hex and ItemHexColorToQualityIndex[hex]
    end

    ---@param itemLink string
    ---@return number rank, string markup
    function GetCraftedStarsFromLink(itemLink)
        for _, info in ipairs(ItemCraftedStars) do
            if itemLink:find(info.name, nil, true) then
                return info.rank, info.markup
            end
        end
        return 0, ""
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
        local colorBlind = C_CVar.GetCVarBool("colorblindMode") or ENABLE_COLORBLIND_MODE == "1"
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

    ns.ItemQualityColorToHexColor = ItemQualityColorToHexColor ---@type SimpleColor[]

end

local CanTransmogItem
local IsTransmogCollected do

    ---@type table<string, boolean?>
    local ignoreEquipLoc = {
        INVTYPE_NON_EQUIP = true,
        INVTYPE_NECK = true,
        INVTYPE_FINGER = true,
        INVTYPE_TRINKET = true,
        INVTYPE_BAG = true,
        INVTYPE_AMMO = true,
        INVTYPE_THROWN = true,
        INVTYPE_QUIVER = true,
        INVTYPE_RELIC = true,
    }

    ---@alias CompactVendorCanTransmogItem fun(itemLinkOrID: string|number): canTransmog: boolean?
    ---@alias CompactVendorIsTransmogCollected fun(itemLink: string): canCollect: boolean?, isCollected: boolean?

    ---@type CompactVendorCanTransmogItem
    local function DefaultCanTransmogItem(itemLinkOrID)
        if not itemLinkOrID then
            return
        end
        local type = type(itemLinkOrID)
        if type ~= "string" and type ~= "number" then
            return
        end
        if not C_Transmog then
            return
        end
        local _, _, _, itemEquipLoc = C_Item.GetItemInfoInstant(itemLinkOrID)
        if itemEquipLoc and ignoreEquipLoc[itemEquipLoc] then
            return
        end
        if not C_Transmog.CanTransmogItem(itemLinkOrID) then
            return false
        end
        return true
    end

    ---@type CompactVendorIsTransmogCollected
    local function DefaultIsTransmogCollected(itemLink)
        if type(itemLink) ~= "string" then
            return
        end
        if not C_Transmog or not C_TransmogCollection then
            return
        end
        if not CanTransmogItem(itemLink) then
            return false
        end
        local _, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
        if not sourceID and not C_TransmogCollection.PlayerHasTransmogByItemInfo then
            return false
        end
        if not sourceID then
            local isCollected = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink)
            return true, isCollected
        end
        local _, _, _, _, isCollected = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
        return true, isCollected
    end

    CanTransmogItem = DefaultCanTransmogItem
    IsTransmogCollected = DefaultIsTransmogCollected

    -- Support CanIMogIt when available as it does things a bit more accurately than the built-in API when used plainly as we do...
    if select(4, C_AddOns.GetAddOnInfo("CanIMogIt")) then

        local function isReady()
            return type(CanIMogIt) == "table" and type(CanIMogIt.IsTransmogable) == "function" and type(CanIMogIt.PlayerKnowsTransmog) == "function"
        end

        local function replaceAPI()

            ---@type CompactVendorCanTransmogItem
            function CanTransmogItem(itemLinkOrID)
                if not itemLinkOrID then
                    return
                end
                local success, canTransmog = pcall(CanIMogIt.IsTransmogable, CanIMogIt, itemLinkOrID)
                if not success then
                    return DefaultCanTransmogItem(itemLinkOrID)
                end
                return canTransmog
            end

            ---@type CompactVendorIsTransmogCollected
            function IsTransmogCollected(itemLink)
                if not itemLink then
                    return
                end
                if not CanTransmogItem(itemLink) then
                    return false
                end
                local success, isCollected = pcall(CanIMogIt.PlayerKnowsTransmog, CanIMogIt, itemLink)
                if not success then
                    return DefaultIsTransmogCollected(itemLink)
                end
                return true, isCollected
            end

        end

        if isReady() then
            replaceAPI()
        else
            local frame = CreateFrame("Frame")
            frame:RegisterEvent("ADDON_LOADED")
            frame:SetScript("OnEvent", function(self, event)
                if not isReady() then return end
                self:UnregisterEvent(event)
                replaceAPI()
            end)
        end

    end

    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        CanTransmogItem = function() end
        IsTransmogCollected = function() end
    end

end

local IsCosmeticBundleCollected do

    ---@param itemLink string
    ---@return boolean? canCollect, boolean? isCollected, number? numCollectedItems, number? numTotalItems
    function IsCosmeticBundleCollected(itemLink)
        if type(itemLink) ~= "string" then
            return
        end
        if not C_Transmog or not C_TransmogCollection then
            return
        end
        if CanTransmogItem(itemLink) or (IsCosmeticItem and IsCosmeticItem(itemLink)) then
            return
        end
        if not IsDressableItemByID(itemLink) then
            return false
        end
        if not C_Item.GetItemLearnTransmogSet then
            return false
        end
        local setID = C_Item.GetItemLearnTransmogSet(itemLink)
        if not setID then
            return false
        end
        local setItems = C_Transmog.GetAllSetAppearancesByID(setID)
        if not setItems then
            return false
        end
        local totalAvailable = #setItems
        local totalCollected = 0
        local slotCollected = {} ---@type table<number, boolean>
        for i = 1, totalAvailable do
            local setItem = setItems[i]
            local itemModifiedAppearanceID = setItem.itemModifiedAppearanceID
            local invSlot = setItem.invSlot
            local _, _, _, _, isCollected = C_TransmogCollection.GetAppearanceSourceInfo(itemModifiedAppearanceID)
            slotCollected[invSlot] = slotCollected[invSlot] or isCollected
            if isCollected then
                totalCollected = totalCollected + 1
            end
        end
        local numAvailable = 0
        local numCollected = 0
        for _, isCollected in pairs(slotCollected) do
            numAvailable = numAvailable + 1
            if isCollected then
                numCollected = numCollected + 1
            end
        end
        return true, numAvailable == numCollected, totalCollected, totalAvailable
    end

end

local CreateTooltipItem
local IsTooltipTextPending do

    ---@alias TooltipDataType Enum.TooltipDataType
    local TooltipDataType = Enum.TooltipDataType

    ---@alias TooltipDataLineType Enum.TooltipDataLineType
    local TooltipDataLineType = Enum.TooltipDataLineType

    ---@type table<TooltipDataLineType, true?>
    local TooltipDataLineTypeIsTextMap = {
        [TooltipDataLineType.None] = true,
        [TooltipDataLineType.RestrictedRaceClass] = true,
        [TooltipDataLineType.RestrictedFaction] = true,
        [TooltipDataLineType.RestrictedSkill] = true,
        [TooltipDataLineType.RestrictedPvPMedal] = true,
        [TooltipDataLineType.RestrictedReputation] = true,
        [TooltipDataLineType.RestrictedSpellKnown] = true,
        [TooltipDataLineType.RestrictedLevel] = true,
        -- [TooltipDataLineType.RestrictedArena] = true,
        -- [TooltipDataLineType.RestrictedBg] = true,
    }

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
    ---@field public type TooltipDataType
    ---@field public hyperlink? string
    ---@field public id? number
    ---@field public guid? string
    ---@field public healthGUID? string

    ---@class TooltipDataLineArgs : TooltipDataLine
    ---@field public type TooltipDataLineType
    ---@field public leftText string
    ---@field public leftColor TooltipSimpleColor
    ---@field public rightText? string
    ---@field public rightColor? TooltipSimpleColor
    ---@field public bonding? number
    ---@field public maxPrice? number
    ---@field public price? number
    ---@field public wrapText? boolean
    ---@field public tooltipID? number
    ---@field public tooltipType? TooltipDataType

    ---@class TooltipItemLine : TooltipDataLineArgs
    local TooltipItemLine = {}

    function TooltipItemLine:GetType()
        return self.type
    end

    function TooltipItemLine:IsTypeText()
        local type = self:GetType()
        return TooltipDataLineTypeIsTextMap[type]
    end

    function TooltipItemLine:IsTypePadding()
        return self:GetType() == TooltipDataLineType.Blank
    end

    function TooltipItemLine:IsTypePrice()
        return self:GetType() == TooltipDataLineType.SellPrice
    end

    function TooltipItemLine:IsTypeEmbed()
        return self:GetType() == TooltipDataLineType.NestedBlock
    end

    function TooltipItemLine:IsTypeBonding()
        return self:GetType() == TooltipDataLineType.ItemBinding
    end

    function TooltipItemLine:GetEmbedItemID()
        if not self:IsTypeEmbed() then
            return
        end
        if self.tooltipType ~= Enum.TooltipDataType.Item then
            return
        end
        return self.tooltipID
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

    ---@param tooltipData TooltipData
    ---@param hyperlinkOrIndex string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    function TooltipItem:OnLoad(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        for _, line in ipairs(tooltipData.lines) do
            Mixin(line, TooltipItemLine)
        end
        self.tooltipData = tooltipData ---@diagnostic disable-line: assign-type-mismatch
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

    ---@return TooltipDataType type
    function TooltipItem:GetType()
        return self.tooltipData.type
    end

    function TooltipItem:IsTypeItem()
        return self:GetType() == TooltipDataType.Item
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

    function TooltipItem:IsPendingEmbed()
        for _, line in ipairs(self.tooltipData.lines) do
            if line:IsTypeEmbed() then
                local embedItemID = line:GetEmbedItemID()
                if embedItemID then
                    local name = line:GetLeftText()
                    return IsTooltipTextPending(name)
                end
            end
        end
        return false
    end

    function TooltipItem:IsPending()
        local name = self:GetName()
        local isPending = IsTooltipTextPending(name)
        return isPending -- or self:IsPendingEmbed()
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
        RenownAndExtra = 9,
    }

    ns.ItemRequirementType = ItemRequirementType

    ---@class ItemRequirementInfo
    ---@field public raw string
    ---@field public type ItemRequirementType
    ---@field public isRed? boolean
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

    ---@type { [1]: string, [2]: ItemRequirementType, [3]: string, [4]: string }[]
    local ItemRequirements = {
        { "Requires %s and Renown Rank %d with the %s.", ItemRequirementType.RenownAndExtra, "requires", "rank", "renown" }, -- TODO: localization
        { "Requires Renown Rank %d with the %s and to primarily wear %s.", ItemRequirementType.RenownAndExtra, "rank", "renown", "requires" }, -- TODO: localization
        { "Requires Renown Rank %d with the %s by a character on this account.", ItemRequirementType.Renown, "rank", "renown" }, -- TODO: localization
        { "Requires Renown Rank %d with the %s.", ItemRequirementType.Renown, "rank", "renown" }, -- TODO: localization
        { ITEM_REQ_ARENA_RATING, ItemRequirementType.Rating, "rating" },
        { ITEM_REQ_PURCHASE_ACHIEVEMENT, ItemRequirementType.Achievement, "achievement" },
        { ITEM_REQ_PURCHASE_GUILD, ItemRequirementType.Guild, "guild" },
        { ITEM_REQ_PURCHASE_GUILD_LEVEL, ItemRequirementType.Guild, "guild", "level" },
        { ITEM_REQ_REPUTATION, ItemRequirementType.Reputation, "reputation", "rank" },
        { ITEM_MIN_SKILL, ItemRequirementType.Profession, "requires", "amount" },
        { ITEM_MIN_LEVEL, ItemRequirementType.Level, "level" },
        { ITEM_REQ_SPECIALIZATION, ItemRequirementType.Specialization, "specialization" },
        { ITEM_REQ_SKILL, ItemRequirementType.Profession, "requires" },
    }

    for _, requirement in ipairs(ItemRequirements) do
        requirement[1] = format("^%s$", ConvertToPattern(requirement[1]))
    end

    ---@param text string
    ---@return ItemRequirementInfo? requirementInfo
    local function GetItemRequirementInfo(text)
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

    ---@param requirementsInfo? ItemRequirementInfo[]
    ---@param hyperlink? string
    local function AppendPlayerLevelRequirement(requirementsInfo, hyperlink)
        if not hyperlink then
            return requirementsInfo
        end
        local found = false
        if requirementsInfo then
            for _, requirementInfo in ipairs(requirementsInfo) do
                if requirementInfo.type == ItemRequirementType.Level then
                    found = true
                    break
                end
            end
        end
        if found then
            return requirementsInfo
        end
        local _, _, _, _, itemMinLevel = C_Item.GetItemInfo(hyperlink)
        if not itemMinLevel or itemMinLevel < 2 then
            return requirementsInfo
        end
        if not requirementsInfo then
            requirementsInfo = {}
        end
        requirementsInfo[#requirementsInfo + 1] = {
            type = ItemRequirementType.Level,
            raw = format(ITEM_MIN_LEVEL, itemMinLevel),
            level = itemMinLevel,
        }
        return requirementsInfo
    end

    ---@param requirementsInfo? ItemRequirementInfo[]
    local function CleanupClutterRequirements(requirementsInfo)
        if not requirementsInfo then
            return
        end
        local playerLevel = UnitLevel("player") or 1
        local temp ---@type ItemRequirementInfo[]?
        local index = 0
        for _, requirementInfo in ipairs(requirementsInfo) do
            local add = true
            local infoType = requirementInfo.type
            if infoType == ItemRequirementType.Level then
                local reqLevel = tonumber(requirementInfo.level) or 0
                if playerLevel >= reqLevel then
                    add = false
                end
            end
            if add then
                if not temp then
                    temp = {}
                end
                index = index + 1
                temp[index] = requirementInfo
            end
        end
        return temp
    end

    ---@return boolean hasRedRequirements, ItemRequirementInfo[]? requirementsInfo
    function TooltipItem:HasRequirements()
        local hasRedRequirements = false
        local requirementsInfo ---@type ItemRequirementInfo[]?
        local index = 0
        local lines = self.tooltipData.lines
        for i = #lines, 2, -1 do
            local line = lines[i]
            if line:IsTypeText() then
                local text = line:GetLeftText()
                local requirementInfo = GetItemRequirementInfo(text)
                if requirementInfo then
                    local color = line:GetLeftColor()
                    if color then
                        local isRed = ColorIsRed(color)
                        requirementInfo.isRed = isRed
                        if isRed then
                            hasRedRequirements = true
                        end
                    end
                    if not requirementsInfo then
                        requirementsInfo = {}
                    end
                    index = index + 1
                    requirementsInfo[index] = requirementInfo
                elseif requirementsInfo then
                    break
                end
            end
        end
        requirementsInfo = AppendPlayerLevelRequirement(requirementsInfo, self.hyperlink)
        requirementsInfo = CleanupClutterRequirements(requirementsInfo)
        return hasRedRequirements, requirementsInfo
    end

    ---@return boolean? isLearned
    function TooltipItem:IsLearned()
        local lines = self.tooltipData.lines
        for i = #lines, 2, -1 do
            local line = lines[i]
            if line:IsTypeText() then
                local text = line:GetLeftText()
                if text == ITEM_SPELL_KNOWN or text == ERR_COSMETIC_KNOWN then
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
        local lines = self.tooltipData.lines
        for i = #lines, 2, -1 do
            local line = lines[i]
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

    ---@param tooltipData TooltipData
    ---@param hyperlinkOrIndex string|number
    ---@param optionalArg1? number
    ---@param optionalArg2? number
    ---@param hideVendorPrice? boolean
    ---@return TooltipItem itemData
    function CreateTooltipItem(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        local itemData = Mixin({}, TooltipItem) ---@type TooltipItem
        itemData:OnLoad(tooltipData, hyperlinkOrIndex, optionalArg1, optionalArg2, hideVendorPrice)
        return itemData
    end

end

--[[ TODO: not stable on classic clients right now (commenting out this block will disable tooltip scanning behavior - unless `C_TooltipInfo` exists in the global environment)
local C_TooltipInfo do

    C_TooltipInfo = _G.C_TooltipInfo

    local function noop() end

    if not C_TooltipInfo then
        C_TooltipInfo = setmetatable({}, {
            __index = function(self, k)
                return noop
            end,
        })
    end

    ---@type BackupTooltipScanner?
    local BackupTooltipScanner

    local createBackup = C_TooltipInfo.GetHyperlink == noop or C_TooltipInfo.GetMerchantItem == noop

    if createBackup then

        local tooltip = CreateFrame("GameTooltip", "CompactVendorBackupTooltipScanner", UIParent, "GameTooltipTemplate")
        tooltip:Hide()

        ---@class BackupTooltipScanner
        BackupTooltipScanner = {}

        ---@param hyperlink string
        function BackupTooltipScanner:SetHyperlink(hyperlink)
            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
            tooltip:SetHyperlink(hyperlink)
            tooltip:Show()
        end

        function BackupTooltipScanner:ClearHyperlink()
            tooltip:Hide()
        end

        ---@return TooltipDataLine[]
        function BackupTooltipScanner:GetLines()
            local lines = {} ---@type TooltipDataLine[]
            local name = tooltip:GetName()
            for i = 1, tooltip:NumLines() do
                local left = _G[format("%sTextLeft%d", name, i)] ---@type FontString
                local right = _G[format("%sTextRight%d", name, i)] ---@type FontString
                local leftText = left:GetText()
                local leftColor = CreateColor(left:GetTextColor())
                local rightText = right:GetText()
                local rightColor = CreateColor(right:GetTextColor())
                lines[#lines + 1] = {
                    type = Enum.TooltipDataLineType.None,
                    wrapText = false,
                    leftText = leftText,
                    leftColor = leftColor,
                    rightText = rightText,
                    rightColor = rightColor,
                }
            end
            return lines
        end

        ---@param hyperlink string
        ---@return TooltipData tooltipData
        function BackupTooltipScanner:ScanHyperlink(hyperlink)
            self:SetHyperlink(hyperlink)
            ---@type TooltipData
            local tooltipData = {
                -- type = Enum.TooltipDataType.Item,
                lines = self:GetLines(),
                dataInstanceID = 0,
            }
            self:ClearHyperlink()
            return tooltipData
        end

    end

    if BackupTooltipScanner  then

        if C_TooltipInfo.GetHyperlink == noop then
            ---@param hyperlink string
            ---@param optionalArg1? number
            ---@param optionalArg2? number
            ---@param hideVendorPrice? boolean
            ---@return TooltipData tooltipData
            ---@diagnostic disable-next-line: duplicate-set-field
            function C_TooltipInfo.GetHyperlink(hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
                return BackupTooltipScanner:ScanHyperlink(hyperlink)
            end
        end

        if C_TooltipInfo.GetMerchantItem == noop then
            ---@param merchantItemIndex number
            ---@return TooltipData tooltipData
            ---@diagnostic disable-next-line: duplicate-set-field
            function C_TooltipInfo.GetMerchantItem(merchantItemIndex)
                local hyperlink = GetMerchantItemLink(merchantItemIndex)
                return BackupTooltipScanner:ScanHyperlink(hyperlink)
            end
        end

    end

end
--]]

local GetSanitizedHyperlinkForItemQuery
local TooltipScannerState
local TooltipScannerStateIsPending
local TooltipScanner do

	---@class TooltipScanEventFrame : Frame
	local eventFrame = CreateFrame("Frame")
	eventFrame.scanObjects = {} ---@type table<TooltipScanObjectMixin, true?>
	eventFrame:RegisterEvent("TOOLTIP_DATA_UPDATE")
	eventFrame:SetScript("OnEvent", function(_, ...)
		for tooltip, _ in pairs(eventFrame.scanObjects) do
			tooltip:OnEvent(...)
		end
	end)

    ---@alias TooltipDataHandlerTooltipInfoGetterName string|"GetHyperlink"|"GetMerchantItem"

    ---@alias TooltipDataHandlerTooltipInfoGetterArgs table

	---@class TooltipDataHandlerTooltipInfo
	---@field public tooltipData? TooltipData If provided, the getters are ignored, otherwise provide the getter fields if tooltipData is missing.
	---@field public getterName? TooltipDataHandlerTooltipInfoGetterName The method name like `GetHyperlink` which then gets used like `C_TooltipInfo.GetHyperlink()`.
	---@field public getterArgs? TooltipDataHandlerTooltipInfoGetterArgs The method arguments which gets unpacked when the getter method is called.
	---@field public append? boolean If true, the tooltip will not be cleared and the backdrop style (Azerite and Corrupted) will not be set.
	---@field public excludeLines? Enum.TooltipDataLineType[] Table of line types to exclude from the tooltip.
	---@field public tooltipPostCall? fun(self: TooltipScanObjectMixin) Callback for the tooltip after it has processed the info.
	---@field public rebuildPreCall? fun(self: TooltipScanObjectMixin): boolean? Callback before the tooltip is rebuilt from a TOOLTIP_DATA_UPDATE. Only checked for primary info in the case of multiple.
	---@field public rebuildPostCall? fun(self: TooltipScanObjectMixin) Callback after the tooltip is rebuilt from a TOOLTIP_DATA_UPDATE. Only checked for primary info in the case of multiple.

	---@class TooltipScanObjectMixin
	---@field public infoList? TooltipDataHandlerTooltipInfo[]
	---@field public processingInfo? TooltipDataHandlerTooltipInfo

	---@class TooltipScanObjectMixin
	local TooltipScanObjectMixin = {}

	function TooltipScanObjectMixin:OnLoad()
		eventFrame.scanObjects[self] = true
	end

	---@param event WowEvent
	function TooltipScanObjectMixin:OnEvent(event, ...)
		if event == "TOOLTIP_DATA_UPDATE" then
			local dataInstanceID = ... ---@type number?
			if not dataInstanceID or self:HasDataInstanceID(dataInstanceID) then
				self:RebuildFromTooltipInfo()
			end
		end
	end

	function TooltipScanObjectMixin:IsTooltipDataLoaded()
		local tooltipData = self:GetTooltipData()
		if not tooltipData then
			return false
		end
		local lines = tooltipData.lines
		if #lines == 0 then
			return false
		end
		for _, line in ipairs(lines) do
			if line.leftText == RETRIEVING_ITEM_INFO then
				return false
			end
		end
		return true
	end

    ---@param callback fun(tooltipData: TooltipData, tooltip: TooltipScanObjectMixin)
    ---@param getterName TooltipDataHandlerTooltipInfoGetterName
    ---@param ... any
    function TooltipScanObjectMixin:Scan(callback, getterName, ...)
		local done = false
		local function postCallback()
			if done then
				return
			end
			if not self:IsTooltipDataLoaded() then
				return
			end
			done = true
			local tooltipData = self:GetTooltipData()
			callback(tooltipData, self) ---@diagnostic disable-line: param-type-mismatch
		end
		---@type TooltipDataHandlerTooltipInfo
		local processInfo = {
			getterName = getterName,
			getterArgs = { ... },
			tooltipPostCall = postCallback,
			rebuildPostCall = postCallback,
		}
		return self:ProcessInfo(processInfo)
    end

	---@param callback fun(tooltipData: TooltipData, tooltip: TooltipScanObjectMixin)
	---@param hyperlink string
	---@param optionalArg1? number
	---@param optionalArg2? number
	---@param hideVendorPrice? boolean
	---@return boolean accepted
	function TooltipScanObjectMixin:ScanHyperlink(callback, hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
        return self:Scan(callback, "GetHyperlink", hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
	end

	---@param callback fun(tooltipData: TooltipData, tooltip: TooltipScanObjectMixin)
	---@param merchantItemIndex number
	---@return boolean accepted
	function TooltipScanObjectMixin:ScanMerchantItem(callback, merchantItemIndex)
		return self:Scan(callback, "GetMerchantItem", merchantItemIndex)
	end

	---@return TooltipDataHandlerTooltipInfo? tooltipInfo
	function TooltipScanObjectMixin:GetTooltipInfo()
		return self.infoList and self.infoList[1]
	end

	---@return TooltipData? tooltipData
	function TooltipScanObjectMixin:GetTooltipData()
		local tooltipInfo = self:GetTooltipInfo()
		return tooltipInfo and tooltipInfo.tooltipData
	end

	function TooltipScanObjectMixin:ResetTooltip()
		self.infoList = nil
		self.processingInfo = nil
	end

	---@param info TooltipDataHandlerTooltipInfo
	function TooltipScanObjectMixin:ProcessInfo(info)
		if not info then
			return false
		end
		if not info.tooltipData then
            local getterName = info.getterName
			if not getterName then
				return false
			end
            local func = type(C_TooltipInfo) == "table" and C_TooltipInfo[getterName] or nil ---@type (fun(...): TooltipData?)?
            if not func then
                return false
            end
			if info.getterArgs then
				info.tooltipData = func(unpack(info.getterArgs))
			else
				info.tooltipData = func()
			end
		end
		local tooltipData = info.tooltipData
		if not tooltipData then
			return false
		end
		if not info.append then
			self.infoList = {}
		elseif not self.infoList then
			self.infoList = {}
		end
		self.infoList[#self.infoList + 1] = info
		self.processingInfo = info
		if self.processingInfo.tooltipPostCall then
			self.processingInfo.tooltipPostCall(self)
		end
		return true
	end

	function TooltipScanObjectMixin:RebuildFromTooltipInfo()
		local oldTooltipInfo = self:GetTooltipInfo()
		if not oldTooltipInfo then
			return
		end
		local infoList = self.infoList
		self.infoList = {}
		if oldTooltipInfo.rebuildPreCall then
			local skipRebuild = oldTooltipInfo.rebuildPreCall(self)
			if skipRebuild then
				return
			end
		end
        if infoList then
            for index, tooltipInfo in ipairs(infoList) do
                if tooltipInfo.getterName then
                    tooltipInfo.tooltipData = nil
                end
                if index == 1 then
                    tooltipInfo.append = false
                end
                self:ProcessInfo(tooltipInfo)
            end
        end
		if oldTooltipInfo.rebuildPostCall then
			oldTooltipInfo.rebuildPostCall(self)
		end
	end

	---@param dataInstanceID number
	function TooltipScanObjectMixin:HasDataInstanceID(dataInstanceID)
		if not self.infoList then
			return false
		end
		for _, tooltipInfo in ipairs(self.infoList) do
			if tooltipInfo.tooltipData and tooltipInfo.tooltipData.dataInstanceID == dataInstanceID then
				return true
			end
		end
		return false
	end

	---@class TooltipScanPoolMixin
	---@field public Acquire fun(self): TooltipScanObjectMixin
	---@field public Release fun(self, tooltip: TooltipScanObjectMixin)
	---@field public ReleaseAll fun(self)
	---@field public EnumerateActive fun(self): fun(): TooltipScanObjectMixin
	---@field public EnumerateInactive fun(self): fun(): TooltipScanObjectMixin
	---@field public GetNextActive fun(self, tooltip: TooltipScanObjectMixin): TooltipScanObjectMixin?
	---@field public GetNextInactive fun(self, current: TooltipScanObjectMixin): TooltipScanObjectMixin?
	---@field public IsActive fun(self, tooltip: TooltipScanObjectMixin): boolean
	---@field public GetNumActive fun(self): number
	---@field public SetResetDisallowedIfNew fun(self, state: boolean)

	---@type fun(creationFunc: (fun(pool: TooltipScanPoolMixin): TooltipScanObjectMixin), resetterFunc?: fun(pool: TooltipScanPoolMixin, object: TooltipScanObjectMixin)): TooltipScanPoolMixin
	local CreateTooltipPool = CreateObjectPool

	---@class TooltipScanPool : TooltipScanPoolMixin
	local TooltipScanPool = CreateTooltipPool(
		function(_)
			local tooltip = Mixin({}, TooltipScanObjectMixin)
			tooltip:OnLoad()
			return tooltip
		end,
		function(_, tooltip)
			tooltip:ResetTooltip()
		end
	)

	---@param hyperlink? string
	function TooltipScanPool:CanScanHyperlink(hyperlink)
		if type(hyperlink) ~= "string" then
			return false
		end
		if not hyperlink:find("|H[^:0-9]+:%d+") then
			return false
		end
		return true
	end

    ---@param query number|string
    ---@return string hyperlink
    function TooltipScanPool:GetSanitizedHyperlinkForItemQuery(query)
        if type(query) == "number" then
            return format("|cffffffff|Hitem:%d::::::::::::::::::|h[]|h|r", query)
        end
        ---@type string, string
        local id, params = query:match("item:(%d+):(.-)|h")
        return format("|cffffffff|Hitem:%s:%s|h[]|h|r", id, params)
    end

	---@param callback fun(tooltipData: TooltipData)
	---@param hyperlink string
	---@param optionalArg1? number
	---@param optionalArg2? number
	---@param hideVendorPrice? boolean
	---@return boolean accepted
	function TooltipScanPool:ScanHyperlink(callback, hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
		local tooltip = self:Acquire()
		return tooltip:ScanHyperlink(
			function(tooltipData)
				self:Release(tooltip)
				callback(tooltipData)
			end,
			hyperlink, optionalArg1, optionalArg2, hideVendorPrice
		)
	end

	---@param callback fun(tooltipData: TooltipData)
	---@param merchantItemIndex number
	---@return boolean accepted
	function TooltipScanPool:ScanMerchantItem(callback, merchantItemIndex)
		local tooltip = self:Acquire()
		return tooltip:ScanMerchantItem(
			function(tooltipData)
				self:Release(tooltip)
				callback(tooltipData)
			end,
			merchantItemIndex
		)
	end

    ---@return string guid
    function TooltipScanPool:CreateGUID(...)
        return table.concat({tostringall(...)}, "\1")
    end

    ---@alias TooltipScanPoolHyperlinkCallback fun(isInstant: boolean, hyperlink: string, tooltipData: TooltipData)

    ---@alias TooltipScanPoolMerchantCallback fun(isInstant: boolean, merchantItemIndex: number, tooltipData: TooltipData)

    ---@alias TooltipScanPoolCallback TooltipScanPoolHyperlinkCallback|TooltipScanPoolMerchantCallback

    ---@alias TooltipScanPoolCache { tooltipData: TooltipData?, callbacks: table<TooltipScanPoolCallback, true?> }

    ---@type table<string, TooltipScanPoolCache>
    TooltipScanPool.cache = {}

    function TooltipScanPool:ClearCache()
        table.wipe(self.cache)
    end

    ---@param guid string
    ---@param callback TooltipScanPoolCallback
    ---@return TooltipScanPoolCache cache, boolean cacheExisted
    function TooltipScanPool:GetCache(guid, callback)
        local cache = self.cache[guid]
        if cache then
            cache.callbacks[callback] = true
            return cache, true
        end
        cache = { tooltipData = nil, callbacks = { [callback] = true } }
        self.cache[guid] = cache
        return cache, false
    end

    ---@param cache TooltipScanPoolCache
    ---@param isInstant boolean
    ---@param query string|number
    ---@param tooltipData TooltipData
    function TooltipScanPool:ProcessCallbacks(cache, isInstant, query, tooltipData)
        for callback, _ in pairs(cache.callbacks) do
            callback(isInstant, query, tooltipData)
        end
        table.wipe(cache.callbacks)
    end

    ---@param cache TooltipScanPoolCache
    ---@param isInstant boolean
    ---@param query string|number
    function TooltipScanPool:ProcessCache(cache, isInstant, query)
        local tooltipData = cache.tooltipData
        if not tooltipData then
            return
        end
        self:ProcessCallbacks(cache, isInstant, query, tooltipData)
    end

	---@param callback TooltipScanPoolHyperlinkCallback
	---@param hyperlink string
	---@param optionalArg1? number
	---@param optionalArg2? number
	---@param hideVendorPrice? boolean
	---@return boolean accepted
    function TooltipScanPool:ScanHyperlinkCached(callback, hyperlink, optionalArg1, optionalArg2, hideVendorPrice)
        if not self:CanScanHyperlink(hyperlink) then
            return false
        end
        local guid = self:CreateGUID("hyperlink", hyperlink, optionalArg1 or "", optionalArg2 or "", hideVendorPrice or false)
        local cache, cacheExisted = self:GetCache(guid, callback)
        if cacheExisted then
            self:ProcessCache(cache, true, hyperlink)
            return true
        end
        return self:ScanHyperlink(
            function(tooltipData)
                cache.tooltipData = tooltipData
                self:ProcessCache(cache, false, hyperlink)
            end,
            hyperlink, optionalArg1, optionalArg2, hideVendorPrice
        )
    end

	---@param callback TooltipScanPoolMerchantCallback
	---@param merchantItemIndex number
	---@return boolean accepted
    function TooltipScanPool:ScanMerchantItemCached(callback, merchantItemIndex)
        local hyperlink = GetMerchantItemLink(merchantItemIndex)
        if not self:CanScanHyperlink(hyperlink) then
            return false
        end
        local guid = self:CreateGUID("merchantItemIndex", merchantItemIndex)
        local cache, cacheExisted = self:GetCache(guid, callback)
        if cacheExisted then
            self:ProcessCache(cache, true, merchantItemIndex)
            return true
        end
        return self:ScanMerchantItem(
            function(tooltipData)
                cache.tooltipData = tooltipData
                self:ProcessCache(cache, false, merchantItemIndex)
            end,
            merchantItemIndex
        )
    end

    ---@param hyperlink string
    function GetSanitizedHyperlinkForItemQuery(hyperlink)
        return TooltipScanPool:GetSanitizedHyperlinkForItemQuery(hyperlink)
    end

    ---@enum TooltipScannerState
    TooltipScannerState = {
        Queued = 1,
        Declined = 2,
        Pending = 3,
        Done = 4,
    }

    ---@param state? TooltipScannerState
    function TooltipScannerStateIsPending(state)
        return state == TooltipScannerState.Queued or state == TooltipScannerState.Pending
    end

    ---@class TooltipScanner
    TooltipScanner = {}

    -- TODO: "merchant" seem to return results too early (the tooltip loads, but additional merchant requirements do not load in time) so using the hyperlink approach for now (there is also the issue of localization when using merchant tooltips...)
    ---@type "hyperlink"|"merchant"
    TooltipScanner.UseTooltipType = "hyperlink"

    function TooltipScanner:IsSupported()
        if type(C_TooltipInfo) ~= "table" then
            return false
        end
        if TooltipScanner.UseTooltipType == "merchant" then
            return type(C_TooltipInfo.GetMerchantItem) == "function"
        end
        return type(C_TooltipInfo.GetHyperlink) == "function"
    end

    function TooltipScanner:ClearCache()
        TooltipScanPool:ClearCache()
    end

    ---@param merchantItem MerchantItem
    function TooltipScanner:ScanMerchantItem(merchantItem)
        if merchantItem.tooltipScannerState then
            return
        end
        local scanMerchantTooltip = self.UseTooltipType == "merchant"
        local tooltipScannerID = scanMerchantTooltip and merchantItem.index or GetSanitizedHyperlinkForItemQuery(merchantItem.itemLink)
        if merchantItem.tooltipScannerID ~= tooltipScannerID then
            merchantItem:ResetTooltipData()
        end
        merchantItem.tooltipScannerID = tooltipScannerID
        merchantItem.tooltipScannerState = TooltipScannerState.Queued
        local parent = merchantItem.parent
        ---@param scannerID string|number
        local function getMerchantItem(scannerID)
            if scanMerchantTooltip then
                return parent:GetMerchantItemByMerchantIndex(scannerID)
            end
            return parent:GetMerchantItemByItemLink(scannerID)
        end
        ---@param isInstant boolean
        ---@param scannerID string|number
        ---@param tooltipData TooltipData
        local function callback(isInstant, scannerID, tooltipData)
            local targetMerchantItem = merchantItem
            if targetMerchantItem.tooltipScannerID ~= scannerID then
                targetMerchantItem = getMerchantItem(scannerID)
            end
            if not targetMerchantItem then
                return
            end
            targetMerchantItem.tooltipScannerState = TooltipScannerState.Pending
            targetMerchantItem:OnTooltipScanResponse(isInstant, tooltipData)
        end
        local isAccepted ---@type boolean
        if scanMerchantTooltip then
            isAccepted = TooltipScanPool:ScanMerchantItemCached(callback, tooltipScannerID)
        else
            isAccepted = TooltipScanPool:ScanHyperlinkCached(callback, tooltipScannerID)
        end
        if not isAccepted then
            merchantItem.tooltipScannerState = TooltipScannerState.Declined
            return
        end
        if merchantItem.tooltipScannerState == TooltipScannerState.Queued then
            merchantItem.tooltipScannerState = TooltipScannerState.Pending
        end
    end

end

local CreateMerchantItem
local CreateMerchantItemButton
local ResetMerchantItemButton
local UpdateMerchantItemButton
local RefreshAndUpdateMerchantItemButton do

    ---@enum MerchantItemCostType
    local MerchantItemCostType = {
        Gold = 1,
        Currency = 2,
        GoldAndCurrency = 3,
        Free = 4,
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
        if not CurrencyContainerUtil or not CurrencyContainerUtil.GetCurrencyContainerInfo then
            return name, texture, numAvailable, quality
        end
        return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality)
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
    ---@field public parentButton? CompactVendorFrameMerchantButtonTemplate
    ---@field public index number
    ---@field public name? string
    ---@field public texture number|string
    ---@field public price number
    ---@field public stackCount number
    ---@field public numAvailable number
    ---@field public isPurchasable boolean
    ---@field public isUsable boolean
    ---@field public extendedCost? boolean
    ---@field public currencyID? number
    ---@field public spellID? number
    ---@field public canAfford boolean
    ---@field public costType MerchantItemCostType
    ---@field public itemLink? string
    ---@field public merchantItemID number Note that both `merchantItemID` and `itemID` should be identical. The `merchantItemID` is primarily used to do things with the itemID (instead of the `itemLink`).
    ---@field public itemLinkOrID? string|number
    ---@field public isHeirloom boolean
    ---@field public isKnownHeirloom boolean
    ---@field public showNonrefundablePrompt boolean
    ---@field public tintRed boolean
    ---@field public availabilityType MerchantItemAvailabilityType
    ---@field public extendedCostCount number
    ---@field public extendedCostItems MerchantItemCostItem[]
    ---@field public quality? number
    ---@field public itemID number Note that both `merchantItemID` and `itemID` should be identical. The `merchantItemID` is primarily used to do things with the itemID (instead of the `itemLink`).
    ---@field public itemType string
    ---@field public itemSubType string
    ---@field public itemEquipLoc string
    ---@field public itemTexture number|string
    ---@field public itemClassID number
    ---@field public itemSubClassID number
    ---@field public maxStackCount? number
    ---@field public isTransmog? boolean
    ---@field public isTransmogCollectable? boolean
    ---@field public isTransmogCollected? boolean
    ---@field public isCosmetic? boolean
    ---@field public isCosmeticBundle? boolean
    ---@field public isCosmeticBundleCollected? boolean
    ---@field public isCosmeticBundleNum? number
    ---@field public isCosmeticBundleNumMax? number
    ---@field public isToy? boolean
    ---@field public isToyCollected? boolean
    ---@field public isLearnable? boolean
    ---@field public tooltipRequirementsScannable? boolean
    ---@field public tooltipScannable? boolean
    ---@field public tooltipScannerState? TooltipScannerState
    ---@field public tooltipScannerID? string|number
    ---@field public tooltipData? TooltipItem
    ---@field public hasRedRequirements? boolean
    ---@field public hasRequirementsInfo? ItemRequirementInfo[]
    ---@field public isLearned? boolean
    ---@field public isCollected? boolean
    ---@field public isCollectedNum? number
    ---@field public isCollectedNumMax? number
    ---@field public craftedStars? number
    ---@field public craftedStarsMarkup? string

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
    function MerchantItem:OnLoad(parent)
        self.parent = parent
        self.index = 0
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
        self.index = 0
        self.qualityColor = nil
        self.tooltipData = nil
        self.hasRequirementsInfo = nil
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
        if self.tooltipScannable and TooltipScannerStateIsPending(self.tooltipScannerState) then
            return true
        end
        return false
    end

    function MerchantItem:HasLimitedAvailability()
        return self.numAvailable and self.numAvailable > 0
    end

    ---@return string? name, number|string texture, number price, number stackCount, number numAvailable, boolean isPurchasable, boolean isUsable, boolean? hasExtendedCost, number? currencyID, number? spellID
    function MerchantItem:GetMerchantItemInfo()
        local index, hasIndex = self:GetIndex()
        if not hasIndex then
            return ---@diagnostic disable-line: missing-return-value
        end
        local temp = {GetMerchantItemInfo(index)}
        local arg1 = temp[1]
        if not arg1 then
            return ---@diagnostic disable-line: missing-return-value
        end
        local info = type(arg1) == "table" and arg1 or nil
        if info then
            return info.name, info.texture, info.price, info.stackCount, info.numAvailable, info.isPurchasable, info.isUsable, info.hasExtendedCost, info.currencyID, info.spellID
        end
        return temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], temp[7], temp[8], temp[9], temp[10] ---@diagnostic disable-line: return-type-mismatch
    end

    function MerchantItem:Refresh()
        local index, hasIndex = self:GetIndex()
        if not hasIndex then
            self:Reset()
            return
        end
        self.name, self.texture, self.price, self.stackCount, self.numAvailable, self.isPurchasable, self.isUsable, self.extendedCost, self.currencyID, self.spellID = self:GetMerchantItemInfo()
        if not self.name then
            self:Reset()
            return
        end
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
        self.itemLink = GetMerchantItemLink(index)
        self.merchantItemID = GetMerchantItemID(index)
        self.itemLinkOrID = self.itemLink or self.merchantItemID
        self.isHeirloom = self.merchantItemID and C_Heirloom and C_Heirloom.IsItemHeirloom(self.merchantItemID) ---@diagnostic disable-line: assign-type-mismatch
        self.isKnownHeirloom = self.isHeirloom and C_Heirloom and C_Heirloom.PlayerHasHeirloom(self.merchantItemID) ---@diagnostic disable-line: assign-type-mismatch
        self.showNonrefundablePrompt = C_MerchantFrame and C_MerchantFrame.IsMerchantItemRefundable and not C_MerchantFrame.IsMerchantItemRefundable(index)
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
                ---@diagnostic disable-next-line: assign-type-mismatch
                costItem = { count = nil } ---@type MerchantItemCostItem
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
        if self.canAfford and self.price <= 0 and (not self.extendedCost or self.extendedCostCount == 0) then
            self.costType = MerchantItemCostType.Free
        end
        if not self.craftedStars and self.itemLink then
            self.craftedStars, self.craftedStarsMarkup = GetCraftedStarsFromLink(self.itemLink)
        end
        if self.itemLink then
            self.quality = GetQualityFromLink(self.itemLink) or self.quality
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
        self.isTransmog = CanTransmogItem(self.itemLinkOrID)
        self.isTransmogCollectable,
        self.isTransmogCollected = IsTransmogCollected(self.itemLink)
        self.isCosmetic = IsCosmeticItem and IsCosmeticItem(self.itemLinkOrID)
        self.isCosmeticBundle,
        self.isCosmeticBundleCollected,
        self.isCosmeticBundleNum,
        self.isCosmeticBundleNumMax = IsCosmeticBundleCollected(self.itemLink)
        self.isToy = self.merchantItemID and C_ToyBox and C_ToyBox.GetToyInfo(self.merchantItemID) and true
        self.isToyCollected = self.merchantItemID and PlayerHasToy and PlayerHasToy(self.merchantItemID)
        self.isLearnable = self.isCosmetic or self.isCosmeticBundle or self:IsLearnable()
        self.tooltipRequirementsScannable = self:IsRequirementScannable()
        self.tooltipScannable = self.isLearnable or self.tooltipRequirementsScannable
        if self.isCosmeticBundle then
            self.isCollected = self.isCosmeticBundleCollected
            self.isCollectedNum = self.isCosmeticBundleNum
            self.isCollectedNumMax = self.isCosmeticBundleNumMax
            self.tooltipScannable = false
        end
        if not self.tooltipScannable then
            return
        end
        if not TooltipScanner:IsSupported() then
            return
        end
        TooltipScanner:ScanMerchantItem(self)
    end

    function MerchantItem:ResetTooltipData()
        self.tooltipData = nil
        self.hasRedRequirements,
        self.hasRequirementsInfo = nil, nil
        self.isLearned = nil
        self.isCollected,
        self.isCollectedNum,
        self.isCollectedNumMax = nil, nil, nil
    end

    function MerchantItem:RefreshTooltipData()
        local tooltipData = self.tooltipData
        if not tooltipData then
            self:ResetTooltipData()
            return
        end
        if self.tooltipRequirementsScannable then
            if self.hasRedRequirements == nil then
                self.hasRedRequirements,
                self.hasRequirementsInfo = tooltipData:HasRequirements()
            end
        else
            self.hasRedRequirements,
            self.hasRequirementsInfo = nil, nil
        end
        if self.isLearnable then
            if self.isLearned == nil then
                self.isLearned = tooltipData:IsLearned()
            end
            if self.isCollected == nil then
                self.isCollected,
                self.isCollectedNum,
                self.isCollectedNumMax = tooltipData:IsCollected()
            end
        else
            self.isLearned = nil
            self.isCollected,
            self.isCollectedNum,
            self.isCollectedNumMax = nil, nil, nil
        end
    end

    ---@param isInstant boolean
    ---@param tooltipData TooltipData
    function MerchantItem:OnTooltipScanResponse(isInstant, tooltipData)
        self.tooltipScannerState = TooltipScannerState.Done
        self.tooltipData = CreateTooltipItem(tooltipData, self.itemLink)
        self:RefreshTooltipData()
        if not isInstant then
            self.parent:UpdateMerchantThrottled()
        end
    end

    ---@return number index, boolean hasIndex
    function MerchantItem:GetIndex()
        local index = self.index or 0
        return index, index > 0
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

    function MerchantItem:CanAfford()
        return self.canAfford
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

    function MerchantItem:IsRequirementScannable()
        return true
    end

    ---@param predicate? fun(requirementInfo: ItemRequirementInfo): boolean?
    ---@return ItemRequirementInfo[]? requirements
    function MerchantItem:GetRequirements(predicate)
        local requirementsInfo = self.hasRequirementsInfo
        if not requirementsInfo then
            return
        end
        if not predicate then
            return requirementsInfo
        end
        local results ---@type ItemRequirementInfo[]?
        local index = 0
        for _, requirementInfo in ipairs(requirementsInfo) do
            if predicate(requirementInfo) then
                if not results then
                    results = {}
                end
                index = index + 1
                results[index] = requirementInfo
            end
        end
        return results
    end

    ---@param requirementInfo ItemRequirementInfo
    ---@return boolean?
    local function getRequirementsForRedProfessionPredicate(requirementInfo)
        return requirementInfo.isRed and requirementInfo.type == 1 -- Profession
    end

    -- Get the first red profession (prioritize any with an `amount` value).
    ---@return ItemRequirementInfo? requirement
    function MerchantItem:GetRequirementsForRedProfession()
        local requirementsInfo = self:GetRequirements(getRequirementsForRedProfessionPredicate)
        if not requirementsInfo then
            return
        end
        for i = #requirementsInfo, 1, -1 do
            local requirementInfo = requirementsInfo[i]
            if requirementInfo.amount then
                return requirementInfo
            end
        end
        return requirementsInfo[1]
    end

    ---@param parent MerchantScanner
    ---@return MerchantItem itemData
    function CreateMerchantItem(parent)
        local itemData = Mixin({}, MerchantItem) ---@type MerchantItem
        itemData:OnLoad(parent)
        return itemData
    end

    ---@param merchantItem MerchantItem
    local function GetTextForItem(merchantItem)
        return format(
            "%s%s%s%s",
            merchantItem.numAvailable and merchantItem.numAvailable > -1 and format("|cffFFFF00[%d]|r ", merchantItem.numAvailable) or "",
            merchantItem.name or SEARCH_LOADING_TEXT,
            merchantItem.craftedStars and merchantItem.craftedStars > 0 and format(" %s", merchantItem.craftedStarsMarkup) or "",
            merchantItem.stackCount and merchantItem.stackCount > 1 and format(" |cffFFFF00x%d|r", merchantItem.stackCount) or ""
        )
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    function UpdateMerchantItemButton(button)
        local merchantItem = button.merchantItem
        if not merchantItem then
            button:SetID(0)
            return
        end
        local index, hasIndex = merchantItem:GetIndex()
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
        -- local isTransmogCollectable = merchantItem.isTransmogCollectable
        -- local isTransmogCollected = merchantItem.isTransmogCollected
        -- local isCosmeticBundle = merchantItem.isCosmeticBundle
        local isCosmeticBundleCollected = merchantItem.isCosmeticBundleCollected
        local isToyCollected = merchantItem.isToyCollected
        -- local hasRedRequirements = merchantItem.hasRedRequirements
        local hasRequirementsInfo = merchantItem.hasRequirementsInfo
        local isLearned = merchantItem.isLearned
        local isCollected = merchantItem.isCollected
        -- local isCollectedNum = merchantItem.isCollectedNum
        -- local isCollectedNumMax = merchantItem.isCollectedNumMax
        if not isPurchasable or not isUsable or not canAfford then
            backgroundColor = BackgroundColorPreset.Red
        end
        if isCosmeticBundleCollected or isToyCollected or isLearned or isCollected then
            backgroundColor = BackgroundColorPreset.None
            textColor = ColorPreset.Gray
        elseif hasRequirementsInfo then
            local requirementInfo = merchantItem:GetRequirementsForRedProfession()
            if requirementInfo then
                if requirementInfo.amount then
                    backgroundColor = BackgroundColorPreset.Yellow
                else
                    backgroundColor = BackgroundColorPreset.Orange
                end
            end
        end
        if not hasIndex then
            backgroundColor = BackgroundColorPreset.None
            textColor = ColorPreset.White
        end
        button:SetBackgroundColor(backgroundColor)
        button:SetTextColor(textColor)
        local canSelectQuantity = merchantItem:CanSpecifyQuantity()
        button.Quantity:SetShown(canSelectQuantity)
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    function RefreshAndUpdateMerchantItemButton(button)
        local merchantItem = button.merchantItem
        if merchantItem then
            merchantItem:Refresh()
        end
        UpdateMerchantItemButton(button)
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    function ResetMerchantItemButton(_, button)
        local merchantItem = button.merchantItem
        if merchantItem then
            merchantItem.parentButton = nil
        end
        button.merchantItem = nil
        button:Hide()
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    ---@param merchantItem? MerchantItem
    ---@return CompactVendorFrameMerchantButtonTemplate merchantButton
    function CreateMerchantItemButton(button, merchantItem)
        button.merchantItem = merchantItem
        merchantItem.parentButton = button
        RefreshAndUpdateMerchantItemButton(button)
        return button
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

    MerchantScanner.merchantOpen = false
    MerchantScanner.collection = {}

    MerchantScanner.MERCHANT_REFRESH_INTERVAL = 0.25
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
    ---@field public EnumerateActive fun(self: ObjectPool): fun(): ObjectPoolObject
    ---@field public GetNextActive fun(self: ObjectPool, current: ObjectPoolObject): fun(): ObjectPoolObject
    ---@field public IsActive fun(self: ObjectPool, object: ObjectPoolObject): boolean
    ---@field public GetNumActive fun(self: ObjectPool): number

    ---@alias FramePoolObject CompactVendorFrameMerchantButtonTemplate
    ---@alias FramePoolCreate fun(pool: FramePool): FramePoolObject
    ---@alias FramePoolReset fun(pool: FramePool, self: FramePoolObject)
    ---@alias FramePoolFunction fun(frameType: FrameType, parent?: string|Region, frameTemplate?: string, resetterFunc?: FramePoolReset, forbidden?: boolean, frameInitFunc?: FramePoolCreate): FramePoolObject

    ---@class FramePool : ObjectPool
    ---@field public Acquire fun(self: FramePool): FramePoolObject, boolean
    ---@field public Release fun(self: FramePool, object: FramePoolObject): boolean
    ---@field public ReleaseAll fun(self: FramePool)
    ---@field public EnumerateActive fun(self: FramePool): fun(): FramePoolObject
    ---@field public GetNextActive fun(self: FramePool, current: FramePoolObject): fun(): FramePoolObject
    ---@field public GetNextInactive fun(self: FramePool, current: FramePoolObject): fun(): FramePoolObject
    ---@field public IsActive fun(self: FramePool, object: FramePoolObject): boolean
    ---@field public EnumerateInactive fun(self: FramePool): fun(): FramePoolObject
    ---@field public GetTemplate fun(self: FramePool): string?
    ---@field public SetResetDisallowedIfNew fun(self: FramePool, disallowed: boolean)

    ---@class MerchantItemFramePool : FramePool

    ---@alias MerchantItemPoolObject MerchantItem
    ---@alias MerchantItemPoolCreate fun(pool: FramePool): MerchantItemPoolObject
    ---@alias MerchantItemPoolReset fun(pool: FramePool, self: MerchantItemPoolObject)
    ---@alias MerchantItemPoolFunction fun(frameType: FrameType, parent?: string|Region, frameTemplate?: string, resetterFunc?: MerchantItemPoolReset, forbidden?: boolean, frameInitFunc?: MerchantItemPoolCreate): MerchantItemPoolObject

    ---@class MerchantItemPool : ObjectPool
    ---@field public Acquire fun(self: MerchantItemPool): MerchantItemPoolObject, boolean
    ---@field public Release fun(self: MerchantItemPool, object: MerchantItemPoolObject): boolean
    ---@field public ReleaseAll fun(self: MerchantItemPool)
    ---@field public EnumerateActive fun(self: MerchantItemPool): fun(): MerchantItemPoolObject
    ---@field public GetNextActive fun(self: MerchantItemPool, current: MerchantItemPoolObject): fun(): MerchantItemPoolObject
    ---@field public IsActive fun(self: MerchantItemPool, object: MerchantItemPoolObject): boolean

    ---@type MerchantItemPool
    MerchantScanner.itemPool = CreateObjectPool(
        ---@param pool MerchantItemPool
        function(pool)
            return CreateMerchantItem(MerchantScanner)
        end,
        ---@param pool MerchantItemPool
        ---@param self MerchantItemPoolObject
        function(pool, self)
            self:Reset()
        end
    )

    ---@type MerchantItemFramePool
    MerchantScanner.buttonPool = CreateFramePool("Button", nil, "CompactVendorFrameMerchantButtonTemplate") ---@diagnostic disable-line: assign-type-mismatch

    ---@return boolean merchantExists
    function MerchantScanner:UpdateMerchantInfo()
        if not self.merchantOpen then
            self.guid = nil
            self.name = nil
            self.isReady = false
            self:TriggerEvent(self.Event.OnHide)
            return false
        end
        self.guid = UnitGUID("npc")
        self.name = UnitName("npc")
        local merchantExists = not not self.guid
        if merchantExists then
            self.isReady = false
            self:TriggerEvent(self.Event.OnShow)
        else
            self.isReady = false
            self:TriggerEvent(self.Event.OnHide)
        end
        return merchantExists
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

    ---@type MerchantItem[]
    MerchantScanner.activeItems = {}

    ---@param numMerchantItems? number
    local function GetActiveItems(numMerchantItems)
        local items = MerchantScanner.activeItems
        table.wipe(items)
        local count = 0
        for item in MerchantScanner.itemPool:EnumerateActive() do
            count = count + 1
            items[count] = item
        end
        if count > 1 then
            table.sort(items, SortCollectionByIndex)
        end
        if numMerchantItems then
            local sort = false
            for i = count + 1, numMerchantItems do
                local item = items[i]
                if not item then
                    item = MerchantScanner.itemPool:Acquire()
                    items[i] = item
                    sort = true
                end
            end
            for i = numMerchantItems + 1, #items do
                local item = items[i]
                MerchantScanner.itemPool:Release(item)
            end
            if sort and numMerchantItems > 1 then
                table.sort(items, SortCollectionByIndex)
            end
        end
        return items
    end

    ---@param isFullUpdate? boolean
    ---@param predicate? fun(itemData: MerchantItem): boolean?
    function MerchantScanner:UpdateMerchant(isFullUpdate, predicate)
        local merchantExists = self:UpdateMerchantInfo()
        if isFullUpdate == true or not merchantExists then
            self.itemPool:ReleaseAll()
            self.isReady = false
            if not merchantExists then
                self:UpdateCollection(true)
                self:TriggerEvent(self.Event.OnHide)
                return
            else
                self:TriggerEvent(self.Event.OnShow)
            end
        end
        local numMerchantItems = GetMerchantNumItems()
        local activeItems = GetActiveItems(numMerchantItems)
        local pending = 0
        for index = 1, numMerchantItems do
            local itemData = activeItems[index]
            if itemData:IsDirty(index) or isFullUpdate == true or itemData:HasLimitedAvailability() or (predicate and predicate(itemData)) then
                pending = pending + 1
                itemData:Refresh()
                if not itemData:IsPending() then
                    pending = pending - 1
                end
                local parentButton = itemData.parentButton
                if parentButton then
                    UpdateMerchantItemButton(parentButton)
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

    ---@type FunctionContainer?
    local throttleHandleFullUpdate

    ---@type table<number, FunctionContainer?>
    local throttleHandleItemUpdate = {}

    local function throttleHandleFullClear()
        if not throttleHandleFullUpdate then
            return
        end
        throttleHandleFullUpdate:Cancel()
        throttleHandleFullUpdate = nil
    end

    ---@param itemID number
    local function throttleHandleItemClear(itemID)
        local handle = throttleHandleItemUpdate[itemID]
        if not handle then
            return
        end
        handle:Cancel()
        throttleHandleItemUpdate[itemID] = nil
    end

    local function TimerSafeUpdateMerchant()
        MerchantScanner:UpdateMerchant()
    end

    ---@param useAdditionalDelayedUpdate? boolean
    function MerchantScanner:UpdateMerchantThrottled(useAdditionalDelayedUpdate)
        throttleHandleFullClear()
        throttleHandleFullUpdate = C_Timer.NewTicker(self.MERCHANT_REFRESH_INTERVAL, function()
            throttleHandleFullClear()
            self:UpdateMerchant()
            if useAdditionalDelayedUpdate then
                C_Timer.After(self.MERCHANT_REFRESH_INTERVAL, TimerSafeUpdateMerchant)
            end
        end)
    end

    ---@param itemID number
    ---@param checkCostItems? boolean
    ---@param includePending? boolean
    function MerchantScanner:UpdateMerchantItemByIDThrottled(itemID, checkCostItems, includePending)
        throttleHandleItemClear(itemID)
        throttleHandleItemUpdate[itemID] = C_Timer.NewTicker(self.ITEM_REFRESH_INTERVAL, function()
            throttleHandleItemClear(itemID)
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

    ---@param hyperlink string
    ---@return MerchantItem? merchantItem
    function MerchantScanner:GetMerchantItemByItemLink(hyperlink)
        local sanitizedHyperlink = GetSanitizedHyperlinkForItemQuery(hyperlink)
        for _, itemData in ipairs(self.collection) do
            local itemLink = itemData.itemLink
            if itemLink then
                local sanitizedItemLink = GetSanitizedHyperlinkForItemQuery(itemLink)
                if sanitizedHyperlink == sanitizedItemLink then
                    return itemData
                end
            end
        end
    end

    ---@param merchantItemIndex number
    ---@return MerchantItem? merchantItem
    function MerchantScanner:GetMerchantItemByMerchantIndex(merchantItemIndex)
        for _, itemData in ipairs(self.collection) do
            if merchantItemIndex == itemData.index then
                return itemData
            end
        end
    end

    ---@param isReset? boolean
    function MerchantScanner:UpdateCollection(isReset)
        local collection = self.collection
        table.wipe(collection)
        if isReset == true then
            return
        end
        local activeItems = GetActiveItems()
        for index, activeItem in ipairs(activeItems) do
            collection[index] = activeItem
        end
    end

    if SetMerchantFilter then

        local function UpdateMerchant()
            MerchantScanner:UpdateMerchant(true)
        end

        hooksecurefunc("SetMerchantFilter", UpdateMerchant)
        hooksecurefunc("ResetSetMerchantFilter", UpdateMerchant)

    end

    ---@type WowEvent[]
    MerchantScanner.Events = {
        "MERCHANT_UPDATE",
        "MERCHANT_FILTER_ITEM_UPDATE",
        "HEIRLOOMS_UPDATED",
        -- "GET_ITEM_INFO_RECEIVED",
        -- "ITEM_DATA_LOAD_RESULT",
    }

    ---@param event WowEvent
    ---@param ... any
    function MerchantScanner:OnEvent(event, ...)
        if event == "MERCHANT_SHOW" then
            FrameUtil.RegisterFrameForEvents(self, self.Events)
            self.merchantOpen = true
            self:UpdateMerchant(true)
        elseif event == "MERCHANT_CLOSED" then
            FrameUtil.UnregisterFrameForEvents(self, self.Events)
            self.merchantOpen = false
            self:UpdateMerchant()
            TooltipScanner:ClearCache()
        elseif event == "UNIT_INVENTORY_CHANGED" then
            local unit = ...
            if unit == "player" then
                self:UpdateMerchant()
            end
        elseif event == "MERCHANT_UPDATE" then
            self:UpdateMerchantThrottled(true)
        elseif event == "MERCHANT_FILTER_ITEM_UPDATE" then
            -- local itemID = ...
            -- self:UpdateMerchantItemByIDThrottled(itemID)
            self:UpdateMerchantThrottled(true)
        elseif event == "HEIRLOOMS_UPDATED" then
            local itemID, updateReason = ...
            if itemID and updateReason == "NEW" then
                self:UpdateMerchantItemByID(itemID)
            end
        elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
            local itemID, success = ...
            if success then
                self:UpdateMerchantItemByIDThrottled(itemID, true, true)
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
        -- "OnReady",
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

    function MerchantDataProvider:IsReady()
        return MerchantScanner.isReady
    end

    function MerchantDataProvider:GetMerchantItems()
        return MerchantScanner:GetMerchantItems()
    end

    function MerchantDataProvider:Refresh()
        local isReady = self:IsReady()
        local items = self:GetMerchantItems()
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

    -- hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function() MerchantDataProvider:Refresh() end)

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
            if ns.Search then
                return ns.Search.Matches(itemData.itemLinkOrID, searchText) ~= true
            end
            local index = name:lower():find(searchText, nil, true)
            return index == nil
        end)

        ---@class CompactVendorFrameSearchBox : EditBox
        ---@field public clearButton Button

        self.Search = CreateFrame("EditBox", nil, self, "SearchBoxTemplate") ---@class CompactVendorFrameSearchBox
        self.Search:SetSize(102, 32)
        self.Search:SetMultiLine(false)
        self.Search:SetMaxLetters(255)
        self.Search:SetCountInvisibleLetters(true)
        self.Search:SetAutoFocus(false)

        SearchBoxTemplate_OnLoad(self.Search)

        local merchantFilter = MerchantFrameLootFilter or MerchantFrame.FilterDropdown ---@type Frame?
        if merchantFilter then
            if IS_TWW then
                self.Search:SetPoint("RIGHT", merchantFilter, "LEFT", -8, 0)
            else
                self.Search:SetPoint("RIGHT", merchantFilter, "LEFT", 14, 3)
            end
        else
            local merchantPortrait = MerchantFramePortrait or MerchantFrame.PortraitContainer.portrait ---@type Frame
            self.Search:SetPoint("LEFT", merchantPortrait, "RIGHT", 12, -19)
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
            GameTooltip:AddLine("You can write parts of the item name or its properties.", 1, 1, 1, false)
            GameTooltip:AddLine("Use the following additional syntax to produce more accurate results.", 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("Type search:", "bop   bou   boe", nil, nil, nil, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "boa  quest", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "l:80", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "q:epic   q:4", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "t:leather   t:shield", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "n:water   n:\"fresh water\"", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine("Modifiers:", "&   Match both", nil, nil, nil, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "|   Match either", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "!   Do not match", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "> < <= >=   Numerical comparisons", 1, 1, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(" ", "= ~=   Equality comparisons", 1, 1, 1, 1, 1, 1)
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
        ---@alias ViewPolyfillElementResetterFunction fun(self: ViewScrollBoxElement, elementData: ViewScrollBoxElementData)
        ---@alias ViewPolyfillElementFactoryFunction fun(factory: fun(), elementData: ViewScrollBoxElementData)

        ---@class ViewPolyfill
        ---@field public templateInfos table<string, table<string, any>>
        ---@field public templateInfoCache table<string, table<string, table<string, any>>>
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
        ---@field public SetFrameFactoryResetter fun(self: ViewPolyfill, resetter?: ViewPolyfillElementResetterFunction)

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
        self.ScrollBox:SetAllPoints() ---@diagnostic disable-line: missing-parameter

        self.Loading = CreateFrame("Frame", nil, self, "SpinnerWithShadowTemplate")
        self.Loading:SetSize(128, 128)
        self.Loading:SetPoint("CENTER", self.ScrollBox, "CENTER", 0, 0)

        self.NoItems = self.ScrollBox:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med3")
        self.NoItems:SetAllPoints(self.ScrollBox)
        self.NoItems:SetText(BROWSE_NO_RESULTS)

        ---@class EventFrame : Frame
        ---@field public Event table<"OnHide"|"OnShow"|"OnSizeChanged", number>
        ---@field public OnLoad_Intrinsic fun(self: EventFrame)
        ---@field public OnHide_Intrinsic fun(self: EventFrame)
        ---@field public OnShow_Intrinsic fun(self: EventFrame)
        ---@field public OnSizeChanged_Intrinsic fun(self: EventFrame, width: number, height: number)

        ---@class WowTrimScrollBar : Frame
        ---@field public minThumbExtent number 23
        ---@field public Backplate TextureBase
        ---@field public Background Frame
        ---@field public Track Frame
        ---@field public Back Button
        ---@field public Forward Button
        ---@field public OnLoad fun(self: WowTrimScrollBar)

        ---@class CompactVendorFrameScrollBar : EventFrame, WowTrimScrollBar

        self.ScrollBar = CreateFrame("EventFrame", nil, self, "WowTrimScrollBar") ---@class CompactVendorFrameScrollBar
        self.ScrollBar:SetPoint("TOPLEFT", self.ScrollBox, "TOPRIGHT", -1, 2)
        self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollBox, "BOTTOMRIGHT", -1, -3)

        local templateKey = "CompactVendorFrameMerchantButtonTemplate"
        local templateInfo = { type = "Button", width = 300, height = 24, keyValues = {} }

        local view = CreateScrollBoxListLinearView() ---@type ViewPolyfill
        if view.templateInfoCache then
            view.templateInfoCache.templateInfos[templateKey] = templateInfo
        else
            view.templateInfos[templateKey] = templateInfo
        end
        view:SetElementInitializer(templateKey, CreateMerchantItemButton)
        view:SetFrameFactoryResetter(ResetMerchantItemButton)
        view:SetPadding(2, 2, 2, 2, 0)
        ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

        self.ScrollBox:SetDataProvider(MerchantDataProvider)

        local scrollPercentage

        local function updateLoading()
            if not MerchantDataProvider:IsReady() then
                self.Loading:Show()
                self.NoItems:Hide()
                return
            end
            self.Loading:Hide()
            self.NoItems:SetShown(MerchantDataProvider:IsEmpty())
        end

        local function OnShow()
            updateLoading()
        end

        local function OnPreUpdate()
            if scrollPercentage then
                return
            end
            scrollPercentage = self.ScrollBox:CalculateScrollPercentage()
        end

        local function OnPostUpdate()
            updateLoading()
            if not scrollPercentage then
                return
            end
            self.ScrollBox:SetScrollPercentage(scrollPercentage)
            scrollPercentage = nil
        end

        MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnShow, OnShow)
        MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnPreUpdate, OnPreUpdate)
        MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnPostUpdate, OnPostUpdate)

    end

    function Frame:CreateSettings()

        ---@class MinimalSliderTemplate : Slider
        ---@field public obeyStepOnDrag boolean
        ---@field public Left TextureBase
        ---@field public Right TextureBase
        ---@field public Middle TextureBase
        ---@field public Thumb TextureBase # ThumbTexture

        ---@class MinimalSliderWithSteppersTemplate : Frame
        ---@field public Slider MinimalSliderTemplate
        ---@field public Back Button
        ---@field public Forward Button
        ---@field public LeftText FontString
        ---@field public RightText FontString
        ---@field public TopText FontString
        ---@field public MinText FontString
        ---@field public MaxText FontString
        ---@field public Init fun(self: MinimalSliderWithSteppersTemplate, value: number, minValue: number, maxValue: number, steps: number, formatters: any[])
        ---@field public SetValue fun(self: MinimalSliderWithSteppersTemplate, value: number)
        ---@field public RegisterCallback fun(self: MinimalSliderWithSteppersTemplate, event: string, callback: fun(ownerID: number, value: number))

        ---@class SettingsAdvancedSliderTemplate : Frame
        ---@field public Text FontString
        ---@field public SliderWithSteppers MinimalSliderWithSteppersTemplate

        local panel = CreateFrame("Frame")

        ---@param name string
        ---@param variable string
        ---@param currentValue number
        ---@param minValue number
        ---@param maxValue number
        ---@param step number
        ---@param labelFunc? fun(value: number): string
        local function CreateSlider(name, variable, currentValue, minValue, maxValue, step, labelFunc)

            if not labelFunc then
                labelFunc = tostring
            end

            ---@type SettingsAdvancedSliderTemplate
            local control = CreateFrame("Frame", nil, panel, "SettingsAdvancedSliderTemplate") ---@diagnostic disable-line: assign-type-mismatch

            control:SetPoint("TOPLEFT", 0, 0)
            control.Text:SetText(name)

            control.SliderWithSteppers:Init(currentValue, minValue, maxValue, (maxValue - minValue) * step, {
                [MinimalSliderWithSteppersMixin.Label.Right] = function(value) return labelFunc(value) end,
            })

            control.SliderWithSteppers:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
                currentValue = value
                CompactVendorDB[variable] = value
            end)

            return control

        end

        do

            local name = "Text size (px)"
            local variable = "ListItemScale"
            local currentValue = CompactVendorDB[variable]
            local minValue, maxValue, step = ListItemScaleToFontObject.minSize, ListItemScaleToFontObject.maxSize, 1

            local control = CreateSlider(name, variable, currentValue, minValue, maxValue, step)
            control:SetPoint("TOPLEFT", 0, 0)

        end

        do

            local name = "Icon shape"
            local variable = "IconShape"
            local currentValue = CompactVendorDB[variable]
            local minValue, maxValue, step = 0, 5, 1

            local IconShapeLabel = {
                [0] = "None",
                [1] = "Round",
                [2] = "Square",
                [3] = "Diamond",
                [4] = "Hexagon",
                [5] = "Octagon",
            }

            local control = CreateSlider(name, variable, currentValue, minValue, maxValue, step, function(value) return IconShapeLabel[value] end)
            control:SetPoint("TOPLEFT", 0, -32)

        end

        ---@alias SettingsTextContainerPolyfillGetDataFunc fun(self: SettingsControlTextContainerPolyfill): SettingsSliderOptionsPolyfill[]

        ---@class SettingsPolyfill
        ---@field public RegisterCanvasLayoutCategory fun(frame: Region, name: string): SettingsCategoryPolyfill
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

        local category = Settings.RegisterCanvasLayoutCategory(panel, addonName)
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
        AutoSize({ self:GetChildren() }) ---@diagnostic disable-line: assign-type-mismatch
        local _, _, width = self:GetBoundsRect()
        if not width then
            return
        end
        if self.isIconTextTemplate then
            -- ---@diagnostic disable-next-line: assign-type-mismatch
            -- local cost = self ---@type CompactVendorFrameMerchantIconTemplate
            -- if cost and cost.Texture and not cost.mode then
            --     width = width - (cost.Texture:IsShown() and cost.Texture:GetWidth() or 0)
            -- end
            width = 24 -- TODO: 10.1 changed something that causes this to align the Icon in a weird way when we autosize so when we encounter this template we force it to the square dimension size
        end
        self:SetWidth(width)
    end

end

---@class CompactVendorFrameMerchantStackSplitTemplate
local CompactVendorFrameMerchantStackSplitTemplate do

    ---@class CompactVendorFrameMerchantStackSplitTemplate : Frame
    ---@field public owner? CompactVendorFrameMerchantButtonQuantityTemplate
    ---@field public SingleItemSplitBackground TextureBase
    ---@field public MultiItemSplitBackground TextureBase
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
        self:SetParent(UIParent) ---@diagnostic disable-line: param-type-mismatch
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
    ---@param anchor FramePoint
    ---@param anchorTo FramePoint
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
        self.StackSplitText:SetText(self.split) ---@diagnostic disable-line: param-type-mismatch
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
            self.StackSplitText:SetText(self.split) ---@diagnostic disable-line: param-type-mismatch
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
            self.StackSplitText:SetText(self.split) ---@diagnostic disable-line: param-type-mismatch
        end
        self.RightButton:SetEnabled(self.split ~= self.maxStack)
        self.LeftButton:SetEnabled(self.split ~= 1)
    end

end

---@class CompactVendorFrameMerchantButtonQuantityTemplate
local CompactVendorFrameMerchantButtonQuantityTemplate do

    ---@class CompactVendorFrameMerchantButtonQuantityTemplate : Button
    ---@field public Bg TextureBase
    ---@field public Name FontString
    ---@field public StackSplitFrameOwnedBy? CompactVendorFrameMerchantButtonTemplate

    CompactVendorFrameMerchantButtonQuantityTemplate = {} ---@class CompactVendorFrameMerchantButtonQuantityTemplate
    _G.CompactVendorFrameMerchantButtonQuantityTemplate = CompactVendorFrameMerchantButtonQuantityTemplate

    C_Timer.After(0.01, function()
        --[[ global ]] CompactVendorFrameMerchantButtonQuantityTemplate.StackSplitFrame = CompactVendorFrameMerchantStackSplitFrame ---@type CompactVendorFrameMerchantStackSplitTemplate
    end)

    ---@type BuyEmAll
    local BuyEmAll do

        ---@alias BuyEmAll fun(): buyEmAllFrame: BuyEmAllFrame?, buyEmAll: BuyEmAllFunc?

        ---@class BuyEmAllFrame : Frame

        ---@class BuyEmAllAPI
        ---@field public MerchantItemButton_OnModifiedClick fun(self: BuyEmAllAPI, ...)

        ---@alias BuyEmAllFunc fun(frame: Button, button: mouseButton): success: boolean

        ---@type BuyEmAllFunc?
        local buyEmAllFunc

        local buyEmAllFuncEnv = setmetatable({
            IsShiftKeyDown = function() return true end,
        }, {
            __index = _G,
        })

        local hasErrored = false

        ---@type BuyEmAll
        function BuyEmAll()
            ---@type BuyEmAllFrame
            local buyEmAllFrame = _G.BuyEmAllFrame ---@diagnostic disable-line: undefined-field
            if not buyEmAllFrame or type(buyEmAllFrame) ~= "table" or type(buyEmAllFrame.GetObjectType) ~= "function" then
                return
            end
            ---@type BuyEmAllAPI
            local buyEmAll = _G.BuyEmAll ---@diagnostic disable-line: undefined-field
            if not buyEmAll or type(buyEmAll) ~= "table" or type(buyEmAll.MerchantItemButton_OnModifiedClick) ~= "function" then
                return
            end
            if not buyEmAllFunc then
                ---@type BuyEmAllFunc
                buyEmAllFunc = function(frame, button)
                    local func = buyEmAll.MerchantItemButton_OnModifiedClick
                    func = setfenv(func, buyEmAllFuncEnv)
                    local success, result = pcall(func, buyEmAll, frame, button)
                    if not success and not hasErrored then
                        hasErrored = true
                        print(addonName, "tried to use BuyEmAll but there was an error:", result)
                    end
                    return success
                end
            end
            return buyEmAllFrame, buyEmAllFunc
        end

    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:Open()
        ---@type CompactVendorFrameMerchantButtonTemplate
        local owner = self:GetParent() ---@diagnostic disable-line: assign-type-mismatch
        local buyEmAllFrame, buyEmAllFunc = BuyEmAll()
        if buyEmAllFrame and buyEmAllFunc and buyEmAllFunc(owner, "LeftButton") then
            buyEmAllFrame:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 8, 0)
            return
        end
        self.StackSplitFrame:OpenStackSplitFrame(250, self, "TOPLEFT", "TOPRIGHT")
        self.StackSplitFrameOwnedBy = owner
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:Close()
        local buyEmAllFrame = BuyEmAll()
        if buyEmAllFrame then
            buyEmAllFrame:Hide()
            return
        end
        self.StackSplitFrame:Hide()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:IsOpen()
        local buyEmAllFrame = BuyEmAll()
        if buyEmAllFrame then
            local _, relativeTo = buyEmAllFrame:GetPoint()
            return self == relativeTo and buyEmAllFrame:IsShown()
        end
        return self == self.StackSplitFrame.owner and self.StackSplitFrame:IsShown()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnLoad()
        self:RegisterForClicks("LeftButtonUp")
        self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0) ---@diagnostic disable-line: undefined-field
        self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5) ---@diagnostic disable-line: undefined-field
        -- required by StackSplitFrame
        self.hasStackSplit = 0
        self.SplitStack = self.StackSplitFrameCallback
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnShow()
        self:Close()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnHide()
        self:Close()
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnClick()
        if self:IsOpen() then
            self:Close()
        else
            self:Open()
        end
    end

    ---@param quantity? number
    function CompactVendorFrameMerchantButtonQuantityTemplate:StackSplitFrameCallback(quantity)
        if not self.StackSplitFrameOwnedBy or not quantity then
            return
        end
        self.StackSplitFrameOwnedBy:Purchase(quantity)
    end

end

---@class CompactVendorFrameMerchantIconTemplate
local CompactVendorFrameMerchantIconTemplate do

    ---@enum IconShape
    local IconShape = {
        None = 0,
        Round = 1,
        Square = 2,
        Diamond = 3,
        Hexagon = 4,
        Octagon = 5,
    }

    ---@class IconShapeMaskAnchor : table

    ---@class IconShapeInfoItemData
    ---@field public file number|string
    ---@field public size number
    ---@field public anchor IconShapeMaskAnchor
    ---@field public texCoords? number[]|false
    ---@field public mask string|number
    ---@field public maskSize number
    ---@field public maskAnchor IconShapeMaskAnchor

    ---@class IconShapeInfoItem
    ---@field public icon IconShapeInfoItemData
    ---@field public border IconShapeInfoItemData

    local TextureHiddenFileID = 130871

    local IconShapeDefaultData = {
        icon = {
            size = 20,
            anchor = { "LEFT", 4, 0 },
            mask = TextureHiddenFileID,
            maskSize = 18,
            maskAnchor = { "CENTER", "$parent.Texture", "CENTER" },
        },
        border = {
            file = TextureHiddenFileID,
            size = 22,
            anchor = { "CENTER", "$parent.Texture", "CENTER" },
            texCoords = false,
            mask = TextureHiddenFileID,
            maskSize = 20,
            maskAnchor = { "CENTER", "$parent.Texture", "CENTER" },
        },
    }

    local IconShapeDefaultDataIcon = { __index = IconShapeDefaultData.icon }
    local IconShapeDefaultDataBorder = { __index = IconShapeDefaultData.border }

    ---@param partial IconShapeInfoItem
    local function InheritFromBase(partial)
        partial.icon = setmetatable(partial.icon or {}, IconShapeDefaultDataIcon)
        partial.border = setmetatable(partial.border or {}, IconShapeDefaultDataBorder)
        return partial
    end

    ---@type IconShapeInfoItem[]
    local IconShapeInfo = {
        [IconShape.None] = InheritFromBase({ ---@diagnostic disable-line: missing-fields
        }),
        [IconShape.Round] = InheritFromBase({
            icon = { ---@diagnostic disable-line: missing-fields
                mask = 130924,
                maskSize = 16,
                maskAnchor = { "LEFT", 6, 0 },
            },
            border = { ---@diagnostic disable-line: missing-fields
                file = "Interface\\Minimap\\MiniMap-TrackingBorder",
                texCoords = { 0.046875, 0.578125, 0.03125, 0.578125 },
                mask = 130924,
                maskAnchor = { "LEFT", 4, 0 },
            },
        }),
        [IconShape.Square] = InheritFromBase({
            icon = { ---@diagnostic disable-line: missing-fields
                mask = 2443038,
            },
            border = { ---@diagnostic disable-line: missing-fields
                file = 2443038,
                mask = 2443038,
            },
        }),
        [IconShape.Diamond] = InheritFromBase({
            icon = { ---@diagnostic disable-line: missing-fields
                mask = 3152572,
            },
            border = { ---@diagnostic disable-line: missing-fields
                file = 3152572,
                mask = 3152572,
            },
        }),
        [IconShape.Hexagon] = InheritFromBase({
            icon = { ---@diagnostic disable-line: missing-fields
                mask = 426723,
            },
            border = { ---@diagnostic disable-line: missing-fields
                file = 426723,
                mask = 426723,
            },
        }),
        [IconShape.Octagon] = InheritFromBase({
            icon = { ---@diagnostic disable-line: missing-fields
                mask = 3750798,
            },
            border = { ---@diagnostic disable-line: missing-fields
                file = 3750798,
                mask = 3750798,
            },
        }),
    }

    ---@param self Region
    ---@param anchor IconShapeMaskAnchor|FramePoint[]
    local function UnpackAnchorArgs(self, anchor)
        local anchor1, anchor2, anchor3, anchor4, anchor5 = unpack(anchor) ---@diagnostic disable-line: param-type-mismatch
        if anchor2 == "$parent.Texture" then
            anchor2 = self:GetParent().Texture ---@diagnostic disable-line: undefined-field
        end
        return anchor1, anchor2, anchor3, anchor4, anchor5
    end

    ---@param info IconShapeInfoItemData
    ---@param texture TextureBase
    ---@param textureMask TextureBase
    ---@param isBorder boolean?
    local function SetShape(info, texture, textureMask, isBorder)
        local invisibleTexture = info.file == TextureHiddenFileID
        local invisibleTextureMask = info.mask == TextureHiddenFileID
        if invisibleTexture then
            texture:Hide()
        end
        if invisibleTextureMask then
            textureMask:Hide()
        end
        if isBorder then
            texture:SetTexture(info.file)
            texture:SetDesaturated(true)
        end
        texture:SetSize(info.size, info.size)
        texture:ClearAllPoints()
        texture:SetPoint(UnpackAnchorArgs(texture, info.anchor))
        if info.texCoords then
            texture:SetTexCoord(unpack(info.texCoords))
        else
            texture:SetTexCoord(0, 1, 0, 1)
        end
        textureMask:SetTexture(info.mask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        textureMask:SetSize(info.maskSize, info.maskSize)
        textureMask:ClearAllPoints()
        textureMask:SetPoint(UnpackAnchorArgs(textureMask, info.maskAnchor))
    end

    ---@class CompactVendorFrameMerchantIconTemplate : CompactVendorFrameAutoSizeTemplate
    ---@field public Texture TextureBase
    ---@field public TextureMask TextureBase #MaskTexture
    ---@field public Border TextureBase
    ---@field public BorderMask TextureBase #MaskTexture
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
        self.Count:SetText(count) ---@diagnostic disable-line: param-type-mismatch
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
        self.Text:SetText(text or "") ---@diagnostic disable-line: param-type-mismatch
        self:SetMode(false)
    end

    ---@param shape IconShape
    function CompactVendorFrameMerchantIconTemplate:SetShape(shape)
        local shapeInfo = shape and IconShapeInfo[shape] or IconShapeInfo[IconShape.None]
        self.shapeInfo = shapeInfo
        SetShape(shapeInfo.icon, self.Texture, self.TextureMask)
        SetShape(shapeInfo.border, self.Border, self.BorderMask, true)
    end

    ---@param asIcon boolean
    function CompactVendorFrameMerchantIconTemplate:SetMode(asIcon)
        self.mode = asIcon
        self.Texture:SetShown(asIcon)
        self.Border:SetShown(asIcon)
        self.Count:SetShown(asIcon)
        self.Text:SetShown(not asIcon)
        local showTextureMask = asIcon
        local showBorder = asIcon
        local showBorderMask = asIcon
        if asIcon and self.shapeInfo then
            showTextureMask = self.shapeInfo.icon.mask ~= TextureHiddenFileID
            showBorder = self.shapeInfo.border.file ~= TextureHiddenFileID
            showBorderMask = self.shapeInfo.border.mask ~= TextureHiddenFileID
        end
        self.TextureMask:SetShown(showTextureMask)
        self.Border:SetShown(showBorder)
        self.BorderMask:SetShown(showBorderMask)
    end

end

---@class CompactVendorFrameMerchantButtonCostButtonTemplate
local CompactVendorFrameMerchantButtonCostButtonTemplate do

    ---@param itemLink string
    ---@return number
    local function CountAvailableItems(itemLink)
        local count = GetItemCount(itemLink, true, false, true, true)
        if count and count > 0 then
            return count
        end
        local currencyID
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink then
            currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(itemLink)
        end
        if not currencyID or currencyID < 1 then
            return 0
        end
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            count = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity
        elseif GetCurrencyInfo then
            count = select(2, GetCurrencyInfo(currencyID))
        end
        return count or 0
    end

    local PRICE_FORMAT = format("%s %%.2f", "€") -- currency is currently hardcoded to Euro
    local TOKEN_COST = 20 -- token price is currently hardcoded to 20 Euro
    local PRICE_THRESHOLD = 0.1

    ---@return number? copperPerUnit
    local function GetCopperPerUnit()
        C_WowTokenPublic.UpdateMarketPrice()
        local price = C_WowTokenPublic.GetCurrentMarketPrice()
        if not price then return end
        return TOKEN_COST / price
    end

    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        GetCopperPerUnit = function() end
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
                local realMoney = copperPerUnit * self.price
                local realMoneyText = realMoney > PRICE_THRESHOLD and format(PRICE_FORMAT, realMoney) or nil
                if realMoneyText then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(realMoneyText, 1, 1, 1, false)
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
                    cost:Update(costType, canAfford, text, costItem.texture, costItem.count, costItem.itemLink, costItem.quality, costItem.name)
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
            local cost = CreateFrame("Button", nil, self, "CompactVendorFrameMerchantButtonCostButtonTemplate") ---@type CompactVendorFrameMerchantButtonCostButtonTemplate
            if prevCost then
                cost:SetPoint("RIGHT", prevCost, "LEFT", 0, 0)
            else
                cost:SetPoint("RIGHT", self, "RIGHT", 0, 0)
            end
            prevCost = cost
            self.Costs[i] = cost
        end
        self:HookScript("OnHide", function()
            for _, cost in ipairs(self.Costs) do
                cost:Hide()
            end
        end)
    end

    function CompactVendorFrameMerchantButtonCostTemplate:Update()
        local merchantItem = self.parent.merchantItem
        local hasItemCost = merchantItem and merchantItem.extendedCost
        local hasPriceCost = merchantItem and merchantItem.price and merchantItem.price > 0
        if not hasItemCost and not hasPriceCost then
            self:Hide()
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
        if hasItemCost then
            UpdateType("Item")
        end
        if hasPriceCost then
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

    ---@param self FontString
    ---@param fontObject any
    ---@param isDefaultFontObject boolean
    local function UpdateFontStringFontObject(self, fontObject, isDefaultFontObject)
        self:SetFontObject(fontObject)
        if not isDefaultFontObject then
            self:SetShadowOffset(0, 0)
            self:SetShadowOffset(1, -1)
            self:SetShadowColor(0, 0, 0, 1)
        end
    end

    ---@class CompactVendorFrameMerchantButtonTemplate : Button
    ---@field public merchantItem? MerchantItem
    ---@field public backgroundColor? number[]
    ---@field public textColor? SimpleColor
    ---@field public hovering? boolean
    ---@field public Bg TextureBase
    ---@field public Name FontString
    ---@field public Icon CompactVendorFrameMerchantIconTemplate
    ---@field public Quantity CompactVendorFrameMerchantButtonQuantityTemplate
    ---@field public Cost CompactVendorFrameMerchantButtonCostTemplate

    CompactVendorFrameMerchantButtonTemplate = {} ---@class CompactVendorFrameMerchantButtonTemplate
    _G.CompactVendorFrameMerchantButtonTemplate = CompactVendorFrameMerchantButtonTemplate

    ---@type WowEvent[]
    CompactVendorFrameMerchantButtonTemplate.Events = {
        "BAG_UPDATE_DELAYED",
        "CURRENCY_DISPLAY_UPDATE",
    }

    function CompactVendorFrameMerchantButtonTemplate:OnLoad()
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end

    function CompactVendorFrameMerchantButtonTemplate:OnShow()
        RefreshAndUpdateMerchantItemButton(self)
        self:UpdateTextSize()
        self:UpdateIconShape()
        FrameUtil.RegisterFrameForEvents(self, self.Events)
    end

    function CompactVendorFrameMerchantButtonTemplate:OnHide()
        FrameUtil.UnregisterFrameForEvents(self, self.Events)
    end

    ---@param event WowEvent
    function CompactVendorFrameMerchantButtonTemplate:OnEvent(event, ...)
        local function update()
            RefreshAndUpdateMerchantItemButton(self)
        end
        if event == "BAG_UPDATE_DELAYED" then
            update()
        elseif event == "CURRENCY_DISPLAY_UPDATE" then
            ---@type number?, number?, number?, Enum.CurrencySource?, Enum.CurrencyDestroyReason?
            local currencyType, quantity, quantityChange, quantityGainSource, destroyReason = ...
            if currencyType == nil then
                update()
            end
        end
    end

    function CompactVendorFrameMerchantButtonTemplate:OnEnter()
        local merchantItem = self.merchantItem
        if not merchantItem then
            return
        end
        local index, hasIndex = merchantItem:GetIndex()
        if not hasIndex then
            return
        end
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
        local _, hasIndex ---@type number, boolean
        if merchantItem then
            _, hasIndex = merchantItem:GetIndex()
        end
        if not merchantItem or not hasIndex then
            return
        end
        if self ~= GameTooltip:GetOwner() then
            return
        end
        if IsModifiedClick("DRESSUP") then
            ShowInspectCursor()
        elseif not merchantItem:CanAfford() then
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
            if not merchantItem:CanAfford() then
                return
            end
            if IsModifiedClick("ALT") then
                self:Purchase(merchantItem.maxStackCount)
            else
                self:Purchase()
            end
        end
    end

    ---@param color number[]
    function CompactVendorFrameMerchantButtonTemplate:SetBackgroundColor(color)
        if self.backgroundColor == color then
            return
        end
        self.backgroundColor = color
        local minColor = CreateColor(color[1], color[2], color[3], color[4])
        local maxColor = CreateColor(color[5], color[6], color[7], color[8])
        self.Bg:SetGradient("HORIZONTAL", minColor, maxColor)
    end

    ---@param color SimpleColor
    function CompactVendorFrameMerchantButtonTemplate:SetTextColor(color)
        if self.textColor == color then
            return
        end
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
        local index, hasIndex = merchantItem:GetIndex()
        if not hasIndex then
            return
        end
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
            if not self.showNonrefundablePrompt then
                return
            end
            local _, frame = StaticPopup_Visible("CONFIRM_PURCHASE_NONREFUNDABLE_ITEM")
            if not frame then
                return
            end
            local textFontString = frame.text or frame.Text or frame:GetTextFontString() or nil ---@type FontString
            local text = textFontString:GetText()
            local warningText = "|cffFF0000Your purchase is not refundable.|r"
            if not text:find(warningText, nil, true) then
                textFontString:SetFormattedText("%s\r\n%s", text, warningText)
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
        local fontObject, _, _, _, isDefaultFontObject = GetListItemScaleFontObject()
        UpdateFontStringFontObject(self.Name, fontObject, isDefaultFontObject)
        for _, cost in pairs(self.Cost.Costs) do
            UpdateFontStringFontObject(cost.Icon.Count, fontObject, isDefaultFontObject)
            UpdateFontStringFontObject(cost.Icon.Text, fontObject, isDefaultFontObject)
        end
        self.Cost:AutoSize()
    end

    function CompactVendorFrameMerchantButtonTemplate:UpdateIconShape()
        local shape = GetIconShape()
        self.Icon:SetShape(shape)
        for _, cost in pairs(self.Cost.Costs) do
            cost.Icon:SetShape(shape)
        end
    end

end
