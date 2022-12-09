---@enum CostTypeEnum
local CostType = {
    Gold = 1,
    Currency = 2,
    GoldAndCurrency = 3,
}

---@enum AvailabilityTypeEnum
local AvailabilityType = {
    NotAvailable = 1,
    NotUsable = 2,
    NotAvailableNotUsable = 3,
    AvailableAndUsable = 4,
}

---@class VladsVendorDataProviderItemDataMixin
---@field public index number
---@field public name? string
---@field public texture string|number
---@field public price number
---@field public stackCount number
---@field public numAvailable number
---@field public isPurchasable boolean
---@field public isUsable boolean
---@field public extendedCost boolean
---@field public currencyID? number
---@field public spellID number
---@field public canAfford boolean
---@field public costType CostTypeEnum
---@field public itemLink? string
---@field public merchantItemID number
---@field public isHeirloom boolean
---@field public isKnownHeirloom boolean
---@field public showNonrefundablePrompt boolean
---@field public tintRed boolean
---@field public availabilityType AvailabilityTypeEnum
---@field public canRefund boolean

---@class VladsVendorDataProviderItemDataMixin
local VladsVendorDataProviderItemDataMixin = {}

---@param currencyID number
---@param numAvailable number
---@param name string
---@param texture string|number
---@param quality? number
---@return string name, string|number texture, number numItems, number? quality
local function GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality)
    return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality) ---@diagnostic disable-line: undefined-global
end

---@class SimpleColor
---@field public r number
---@field public g number
---@field public b number
---@field public hex string

local ItemQualityColorToHexColor = {} ---@type table<number, SimpleColor>
local ItemHexColorToQualityIndex = {} ---@type table<string, number>
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

---@param quality? number
---@return SimpleColor? color
local function GetColorFromQuality(quality)
    if not quality then
        return
    end
    return ItemQualityColorToHexColor[quality]
end

---@param itemLink? string
---@return number? quality
local function GetQualityFromLink(itemLink)
    if not itemLink then
        return
    end
    local hex = itemLink:match("|c([%x]+)|")
    if not hex then
        return
    end
    return ItemHexColorToQualityIndex[hex]
end

---@param index number
function VladsVendorDataProviderItemDataMixin:Init(index)
    self.index = index
    self:Refresh()
end

function VladsVendorDataProviderItemDataMixin:IsPending()
    return not self.itemLink
end

function VladsVendorDataProviderItemDataMixin:Refresh()
    self.name, self.texture, self.price, self.stackCount, self.numAvailable, self.isPurchasable, self.isUsable, self.extendedCost, self.currencyID, self.spellID = GetMerchantItemInfo(self.index) ---@diagnostic disable-line: assign-type-mismatch
    if self.currencyID then
        self.name, self.texture, self.numAvailable, self.quality = GetCurrencyContainerInfo(self.currencyID, self.numAvailable, self.name, self.texture, nil)
    end
    self.canAfford = CanAffordMerchantItem(self.index) ---@diagnostic disable-line: assign-type-mismatch
    if self.extendedCost and self.price <= 0 then
        self.costType = CostType.Currency
    elseif self.extendedCost and self.price > 0 then
        self.costType = CostType.GoldAndCurrency
    else
        self.costType = CostType.Gold
    end
    self.itemLink = GetMerchantItemLink(self.index)---@diagnostic disable-line: assign-type-mismatch
    self.merchantItemID = GetMerchantItemID(self.index)---@diagnostic disable-line: assign-type-mismatch
    self.isHeirloom = self.merchantItemID and C_Heirloom.IsItemHeirloom(self.merchantItemID)---@diagnostic disable-line: assign-type-mismatch
    self.isKnownHeirloom = self.isHeirloom and C_Heirloom.PlayerHasHeirloom(self.merchantItemID)---@diagnostic disable-line: assign-type-mismatch
    self.showNonrefundablePrompt = not C_MerchantFrame.IsMerchantItemRefundable(self.index)
    self.tintRed = not self.isPurchasable or (not self.isUsable and not self.isHeirloom)
    if self.numAvailable == 0 or self.isKnownHeirloom then
        if self.tintRed then
            self.availabilityType = AvailabilityType.NotAvailable
        else
            self.availabilityType = AvailabilityType.NotUsable
        end
    elseif self.tintRed then
        self.availabilityType = AvailabilityType.NotUsable
    else
        self.availabilityType = AvailabilityType.AvailableAndUsable
    end
    if not self.quality then
        self.quality = GetQualityFromLink(self.itemLink)
    end
