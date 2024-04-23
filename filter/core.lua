local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded ---@diagnostic disable-line: deprecated

local CompactVendorFrame = CompactVendorFrame ---@type CompactVendorFrame

---@class DropdownInfoPolyfill
---@field public keepShownOnClick boolean?
---@field public isNotRadio boolean?
---@field public notCheckable boolean?
---@field public checked boolean?
---@field public isTitle boolean?
---@field public disabled boolean?
---@field public colorCode string?
---@field public hasArrow boolean?
---@field public value any?
---@field public text string
---@field public func fun(self: Button, arg1: any?, arg2: any?, checked :boolean?, mouseButton: string?)
---@field public arg1? any
---@field public arg2? any

local CloseDropDownMenus = CloseDropDownMenus ---@type fun(level?: number)
local ToggleDropDownMenu = ToggleDropDownMenu ---@type fun(level?: number, value?: any, dropDownFrame?: Region, anchorName?: Region, xOffset?: number, yOffset?: number, menuList?: table, button?: string, autoHideDelay?: boolean)
local UIDropDownMenu_SetInitializeFunction = UIDropDownMenu_SetInitializeFunction ---@type fun(self: Region, init: fun())
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton ---@type fun(info: DropdownInfoPolyfill, level?: number)

---@class CompactVendorFilterButtonTemplate
local CompactVendorFilterButtonTemplate do

    ---@class CompactVendorFilterButtonTemplate : Button
    ---@field public Icon Texture
    ---@field public All Texture

    CompactVendorFilterButtonTemplate = {}
    _G.CompactVendorFilterButtonTemplate = CompactVendorFilterButtonTemplate

    function CompactVendorFilterButtonTemplate:OnLoad()
        C_Timer.After(0.01, function() self.Menu = CompactVendorFilterFrame end) -- HOTFIX: the template XML loads after the frame runs this code so the reference isn't available just yet
        self:SetParent(MerchantFrameCloseButton)
        self:RegisterForClicks("LeftButtonUp")
        self:SetPoint("RIGHT", MerchantFrameCloseButton, "LEFT", 8 - 4, 0)
        self:SetScale(0.85)
        hooksecurefunc("MerchantFrame_Update", function() self:SetShown(self.Menu and MerchantFrame.selectedTab == 1) end)
    end

    function CompactVendorFilterButtonTemplate:OnEnter()
        self.IsOnButton = true
        self.IsShown = self:IsDropDownShown()
    end

    function CompactVendorFilterButtonTemplate:OnLeave()
        self.IsOnButton = false
        self.IsShown = self:IsDropDownShown()
    end

    function CompactVendorFilterButtonTemplate:OnMouseDown()
        if self.IsOnButton and self.IsShown then
            self.IsShown = false
            CloseDropDownMenus()
        else
            self.IsShown = true
            ToggleDropDownMenu(1, nil, self.Menu, self, 0, 0)
        end
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end

    function CompactVendorFilterButtonTemplate:IsDropDownShown()
        return DropDownList1.dropdown == self.Menu and DropDownList1:IsShown()
    end

end

