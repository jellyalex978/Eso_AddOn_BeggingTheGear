BTG = {}
BTG.ename = 'BTG'
BTG.name = 'BeggingTheGear' -- sugar daddy
BTG.version = '1.9.0'
BTG.init = false
BTG.savedata = {}
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local strformat = zo_strformat
local init_savedef = {
	combattip_pos = {500,500}, -- x y
	gearlist_pos = {500,500,955,670}, -- wx y w h
	def_gearlist = {
		keyword = '',
		price = '1K',
		equiptype = {},
		equiptrait = {},
		jewelrytrait = {},
		weapontype = {},
		weapontrait = {},
		thingtype = {},
		--cplevel = '160',
	},
	def_daddylist = {
		username = '',
		itemlink = '',
	},
	gearlist = {},
	daddylist = {},
}
local ValueList_EquipType = {1,2,3,4,8,9,10,12,13}
local ValueList_EquipTrait = {11,12,13,14,15,16,17,18,25}
local ValueList_JewelryTrait = {22,21,23,30,33,32,28,29,31}
local ValueList_WeaponType = {1,2,3,4,5,6,8,9,11,12,13,14,15}
local ValueList_WeaponTrait = {1,2,3,4,5,6,7,8,26}
local ValueList_ThingType = {999}
local W_width = 0
local BTG_max_left = 0
local debug_mode = false


function dev_reloadui()
    SLASH_COMMANDS["/reloadui"]()
end

function GetColor(val,a)
	local r,g = 0,0
	if val >= 50 then r = 100-((val-50)*2); g = 100 else r = 100; g = val*2 end
	return r/100, g/100, 0, a
end

function isayToChat(msg)
	CHAT_SYSTEM.textEntry:SetText( msg )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
end

-- 亂寫一個 in array
function in_array( val , arr )
	local findstatus = false
	for k,v in pairs(arr) do
		if v == val then
			findstatus = true
      return findstatus
		end
	end
	return findstatus
end

-- 亂摳一個排序
function sortByFilterKeyword(a, b)
	return a.keyword < b.keyword
-- 　if a.level == b.level then
-- 　　return a.　keyword < b.　keyword
-- 　else
-- 　　return a.level < b.level
-- 　end
end

-- 亂寫一個n陣列處理
function findArrThenBack( curl , arr , val )
	-- 新增值到陣列中
    if curl == 'c' then
		table.insert(arr, val)
	end
    -- 刪除陣列中的值
	if curl == 'd' then
		for k,v in pairs(arr) do
			if v == val then
				table.remove(arr, k)
			end
		end
	end
	return arr
end
-- tab 轉 字串
-- http://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- Alundaio @ answered Feb 6 at 7:23
function table2string(node)
    -- to make output beautiful
    local function tab(amt)
        local str = ""
        for i=1,amt do
            str = str .. "--"
        end
        return str
    end

    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. tab(depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    return output_str
end
-- @SilverWF idea
function findDaddy4Group (daddyName)
    local daddyhere = false
    for sortIndex = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(sortIndex)
        local unitName = GetUnitName(unitTag)
        if daddyName == unitName then
          daddyhere = true
        end
    end
    return daddyhere
end
----------------------------------------
-- ZO_ScrollList @ ListGert Start
----------------------------------------
function BTG.ListGertInitializeRow(control, data)
	local filter = BTG.savedata.gearlist[data.key]
	-- 暫存著偷偷用
	control.keyid = data.key

	-- 因為會莫名其妙自己亮起來 只好強迫全關一次
	for key, val in pairs(ValueList_EquipType) do
		control:GetNamedChild("FilterGearBoxEquipType_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterGearBoxEquipType_"..val.."Btn").status = 0
	end
	for key, val in pairs(ValueList_EquipTrait) do
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val.."Btn").status = 0
	end
    for key, val in pairs(ValueList_JewelryTrait) do
        control:GetNamedChild("FilterJewelryTraitBoxJewelryTrait_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterJewelryTraitBoxJewelryTrait_"..val.."Btn").status = 0
    end
	for key, val in pairs(ValueList_WeaponType) do
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterWeaponBoxWeaponType_"..val.."Btn").status = 0
	end
	for key, val in pairs(ValueList_WeaponTrait) do
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val.."Btn").status = 0
	end
	for key, val in pairs(ValueList_ThingType) do
		control:GetNamedChild("FilterThingBoxThingType_"..val):SetCenterColor(0,0,0,0)
        control:GetNamedChild("FilterThingBoxThingType_"..val.."Btn").status = 0
	end

	-- 初始 savedata 值
	-- 增加判斷 , 如果陣列不存在 補上它
	-- 因為 2017 05 29 增加新判斷 導致舊用戶 缺資料
	control:GetNamedChild("InputKeyword"):SetText(filter.keyword)
	control:GetNamedChild("InputPrice"):SetText(filter.price)
	--control:GetNamedChild("InputCPlevel"):SetText(filter.cplevel)
	for key, val in pairs(filter.equiptype) do
		control:GetNamedChild("FilterGearBoxEquipType_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterGearBoxEquipType_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.equiptrait) do
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val.."Btn").status = 1
	end
    for key, val in pairs(filter.jewelrytrait) do
        control:GetNamedChild("FilterJewelryTraitBoxJewelryTrait_"..val):SetCenterColor(255,134,0,1)
        control:GetNamedChild("FilterJewelryTraitBoxJewelryTrait_"..val.."Btn").status = 1
    end
	for key, val in pairs(filter.weapontype) do
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.weapontrait) do
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.thingtype) do
		control:GetNamedChild("FilterThingBoxThingType_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterThingBoxThingType_"..val.."Btn").status = 1
	end
