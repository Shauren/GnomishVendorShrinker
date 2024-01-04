
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
			if line.type == Enum.TooltipDataLineType.RestrictedSpellKnown then return true end
			if line.leftText == ERR_COSMETIC_KNOWN then return true end
		end
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