---@class CompactVendorFilterFrameTemplate
local CompactVendorFilterFrameTemplate do

    ---@class CompactVendorFilterFrameTemplate : Frame

    CompactVendorFilterFrameTemplate = {}
    _G.CompactVendorFilterFrameTemplate = CompactVendorFilterFrameTemplate

    ---@type WowEvent[]
    CompactVendorFilterFrameTemplate.Events = {
        "ADDON_LOADED",
        "MERCHANT_SHOW",
        "MERCHANT_CLOSED",
    }

    function CompactVendorFilterFrameTemplate:OnLoad()
        self.MerchantDataProvider = CompactVendorFrame.ScrollBox:GetDataProvider()
        self.Button = CompactVendorFilterButton ---@type CompactVendorFilterButtonTemplate
        self:SetParent(self.Button) ---@diagnostic disable-line: param-type-mismatch
        self:SetFrameStrata("HIGH")
        self:SetToplevel(true)
        self:EnableMouse(true)
        self:Hide()
        FrameUtil.RegisterFrameForEvents(self, self.Events)
        self.Filters = {} ---@type table<string, CompactVendorFilterTemplate>
        ---@diagnostic disable-next-line: missing-fields
        self.DropdownInfo = {} ---@type DropdownInfoPolyfill
        self.DropdownSortedFilters = {} ---@type string[]
        self.VendorOpen = false
        self.VendorUpdating = false
        UIDropDownMenu_SetInitializeFunction(self, self.DropdownInitialize)
        self.MerchantDataProvider:RegisterCallback(self.MerchantDataProvider.Event.OnReady, function() self:Refresh() end)
    end

    ---@param event WowEvent
    ---@param ... any
    function CompactVendorFilterFrameTemplate:OnEvent(event, ...)
        if event == "ADDON_LOADED" then
            self:SetupAddOnSupport()
        elseif event == "MERCHANT_SHOW" then
            self:MerchantOpen()
        elseif event == "MERCHANT_CLOSED" then
            self:MerchantClose()
        end
    end

    function CompactVendorFilterFrameTemplate:MerchantOpen()
        self.VendorOpen = true
        self:Refresh()
        C_Timer.After(0.5, function() self:Refresh() end) -- HOTFIX: force update the dropdown choices once data is fully loaded
    end

    function CompactVendorFilterFrameTemplate:MerchantClose()
		self.VendorOpen = false
		for _, filter in pairs(self.Filters) do
			filter:ClearAll()
		end
		CloseDropDownMenus()
    end

    ---@param filter CompactVendorFilterTemplate
    function CompactVendorFilterFrameTemplate:AddFilter(filter)
        assert(type(filter) == "table", "CompactVendorFilter AddFilter requires a valid filter object.")
        assert(type(filter.name) == "string", "CompactVendorFilter AddFilter requires a filter name.")
        assert(type(filter.defaults) == "table", "CompactVendorFilter AddFilter requires filter defaults.")
        assert(type(filter.OnLoad) == "function", "CompactVendorFilter AddFilter requires a filter object with a OnLoad method.")
        assert(type(filter.OnRefresh) == "function", "CompactVendorFilter AddFilter requires a filter object with a OnRefresh method.")
        assert(type(filter.ClearAll) == "function", "CompactVendorFilter AddFilter requires a filter object with a ClearAll method.")
        assert(type(filter.ResetFilter) == "function", "CompactVendorFilter AddFilter requires a filter object with a ResetFilter method.")
        assert(type(filter.ShowAll) == "function", "CompactVendorFilter AddFilter requires a filter object with a ShowAll method.")
        assert(type(filter.FilterAll) == "function", "CompactVendorFilter AddFilter requires a filter object with a FilterAll method.")
        assert(type(filter.IsRelevant) == "function", "CompactVendorFilter AddFilter requires a filter object with a IsRelevant method.")
        assert(type(filter.GetDropdown) == "function", "CompactVendorFilter AddFilter requires a filter object with a GetDropdown method.")
        assert(type(filter.IsFiltered) == "function", "CompactVendorFilter AddFilter requires a filter object with a IsFiltered method.")
        filter:OnLoad(self)
        self.Filters[filter.name] = filter
        self.MerchantDataProvider:AddFilter(function(...) return filter:IsFiltered(...) end)
        return true
    end

    function CompactVendorFilterFrameTemplate:RefreshDropdown()
        ToggleDropDownMenu(1, nil, self, self.Button, 0, 0)
        ToggleDropDownMenu(1, nil, self, self.Button, 0, 0)
        self:Refresh()
    end

    function CompactVendorFilterFrameTemplate:Refresh()
        if self.VendorUpdating then
            return
        end
        self.VendorUpdating = true
        for _, filter in pairs(self.Filters) do
            filter:OnRefresh()
            if not filter:IsRelevant() then
                filter:ShowAll()
            end
        end
        self.MerchantDataProvider:Refresh()
        self.VendorUpdating = false
    end

    ---@return MerchantItem[] items
    function CompactVendorFilterFrameTemplate:GetMerchantItems()
        return self.MerchantDataProvider:GetMerchantItems()
    end

    ---@param level number?
    function CompactVendorFilterFrameTemplate:DropdownInitialize(level)
        if not level then
            return
        end
        if level == 1 then
            local sorted = self.DropdownSortedFilters
            table.wipe(sorted)
            local index = 0
            for name, _ in pairs(self.Filters) do
                index = index + 1
                sorted[index] = name
            end
            table.sort(sorted)
            local info = self:GetDropdownInfo(true)
            info.notCheckable = true
            info.isTitle = true
            info.keepShownOnClick = true
            for i = 1, index do
                local name = sorted[i]
                local filter = self.Filters[name]
                if filter:IsRelevant() then
                    -- info.text = format("%s%s%s", NORMAL_FONT_COLOR_CODE, filter.name, FONT_COLOR_CODE_CLOSE)
                    -- UIDropDownMenu_AddButton(info, level)
                    filter:GetDropdown(level)
                end
            end
            info.notCheckable = true
            info.isTitle = nil
            info.disabled = nil
            info.text = format("%s%s%s", GREEN_FONT_COLOR_CODE, COMBAT_LOG_MENU_EVERYTHING, FONT_COLOR_CODE_CLOSE)
            ---@diagnostic disable-next-line: duplicate-set-field
            info.func = function()
                for _, filter in pairs(self.Filters) do
                    filter:ShowAll()
                end
                self:RefreshDropdown()
            end
            UIDropDownMenu_AddButton(info, level)
            info.text = format("%s%s%s", NORMAL_FONT_COLOR_CODE, RESET, FONT_COLOR_CODE_CLOSE)
            ---@diagnostic disable-next-line: duplicate-set-field
            info.func = function()
                for _, filter in pairs(self.Filters) do
                    if filter:IsRelevant() then
                        filter:ResetFilter()
                    end
                end
                self:RefreshDropdown()
            end
            UIDropDownMenu_AddButton(info, level)
            info.text = CLOSE
            ---@diagnostic disable-next-line: duplicate-set-field
            info.func = function()
                if self == UIDROPDOWNMENU_OPEN_MENU then
                    CloseDropDownMenus()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            for _, filter in pairs(self.Filters) do
                if filter:IsRelevant() then
                    filter:GetDropdown(level)
                end
            end
        end
    end

    function CompactVendorFilterFrameTemplate:GetDropdownInfo(reset)
        local info = self.DropdownInfo
        if reset then
            table.wipe(info)
        end
        return info
    end

    function CompactVendorFilterFrameTemplate:SetupAddOnSupport()
        if IsAddOnLoaded("ElvUI") then
            self:SetupElvUI()
        end
    end

    function CompactVendorFilterFrameTemplate:SetupElvUI()
        if self.setupElvUI then
            return
        end
        local E = ElvUI and ElvUI[1]
        local S = E and E:GetModule("Skins")
        if not S then
            return
        end
        if not E.Border or not S.ArrowRotation then
            return
        end
        ---@type Button
        local button = self:GetParent() ---@diagnostic disable-line: assign-type-mismatch
        S:HandleButton(button)
        button:SetSize(20, 20)
        button.Icon:SetRotation(S.ArrowRotation["down"]) ---@diagnostic disable-line: undefined-field
        button.Icon:Show() ---@diagnostic disable-line: undefined-field
        self.setupElvUI = true
    end

