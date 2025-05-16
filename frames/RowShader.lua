
local myname, ns = ...



local GARRISON_ICONS = {[1001489] = true, [1001490] = true, [1001491] = true}


local function Knowable(link)
	local id = ns.ids[link]
	if not id then return false end
	if C_Heirloom.IsItemHeirloom(id) then return true end

	local _, _, _, _, texture, classID, subclassID = GetItemInfoInstant(link)
	if classID == Enum.ItemClass.Miscellaneous and select(2, C_ToyBox.GetToyInfo(id)) then return true end
	if classID == Enum.ItemClass.Recipe or GARRISON_ICONS[texture] then return true end
	if C_Item.IsDressableItemByID(id) then 
		local _, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(link)
		if not itemModifiedAppearanceID then
			itemModifiedAppearanceID = select(2, C_TransmogCollection.GetItemInfo(id))
		end
		if itemModifiedAppearanceID and (select(2, C_TransmogCollection.AccountCanCollectSource(itemModifiedAppearanceID)) or select(2, C_TransmogCollection.PlayerCanCollectSource(itemModifiedAppearanceID))) then
			return true
		end
		if C_Item.GetItemLearnTransmogSet(link) then return true end
	end
	if C_Item.IsCosmeticItem(id) then return true end
	if classID == Enum.ItemClass.Miscellaneous and subclassID == Enum.ItemMiscellaneousSubclass.Mount then return true end
end


local function RecipeNeedsRank(link)
	local _, _, _, _, _, classID = GetItemInfoInstant(link)
	if classID ~= Enum.ItemClass.Recipe then return end
	return ns.unmet_requirements[link]
end


local DEFAULT_GRAD = {0,1,0,0.75, 0,1,0,0} -- green
local GRADS = {
	red = {1,0,0,0.75, 1,0,0,0},
	[1] = {1,1,1,0.75, 1,1,1,0}, -- white
	[2] = DEFAULT_GRAD, -- green
	[3] = {0.5,0.5,1,1, 0,0,1,0}, -- blue
	[4] = {1,0,1,0.75, 1,0,1,0}, -- purple
	[7] = {1,.75,.5,0.75, 1,.75,.5,0}, -- heirloom
}
GRADS = setmetatable(GRADS, {
	__index = function(t,i)
		t[i] = DEFAULT_GRAD
		return DEFAULT_GRAD
	end
})


function ns.GetRowGradient(index)
	local gradient = DEFAULT_GRAD
	local shown = false

	local _, _, _, _, _, isUsable = GetMerchantItemInfo(index)
	if not isUsable then
		gradient = GRADS.red
		shown = true
	end

	local link = GetMerchantItemLink(index)
	if not (link and Knowable(link)) then
    	return { r = gradient[1], g = gradient[2], b = gradient[3], a = gradient[4] }, { r = gradient[5], g = gradient[6], b = gradient[7], a = gradient[8] }, shown
	end

	if ns.knowns[link] then
		shown = false
	elseif RecipeNeedsRank(link) then
		gradient = GRADS.red
		shown = true
	else
		local _, _, quality = GetItemInfo(link)
		gradient = GRADS[quality]
		shown = true
	end
    return { r = gradient[1], g = gradient[2], b = gradient[3], a = gradient[4] }, { r = gradient[5], g = gradient[6], b = gradient[7], a = gradient[8] }, shown
end


function ns.GetItemQualityColor(quality)
	local _, _, _, hex = GetItemQualityColor(quality)
	return "|c"..hex
end

local NON_EQUIP_LOC = C_Item.GetItemInventorySlotKey(0)

function ns.GetRowTextColor(index)
	local link = GetMerchantItemLink(index)
	if not link then return ns.GetItemQualityColor(1) end

	local _, _, quality, _, _, _, _, _, itemEquipLoc = GetItemInfo(link)

	-- Grey out if already known
	if (not itemEquipLoc or itemEquipLoc == NON_EQUIP_LOC) and Knowable(link) and ns.knowns[link] then return ns.GetItemQualityColor(0) end

	return ns.GetItemQualityColor(quality or 1)
end


function ns.GetRowVertexColor(index)
	local _, _, _, _, _, isUsable = GetMerchantItemInfo(index)
	if isUsable then return 1.0, 1.0, 1.0
	else             return 0.9, 0.0, 0.0
	end
end
