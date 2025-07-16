---@diagnostic disable: deprecated

local strcmputf8i = strcmputf8i ---@type fun(str1: string|number, str2: string|number): result: number
local GetItemInfoInstant = GetItemInfoInstant or C_Item.GetItemInfoInstant
local GetItemClassInfo = GetItemClassInfo or C_Item.GetItemClassInfo
local GetItemSubClassInfo = GetItemSubClassInfo or C_Item.GetItemSubClassInfo
local GetItemInfo = GetItemInfo or C_Item.GetItemInfo

local ns = select(2, ...) ---@class CompactVendorNS

---@class CompactVendorSearch
ns.Search = {}

ns.Search.BindType = {
    [Enum.ItemBind.OnAcquire] = "bop",
    [Enum.ItemBind.OnEquip] = "boe",
    [Enum.ItemBind.OnUse] = "bou",
}

---@alias CompactVendorSearchModType
---|"t" Item Type
---|"e" Equipment Location
---|"n" Item Name
---|"i" Item Level
---|"q" Item Quality
---|"b" Item Bind Type
---|"x" Expansion

---@alias CompactVendorSearchModOperator
---|"<" Lt
---|">" Gt
---|"<=" Le
---|">=" Ge
---|"=" Eq
---|"~=" Ne

---@param query string
---@return string[] parts, (CompactVendorSearchModType|nil)[]? mods
local function SplitQuery(query)
    local parts = { strsplit(" ", query) }
    local hasQuotes = false
    local hasMods = false
    for i = 1, #parts do
        local part = parts[i] ---@type string
        local modStart, modEnd = part:find("^([^:]+):")
        local modQuote = modEnd and part:sub(modEnd + 1, modEnd + 1) == '"'
        if modQuote or part:sub(1, 1) == '"' then
            hasQuotes = true
        end
        if modStart then
            hasMods = true
        end
        if hasQuotes and hasMods then
            break
        end
    end
    if not hasQuotes and not hasMods then
        return { query:trim() }
    end
    hasMods = false
    local inQuote ---@type boolean?
    local words = {} ---@type string[]
    local wordsIndex = 0
    local temp = {} ---@type string[]
    local tempIndex = 0
    local mods = {} ---@type string[]
    for i = 1, #parts do
        local part = parts[i] ---@type string
        local add = 1
        if not inQuote then
            local modStart, modEnd = part:find("^([^:]+):")
            local modQuote = modEnd and part:sub(modEnd + 1, modEnd + 1) == '"'
            if modQuote or part:sub(1, 1) == '"' then
                add = 2
                inQuote = true
                if modStart then
                    add = 3
                else
                    part = part:sub(2)
                end
            elseif modStart then
                add = 3
            end
            if add == 3 and modStart then
                hasMods = true
                mods[wordsIndex + 1] = part:sub(modStart, modEnd - 1):lower()
                part = part:sub(modEnd + (modQuote and 2 or 1))
            end
        end
        if inQuote then
            add = 2
            if part:sub(-1) == '"' then
                inQuote = false
                part = part:sub(1, -2)
            end
        end
        if add == 1 then
            wordsIndex = wordsIndex + 1
            words[wordsIndex] = part
        else
            tempIndex = tempIndex + 1
            temp[tempIndex] = part
            if not inQuote then
                temp[tempIndex + 1] = nil
                wordsIndex = wordsIndex + 1
                words[wordsIndex] = table.concat(temp, " ")
                tempIndex = 0
            end
        end
    end
    if tempIndex > 0 then
        temp[tempIndex + 1] = nil
        wordsIndex = wordsIndex + 1
        words[wordsIndex] = table.concat(temp, " ")
    end
    if hasMods then
        return words, mods
    end
    return words
end

---@param str1 string|number
---@param str2 (string|number)?
---@return boolean? isExact
local function IsExact(str1, str2)
    if not str2 then
        return
    end
    return strcmputf8i(str2, str1) == 0
end

---@param str1 string
---@param str2 string?
---@return boolean? isPartial
local function IsPartial(str1, str2)
    if not str2 then
        return
    end
    local pos = str2:find(str1, nil, true)
    if not pos then
        return
    end
    return pos >= 1
end

---@param mod CompactVendorSearchModType|nil
---@param part string|nil
---@param value any|nil
---@return boolean? hasMod
local function HasMod(mod, part, value)
    if not part or not mod or not value then
        return
    end
    ---@type boolean, CompactVendorSearchModOperator, string
    local negate, operator, criteria = part:match("^([!]?)([<>~=]*)(.*)$")
    negate = negate == "!"
    if not operator or operator == "" then
        operator = "="
    end
    if not criteria then
        criteria = ""
    end
    local safeValue = value ---@type any
    local safeCriteria = criteria ---@type any
    local has ---@type boolean?
    if mod == "t" or mod == "e" or mod == "n" or mod == "b" then
        safeValue = type(value) == "string" and value or tostring(value) ---@type string
        safeCriteria = criteria
        if safeCriteria == "" then
            return
        end
    elseif mod == "i" or mod == "q" or mod == "x" then
        safeValue = type(value) == "number" and value or tonumber(value) ---@type number?
        if not safeValue then
            return
        end
        safeCriteria = tonumber(criteria)
        if not safeCriteria then
            return
        end
    end
    if operator == "<" then
        has = safeValue < safeCriteria
    elseif operator == ">" then
        has = safeValue > safeCriteria
    elseif operator == "<=" then
        has = safeValue <= safeCriteria
    elseif operator == ">=" then
        has = safeValue >= safeCriteria
    elseif operator == "=" then
        has = safeValue == safeCriteria
    elseif operator == "~=" then
        has = safeValue ~= safeCriteria
    end
    if has == nil then
        return
    end
    if negate then
        return not has
    end
    return has