end

---@class CompactVendorFilterTemplate
local CompactVendorFilterTemplate do

    ---@alias CompactVendorFilterTemplateDefaults table

    ---@class CompactVendorFilterTemplate
    ---@field public parent CompactVendorFilterFrameTemplate
    ---@field public name string
    ---@field public defaults CompactVendorFilterTemplateDefaults

    CompactVendorFilterTemplate = {}
    _G.CompactVendorFilterTemplate = CompactVendorFilterTemplate

    ---@param parent CompactVendorFilterFrameTemplate
    function CompactVendorFilterTemplate:OnLoad(parent)
        self.parent = parent
        if self.defaults == nil then
            self.defaults = {}
        end
        self:ResetFilter()
    end

    function CompactVendorFilterTemplate:OnRefresh()
    end

    function CompactVendorFilterTemplate:ClearAll()
        self:ResetFilter()
    end

    function CompactVendorFilterTemplate:ResetFilter()
    end

    function CompactVendorFilterTemplate:ShowAll()
    end

    function CompactVendorFilterTemplate:FilterAll()
    end

    function CompactVendorFilterTemplate:IsRelevant()
        return true
    end

    ---@param level number
    function CompactVendorFilterTemplate:GetDropdown(level)
    end

    ---@param itemData MerchantItem
    ---@return boolean? isFiltered #The return should be `nil` if the filter is not relevant to this item, so the item doesn't get filtered, otherwise `true` or `false` is expected.
    function CompactVendorFilterTemplate:IsFiltered(itemData)
        return false
    end

    ---@param name string?
    ---@param defaults CompactVendorFilterTemplateDefaults?
    function CompactVendorFilterTemplate:New(name, defaults)
        local filter = {} ---@type CompactVendorFilterTemplate
        Mixin(filter, self)
        if name ~= nil then
            filter.name = name
        end
        if defaults ~= nil then
            filter.defaults = defaults
        end
        return filter
    end

    function CompactVendorFilterTemplate:Publish()
        if CompactVendorFilterFrame then
            CompactVendorFilterFrame:AddFilter(self)
        else
            C_Timer.After(0.25, function() if CompactVendorFilterFrame then CompactVendorFilterFrame:AddFilter(self) end end)
        end
    end