end

function BTG.UpdateListGertBox()
    local scrollData = ZO_ScrollList_GetDataList(BTGPanelViewListGertBox)
    ZO_ScrollList_Clear(BTGPanelViewListGertBox)
    local entries = BTG.gearlistCTL:GetKeys()
    for i=1, #entries do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BTG.gearlist_NOTE_TYPE, {key = entries[i]})
    end
    ZO_ScrollList_Commit(BTGPanelViewListGertBox)
end

function BTG.AddGearListFilter()
	keyword = BTGPanelViewInputTxtBoxInputTxt:GetText()
	BTGPanelViewInputTxtBoxInputTxt:SetText('')
	if keyword ~= '' then
		local filter = ZO_DeepTableCopy(init_savedef.def_gearlist)
		filter.keyword = keyword
		table.insert(BTG.savedata.gearlist , filter)
		table.sort(BTG.savedata.gearlist, sortByFilterKeyword)
		BTG.UpdateListGertBox()
	end
	BTGPanelViewInputTxtBoxInputTxt:LoseFocus()
end

function BTG.DelGearListFilter(tar)
	local keyid = tar:GetParent().keyid
	table.remove(BTG.savedata.gearlist , keyid)
	table.sort(BTG.savedata.gearlist, sortByFilterKeyword)
	BTG.UpdateListGertBox()
end

function BTG.CallIIfA2showme(tar)
	if IIfA ~= nil then
		local keyid = tar:GetParent().keyid
		local keyword = BTG.savedata.gearlist[keyid].keyword
		IIFA_GUI_SearchBox:SetText(keyword)

		if IIFA_GUI:IsHidden() then
			IIfA:ToggleInventoryFrame()
		end
	else
		d('BTG: Please install addon : Inventory Insight (3.0)')
		d('http://www.esoui.com/downloads/info731-InventoryInsight.html')
	end
end
--jellyIIFAMenuOption
function BTG:showItemName2IIFA(itemLink)
	itemname = GetItemLinkName(itemLink)
	if IIfA ~= nil then
		IIFA_GUI_SearchBox:SetText(itemname)
		if IIFA_GUI:IsHidden() then
			IIfA:ToggleInventoryFrame()
		end
	else
		d('please install addon : Inventory Insight (3.0)')
		d('http://www.esoui.com/downloads/info731-InventoryInsight.html')
	end
end
function BTG:copyItemName2IIFA(inventorySlot)
	if IIfA ~= nil then
		local st = ZO_InventorySlot_GetType(inventorySlot)
	    link = nil
	    if st == SLOT_TYPE_ITEM or st == SLOT_TYPE_EQUIPMENT or st == SLOT_TYPE_BANK_ITEM or st == SLOT_TYPE_GUILD_BANK_ITEM or
	       st == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or st == SLOT_TYPE_REPAIR or st == SLOT_TYPE_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or
	       st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or st == SLOT_TYPE_CRAFT_BAG_ITEM then
	        local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
	        link = GetItemLink(bag, index)
	    end
	    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
	        link = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
	    end
	    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
	        link = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot), linkStyle)
	    end
	    if (link and string.match(link, '|H.-:item:(.-):')) then
			zo_callLater(function()
				AddMenuItem('BTG-Check IIFA', function() BTG:showItemName2IIFA(link) end, MENU_ADD_OPTION_LABEL)
	            ShowMenu(self)
	        end, 50)
	    end
	end
end

