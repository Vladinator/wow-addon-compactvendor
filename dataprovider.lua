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

---@class VladsVendorDataProviderElementDataMixin
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

---@class VladsVendorDataProviderElementDataMixin
local VladsVendorDataProviderElementDataMixin = {}

---@param currencyID number
---@param numAvailable number
---@param name string
---@param texture string|number
---@param quality? number
---@return string name, string|number texture, number numItems, number? quality
local function GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality)
    return CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, quality) ---@diagnostic disable-line: undefined-global
end

---@param index number
function VladsVendorDataProviderElementDataMixin:Init(index)
    self.index = index
    self:Refresh()
end

function VladsVendorDataProviderElementDataMixin:Refresh()
    self.name, self.texture, self.price, self.stackCount, self.numAvailable, self.isPurchasable, self.isUsable, self.extendedCost, self.currencyID, self.spellID = GetMerchantItemInfo(self.index) ---@diagnostic disable-line: assign-type-mismatch
    if self.currencyID then
        self.name, self.texture, self.numAvailable = GetCurrencyContainerInfo(self.currencyID, self.numAvailable, self.name, self.texture, nil)
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
end

---@param index number
local function CreateMerchantItem(index)
    local elementData = Mixin({}, VladsVendorDataProviderElementDataMixin)
    elementData:Init(index)
    return elementData
end

---@alias DataProviderElementData VladsVendorDataProviderElementDataMixin

---@alias DataProviderEnumerator fun(table: DataProviderElementData[], i?: number): number, DataProviderElementData

---@alias DataProviderPredicate fun(elementData: DataProviderElementData): boolean?

---@alias DataProviderSortComparator fun(a: DataProviderElementData, b: DataProviderElementData): boolean

---@alias DataProviderForEach fun(elementData: DataProviderElementData)

---@class DataProvider
---@field public collection DataProviderElementData[]
---@field public sortComparator? DataProviderSortComparator
---@field public Init fun(self: DataProvider, tbl?: DataProviderElementData[])
---@field public Enumerate fun(self: DataProvider, indexBegin?: number, indexEnd?: number): DataProviderEnumerator
---@field public GetSize fun(self: DataProvider): number
---@field public IsEmpty fun(self: DataProvider): boolean
---@field public InsertInternal fun(self: DataProvider, elementData: DataProviderElementData, hasSortComparator: boolean)
---@field public Insert fun(self: DataProvider, ...: DataProviderElementData)
---@field public InsertTable fun(self: DataProvider, tbl: DataProviderElementData[])
---@field public InsertTableRange fun(self: DataProvider, tbl: DataProviderElementData[], indexBegin: number, indexEnd: number)
---@field public Remove fun(self: DataProvider, ...: DataProviderElementData): removedIndex: number
---@field public RemoveByPredicate fun(self: DataProvider, predicate: DataProviderPredicate)
---@field public RemoveIndex fun(self: DataProvider, index: number)
---@field public RemoveIndexRange fun(self: DataProvider, indexBegin: number, indexEnd: number)
---@field public SetSortComparator fun(self: DataProvider, sortComparator: DataProviderSortComparator, skipSort: boolean)
---@field public HasSortComparator fun(self: DataProvider): boolean
---@field public Sort fun(self: DataProvider)
---@field public Find fun(self: DataProvider, index: number): elementData: DataProviderElementData?
---@field public FindIndex fun(self: DataProvider, elementData: DataProviderElementData): index: number?, elementDataIter: DataProviderEnumerator?
---@field public FindByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): index: number?, elementData: DataProviderElementData?
---@field public FindElementDataByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): elementData: DataProviderElementData?
---@field public FindIndexByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): index: number?
---@field public ContainsByPredicate fun(self: DataProvider, predicate: DataProviderPredicate): boolean
---@field public ForEach fun(self: DataProvider, func: DataProviderForEach)
---@field public Flush fun(self: DataProvider)

---@diagnostic disable-next-line: undefined-global
--[[ global ]] VladsVendorDataProvider = CreateDataProvider() ---@class DataProvider

---@return boolean merchantExists, boolean sameMerchant
function VladsVendorDataProvider:UpdateMerchantInfo()
    local guid = self.guid
    self.guid = UnitGUID("npc")
    self.name = UnitName("npc")
    return not not self.guid, self.guid == guid
end

---@return string guid, string name
function VladsVendorDataProvider:GetMerchantInfo()
    return self.guid, self.name
end

function VladsVendorDataProvider:UpdateMerchant()
    local merchantExists, sameMerchant = self:UpdateMerchantInfo()
    if sameMerchant then
        return
    end
    self:Flush()
    if not merchantExists then
        return
    end
    local numMerchantItems = GetMerchantNumItems()
    local collection = {} ---@type DataProviderElementData[]
    for index = 1, numMerchantItems do
        local elementData = CreateMerchantItem(index)
        collection[index] = elementData
    end
    self:InsertTable(collection)
end

---@param predicate? DataProviderPredicate
---@return DataProviderElementData[]? merchantItems
function VladsVendorDataProvider:GetMerchantItems(predicate)
    if not predicate then
        return self.collection
    end
    local collection = {} ---@type DataProviderElementData
    local index = 0
    for _, elementData in self:Enumerate() do
        if predicate(elementData) then
            index = index + 1
            collection[index] = elementData
        end
    end
    if index > 0 then
        return collection
    end
end

---@param index number
---@return DataProviderElementData? elementData
function VladsVendorDataProvider:GetMerchantItem(index)
    return self.collection[index]
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, event, itemID, success)
    if event ~= "ITEM_DATA_LOAD_RESULT" and event ~= "GET_ITEM_INFO_RECEIVED" then
        return
    end
    if not success then
        return
    end
    if VladsVendorDataProvider:IsEmpty() then
        return
    end
    for _, elementData in pairs(VladsVendorDataProvider.collection) do
        if elementData.merchantItemID == itemID then
            elementData:Refresh()
        end
    end
end)