end

---@class CompactVendorFilterToggleTemplate
local CompactVendorFilterToggleTemplate do

    ---@alias CompactVendorFilterToggleTemplateIsChecked fun(self: CompactVendorFilterToggleTemplate): boolean?

    ---@class CompactVendorFilterToggleTemplate : CompactVendorFilterTemplate
    ---@field public key string
    ---@field public itemDataKey string
    ---@field public isChecked? CompactVendorFilterToggleTemplateIsChecked
    ---@field public isLogicReversed? boolean
    ---@field public isCheckLogicReversed? boolean

    CompactVendorFilterToggleTemplate = {}
    _G.CompactVendorFilterToggleTemplate = CompactVendorFilterToggleTemplate

    Mixin(CompactVendorFilterToggleTemplate, CompactVendorFilterTemplate)

    ---@type CompactVendorFilterToggleTemplateIsChecked
    function CompactVendorFilterToggleTemplate:IsCheckedFallback()
        local option = self[self.key]
        if option == nil then
            return
        end
        if self.isLogicReversed then
            return option
        end
        return not option
    end

    function CompactVendorFilterToggleTemplate:ResetFilter()
        CompactVendorFilterTemplate.ResetFilter(self)
        self[self.key] = self.defaults[self.key]
    end

    function CompactVendorFilterToggleTemplate:FilterAll()
        CompactVendorFilterTemplate.FilterAll(self)
        self[self.key] = self.isLogicReversed
    end

    function CompactVendorFilterToggleTemplate:ShowAll()
        CompactVendorFilterTemplate.FilterAll(self)
        self[self.key] = nil
    end

    ---@param itemData MerchantItem
    ---@return boolean? isFiltered
    function CompactVendorFilterToggleTemplate:IsFiltered(itemData)
        local value = itemData[self.itemDataKey]
        if value == nil then
            return
        end
        local option = self:isChecked()
        if option == nil then
            return
        end
        if not self:IsRelevant() then
            return
        end
        local filtered = (option and value) or (not option and not value)
        return filtered
    end

    function CompactVendorFilterToggleTemplate:IsRelevant()
        local items = self.parent:GetMerchantItems()
        local enabled = false
        local disabled = false
        for _, itemData in pairs(items) do
            local value = itemData[self.itemDataKey]
            if value then
                enabled = true
            else
                disabled = true
            end
            if enabled and disabled then
                return true
            end
        end
        return false
    end

    ---@param level number
    function CompactVendorFilterToggleTemplate:GetDropdown(level)
        if level ~= 1 then
            return
        end
        ---@diagnostic disable-next-line: missing-fields
        local info = {} ---@type DropdownInfoPolyfill
        info.keepShownOnClick = true
        info.isNotRadio = true
        info.text = self.name
        info.checked = self:isChecked()
        info.colorCode = nil
        if info.checked == nil then
            info.colorCode = GRAY_FONT_COLOR_CODE
        elseif self.isCheckLogicReversed then
            info.checked = not info.checked
        end
        info.func = function()
            self[self.key] = not self[self.key]
            self.parent:RefreshDropdown()
        end
        UIDropDownMenu_AddButton(info, level)
    end

    ---@param name string?
    ---@param defaults CompactVendorFilterTemplateDefaults?
    ---@param key string
    ---@param itemDataKey string
    ---@param isChecked CompactVendorFilterToggleTemplateIsChecked?
    ---@param isLogicReversed boolean?
    ---@param isCheckLogicReversed boolean?
    function CompactVendorFilterToggleTemplate:New(name, defaults, key, itemDataKey, isChecked, isLogicReversed, isCheckLogicReversed)
        ---@type CompactVendorFilterToggleTemplate
        local filter = CompactVendorFilterTemplate:New(name, defaults) ---@diagnostic disable-line: assign-type-mismatch
        Mixin(filter, self)
        filter.key = key
        filter.itemDataKey = itemDataKey
        filter.isChecked = isChecked or filter.IsCheckedFallback
        filter.isLogicReversed = isLogicReversed
        filter.isCheckLogicReversed = isCheckLogicReversed ~= false
        return filter
    end