function BTG.DelAllGearListFilter()
	for i=1,table.getn(BTG.savedata.gearlist) do
		table.remove(BTG.savedata.gearlist , 1)
	end
	table.sort(BTG.savedata.gearlist, sortByFilterKeyword)
	BTG.UpdateListGertBox()
end

function BTG.UpdateGearListKeyword(tar)
	local keyid = tar:GetParent().keyid
	local keyword = tar:GetText()
	if keyword ~= '' then
		BTG.savedata.gearlist[keyid].keyword = keyword
	else
		table.remove(BTG.savedata.gearlist , keyid)
	end
	table.sort(BTG.savedata.gearlist, sortByFilterKeyword)
	BTG.UpdateListGertBox()
	tar:LoseFocus()
end

function BTG.UpdateGearListPrice(tar)
	local keyid = tar:GetParent().keyid
	local price = tar:GetText()
	BTG.savedata.gearlist[keyid].price = price
	tar:LoseFocus()
end

function BTG.UpdateGearListCPlevel(tar)
	local keyid = tar:GetParent().keyid
	local cplevel = tar:GetText()
	BTG.savedata.gearlist[keyid].cplevel = cplevel
	tar:LoseFocus()
end

function BTG.OnFilterClick(tar , filterType , filterId)
	local keyid = tar:GetParent():GetParent():GetParent().keyid
	local status = tar.status
	local findArrThenBack_curl = 'c'

	if status == 1 then
		status = 0
		findArrThenBack_curl = 'd'
		tar:GetParent():SetCenterColor(0,0,0,0)
		tar.status = status
	else
		status = 1
		findArrThenBack_curl = 'c'
		tar:GetParent():SetCenterColor(255,134,0,1)
		tar.status = status
	end

	if filterType == 'EType' then
		BTG.savedata.gearlist[keyid].equiptype = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].equiptype , filterId )
	end
	if filterType == 'ETrait' then
		BTG.savedata.gearlist[keyid].equiptrait = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].equiptrait , filterId )
	end
    if filterType == 'JTrait' then
        BTG.savedata.gearlist[keyid].jewelrytrait = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].jewelrytrait , filterId )
    end
	if filterType == 'WType' then
		BTG.savedata.gearlist[keyid].weapontype = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].weapontype , filterId )
	end
	if filterType == 'WTrait' then
		BTG.savedata.gearlist[keyid].weapontrait = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].weapontrait , filterId )
	end
	if filterType == 'TType' then
		BTG.savedata.gearlist[keyid].thingtype = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].thingtype , filterId )
	end
end


function BTG.GearListInputTip(type , tar , msg)
	if type == 1 then
		if msg ~= '' and msg ~= nil then
			ZO_Tooltips_ShowTextTooltip(tar, BOTTOM, msg)
		else
			ZO_Tooltips_ShowTextTooltip(tar, BOTTOM, 'press enter to save')
		end
	end
	if type == 0 then
		ZO_Tooltips_HideTextTooltip()
	end
end
----------------------------------------
-- ZO_ScrollList @ ListGert End
----------------------------------------


----------------------------------------
-- ZO_ScrollList @ ListDaddy Start
----------------------------------------
function BTG.ListDaddyInitializeRow(control, data)
	local daddy = BTG.savedata.daddylist[data.key]
	-- 暫存著偷偷用
	control.keyid = data.key
	-- 初始 savedata 值
	local icon,_,_,_,_ = GetItemLinkInfo(daddy.itemlink)
	local username = zo_strformat("<<1>>", daddy.username);
	local itemlink = '|t22:22:'..icon..'|t' .. '|u5:0::|u' ..daddy.itemlink;
	-- 塞值
	control:GetNamedChild("TxtDaddy"):SetText(username)
	control:GetNamedChild("TxtItemlink"):SetText(itemlink)
end

function BTG.UpdateListDaddyBox()
    local scrollData = ZO_ScrollList_GetDataList(BTGPanelViewListDaddyBox)
    ZO_ScrollList_Clear(BTGPanelViewListDaddyBox)
    local entries = BTG.daddylistCTL:GetKeys()
    for i=1, #entries do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BTG.daddylist_NOTE_TYPE, {key = entries[i]})
    end
    ZO_ScrollList_Commit(BTGPanelViewListDaddyBox)
end

function BTG.AddDaddyListRow(user , itemlink)
	if user ~= '' and itemlink ~= '' then
		local daddy = {
			username = user,
			itemlink = itemlink,
		}
		table.insert(BTG.savedata.daddylist , daddy)
		BTG.UpdateListDaddyBox()
	end
end

function BTG.DelDaddyListRow(tar)
	local keyid = tar:GetParent().keyid
	table.remove(BTG.savedata.daddylist , keyid)
	BTG.UpdateListDaddyBox()
