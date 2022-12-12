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
local FrameUtil = FrameUtil ---@type table<any, any>
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

local ConfirmationRequirementForVendors = {
    [151950] = false, -- Mrrglrlr
    [151951] = false, -- Grrmrlg
    [151952] = false, -- Flrggrl
    [151953] = false, -- Hurlgrl
    [152084] = true, -- Mrrl
    [152593] = false, -- Murloco
}

local ItemQualityColorToHexColor
local ItemHexColorToQualityIndex
local ColorPreset
local BackgroundColorPreset
local GetColorFromQuality
local GetQualityFromLink
local GetItemIDFromLink
local GetInfoFromGUID
local GetMoneyString do

    ---@class SimpleColor
    ---@field public r number
    ---@field public g number
    ---@field public b number
    ---@field public hex string

    ItemQualityColorToHexColor = {} ---@type table<number, SimpleColor>
    ItemHexColorToQualityIndex = {} ---@type table<string, number>

    for i = 0, 8 do

        local r, g, b, hex = GetItemQualityColor(i)

        ItemQualityColorToHexColor[i] = {
            r = r,
            g = g,
            b = b,
            hex = hex,
        }

        ItemHexColorToQualityIndex[hex] = i

    end

    ItemHexColorToQualityIndex.None = ItemHexColorToQualityIndex[0]
    ColorPreset = ItemHexColorToQualityIndex

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
    ---@field public parent MerchantDataProvider
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

    local MerchantItem = {} ---@class MerchantItem

    ---@param parent MerchantDataProvider
    ---@param index number
    function MerchantItem:OnLoad(parent, index)
        self.parent = parent
        self.index = index
        self.extendedCostItems = {}
        self:Refresh()
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
        return false
    end

    function MerchantItem:Refresh()
        local index = self:GetIndex()
        self.name, self.texture, self.price, self.stackCount, self.numAvailable, self.isPurchasable, self.isUsable, self.extendedCost, self.currencyID, self.spellID = GetMerchantItemInfo(index) ---@diagnostic disable-line: assign-type-mismatch
        if self.currencyID then
            self.name, self.texture, self.numAvailable, self.quality = GetCurrencyContainerInfo(self.currencyID, self.numAvailable, self.name, self.texture, nil)
        end
        self.canAfford = CanAffordMerchantItem(index) ---@diagnostic disable-line: assign-type-mismatch
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
        return true -- TOOD: figure out what items we can actually buy in bulk, and what items we can't and should just hide the quantity button
    end

    function MerchantItem:CanSkipConfirmation()
        local guid = self.parent:GetMerchantInfo()
        local npcType, npcID = GetInfoFromGUID(guid)
        if (npcType == "Creature" or npcType == "Vehicle" or npcType == "GameObject") and (npcID and ConfirmationRequirementForVendors[npcID]) then
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

    ---@param parent MerchantDataProvider
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
            merchantItem.numAvailable and merchantItem.numAvailable > -1 and format("|cffFFFF00[%d]|r", merchantItem.numAvailable) or "",
            merchantItem.name or SEARCH_LOADING_TEXT,
            merchantItem.stackCount and merchantItem.stackCount > 1 and format(" |cffFFFF00x%d|r", merchantItem.stackCount) or ""
        )
    end

    ---@param button CompactVendorFrameMerchantButtonTemplate
    ---@param merchantItem? MerchantItem
    function UpdateMerchantItemButton(button, merchantItem)
        button.merchantItem = merchantItem
        if not merchantItem then
            return
        end
        local index = merchantItem:GetIndex()
        button:SetID(index)
        button.Icon:SetTexture(merchantItem.texture)
        local text = GetTextForItem(merchantItem)
        button.Name:SetText(text)
        button.Cost:Update()
        local backgroundColor = BackgroundColorPreset.None
        local textColor = ColorPreset[max(1, merchantItem.quality or 0)] or ColorPreset.None
        local isPurchasable = not merchantItem.tintRed
        local isUsable = merchantItem.isUsable
        local canAfford = merchantItem.canAfford
        local canLearn = false -- TODO
        if isPurchasable == false or isUsable == false or canAfford == false then
            backgroundColor = BackgroundColorPreset.Red
        end
        if canLearn then
            -- TODO
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