end

function VladsVendorDataProviderItemDataMixin:GetIndex()
    return self.index
end

---@param index number
local function CreateMerchantItem(index)
    local itemData = Mixin({}, VladsVendorDataProviderItemDataMixin)
    itemData:Init(index)
    return itemData
end

---@alias CallbackRegistryCallbackFunc fun(owner: number, ...: any)

---@class CallbackRegistryCallbackHandle
---@field public Unregister fun()

---@class CallbackRegistry
---@field public SetUndefinedEventsAllowed fun(self: CallbackRegistry, allowed: boolean)
---@field public HasRegistrantsForEvent fun(self: CallbackRegistry, event: string|number): boolean
---@field public SecureInsertEvent fun(self: CallbackRegistry, event: string|number)
---@field public RegisterCallback fun(self: CallbackRegistry, event: string|number, func: CallbackRegistryCallbackFunc, owner: string|nil, ...: any)
---@field public RegisterCallbackWithHandle fun(self: CallbackRegistry, event: string|number, func: CallbackRegistryCallbackFunc, owner: string|nil, ...: any): CallbackRegistryCallbackHandle
---@field public TriggerEvent fun(self: CallbackRegistry, event: string|number, ...: any)
---@field public UnregisterCallback fun(self: CallbackRegistry, event: string|number, owner: string|number)
---@field public GenerateCallbackEvents fun(self: CallbackRegistry, events: DataProviderEvent[])

---@alias DataProviderItemData VladsVendorDataProviderItemDataMixin

---@alias DataProviderEnumerator fun(table: DataProviderItemData[], i?: number): number, DataProviderItemData

---@alias DataProviderPredicate fun(itemData: DataProviderItemData): boolean?

---@alias DataProviderSortComparator fun(a: DataProviderItemData, b: DataProviderItemData): boolean

---@alias DataProviderForEach fun(itemData: DataProviderItemData)

---@alias DataProviderEvent "OnMerchantShow"|"OnMerchantHide"|"OnMerchantReady"|"OnMerchantFilter"

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

---@diagnostic disable-next-line: undefined-global
--[[ global ]] VladsVendorDataProvider = CreateDataProvider() ---@class DataProvider

VladsVendorDataProvider:GenerateCallbackEvents({
    "OnMerchantShow",
    "OnMerchantHide",
    "OnMerchantReady",
    "OnMerchantFilter",
})

---@return boolean merchantExists, boolean sameMerchant
function VladsVendorDataProvider:UpdateMerchantInfo()
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
function VladsVendorDataProvider:GetMerchantInfo()
    return self.guid, self.name
end

---@param forceFullUpdate? boolean
function VladsVendorDataProvider:UpdateMerchant(forceFullUpdate)
    local merchantExists, sameMerchant = self:UpdateMerchantInfo()
    if sameMerchant and forceFullUpdate ~= true then
        return
    end
    self:Flush()
    if not merchantExists then
        return
    end
    local numMerchantItems = GetMerchantNumItems()
    local collection = {} ---@type DataProviderItemData[]
    for index = 1, numMerchantItems do
        local itemData = CreateMerchantItem(index)
        collection[index] = itemData
    end
    self:InsertTable(collection)
end

function VladsVendorDataProvider:UpdateMerchantPendingItems()
    local pending = 0
    for _, itemData in self:Enumerate() do
        if itemData:IsPending() then
            pending = pending + 1
            itemData:Refresh()
            if not itemData:IsPending() then
                pending = pending - 1
            end
        end
    end
    if pending == 0 and not self.isReady then
        self.isReady = true
        self:TriggerEvent(self.Event.OnMerchantReady)
    end
end

---@param itemID number
function VladsVendorDataProvider:UpdateMerchantItemByID(itemID)
    local items = self:GetMerchantItems(function(itemData)
        return itemData.merchantItemID == itemID
    end)
    if not items then
        return
    end
    for _, itemData in ipairs(items) do
        itemData:Refresh()
    end
end