end

function BTG.DelAllDaddyListRow()
	for i=1,table.getn(BTG.savedata.daddylist) do
		table.remove(BTG.savedata.daddylist , 1)
	end
	BTG.UpdateListDaddyBox()
end

function BTG.BeggingDaddyListRow(tar , act)
	local keyid = tar:GetParent().keyid
	local daddy = BTG.savedata.daddylist[keyid]
	local daddyName = zo_strformat("<<1>>", daddy.username)
    local daddyTrait = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo (daddy.itemlink))
	local isay = ''
	local channel = '/say'
	if act == 1 then
		if( findDaddy4Group(daddyName) ) then
			isay = "BTG: "..daddyName..", may I have your "..zo_strformat("<<1>>", daddy.itemlink).." ("..zo_strformat("<<1>>", daddyTrait).."), if you don't need it, please?"
			channel = "/p "
		else
			isay = daddyName..", BTG: may I have your "..zo_strformat("<<1>>", daddy.itemlink).." ("..zo_strformat("<<1>>", daddyTrait).."), if you don't need it, please?"
			channel = "/w "
		end
		isayToChat(channel..isay)
	else
		-- StartChatInput(isay, channel, target)
	end
end

function BTG.PriceDaddyListRow(tar , act)
	local keyid = tar:GetParent().keyid
	local daddy = BTG.savedata.daddylist[keyid]
	local daddyName = zo_strformat("<<1>>", daddy.username)
    local daddyTrait = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo (daddy.itemlink))
	local re = BTG.MatchItemFilter(daddy.itemlink,false) -- why you need match again ?
	local isay = ''
	local channel = '/say'
    if re.match then
    	if act == 1 then
    		if( findDaddy4Group(daddyName) ) then
    			isay = "BTG: "..daddyName..", I offer "..zo_strformat("<<1>>", re.price).." g. for your "..zo_strformat("<<1>>", daddy.itemlink).." ("..zo_strformat("<<1>>", daddyTrait).."), agreed?"
    			channel = "/p "
    		else
    			isay = daddyName..", BTG: I offer "..zo_strformat("<<1>>", re.price).." g. for your "..zo_strformat("<<1>>", daddy.itemlink).." ("..zo_strformat("<<1>>", daddyTrait).."), agreed?"
    			channel = "/w "
    		end
    		isayToChat(channel..isay)
    	else
    		-- StartChatInput(isay, channel, target)
        end
    else
        d('BTG can\'t find filter price')
    end
end

function BTG.DaddyOnMouseEnter(tar)
	local keyid = tar:GetParent().keyid
	local daddy = BTG.savedata.daddylist[keyid]
	if W_width == 0 then
		W_width = GuiRoot:GetRight()
		BTG_max_left = W_width - 800 - 420
	end
	if BTGPanelView:GetLeft() > BTG_max_left then
		InitializeTooltip(BTGTooltip, BTGPanelView, TOPRIGHT, -20, 0, TOPLEFT)
	else
		InitializeTooltip(BTGTooltip, BTGPanelView, TOPLEFT, 5, 0, TOPRIGHT)
	end
	BTGTooltip:SetLink(daddy.itemlink);
end

function BTG.DaddyOnMouseExit(tar)
	ClearTooltip(BTGTooltip);
end
----------------------------------------
-- ZO_ScrollList @ ListDaddy End
----------------------------------------



----------------------------------------
-- UI CTRL Start
----------------------------------------
function BTG:OnUiPosLoad()
	BTGPanelView:ClearAnchors()
	BTGPanelView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BTG.savedata.gearlist_pos[0], BTG.savedata.gearlist_pos[1])
    BTGPanelView:SetWidth(BTG.savedata.gearlist_pos[2])
    BTGPanelView:SetHeight(BTG.savedata.gearlist_pos[3])
    BTG.UpdateListDaddyBox()
    BTG.UpdateListGertBox()

	BTGLootTipView:ClearAnchors()
	BTGLootTipView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BTG.savedata.combattip_pos[0], BTG.savedata.combattip_pos[1])
end

function BTG.OnUiPosSave(tag)
	if tag == 'BTGPanelView' then
		BTG.savedata.gearlist_pos[0] = BTGPanelView:GetLeft()
		BTG.savedata.gearlist_pos[1] = BTGPanelView:GetTop()
        BTG.savedata.gearlist_pos[2] = BTGPanelView:GetWidth()
        BTG.savedata.gearlist_pos[3] = BTGPanelView:GetHeight()
        BTG.UpdateListDaddyBox()
        BTG.UpdateListGertBox()
	end
	if tag == 'BTGLootTipView' then
		BTG.savedata.combattip_pos[0] = BTGLootTipView:GetLeft()
		BTG.savedata.combattip_pos[1] = BTGLootTipView:GetTop()
	end
