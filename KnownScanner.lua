
local myname, ns = ...


local function HasHeirloom(id)
	return C_Heirloom.IsItemHeirloom(id) and C_Heirloom.PlayerHasHeirloom(id)
end

local function GetNestedItemTooltipLineCount(itemID)
	local data = C_TooltipInfo.GetItemByID(itemID)
	if data then
		return #data.lines;
	end
	return 0
end

function IsKnown(link)
	local data = C_TooltipInfo.GetHyperlink(link)
	local blockUntil = 1;
	for i=1,#data.lines do
		if i >= blockUntil then
			local line = data.lines[i]
			if line.type == Enum.TooltipDataLineType.NestedBlock and line.tooltipType == Enum.TooltipDataType.Item then blockUntil = i + GetNestedItemTooltipLineCount(line.tooltipID) end
			if line.leftText == ITEM_SPELL_KNOWN or line.leftText == ERR_COSMETIC_KNOWN then return true end
		end
	end
	local _, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(link)
	if itemModifiedAppearanceID then
		if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(itemModifiedAppearanceID) then return true end
	else
		-- some items don't have return anything from C_TransmogCollection.GetItemInfo (caused by missing itemid+itemAppearanceModID pair in ItemModifiedAppearance)
		-- in such cases the game falls back to itemid+0 pair to display the model ingame
		-- but this is not exposed in C_TransmogCollection.GetItemInfo
		-- on the other hand C_TransmogCollection.PlayerHasTransmogByItemInfo always does the lookup using itemid+0 pair so we cannot only use that to determine learned status
		if C_TransmogCollection.PlayerHasTransmogByItemInfo(link) then return true end
	end
end


ns.knowns = setmetatable({}, {
	__index = function(t, i)
		local id = ns.ids[i]
		if not id then return end

		if HasHeirloom(id) or IsKnown(i) then
			t[i] = true
			return true
		end
	end
})


-- "Requires Previous Rank"
local PREV_RANK = TOOLTIP_SUPERCEDING_SPELL_NOT_KNOWN
local function NeedsRank(link)
	local data = C_TooltipInfo.GetHyperlink(link)
	for _,line in ipairs(data.lines) do
		if line.leftText == PREV_RANK then return true end
	end
end


ns.unmet_requirements = setmetatable({}, {
	__index = function(t, i)
		local id = ns.ids[i]
		if not id then return end

		if NeedsRank(i) then
			t[i] = true
			return true
		end
	end
})