---@class MerchantDataProvider
local MerchantDataProvider do

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

    ---@alias MerchantDataProviderEvent DataProviderEvent|"OnMerchantShow"|"OnMerchantHide"|"OnMerchantUpdate"|"OnMerchantReady"

    ---@class MerchantDataProvider : DataProvider
    ---@field public Event table<MerchantDataProviderEvent, number>
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: MerchantDataProviderEvent[])

    MerchantDataProvider = CreateDataProvider() ---@type MerchantDataProvider

    MerchantDataProvider:GenerateCallbackEvents({
        "OnMerchantShow",
        "OnMerchantHide",
        "OnMerchantUpdate",
        "OnMerchantReady",
    })

    ---@return boolean merchantExists, boolean sameMerchant
    function MerchantDataProvider:UpdateMerchantInfo()
        local guid = self.guid
        self.guid = UnitGUID("npc")
        self.name = UnitName("npc")
        local merchantExists = not not self.guid
        local sameMerchant = self.guid == guid
        if merchantExists and not sameMerchant then
            self.isReady = false
            self:TriggerEvent(self.Event.OnMerchantShow)
        elseif not merchantExists then
            self:TriggerEvent(self.Event.OnMerchantHide)
        end
        return merchantExists, sameMerchant
    end

    ---@return string guid, string name
    function MerchantDataProvider:GetMerchantInfo()
        return self.guid, self.name
    end

    ---@param forceFullUpdate? boolean
    function MerchantDataProvider:UpdateMerchant(forceFullUpdate)
        local merchantExists, sameMerchant = self:UpdateMerchantInfo()
        if sameMerchant and forceFullUpdate ~= true then
            return
        end
        if not merchantExists then
            self:Flush()
            return
        end
        local numMerchantItems = GetMerchantNumItems()
        if numMerchantItems == self:GetSize() then
            self:UpdateMerchantPendingItems()
            return
        end
        self:Flush()
        local collection = {} ---@type DataProviderItemData[]
        for index = 1, numMerchantItems do
            local itemData = CreateMerchantItem(self, index)
            collection[index] = itemData
        end
        self:InsertTable(collection)
        self:TriggerEvent(self.Event.OnMerchantUpdate, self.isReady)
    end

    function MerchantDataProvider:UpdateMerchantPendingItems()
        local items = self:GetMerchantItems(function(itemData)
            return itemData:IsPending()
        end)
        local pending = 0
        for _, itemData in ipairs(items) do
            pending = pending + 1
            itemData:Refresh()
            if not itemData:IsPending() then
                pending = pending - 1
            end
        end
        if pending == 0 and not self.isReady then
            self.isReady = true
            self:TriggerEvent(self.Event.OnMerchantReady)
            self:TriggerEvent(self.Event.OnMerchantUpdate, self.isReady)
        end
    end

    ---@param itemID number
    ---@param checkCostItems? boolean
    function MerchantDataProvider:UpdateMerchantItemByID(itemID, checkCostItems)
        local items = self:GetMerchantItems(function(itemData)
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
        for _, itemData in ipairs(items) do
            itemData:Refresh()
        end
        self:TriggerEvent(self.Event.OnMerchantUpdate, self.isReady)
    end

    function MerchantDataProvider:UpdateMerchantStockItems()
        local items = self:GetMerchantItems()
        for _, itemData in ipairs(items) do
            if itemData.numAvailable ~= -1 then
                itemData:Refresh()
            end
        end
    end

    ---@param predicate? DataProviderPredicate
    ---@return DataProviderItemData[] merchantItems
    function MerchantDataProvider:GetMerchantItems(predicate)
        if type(predicate) ~= "function" then
            predicate = nil
        end
        local collection = {} ---@type DataProviderItemData
        local index = 0
        for _, itemData in ipairs(self.collection) do
            if not predicate or predicate(itemData) then
                index = index + 1
                collection[index] = itemData
            end
        end
        return collection
    end

    ---@param index number
    ---@return DataProviderItemData? itemData
    function MerchantDataProvider:GetMerchantItem(index)
        return self.collection[index]
    end

    ---@return boolean hasMerchantItems
    function MerchantDataProvider:HasMerchantItems()
        return not not self.collection[1]
    end

    function MerchantDataProvider:HasMerchantPendingItems()
        if not self.isReady then
            return 1
        end
        for _, itemData in ipairs(self.collection) do
            if itemData:IsPending() then
                return true
            end
        end
        return false
    end

    local function UpdateMerchant()
        MerchantDataProvider:UpdateMerchant(true)
    end

    hooksecurefunc("SetMerchantFilter", UpdateMerchant)
    hooksecurefunc("ResetSetMerchantFilter", UpdateMerchant)

    local Service = CreateFrame("Frame")

    ---@type WowEvent[]
    Service.MerchantEvents = {
        "MERCHANT_UPDATE",
        "MERCHANT_FILTER_ITEM_UPDATE",
        "HEIRLOOMS_UPDATED",
        "GET_ITEM_INFO_RECEIVED",
        "ITEM_DATA_LOAD_RESULT",
    }

    ---@param event WowEvent
    ---@param ... any
    function Service:OnEvent(event, ...)
        if event == "MERCHANT_SHOW" then
            FrameUtil.RegisterFrameForEvents(self, self.MerchantEvents)
            MerchantDataProvider:UpdateMerchant(true)
        elseif event == "MERCHANT_CLOSED" then
            FrameUtil.UnregisterFrameForEvents(self, self.MerchantEvents)
            MerchantDataProvider:UpdateMerchant()
        elseif event == "UNIT_INVENTORY_CHANGED" then
            local unit = ...
            if unit == "player" then
                MerchantDataProvider:UpdateMerchantStockItems()
            end
        elseif event == "MERCHANT_UPDATE" then
            MerchantDataProvider:UpdateMerchantPendingItems()
        elseif event == "MERCHANT_FILTER_ITEM_UPDATE" then
            local itemID = ...
            MerchantDataProvider:UpdateMerchantItemByID(itemID)
        elseif event == "HEIRLOOMS_UPDATED" then
            local itemID, updateReason = ...
            if itemID and updateReason == "NEW" then
                MerchantDataProvider:UpdateMerchantItemByID(itemID)
            end
        elseif event == "GET_ITEM_INFO_RECEIVED" or event == "ITEM_DATA_LOAD_RESULT" then
            local itemID, success = ...
            if success then
                MerchantDataProvider:UpdateMerchantItemByID(itemID, true)
            end
        end
        if MerchantDataProvider:HasMerchantPendingItems() then
            Service:StartPending()
        else
            Service:StopPending()
        end
    end

    Service:SetScript("OnEvent", Service.OnEvent)
    Service:RegisterEvent("MERCHANT_SHOW")
    Service:RegisterEvent("MERCHANT_CLOSED")
    Service:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")

    local PendingTicker

    local function PendingTick()
        if MerchantDataProvider:HasMerchantPendingItems() then
            MerchantDataProvider:UpdateMerchantPendingItems()
        else
            Service:StopPending()
        end
    end

    function Service:StartPending()
        if PendingTicker then
            return
        end
        PendingTicker = C_Timer.NewTicker(0.25, PendingTick)
    end

    function Service:StopPending()
        if not PendingTicker then
            return
        end
        PendingTicker:Cancel()
        PendingTicker = nil
    end

end

---@class MerchantItemProvider
local MerchantItemProvider do

    ---@alias MerchantItemProviderEvent DataProviderEvent|"OnMerchantItemsShow"|"OnMerchantItemsUpdate"|"OnMerchantItemsReady"|"OnMerchantItemsHide"

    ---@class MerchantItemProvider : DataProvider
    ---@field public Event table<MerchantItemProviderEvent, number>
    ---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: MerchantItemProviderEvent[])

    MerchantItemProvider = CreateDataProvider() ---@type MerchantItemProvider

    MerchantItemProvider:GenerateCallbackEvents({
        "OnMerchantItemsShow",
        "OnMerchantItemsUpdate",
        "OnMerchantItemsReady",
        "OnMerchantItemsHide",
    })

    ---@alias MerchantItemFilter fun(itemData: MerchantItem): boolean?

    -- ---@type MerchantItemFilter[]
    -- MerchantItemProvider.Filters = {}

    -- ---@type table<MerchantItem, boolean?>
    -- MerchantItemProvider.Filtered = {}

    -- function MerchantItemProvider:InternalFlush()
    --     self:Flush()
    --     table.wipe(self.Filtered)
    -- end

    -- ---@param items MerchantItem[]
    -- function MerchantItemProvider:InternalInsert(items)
    --     local collection = {}
    --     local index = 0
    --     for _, itemData in ipairs(items) do
    --         local filtered
    --         for _, filter in ipairs(self.Filters) do
    --             if filter(itemData) then
    --                 filtered = true
    --                 break
    --             else
    --                 filtered = false
    --             end
    --         end
    --         if not filtered then
    --             index = index + 1
    --             collection[index] = itemData
    --         end
    --     end
    --     self:InsertTable(collection)
    -- end

    -- function MerchantItemProvider:Enumerate()
    --     local index = 0
    --     local itemData
    --     return function()
    --         repeat
    --             index = index + 1
    --             itemData = self.collection[index]
    --             if not itemData then
    --                 return
    --             end
    --             if not self.Filtered[itemData] then
    --                 break
    --             end
    --         until not itemData
    --         return itemData
    --     end
    -- end

    local function OnShow()
        MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnMerchantItemsShow)
    end

    ---@param isFullUpdate boolean
    local function OnReady(isFullUpdate)
        local items = MerchantDataProvider:GetMerchantItems()
        if isFullUpdate == true then
            local hasSortComparator = MerchantItemProvider:HasSortComparator()
            local hasUpdated = false
            for oldIndex, oldItemData in ipairs(MerchantItemProvider.collection) do
                local itemData ---@type MerchantItem?
                for _, newItemData in ipairs(items) do
                    if oldItemData:GetIndex() == newItemData:GetIndex() then
                        itemData = newItemData
                        break
                    end
                end
                if itemData then
                    hasUpdated = true
                    MerchantItemProvider.collection[oldIndex] = itemData
                    -- MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnInsert, oldIndex, itemData, hasSortComparator)
                end
            end
            if hasUpdated then
                MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnSizeChanged, hasSortComparator)
                MerchantItemProvider:Sort()
            end
            MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnMerchantItemsUpdate)
            return
        end
        MerchantItemProvider:Flush()
        MerchantItemProvider:InsertTable(items)
        MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnMerchantItemsReady)
    end

    ---@param isReady boolean
    local function OnUpdate(_, isReady)
        if isReady ~= true then
            return
        end
        OnReady(true)
    end

    local function OnHide()
        MerchantItemProvider:Flush()
        MerchantItemProvider:TriggerEvent(MerchantItemProvider.Event.OnMerchantItemsHide)
    end

    MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnMerchantShow, OnShow)
    MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnMerchantReady, OnReady)
    MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnMerchantUpdate, OnUpdate)
    MerchantDataProvider:RegisterCallback(MerchantDataProvider.Event.OnMerchantHide, OnHide)