end

function BTG.toggleBTGPanelView(open)
	if open == nil then
		SM:ToggleTopLevel(BTGPanelView)
	elseif open == 1 then
		SM:ShowTopLevel(BTGPanelView)
	elseif open == 0 then
		SM:HideTopLevel(BTGPanelView)
	end
end

function BTG.moveCloseBTGPanelView(eventCode)
	if BTGPanelView:IsHidden() then
		-- SM:ToggleTopLevel(BTGPanelView)
		-- SM:HideTopLevel(BTGPanelView)
	else
		BTGPanelView:SetHidden(true)
	end
end

function BTG.setBTGPanelPos(parent,pos)
	BTGPanelView:ClearAnchors()
	BTGPanelView:SetAnchor(8,parent,2,pos,0)
end

function BTG.resetBTGPanelPos()
	BTGPanelView:ClearAnchors()
	BTGPanelView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BTG.savedata.gearlist_pos[0], BTG.savedata.gearlist_pos[1])
end

function BTG.toggleBTGLootTipView(open)
	if open == nil then
		if BTGLootTipView:IsHidden() then
			BTGLootTipView:SetHidden(false)
		else
			BTGLootTipView:SetHidden(true)
		end
	elseif open == 1 then
		BTGLootTipView:SetHidden(false)
	elseif open == 0 then
		BTGLootTipView:SetHidden(true)
	end
end

function BTG.conmoveBTGLootTipView(status)
	if status == 1 then
		BTGLootTipViewBg:SetCenterColor(255,0,0,1)
		-- BTGLootTipViewBg:SetEdgeColor(200,0,0,1)
		WM:SetMouseCursor(MOUSE_CURSOR_PAN)
	elseif status == 0 then
		BTGLootTipViewBg:SetCenterColor(0,0,0,1)
		-- BTGLootTipViewBg:SetEdgeColor(107,61,59,1)
		WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
	end
	-- btn:SetNormalTexture(textures.NORMAL)
 	-- btn:SetPressedTexture(textures.PRESSED)
 	-- btn:SetMouseOverTexture(textures.MOUSEOVER)
 	-- btn:SetDisabledTexture(textures.DISABLED)
end
----------------------------------------
-- UI CTRL End
----------------------------------------



----------------------------------------
-- TEST Start
----------------------------------------
function BTG.TestByJelly()
	local itemlink = BTGPanelViewInputTxtBoxInputTxt:GetText()
	if itemlink == '' then
		BTG.toggleBTGLootTipView(1)
		-- d(BTG.MatchItemFilter('|H1:item:97022:4:22:0:0:0:0:0:0:0:0:0:0:0:0:11:0:0:0:10000:0|h|h'))
	else
		local tbl = BTG.MatchItemFilter(itemlink,true)
		local str = "Debug Msg : ".."\n"
        str = str..table2string(tbl).."\n"
		str = str.."match : "..tostring(tbl.match).."\n"
		str = str.."filterid : "..tostring(tbl.filterid).."\n"
		str = str.."filterkeyword : "..tostring(tbl.filterkeyword).."\n"

        local length = ZoUTF8StringLength(str) + 1000
        BTGPanelViewLogTxtBoxVal:SetMaxInputChars(length)
		BTGPanelViewLogTxtBoxVal:SetText(str)
		BTGPanelViewLogTxtBox:SetHidden(false)
	end
end

-- 可以抓出 飾品 特性 的遊戲中資料
-- for trait = 1, 12 do
--     local tid = GetSmithingResearchLineTraitInfo(7,1,trait)
--     local _,desc = GetSmithingResearchLineTraitInfo(7,1,trait)
--     local _,name,icon = GetSmithingTraitItemInfo(tid + 1)
--     d(GetString('SI_ITEMTRAITTYPE',tid)..' |t25:25:'..icon..'|t|t5:25:x.dds|t')
--     d(icon)
--     d(name)
--     d(desc)
-- end

----------------------------------------
-- TEST End
----------------------------------------


----------------------------------------
-- listen Loot EVENT Start
----------------------------------------
function BTG.OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId)
    -- 比對字串
    local re = BTG.MatchItemFilter(itemName,false)
    local name = 'yourself'
    if receivedBy ~= nil then
        name = receivedBy
    end
    if re.match then
        BTG.AddDaddyListRow(name , itemName)
        BTGLootTipView:SetHidden(false)
    end
end

