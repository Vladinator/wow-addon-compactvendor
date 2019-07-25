--[[ global ]] VladsVendorListTooltipMixin = {}

-- text cache over previously scanned links
local textCache = {}

-- returns cache entry
local function TooltipReadCache(link)
	return textCache[link]
end

-- writes cache entry
local function TooltipWriteCache(tip, link)
	local cache = VladsVendorListTooltipMixin:TooltipText(tip)

	if cache then
		textCache[link] = cache
	end
end

-- converts rgb to hex color string
local function RGB2HEX(r, g, b)
	return format("%02X%02X%02X", floor(r*255+.5), floor(g*255+.5), floor(b*255+.5))
end

-- converts a localization string to a pattern
local function SafePattern(pattern)
return pattern
	:gsub("%%", "%%%%")
	:gsub("%.", "%%%.")
	:gsub("%?", "%%%?")
	:gsub("%+", "%%%+")
	:gsub("%-", "%%%-")
	:gsub("%(", "%%%(")
	:gsub("%)", "%%%)")
	:gsub("%[", "%%%[")
	:gsub("%]", "%%%]")
	:gsub("%%%%s", "(.-)")
	:gsub("%%%%d", "(%%d+)")
	:gsub("%%%%%%[%d%.%,]+f", "([%%d%%.%%,]+)")
end

-- on-demand populated in TooltipScan
local TooltipTextPattern

-- call this once the patterns are actually needed
local function TooltipTextPatternInit()
	TooltipTextPattern = {
		Reputation = SafePattern(_G.ITEM_REQ_REPUTATION),
		Profession = SafePattern(_G.ITEM_MIN_SKILL),
		ProfessionPrevRank = SafePattern(_G.TOOLTIP_SUPERCEDING_SPELL_NOT_KNOWN),
		AlreadyKnown = SafePattern(_G.ITEM_SPELL_KNOWN),
		BattlePetCollected = SafePattern(_G.ITEM_PET_KNOWN),
	}
end

-- tooltip pool create, reset and callback trigger
local TooltipPool do

	local function OnTooltipSet(tip)
		for itemButton, _ in pairs(tip.itemButtons) do
			local list = itemButton:GetList()
			list:TriggerEvent(list.Event.Tooltip, itemButton, tip)
		end
		tip.updateCount = tip.updateCount + 1
		if tip.updateCount >= tip.scanCount then
			TooltipPool:Release(tip)
		end
	end

	local function OnTooltipCreate(pool)
		local tip = CreateFrame("GameTooltip", nil, WorldFrame)
		tip.textLeft, tip.textRight = {}, {}
		for i = 1, 30 do
			tip.textLeft[i], tip.textRight[i] = tip:CreateFontString(nil, nil, "GameFontNormal"), tip:CreateFontString(nil, nil, "GameFontNormal")
			tip:AddFontStrings(tip.textLeft[i], tip.textRight[i])
		end
		tip.link = nil
		tip.itemButtons = {}
		tip.scanCount = 1
		tip.updateCount = 0
		tip:SetScript("OnTooltipSetItem", OnTooltipSet)
		tip:SetScript("OnTooltipSetSpell", OnTooltipSet)
		tip:SetOwner(WorldFrame, "ANCHOR_NONE")
		return tip
	end

	local function OnTooltipReset(pool, tip)
		TooltipWriteCache(tip, tip.link)
		table.wipe(tip.itemButtons)
		tip.link = nil
		tip.scanCount = 1
		tip.updateCount = 0
		tip:ClearLines()
	end

	TooltipPool = CreateObjectPool(OnTooltipCreate, OnTooltipReset)

	function TooltipPool:AcquireTip(itemButton, link)
		for tip in self:EnumerateActive() do
			if tip.link == link then
				return tip, true
			end
		end
		local tip = self:Acquire()
		tip.link = link
		tip.itemButtons[itemButton] = true
		tip:SetHyperlink(link)
		return tip, false
	end

end

-- reads the tooltip lines and returns a table with text and color data
function VladsVendorListTooltipMixin:TooltipText(tip)
	local numLines = tip:NumLines()
	local temp = { numLines = numLines }

	for i = 1, numLines do
		local textLeft, textRight = tip.textLeft[i], tip.textRight[i]
		temp[i] = { textLeft:GetText(), textRight:GetText(), RGB2HEX(textLeft:GetTextColor()), RGB2HEX(textRight:GetTextColor()) }
	end

	if temp[1] then
		return temp
	end
end

-- hardcoded red color for unavailable lines
local RedTooltipColor = "FF2020"