end

---@class CompactVendorFrame : Frame
local Frame do

    ---@diagnostic disable-next-line: assign-type-mismatch
    Frame = CreateFrame("Frame", addonName .. "Frame", MerchantBuyBackItem) ---@type CompactVendorFrame

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
            end
        end
    end

    function Frame:OnLoad()

        do

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

        do

            self:SetFrameStrata("HIGH")

            self:SetPoint("TOPLEFT", MerchantFrameInset, "TOPLEFT", 3, -2)
            self:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOMRIGHT", -20, 55)

            self:SetScript("OnEvent", self.OnEvent)
            FrameUtil.RegisterFrameForEvents(self, self.Events)

            self:SetScript("OnShow", self.OnShow)
            self:SetScript("OnHide", self.OnHide)

        end

        do

            ---@class CompactVendorFrameSearchBox : EditBox
            ---@field public clearButton Button

            ---@diagnostic disable-next-line: assign-type-mismatch
            self.Search = CreateFrame("EditBox", nil, self, "SearchBoxTemplate") ---@type CompactVendorFrameSearchBox
            self.Search:SetSize(102, 32)
            self.Search:SetMultiLine(false)
            self.Search:SetMaxLetters(255)
            self.Search:SetCountInvisibleLetters(true)
            self.Search:SetAutoFocus(false)

            do

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
            ---@alias ScrollBoxDataProvider MerchantItemProvider
            ---@alias ScrollBoxFrameData any
            ---@alias ScrollBoxFrame Frame
            ---@alias ScrollBoxBaseEvents "OnAllowScrollChanged"|"OnSizeChanged"|"OnScroll"|"OnLayout"
            ---@alias ScrollBoxListEvents "OnAcquiredFrame"|"OnInitializedFrame"|"OnReleasedFrame"|"OnDataRangeChanged"|"OnUpdate"
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

            do

                local view = CreateScrollBoxListLinearView() ---@type ViewPolyfill
                view.templateInfos["CompactVendorFrameMerchantButtonTemplate"] = { type = "Button", width = 300, height = 24, keyValues = {} }
                view:SetElementInitializer("CompactVendorFrameMerchantButtonTemplate", CreateMerchantItemButton)
                view:SetPadding(2, 2, 2, 2, 0)
                ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

                self.ScrollBox:SetDataProvider(MerchantItemProvider)

                local function Refresh()
                    self.ScrollBox:Update()
                end

                MerchantItemProvider:RegisterCallback(MerchantItemProvider.Event.OnMerchantItemsShow, Refresh)
                MerchantItemProvider:RegisterCallback(MerchantItemProvider.Event.OnMerchantItemsReady, Refresh)
                MerchantItemProvider:RegisterCallback(MerchantItemProvider.Event.OnMerchantItemsUpdate, Refresh)

            end

        end

    end

    function Frame:OnShow()
        self.ScrollBox:Update()
    end

    function Frame:OnHide()
    end

    Frame:OnLoad()