function VladsVendorDataProvider:UpdateMerchantStockItems()
    local items = self:GetMerchantItems()
    if not items then
        return
    end
    for _, itemData in ipairs(items) do
        if itemData.numAvailable ~= -1 then
            itemData:Refresh()
        end
    end
end

---@param predicate? DataProviderPredicate
---@return DataProviderItemData[]? merchantItems
function VladsVendorDataProvider:GetMerchantItems(predicate)
    if not predicate then
        local collection = self.collection
        if collection[1] then
            return collection
        end
        return
    end
    local collection = {} ---@type DataProviderItemData
    local index = 0
    for _, itemData in self:Enumerate() do
        if predicate(itemData) then
            index = index + 1
            collection[index] = itemData
        end
    end
    if index > 0 then
        return collection
    end
end

---@param index number
---@return DataProviderItemData? itemData
function VladsVendorDataProvider:GetMerchantItem(index)
    return self.collection[index]
end

function VladsVendorDataProvider:HasMerchantItems()
    return self.collection[1] and true or false
end

function VladsVendorDataProvider:GetNumMerchantItems()
    return self:GetSize()
end

---@enum MerchantFilterEnum
VladsVendorDataProvider.Filter = {
    LE_LOOT_FILTER_RESET = 0, -- custom
    LE_LOOT_FILTER_ALL = 1,
    LE_LOOT_FILTER_CLASS = 2,
    LE_LOOT_FILTER_SPEC1 = 3,
    LE_LOOT_FILTER_SPEC2 = 4,
    LE_LOOT_FILTER_SPEC3 = 5,
    LE_LOOT_FILTER_SPEC4 = 6,
    LE_LOOT_FILTER_BOE = 7,
}

---@param filter MerchantFilterEnum
hooksecurefunc("SetMerchantFilter", function(filter)
    VladsVendorDataProvider:TriggerEvent(VladsVendorDataProvider.Event.OnMerchantFilter, filter)
    VladsVendorDataProvider:UpdateMerchant(true)
end)

hooksecurefunc("ResetSetMerchantFilter", function()
    VladsVendorDataProvider:TriggerEvent(VladsVendorDataProvider.Event.OnMerchantFilter, VladsVendorDataProvider.Filter.LE_LOOT_FILTER_RESET)
    VladsVendorDataProvider:UpdateMerchant(true)
end)

local function OnEvent(_, event, ...)
    if event == "MERCHANT_SHOW" then
        VladsVendorDataProvider:UpdateMerchant()
        VladsVendorDataProvider:UpdateMerchantPendingItems()
    elseif event == "MERCHANT_CLOSED" then
        VladsVendorDataProvider:UpdateMerchant()
    elseif event == "MERCHANT_UPDATE" then
        VladsVendorDataProvider:UpdateMerchantPendingItems()
    elseif event == "MERCHANT_FILTER_ITEM_UPDATE" then
        local itemID = ...
        VladsVendorDataProvider:UpdateMerchantItemByID(itemID)
    elseif event == "HEIRLOOMS_UPDATED" then
        local itemID, updateReason = ...
        if itemID and updateReason == "NEW" then
            VladsVendorDataProvider:UpdateMerchantItemByID(itemID)
        end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local itemID, success = ...
        if success then
            VladsVendorDataProvider:UpdateMerchantItemByID(itemID)
        end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            VladsVendorDataProvider:UpdateMerchantStockItems()
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("MERCHANT_UPDATE")
frame:RegisterEvent("MERCHANT_FILTER_ITEM_UPDATE")
frame:RegisterEvent("HEIRLOOMS_UPDATED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")

-- VladsVendorDataProvider:RegisterCallback(VladsVendorDataProvider.Event.OnMerchantShow, function() print("Show") end)
-- VladsVendorDataProvider:RegisterCallback(VladsVendorDataProvider.Event.OnMerchantHide, function() print("Hide") end)
-- VladsVendorDataProvider:RegisterCallback(VladsVendorDataProvider.Event.OnMerchantFilter, function(_, filter) print("Filter", filter) end)
-- VladsVendorDataProvider:RegisterCallback(VladsVendorDataProvider.Event.OnMerchantReady, function() print("Ready") local items = VladsVendorDataProvider:GetMerchantItems() if items then for index, itemData in ipairs(items) do print(index, itemData.index, itemData.itemLink, itemData.costType, itemData.availabilityType, "") end end end)
