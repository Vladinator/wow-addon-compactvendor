local CompactVendorFilterDropDownToggleWrapperTemplate = CompactVendorFilterDropDownToggleWrapperTemplate ---@type CompactVendorFilterDropDownToggleWrapperTemplate
local ns = select(2, ...) ---@type CompactVendorNS
local C_HousingCatalog_CreateCatalogSearcher = C_HousingCatalog and C_HousingCatalog.CreateCatalogSearcher ---@type (fun())?

-- HOTFIX: until the `C_HousingCatalog.GetCatalogEntryInfoByItem` API gets properly fixed this helps mitigate the issue somewhat
if C_HousingCatalog_CreateCatalogSearcher then

    local previous

    local function UpdateCatalog()
        local now = GetTime()
        if previous and now - previous < 1 then
            return
        end
        previous = now
        C_HousingCatalog_CreateCatalogSearcher()
    end

    hooksecurefunc(ns.Frame, "OnLoaded", function()
        local provider = ns.Frame.ScrollBox:GetDataProvider()
        provider:RegisterCallback(provider.Event.OnShow, UpdateCatalog)
        provider:RegisterCallback(provider.Event.OnUpdate, UpdateCatalog)
    end)

end

do

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Decor",
        function(self, itemLink, itemData)
            return itemData.isDecor
        end,
        function(self, value)
            return value and YES or NO
        end,
        true
    )

    filter:Publish()

end

do

    local filter = CompactVendorFilterDropDownToggleWrapperTemplate:New(
        "Decor: Collected",
        function(self, itemLink, itemData)
            if not itemData.isDecor then
                return
            end
            return itemData.isDecorCollected
        end,
        function(self, value)
            return value and YES or NO
        end
    )

    filter:Publish()

end