function BTG.MatchItemFilter(itemlink , debug)
	local findmax = 1 -- 最多比對成功次數
	local re = {
		match = false, -- 回傳 最終結果判斷
		itemname = '', -- Name of the item
        itemstring = '', -- 物品名稱轉小寫比對用
		itemsetname = '', -- Name of the set
        itemsetstring = '', -- 套裝名稱轉小寫比對用
        itemtype = '', -- 物品分類
        itemkind = '', -- 物品部位或種類
        itemtrait = '', -- 物品特性
        cplevel = '0', -- CP level
        price = '', -- 設定金額
        filterid = '', -- 和第幾項比對成功
        filterkeyword = '', -- 和第幾項字串成功
		z_res = {}, -- 比對歷程
	}

    -- 取得物品資料
    re.itemname = GetItemLinkName(itemlink)
    re.itemstring = string.lower(re.itemname) -- 物品字串轉小寫來比對
    _, re.itemsetname, _, _, _, _ = GetItemLinkSetInfo(itemlink) -- Get the name of set
    re.itemsetstring = string.lower(re.itemsetname) --
    -- re.itemQuality = GetItemLinkQuality(itemlink) -- 1白 2綠 3 藍 4紫 5 金
    -- re.itemQuality = GetString('SI_ITEMQUALITY',GetItemLinkQuality(itemlink))
    re.itemtype = GetItemLinkItemType(itemlink) -- 1 武器 2 裝備
    re.itemtrait = GetItemLinkTraitInfo(itemlink) -- 1 - 8 + 26 武器, 11 - 18 + 25 裝備, 21~33 -25 - 26 飾品 http://wiki.esoui.com/Constant_Values#ITEM_TRAIT_TYPE_JEWELRY_ARCANE
    if re.itemtype == 1 then
        re.itemkind = GetItemLinkWeaponType(itemlink) -- 1 單手斧 2 單手槌 3 單手劍 14 盾 11 匕首 8 弓 9 回杖 12 火杖 13 冰杖 15 電杖 4 雙手劍 5 雙手斧 6 雙手槌
    elseif re.itemtype == 2 then
        re.itemkind = GetItemLinkEquipType(itemlink) -- 1 頭 3 身 8 腰 9 褲 4 肩 10 腳 13 手 2 項鍊 12 戒指
    end
	re.cplevel = GetItemLinkRequiredChampionPoints(itemlink)

	-- 輪巡 gearlist
	for k,filter in pairs(BTG.savedata.gearlist) do
		if findmax < 1 then break end -- 如果已經找到了 就不找了

        -- 預設比對資料
        local res = {
            keyword = string.lower(filter.keyword),
            m_k_word = false, -- 字串 比對結果
            n_e_type = 0, --要比對的 裝備分類 總數
            m_e_type = false, -- 裝備分類 比對結果
            n_e_trait = 0, --要比對的 裝備特性 總數
            m_e_trait = false, -- 裝備特性 比對結果
            n_j_trait = 0, --要比對的 飾品特性 總數
            m_j_trait = false, -- 飾品特性 比對結果
            n_w_type = 0, --要比對的 武器分類 總數
            m_w_type = false, -- 武器分類 比對結果
            n_w_trait = 0, --要比對的 武器特性 總數
            m_w_trait = false, -- 武器特性 比對結果
            n_t_type = 0, --要比對的 道具分類 總數
            m_t_type = false, -- 道具分類 比對結果
            n_l_cplevel = 160, --  CP level
            m_l_cplevel = false, --  CP level
        }
		res.n_e_type = table.getn(filter.equiptype) --要比對的 裝備分類 總數
		res.n_e_trait = table.getn(filter.equiptrait) --要比對的 裝備特性 總數
		res.n_j_trait = table.getn(filter.jewelrytrait) --要比對的 飾品特性 總數
		res.n_w_type = table.getn(filter.weapontype) --要比對的 武器分類 總數
		res.n_w_trait = table.getn(filter.weapontrait) --要比對的 武器特性 總數
		res.n_t_type = table.getn(filter.thingtype) --要比對的 其他道具 總數

        -- step1 : check keyword to skip all if else if else balabala
        if res.keyword ~= '' then
            res.m_k_word = (string.match(re.itemsetstring, res.keyword) ~= nil) -- Compare keyword with the set name
            if not res.m_k_word then -- If set name comparison was failed, then compare with the item name
                res.m_k_word = (string.match(re.itemstring, res.keyword) ~= nil)
            end
        end
        -- step2 : check cplevel to skip all if else if else balabala
        if re.itemtype == 1 or re.itemtype == 2 then
            if re.cplevel >= res.n_l_cplevel then
                res.m_l_cplevel = true
            end
        else
            res.m_l_cplevel = true
        end

        if (res.m_k_word and res.m_l_cplevel) or debug then
            -- 判斷資料 不須判斷的 直接設定成比對成功
            if re.itemtype == 1 then
                -- 除武器特性外 通通沒選就 直接比對成功
                if res.n_w_type == 0 and res.n_e_type == 0 and res.n_e_trait == 0 and res.n_j_trait == 0 then
                    res.m_w_type = true
                end
                if res.n_w_type == 0 and res.n_w_trait ~= 0 then
                    res.m_w_type = true
                end
                -- 判斷特性
                if re.itemkind == 14 then
                    -- 盾的特性判斷 裝備
                    if res.n_e_trait == 0 then
                        res.m_e_trait = true
                    end
                    res.m_w_trait = true
                else
                    if res.n_w_trait == 0 then
                        res.m_w_trait = true
                    end
                    res.m_e_trait = true
                end
                res.m_e_type = true
                res.m_j_trait = true
                res.m_t_type = true
            elseif re.itemtype == 2 then
                -- 如果 沒選裝備 直接比對成功
                if res.n_e_type == 0 and res.n_w_type == 0 and res.n_w_trait == 0 then
                    res.m_e_type = true
                end
                if res.n_e_type == 0 and res.n_e_trait ~= 0 then
                    res.m_e_type = true
                end
                -- 判斷特性
                if re.itemkind == 2 or re.itemkind == 12 then
                    -- 如果 是 項鍊 戒指 裝備特性 直接比對成功
                    if res.n_j_trait == 0 and res.n_e_trait == 0 then
                        res.m_j_trait = true
                    end
                    if res.n_j_trait == 0 and res.n_e_type ~= 0 and res.n_e_trait ~= 0 then
                        res.m_j_trait = true
                    end
                    res.m_e_trait = true
                else
                    if res.n_e_trait == 0 and res.n_j_trait == 0 then
                        res.m_e_trait = true
                    end
                    if res.n_e_trait == 0 and res.n_e_type ~= 0 and res.n_j_trait ~= 0 then
                        res.m_e_trait = true
                    end
                    res.m_j_trait = true
                end
                res.m_w_type = true
                res.m_w_trait = true
                res.m_t_type = true
            else
                -- 目前只有單選不考慮
                -- if res.n_t_type == 0 then
                --  res.m_t_type = true
                -- end
                -- 非裝備可否直接 pass 那堆
                res.m_e_type = true
                res.m_e_trait = true
                res.m_j_trait = true
                res.m_w_type = true
                res.m_w_trait = true
            end

            -- 比對 需求 > 0 + 尚未確定比對結果的
            if res.n_e_type > 0 and res.m_e_type == false then
                res.m_e_type = in_array( re.itemkind , filter.equiptype )
            end
            if res.n_e_trait > 0 and res.m_e_trait == false then
                res.m_e_trait = in_array( re.itemtrait , filter.equiptrait )
            end
            if res.n_j_trait > 0 and res.m_j_trait == false then
                res.m_j_trait = in_array( re.itemtrait , filter.jewelrytrait )
            end
            if res.n_w_type > 0 and res.m_w_type == false then
                res.m_w_type = in_array( re.itemkind , filter.weapontype )
            end
            if res.n_w_trait > 0 and res.m_w_trait == false then
                res.m_w_trait = in_array( re.itemtrait , filter.weapontrait )
            end
            if res.n_t_type > 0 and res.m_t_type == false then
                --res.m_t_type = in_array( xxxxx , filter.thingtype )
                res.m_t_type = in_array( 999 , filter.thingtype )
            end
        else
            -- 不比對
        end

		if debug then
            -- 存 log
    		table.insert(re.z_res, res)
        end

		-- 若全部成立 修改 match 值
		if res.m_k_word and res.m_e_type and res.m_e_trait and res.m_j_trait and res.m_w_type and res.m_w_trait and res.m_t_type and res.m_l_cplevel then
			re.match = true
			re.filterid = k
			re.filterkeyword = res.m_k_word
			re.price = filter.price
			findmax = 0
		else
			-- 洗掉
			re.match = false
			re.filterid = ''
			re.filterkeyword = ''
			re.price = ''
		end
	end

	return re