end

---@class CompactVendorFrameAutoSizeTemplate
local CompactVendorFrameAutoSizeTemplate do

    CompactVendorFrameAutoSizeTemplate = {} ---@class CompactVendorFrameAutoSizeTemplate : Frame
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
        if width then self:SetWidth(width) end
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
        -- start watching for scroll events and move the StackSplitFrame accordingly and track the correct StackSplitFrameOwnedBy for when we perform a purchase
    end

    function CompactVendorFrameMerchantButtonQuantityTemplate:OnHide()
        -- stop watching for scroll events and move the StackSplitFrame accordingly and track the correct StackSplitFrameOwnedBy for when we perform a purchase
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

    ---@class CompactVendorFrameMerchantButtonCostButtonTemplateIcon : Frame, CompactVendorFrameAutoSizeTemplate
    ---@field public Texture Texture
    ---@field public Count FontString

    ---@class CompactVendorFrameMerchantButtonCostButtonTemplate : Button, CompactVendorFrameAutoSizeTemplate
    ---@field public parent CompactVendorFrameMerchantButtonCostTemplate
    ---@field public costType? CompactVendorFrameMerchantButtonCostButtonCostType
    ---@field public link? string
    ---@field public price? number
    ---@field public Name FontString
    ---@field public Icon CompactVendorFrameMerchantButtonCostButtonTemplateIcon
    ---@field public CircleMask Texture MaskTexture
    ---@field public Count FontString

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
        self.Name:SetText()
        self.Icon:Hide()
        self.Icon.Texture:SetTexture(0)
        self.Icon.Count:SetText()
    end

    ---@param costType CompactVendorFrameMerchantButtonCostButtonCostType
    ---@param canAfford boolean
    ---@param text string|number
    ---@param texture? number|string
    ---@param price? number
    ---@param link? string
    ---@param name? string
    function CompactVendorFrameMerchantButtonCostButtonTemplate:Update(costType, canAfford, text, texture, price, link, name)
        self:Reset()
        if canAfford then
            self.Icon.Texture:SetVertexColor(1, 1, 1)
        else
            self.Icon.Texture:SetVertexColor(1, 0, 0)
        end
        if costType == "Item" then
            self.Icon.Count:SetText(text)
            self.Icon.Texture:SetTexture(texture or 0)
            self.Icon:Show()
        elseif costType == "Money" then
            self.Name:SetText(text)
        end
        self.costType = costType
        self.link = link
        self.price = price
        self:Show()
        if costType == "Money" then
            self:SetWidth(max(16, self.Name:GetStringWidth() + (text:find("GoldIcon") and 6 or 0) + (text:find("SilverIcon") and 6 or 0) + (text:find("CopperIcon") and 6 or 0)))
        end
    end

    ---@param merchantItem MerchantItem
    ---@param costType CompactVendorFrameMerchantButtonCostButtonCostType
    ---@param pool CompactVendorFrameMerchantButtonCostTemplatePool
    ---@return boolean? success
    function CompactVendorFrameMerchantButtonCostButtonTemplate:Set(merchantItem, costType, pool)
        local cost = self
        if costType == "Item" then
            for i = 1, merchantItem.extendedCostCount do
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
                    cost:Update(costType, canAfford, text, costItem.texture, costItem.count, costItem.itemLink, costItem.name)
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
            cost.Name:SetText()
            cost.Icon:Hide()
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
    ---@field public Icon Texture
    ---@field public CircleMask Texture MaskTexture
    ---@field public Name FontString
    ---@field public Quantity CompactVendorFrameMerchantButtonQuantityTemplate
    ---@field public Cost CompactVendorFrameMerchantButtonCostTemplate

    CompactVendorFrameMerchantButtonTemplate = {} ---@class CompactVendorFrameMerchantButtonTemplate
    _G.CompactVendorFrameMerchantButtonTemplate = CompactVendorFrameMerchantButtonTemplate

    function CompactVendorFrameMerchantButtonTemplate:OnLoad()
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end

    function CompactVendorFrameMerchantButtonTemplate:OnShow()
        UpdateMerchantItemButton(self, self.merchantItem)
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
        else
            local index = merchantItem:GetIndex()
            if CanAffordMerchantItem(index) == false then
                SetCursor("BUY_ERROR_CURSOR")
            else
                SetCursor("BUY_CURSOR")
            end
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

end