end

---@param item? string|number
---@param query? string
---@return boolean? matched
function ns.Search.Matches(item, query)
    if not item or not query then
        return
    end
    query = query:trim()
    if query == "" then
        return
    end
    local parts, mods = SplitQuery(query)
    local itemID, itemType, itemSubType, itemEquipLoc, _, classID, subClassID = GetItemInfoInstant(item)
    if itemEquipLoc and itemEquipLoc ~= "" then
        itemEquipLoc = _G[itemEquipLoc]
    end
    local className = classID and GetItemClassInfo(classID) ---@type string?
    local subClassName = classID and subClassID and GetItemSubClassInfo(classID, subClassID) ---@type string?
    for i = 1, #parts do
        local part = parts[i]
        local mod = mods and mods[i]
        if not mod then
            if IsExact(part, itemID) then return true end
            if IsExact(part, itemType) then return true end
            if IsExact(part, itemSubType) then return true end
            if IsExact(part, itemEquipLoc) then return true end
            if IsExact(part, className) then return true end
            if IsExact(part, subClassName) then return true end
        end
        if mod == "t" then
            if HasMod(mod, part, itemType) then return true end
            if HasMod(mod, part, itemSubType) then return true end
            if HasMod(mod, part, className) then return true end
            if HasMod(mod, part, subClassName) then return true end
        elseif mod == "e" then
            if HasMod(mod, part, itemEquipLoc) then return true end
        end
    end
    local sItemID = tostring(itemID)
    local itemTypeLC = itemType:lower()
    local itemSubTypeLC = itemSubType:lower()
    local itemEquipLocLC = itemEquipLoc and itemEquipLoc:lower()
    local classNameLC = className and className:lower()
    local subClassNameLC = subClassName and subClassName:lower()
    for i = 1, #parts do
        local part = parts[i]
        local partLC = part:lower()
        local mod = mods and mods[i]
        if not mod then
            if IsPartial(part, sItemID) then return true end
            if IsPartial(partLC, itemTypeLC) then return true end
            if IsPartial(partLC, itemSubTypeLC) then return true end
            if IsPartial(partLC, itemEquipLocLC) then return true end
            if IsPartial(partLC, classNameLC) then return true end
            if IsPartial(partLC, subClassNameLC) then return true end
        end
        if mod == "t" then
            if HasMod(mod, part, itemTypeLC) then return true end
            if HasMod(mod, part, itemSubTypeLC) then return true end
            if HasMod(mod, part, classNameLC) then return true end
            if HasMod(mod, part, subClassNameLC) then return true end
        elseif mod == "e" then
            if HasMod(mod, part, itemEquipLocLC) then return true end
        end
    end
    ---@type string?, _, number, number?, number?, _, _, _, _, _, _, _, _, number?, number?
    local name, _, quality, ilvl, milvl, _, _, _, _, _, _, _, _, bind, expansion = GetItemInfo(item)
    if ilvl and ilvl <= 1 then ilvl = nil end
    if milvl and milvl <= 1 then milvl = nil end
    if not name then
        return
    end
    local qualityName = quality and _G[format("ITEM_QUALITY%d_DESC", quality)] ---@type string?
    local bindName = bind and ns.Search.BindType[bind] ---@type string?
    local expansionName = expansion and _G[format("EXPANSION_NAME%d", expansion)] ---@type string?
    for i = 1, #parts do
        local part = parts[i]
        local mod = mods and mods[i]
        if IsExact(part, name) then return true end
        if mod then
            if IsExact(part, ilvl) then return true end
            if IsExact(part, milvl) then return true end
            if IsExact(part, qualityName) then return true end
            if IsExact(part, bindName) then return true end
            if IsExact(part, expansionName) then return true end
        end
        if mod == "n" then
            if HasMod(mod, part, name) then return true end
        elseif mod == "i" then
            if HasMod(mod, part, ilvl) then return true end
            if HasMod(mod, part, milvl) then return true end
        elseif mod == "q" then
            if HasMod(mod, part, quality) then return true end
        elseif mod == "b" then
            if HasMod(mod, part, bindName) then return true end
        elseif mod == "x" then
            if HasMod(mod, part, expansion and expansion + 1) then return true end
        end
    end
    local nameLC = name:lower()
    local sIlvl = ilvl and tostring(ilvl)
    local sMIlvl = milvl and tostring(milvl)
    local qualityNameLC = qualityName and qualityName:lower()
    local bindNameLC = bindName and bindName:lower()
    local expansionNameLC = expansionName and expansionName:lower()
    for i = 1, #parts do
        local part = parts[i]
        local partLC = part:lower()
        local mod = mods and mods[i]
        if IsPartial(partLC, nameLC) then return true end
        if not mod then
            if IsPartial(partLC, sIlvl) then return true end
            if IsPartial(partLC, sMIlvl) then return true end
            if IsPartial(partLC, qualityNameLC) then return true end
            if IsPartial(partLC, bindNameLC) then return true end
            if IsPartial(partLC, expansionNameLC) then return true end
        end
        if mod == "n" then
            if HasMod(mod, part, nameLC) then return true end
        elseif mod == "i" then
            if HasMod(mod, part, sIlvl) then return true end
            if HasMod(mod, part, sMIlvl) then return true end
        elseif mod == "q" then
            if HasMod(mod, part, qualityNameLC) then return true end
        elseif mod == "b" then
            if HasMod(mod, part, bindNameLC) then return true end
        elseif mod == "x" then
            if HasMod(mod, part, expansionNameLC) then return true end
        end
    end
    return false
end