end

---@class CompactVendorFilterDropDownTemplate
local CompactVendorFilterDropDownTemplate do

    ---@alias CompactVendorFilterDropDownTemplateOnRefresh fun(self: CompactVendorFilterDropDownTemplate)
    ---@alias CompactVendorFilterDropDownTemplateGetValue fun(self: CompactVendorFilterDropDownTemplate, value: any, itemData: MerchantItem): any?
    ---@alias CompactVendorFilterDropDownTemplateHasValue fun(self: CompactVendorFilterDropDownTemplate, value: any, itemValue: any, itemData: MerchantItem): boolean?

    ---@class CompactVendorFilterDropDownTemplateOption : DropdownInfoPolyfill
    ---@field public index number?
    ---@field public value any
    ---@field public text string
    ---@field public show boolean?
    ---@field public checked boolean?

    ---@class CompactVendorFilterDropDownTemplate : CompactVendorFilterTemplate
    ---@field public itemDataKey string
    ---@field public values any[]
    ---@field public options CompactVendorFilterDropDownTemplateOption[]
    ---@field public onRefresh CompactVendorFilterDropDownTemplateOnRefresh?
    ---@field public getValue CompactVendorFilterDropDownTemplateGetValue?
    ---@field public hasValue CompactVendorFilterDropDownTemplateHasValue?
    ---@field public isAccumulative boolean?

    CompactVendorFilterDropDownTemplate = {}
    _G.CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate

    function CompactVendorFilterDropDownTemplate:OnRefresh()
        CompactVendorFilterTemplate.OnRefresh(self)
        if self.onRefresh then
            self:onRefresh()
        end
        for _, option in ipairs(self.options) do
            option.show = self.values[option.value] ~= nil
        end
        self:SortOptions()
    end

    function CompactVendorFilterDropDownTemplate:ResetFilter()
        CompactVendorFilterTemplate.ResetFilter(self)
        for _, option in ipairs(self.options) do
            option.checked = true
        end
    end

    function CompactVendorFilterDropDownTemplate:FilterAll()
        CompactVendorFilterTemplate.FilterAll(self)
        for _, option in ipairs(self.options) do
            option.checked = false
        end
    end

    function CompactVendorFilterDropDownTemplate:ShowAll()
        CompactVendorFilterTemplate.FilterAll(self)
        for _, option in ipairs(self.options) do
            option.checked = true
        end
    end

    ---@param itemData MerchantItem
    ---@return boolean? isFiltered
    function CompactVendorFilterDropDownTemplate:IsFiltered(itemData)
        local value = itemData[self.itemDataKey]
        if self.getValue then
            value = self:getValue(value, itemData)
        end
        local hasValue = self.hasValue
        local numFiltered = 0
        local numUnfiltered = 0
        for _, option in ipairs(self.options) do
            local isUnchecked = not option.checked
            if hasValue then
                if hasValue(self, option.value, value, itemData) == true then
                    if self.isAccumulative then
                        if isUnchecked then
                            numFiltered = numFiltered + 1
                        else
                            numUnfiltered = numUnfiltered + 1
                        end
                    else
                        return isUnchecked
                    end
                end
            elseif option.value == value then
                if self.isAccumulative then
                    if isUnchecked then
                        numFiltered = numFiltered + 1
                    else
                        numUnfiltered = numUnfiltered + 1
                    end
                else
                    return isUnchecked
                end
            end
        end
        if self.isAccumulative then
            return numFiltered ~= 0 and numUnfiltered ~= 0
        end
        return false
    end

    function CompactVendorFilterDropDownTemplate:IsRelevant()
        local count = 0
        for _, _ in pairs(self.values) do
            count = count + 1
        end
        return count > 1
    end

    ---@param level number
    function CompactVendorFilterDropDownTemplate:GetDropdown(level)
        if level == 1 then
            ---@diagnostic disable-next-line: missing-fields
            local info = {} ---@type DropdownInfoPolyfill
            info.keepShownOnClick = true
            info.isNotRadio = true
            info.text = self.name
            info.value = self.name
            info.notCheckable = true
            info.hasArrow = true
            info.func = function()
                local checked
                for _, option in ipairs(self.options) do
                    if option.show then
                        if checked == nil then
                            checked = option.checked
                        end
                        option.checked = not checked
                    end
                end
                self.parent:RefreshDropdown()
            end
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 and self.name == UIDROPDOWNMENU_MENU_VALUE then
            ---@diagnostic disable-next-line: missing-fields
            local info = {} ---@type DropdownInfoPolyfill
            info.keepShownOnClick = true
            info.isNotRadio = true
            for _, option in ipairs(self.options) do
                if option.show then
                    info.text = option.text
                    info.colorCode = option.colorCode
                    info.checked = option.checked
                    info.arg1 = option
                    info.func = function()
                        option.checked = not option.checked
                        self.parent:Refresh()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end

    ---@param valueOrText any
    ---@return CompactVendorFilterDropDownTemplateOption? option, number? index
    function CompactVendorFilterDropDownTemplate:GetOption(valueOrText)
        for index, option in ipairs(self.options) do
            if option.value == valueOrText or option.text == valueOrText then
                return option, index
            end
        end
    end

    function CompactVendorFilterDropDownTemplate:SortOptions()
        table.sort(self.options, function(a, b)
            local x = a.index
            local y = b.index
            if x and y then
                return x < y
            end
            return a.text < b.text
        end)
    end

    ---@param name string?
    ---@param defaults CompactVendorFilterTemplateDefaults?
    ---@param itemDataKey string
    ---@param options CompactVendorFilterDropDownTemplateOption[]
    ---@param onRefresh CompactVendorFilterDropDownTemplateOnRefresh?
    ---@param getValue CompactVendorFilterDropDownTemplateGetValue?
    ---@param hasValue CompactVendorFilterDropDownTemplateHasValue?
    ---@param isAccumulative boolean?
    function CompactVendorFilterDropDownTemplate:New(name, defaults, itemDataKey, options, onRefresh, getValue, hasValue, isAccumulative)
        ---@type CompactVendorFilterDropDownTemplate
        local filter = CompactVendorFilterTemplate:New(name, defaults) ---@diagnostic disable-line: assign-type-mismatch
        Mixin(filter, self)
        filter.values = Mixin({}, defaults and defaults.values or {})
        filter.itemDataKey = itemDataKey
        filter.options = options
        filter.isAccumulative = isAccumulative
        filter.onRefresh = onRefresh
        filter.getValue = getValue
        filter.hasValue = hasValue
        for _, option in pairs(options) do
            if option.checked == nil then
                option.checked = true
            end
            if option.show == nil then
                option.show = true
            end
        end
        return filter
    end