end
----------------------------------------
-- listen Loot EVENT End
----------------------------------------


----------------------------------------
-- INIT
----------------------------------------
function BTG:Initialize()
	SM:RegisterTopLevel(BTGPanelView,false) -- 註冊最高層

	--local Storage = BTG.Storage
	local SLGD = BTG.SLGD
	local SLDD = BTG.SLDD

	BTG.savedata = ZO_SavedVars:NewAccountWide('BTG_savedata',1,nil,init_savedef)
	-- 2017 05 29 增加資料 檢查舊資料的預設直
	for k,filter in pairs(BTG.savedata.gearlist) do
		for k2,filterfield in pairs(init_savedef.def_gearlist) do
			if filter[k2] == nil then
				BTG.savedata.gearlist[k] = {k2=filterfield} -- SilverWF: I am totally fucked up here. Have no idea what does it doing, but, at least, it doesn't produce errors and not ruin variables :D
				--filter[k2] = ZO_DeepTableCopy(filterfield) -- Old version of that string, it doesn't works, because old user variables doesn't has CP level value and this script just fucks up.
			end
		end
		BTG.savedata.gearlist[k] = filter
	end
    BTG.gearlistCTL = SLGD:New(BTG.savedata)
    BTG.daddylistCTL = SLDD:New(BTG.savedata)

	-- key bind controls
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_BTGPanelView", "toggle ui")
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_BTGLootTipView", "toggle alert icon")
	ZO_CreateStringId("SI_BINDING_NAME_DEV_BTGReloadUi", "reload interface")

	-- BTGPanelView gear list
    BTG.gearlist_NOTE_TYPE = 1
    ZO_ScrollList_AddDataType(BTGPanelViewListGertBox, BTG.gearlist_NOTE_TYPE, "ListGertTpl", 145 , BTG.ListGertInitializeRow)
    BTG.gearlistCTL:RegisterCallback("OnKeysUpdated", BTG.UpdateListGertBox)
    BTG.UpdateListGertBox()
    -- BTGPanelView daddy list
    BTG.daddylist_NOTE_TYPE = 1
    ZO_ScrollList_AddDataType(BTGPanelViewListDaddyBox, BTG.daddylist_NOTE_TYPE, "ListDaddyTpl", 70 , BTG.ListDaddyInitializeRow)
    BTG.daddylistCTL:RegisterCallback("OnKeysUpdated", BTG.UpdateListDaddyBox)
    BTG.UpdateListDaddyBox()

	-- 物品撿取
	EM:RegisterForEvent(self.ename, EVENT_LOOT_RECEIVED, self.OnLootReceived)
	-- EVENT_MANAGER:UnregisterForEvent(moduleName, EVENT_LOOT_RECEIVED)

	-- 一堆 TopLevel 視窗問題
	EM:RegisterForEvent(self.ename,EVENT_NEW_MOVEMENT_IN_UI_MODE, function() BTG.toggleBTGPanelView(0) end)
	ZO_PreHookHandler(ZO_PlayerInventory,'OnShow', function() BTG.setBTGPanelPos(ZO_PlayerInventory,-50) end)
	ZO_PreHookHandler(ZO_PlayerInventory,'OnHide', BTG.resetBTGPanelPos)
	ZO_PreHookHandler(ZO_Skills,'OnShow', function() BTG.toggleBTGPanelView(0) end)
	ZO_PreHookHandler(ZO_ChampionPerks,'OnShow', function() BTG.toggleBTGPanelView(0) end)
	ZO_PreHookHandler(BTGPanelView,'OnShow', function() BTG.toggleBTGLootTipView(0) end)
	ZO_PreHookHandler(BTGPanelView,'OnHide', function() BTG.toggleBTGLootTipView(0); BTGPanelViewLogTxtBox:SetHidden(true); end)


	ZO_PreHookHandler(BTGLootTipView,'OnMouseEnter', function() BTG.conmoveBTGLootTipView(1) end)
	ZO_PreHookHandler(BTGLootTipView,'OnMouseExit', function() BTG.conmoveBTGLootTipView(0) end)

	--jelly add menu opt item to iifa
    ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(rowControl) BTG:copyItemName2IIFA(rowControl) end)

	-- 一些 SLASH COMMANDS 視窗問題
	SLASH_COMMANDS["/btg"] = function()
    	BTG.toggleBTGPanelView();
    end
    SLASH_COMMANDS["/btgt"] = function()
    	BTG.toggleBTGLootTipView();
    end
	BTG:OnUiPosLoad()
end

function BTG.OnAddOnLoaded(event, addonName)
	if addonName ~= BTG.name then return end
	EM:UnregisterForEvent(BTG.ename,EVENT_ADD_ON_LOADED)
	BTG:Initialize()

	SLASH_COMMANDS["/j1"] = function()
		d('OnAddOnLoaded')
    end
end
EM:RegisterForEvent(BTG.ename, EVENT_ADD_ON_LOADED, BTG.OnAddOnLoaded);