-- returns if there is a match on the line and color
-- [arg1] 1 = reputation, 2 = profession, 3 = profession rank, 4 = already known
-- [arg2] true = available, false = not available
function VladsVendorListTooltipMixin:TooltipTextParse(text, color)
	if text:find(TooltipTextPattern.Reputation) then
		return 1, color ~= RedTooltipColor
	elseif text:find(TooltipTextPattern.Profession) then
		return 2, color ~= RedTooltipColor
	elseif text:find(TooltipTextPattern.ProfessionPrevRank) then
		return 3, color ~= RedTooltipColor
	elseif text:find(TooltipTextPattern.AlreadyKnown) then
		return 4, color ~= RedTooltipColor
	elseif text:find(TooltipTextPattern.BattlePetCollected) then
		return 5, color ~= RedTooltipColor
	end
end

-- scans a link and triggers a response in the provided itemButton:TooltipCallback()
function VladsVendorListTooltipMixin:TooltipScan(itemButton, link)
	-- resolve the pattern strings
	if not TooltipTextPattern then
		TooltipTextPatternInit()
	end
	-- return cached text
	local cache = TooltipReadCache(link)
	if cache then
		local list = itemButton:GetList()
		list:TriggerEvent(list.Event.Tooltip, itemButton, nil, cache)
		return
	end
	-- scan link
	local tip, pending = TooltipPool:AcquireTip(itemButton, link)
	-- adjust scan count requirement so recipes use two cycles (one to load the recipe, and one to load the item itself that is part of the recipe)
	if itemButton:GetItem():IsRecipe() then
		tip.scanCount = 2
	end
	-- avoid deadlock by releasing and caching after a moment
	if not pending then
		C_Timer.After(1, function()
			if TooltipPool:IsActive(tip) then
				TooltipPool:Release(tip)
			end
		end)
	end
end

-- experimental tooltip scanning without waiting for the tooltip to signal it is ready (if used, caching isn't used as it's instant response)
VladsVendorListTooltipMixin.UseExperimentalScanning = true

-- we create a tooltip by borrowing one from the TooltipPool and further modifying it to our application
local InstantTip do
	InstantTip = TooltipPool:Acquire()
	InstantTip:SetScript("OnTooltipSetItem", nil)

	local TextLeft = InstantTip.textLeft
	local TextRight = InstantTip.textRight

	InstantTip.L = setmetatable({}, {
		__index = function(self, i)
			local v = TextLeft[i]:GetText()
			self[i] = v
			return v
		end,
	})

	InstantTip.R = setmetatable({}, {
		__index = function(self, i)
			local v = TextRight[i]:GetText()
			self[i] = v
			return v
		end,
	})

	InstantTip.LC = setmetatable({}, {
		__index = function(self, i)
			local v = RGB2HEX(TextLeft[i]:GetTextColor())
			self[i] = v
			return v
		end,
	})

	InstantTip.RC = setmetatable({}, {
		__index = function(self, i)
			local v = RGB2HEX(TextRight[i]:GetTextColor())
			self[i] = v
			return v
		end,
	})

	function InstantTip:Erase()
		self:ClearLines()
		for i in pairs(self.L) do
			-- TextLeft[i]:SetText()
			self.L[i] = nil
			self.LC[i] = nil
		end
		for i in pairs(self.R) do
			-- TextRight[i]:SetText()
			self.R[i] = nil
			self.RC[i] = nil
		end
	end

	local funcs = {
		"SetHyperlink",
	}

	for _, func in pairs(funcs) do
		local ofunc = InstantTip[func]
		InstantTip[func] = function(self, ...)
			self:Erase()
			return ofunc(self, ...)
		end
	end
end

-- used in TooltipScanInstant
local band = bit.band
local bor = bit.bor
local RecipeMask = {
	Reputation = 1,
	Profession = 2,
	ProfessionRank = 4,
	AlreadyKnown = 8,
	BattlePetCollected = 16,
}
VladsVendorListTooltipMixin.RecipeMask = RecipeMask

-- scans a link without a callback (experimental and might not be as reliable for recipes, at least can't cache these results, probably?)
function VladsVendorListTooltipMixin:TooltipScanInstant(itemButton, link)
	-- resolve the pattern strings
	if not TooltipTextPattern then
		TooltipTextPatternInit()
	end
	-- set the tip hyperlink
	InstantTip:SetHyperlink(link)
	-- instantly respond
	itemButton:TooltipCallbackInstant(InstantTip)
end

--[[ generic useful methods
function VladsVendorListTooltipMixin:IsKnown(link)
	InstantTip:SetHyperlink(link)
	for i = 2, InstantTip:NumLines(), 1 do
		if InstantTip.L[i] == _G.ITEM_SPELL_KNOWN then
			return true
		end
	end
	return false
end
--]]