end

---@class CompactVendorFilterDropDownWrapperTemplate
local CompactVendorFilterDropDownWrapperTemplate do

    ---@class CompactVendorFilterDropDownWrapperTemplate : CompactVendorFilterDropDownTemplate
    ---@field public valueIsLocaleKey boolean?

    CompactVendorFilterDropDownWrapperTemplate = {}
    _G.CompactVendorFilterDropDownWrapperTemplate = CompactVendorFilterDropDownWrapperTemplate

    function CompactVendorFilterDropDownWrapperTemplate:OnRefreshWrapper()
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values
        local options = self.options
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local value = itemData[itemDataKey] ---@type string
            if value ~= nil and (not self.valueIsLocaleKey or _G[value] ~= nil) then
                values[value] = true
            end
        end
        for _, option in ipairs(options) do
            option.show = false
        end
        for value, _ in pairs(values) do
            local option = self:GetOption(value)
            if not option then
                option = {} ---@diagnostic disable-line: missing-fields
                options[#options + 1] = option
            end
            option.value = value
            if self.valueIsLocaleKey then
                option.text = tostring(_G[value])
            else
                option.text = tostring(value)
            end
            option.show = true
            if option.checked == nil then
                option.checked = true
            end
        end
    end

    ---@param name string?
    ---@param itemDataKey string
    ---@param valueIsLocaleKey boolean?
    function CompactVendorFilterDropDownWrapperTemplate:New(name, itemDataKey, valueIsLocaleKey)
        ---@type CompactVendorFilterDropDownWrapperTemplate
        local filter = CompactVendorFilterDropDownTemplate:New(name, {}, itemDataKey, {}, self.OnRefreshWrapper) ---@diagnostic disable-line: assign-type-mismatch
        Mixin(filter, self)
        filter.valueIsLocaleKey = valueIsLocaleKey
        return filter
    end

end

---@class CompactVendorFilterDropDownToggleWrapperTemplate
local CompactVendorFilterDropDownToggleWrapperTemplate do

    ---@alias CompactVendorFilterDropDownToggleWrapperTemplateGetValueKey fun(self: CompactVendorFilterDropDownToggleWrapperTemplate, value: any, itemData: MerchantItem): any?
    ---@alias CompactVendorFilterDropDownToggleWrapperTemplateGetValueText fun(self: CompactVendorFilterDropDownToggleWrapperTemplate, value: any): string

    ---@class CompactVendorFilterDropDownToggleWrapperTemplate : CompactVendorFilterDropDownTemplate
    ---@field public getValueKey? CompactVendorFilterDropDownToggleWrapperTemplateGetValueKey
    ---@field public getValueText? CompactVendorFilterDropDownToggleWrapperTemplateGetValueText
    ---@field public isYesNo? boolean

    CompactVendorFilterDropDownToggleWrapperTemplate = {}
    _G.CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate

    function CompactVendorFilterDropDownToggleWrapperTemplate:OnRefreshWrapper()
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values
        local options = self.options
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local itemLink = itemData[itemDataKey]
            local value
            if self.getValueKey then
                value = self:getValueKey(itemLink, itemData)
            else
                value = itemLink
            end
            if value ~= nil then
                values[value] = true
            end
        end
        for _, option in ipairs(options) do
            option.show = false
        end
        for value, _ in pairs(values) do
            local option = self:GetOption(value)
            if not option then
                option = {} ---@diagnostic disable-line: missing-fields
                options[#options + 1] = option
            end
            option.value = value
            if self.getValueText then
                option.text = self:getValueText(value)
            else
                option.text = tostring(value)
            end
            if self.isYesNo then
                option.index = option.text == YES and 1 or 2
            end
            option.show = true
            if option.checked == nil then
                option.checked = true
            end
        end
    end

    ---@param itemLink string
    ---@param itemData MerchantItem
    function CompactVendorFilterDropDownToggleWrapperTemplate:GetValueWrapper(itemLink, itemData, ...)
        if self.getValueKey then
            return self:getValueKey(itemLink, itemData)
        end
        return itemLink
    end

    ---@param value any
    ---@param itemValue any
    ---@param itemData MerchantItem
    function CompactVendorFilterDropDownToggleWrapperTemplate:HasValueWrapper(value, itemValue, itemData)
        if itemValue == nil then
            return
        end
        return value == itemValue
    end

    ---@param name string?
    ---@param getValueKey CompactVendorFilterDropDownToggleWrapperTemplateGetValueKey?
    ---@param getValueText CompactVendorFilterDropDownToggleWrapperTemplateGetValueText?
    ---@param isYesNo boolean?
    function CompactVendorFilterDropDownToggleWrapperTemplate:New(name, getValueKey, getValueText, isYesNo)
        local filter = CompactVendorFilterDropDownTemplate:New(name, {}, "itemLink", {}, self.OnRefreshWrapper, self.GetValueWrapper, self.HasValueWrapper) ---@class CompactVendorFilterDropDownToggleWrapperTemplate
        Mixin(filter, self)
        filter.getValueKey = getValueKey
        filter.getValueText = getValueText
        filter.isYesNo = isYesNo
        return filter
    end

end
