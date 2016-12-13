BTG = {}

BTG.ename = 'BTG'
BTG.name = 'BeggingTheGear'
BTG.version = '1.0'
BTG.init = false
BTG.savedata = {}
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local strformat = zo_strformat
local init_savedef = {
	combattip_pos = {500,500},
	gearlist_pos = {500,500},
	def_gearlist = {
		keyword = 'quest',
		price = '',
		equiptype = {},
		equiptrait = {},
		weapontype = {},
		weapontrait = {},
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
local ValueList_WeaponType = {1,2,3,4,5,6,8,9,11,12,13,14,15}
local ValueList_WeaponTrait = {1,2,3,4,5,6,7,8,26}
local W_width = 0
local BTG_max_left = 0
local debug_mode = false



function dev_reloadui()
    SLASH_COMMANDS["/reloadui"]()
end
local function GetColor(val,a)
	local r,g = 0,0
	if val >= 50 then r = 100-((val-50)*2); g = 100 else r = 100; g = val*2 end
	return r/100, g/100, 0, a
end
local function printToChat(msg)
	local msg = BTG.FormatMessage(msg or 'no message', 1)
	-- We will print into first window of primary container
	local pc = CHAT_SYSTEM.primaryContainer
	pc.windows[1].buffer:AddMessage(msg)
	if pc.windows[1].buffer == pc.currentBuffer then
		pc:SyncScrollToBuffer()
	end
end
local function isayToChat(msg)
	CHAT_SYSTEM.textEntry:SetText( msg )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
	-- strformat("|cff9900 BTG :: |r<<1>> !!  Can I have your <<t:2>> ?", daddy.username , daddy.itemlink)
	-- StartChatInput(isay, channel, target)
	-- StartChatInput(isay, CHAT_CHANNEL_SAY)
	-- printToChat(isay)
	-- StartChatInput("", CHAT_CHANNEL_WHISPER, data.displayName)
end

-- 亂寫一個 in array
function in_array( val , arr )
	local findstatus = false
	for k,v in pairs(arr) do
		if v == val then
			findstatus = true
		end
	end
	return findstatus
end
-- 亂寫一個n陣列處理
function findArrThenBack( curl , arr , val )
	if curl == 'c' then
		table.insert(arr, val)
	end
	if curl == 'd' then
		for k,v in pairs(arr) do
			if v == val then
				table.remove(arr, k)
			end
		end
	end
	return arr
end

function BTG.FormatMessage(msg, doTimestamp)
	local msg = msg or ""
	if doTimestamp then
		--[[ Disabling this code, for now
		-- We want to have timestamp of the same colour as the message
		local timeStamp = '[' .. GetTimeString() .. '] '
		if "|c" == strsub(msg, 0, 2) then
			msg = strsub(msg, 0, 8) .. timeStamp .. strsub(msg, 9)
		else
			msg = timeStamp .. msg
		end
		]]-- Instead just put gray timestamp
		msg = '|c666666[' .. GetTimeString() .. ']|r ' .. msg
	end
	return msg
end

function BTG:Initialize()

	SLASH_COMMANDS["/j123"] = function()
    	d('j123') 
    end

	-- SM:RegisterTopLevel(BTGPanelView,false)
	-- EM:UnregisterForEvent('AG4',EVENT_ADD_ON_LOADED)
	-- EM:RegisterForEvent('AG4',EVENT_ACTION_SLOTS_FULL_UPDATE, AG.Swap)
	-- EM:RegisterForEvent('AG4',EVENT_INVENTORY_FULL_UPDATE, function() PREBAG = nil end)


	--local Storage = BTG.Storage
	local SLGD = BTG.SLGD
	local SLDD = BTG.SLDD


	BTG.savedata = ZO_SavedVars:NewAccountWide('BTG_savedata',1,nil,init_savedef)
    BTG.gearlistCTL = SLGD:New(BTG.savedata)
    BTG.daddylistCTL = SLDD:New(BTG.savedata)


	--local SLGD = SLGD:New(data_listgear);

	-- local saveData = ZO_SavedVars:NewAccountWide("SimpleNotebook_Data", 1)
    -- local storage = Storage:New(saveData)


	--local storage = Storage:New(saveData)


	-- key bind controls
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_BTGPanelView", "toggle ui")
	ZO_CreateStringId("SI_BINDING_NAME_DEV_BTGReloadUi", "reload interface")


	-- BTGPanelView gear list
    BTG.gearlist_NOTE_TYPE = 1
    ZO_ScrollList_AddDataType(BTGPanelViewListGertBox, BTG.gearlist_NOTE_TYPE, "ListGertTpl", 190 , BTG.ListGertInitializeRow)
    BTG.gearlistCTL:RegisterCallback("OnKeysUpdated", BTG.UpdateListGertBox)
    BTG.UpdateListGertBox()
    -- BTGPanelView daddy list
    BTG.daddylist_NOTE_TYPE = 1
    ZO_ScrollList_AddDataType(BTGPanelViewListDaddyBox, BTG.daddylist_NOTE_TYPE, "ListDaddyTpl", 130 , BTG.ListDaddyInitializeRow)
    BTG.daddylistCTL:RegisterCallback("OnKeysUpdated", BTG.UpdateListDaddyBox)
    BTG.UpdateListDaddyBox()


	-- for i, row in pairs(ZO_FriendsListList.activeControls) do
	--    local button = CreateControlFromVirtual("DynamicButton", ZO_FriendsListList, "ZO_DefaultTextButton", i)
	--    button:SetAnchor(RIGHT, row, LEFT, 50, 0)
	--    button:SetText(tostring(i))
	-- end
	 
	-- DynamicButton2:SetText("2")

	EM:RegisterForEvent(self.ename, EVENT_LOOT_RECEIVED, self.OnLootReceived)
	-- EVENT_MANAGER:UnregisterForEvent(moduleName, EVENT_LOOT_RECEIVED)

	BTG:OnUiPosLoad()
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
	end
	for key, val in pairs(ValueList_EquipTrait) do
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val):SetCenterColor(0,0,0,0)
	end
	for key, val in pairs(ValueList_WeaponType) do
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val):SetCenterColor(0,0,0,0)
	end
	for key, val in pairs(ValueList_WeaponTrait) do
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val):SetCenterColor(0,0,0,0)
	end
	-- 初始 savedata 值
	control:GetNamedChild("InputKeyword"):SetText(filter.keyword)
	control:GetNamedChild("InputPrice"):SetText(filter.price)
	for key, val in pairs(filter.equiptype) do
		control:GetNamedChild("FilterGearBoxEquipType_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterGearBoxEquipType_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.equiptrait) do
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterGearTraitBoxEquipTrait_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.weapontype) do
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterWeaponBoxWeaponType_"..val.."Btn").status = 1
	end
	for key, val in pairs(filter.weapontrait) do
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val):SetCenterColor(255,134,0,1)
		control:GetNamedChild("FilterWeaponTraitBoxWeaponTrait_"..val.."Btn").status = 1
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
		local filter = {
			keyword = '',
			price = '',
			equiptype = {},
			equiptrait = {},
			weapontype = {},
			weapontrait = {},
		}
		filter.keyword = keyword
		table.insert(BTG.savedata.gearlist , filter)
		BTG.UpdateListGertBox()	
	end
	BTGPanelViewInputTxtBoxInputTxt:LoseFocus()
end

function BTG.DelGearListFilter(tar)
	local keyid = tar:GetParent().keyid
	table.remove(BTG.savedata.gearlist , keyid)
	BTG.UpdateListGertBox()
end

function BTG.DelAllGearListFilter()
	for i=1,table.getn(BTG.savedata.gearlist) do
		table.remove(BTG.savedata.gearlist , 1)
	end
	BTG.UpdateListGertBox()
end

function BTG.UpdateGearListKeyword(tar)
	local keyid = tar:GetParent().keyid
	local keyword = tar:GetText()
	if keyword ~= '' then
		BTG.savedata.gearlist[keyid].keyword = keyword
	else
		table.remove(BTG.savedata.gearlist , keyid)
		BTG.UpdateListGertBox()
	end
	tar:LoseFocus()
end

function BTG.UpdateGearListPrice(tar)
	local keyid = tar:GetParent().keyid
	local price = tar:GetText()
	BTG.savedata.gearlist[keyid].price = price
	tar:LoseFocus()
end

function BTG.OnFilterClick(tar , filterType , filterId)
	local keyid = tar:GetParent():GetParent():GetParent().keyid
	local status = tar.status
	local findArrThenBack_curl = 'c'
	-- 
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
	-- 
	if filterType == 'EType' then
		BTG.savedata.gearlist[keyid].equiptype = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].equiptype , filterId )
	end
	if filterType == 'ETrait' then
		BTG.savedata.gearlist[keyid].equiptrait = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].equiptrait , filterId )
	end
	if filterType == 'WType' then
		BTG.savedata.gearlist[keyid].weapontype = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].weapontype , filterId )
	end
	if filterType == 'WTrait' then
		BTG.savedata.gearlist[keyid].weapontrait = findArrThenBack( findArrThenBack_curl , BTG.savedata.gearlist[keyid].weapontrait , filterId )
	end
end


function BTG.GearListInputTip(type , tar)
	if type == 1 then
		ZO_Tooltips_ShowTextTooltip(tar, BOTTOM, 'press enter to save')
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
	control:GetNamedChild("TxtDaddy"):SetText(daddy.username)
	-- |t16:16:/esoui/art/icons/crafting_worms.dds|t icon
	control:GetNamedChild("TxtItemlink"):SetText(daddy.itemlink)
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
	if act == 1 then
		local isay = "BTG :: "..zo_strformat("<<!aC:1>>", daddy.username).." !!  Can I have your "..zo_strformat("<<!aC:1>>", daddy.itemlink).." ?"
		local channel = IsUnitGrouped('player') and "/p " or "/say "
		
		isayToChat(channel..isay)
	else
		-- StartChatInput(isay, channel, target)
	end
end
function BTG.PriceDaddyListRow(tar , act)
	local keyid = tar:GetParent().keyid
	local daddy = BTG.savedata.daddylist[keyid]

	local re = BTG.MatchItemFilter(daddy.itemlink)
	if re.match then
		if act == 1 then
			local isay = "BTG :: "..zo_strformat("<<!aC:1>>", daddy.username).." !!  Can I offer $"..zo_strformat("<<!aC:1>>", re.price).." to buy your "..zo_strformat("<<!aC:1>>", daddy.itemlink).." ?"
			local channel = IsUnitGrouped('player') and "/p " or "/say "

			isayToChat(channel..isay)
		else
			-- StartChatInput(isay, channel, target)
		end
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
	BTGLootTipView:ClearAnchors()
	BTGLootTipView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BTG.savedata.combattip_pos[0], BTG.savedata.combattip_pos[1])
end

function BTG.OnUiPosSave(tag)
	if tag == 'BTGPanelView' then
		BTG.savedata.gearlist_pos[0] = BTGPanelView:GetLeft()
		BTG.savedata.gearlist_pos[1] = BTGPanelView:GetTop()
	end
	if tag == 'BTGLootTipView' then
		BTG.savedata.combattip_pos[0] = BTGLootTipView:GetLeft()
		BTG.savedata.combattip_pos[1] = BTGLootTipView:GetTop()
	end
end

function BTG.toggleBTGPanelView(open)
	if open == 1 then 
		BTGPanelView:SetHidden(false)
		BTGLootTipView:SetHidden(true)
	else
		if BTGPanelView:IsHidden() then
			BTGPanelView:SetHidden(false)
		else 
			BTGPanelView:SetHidden(true)
		end
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
----------------------------------------
-- UI CTRL End
----------------------------------------






----------------------------------------
-- TEST Start
----------------------------------------
function BTG.TestByJelly()
	-- BTG.UpdateListGertBox()
	-- d(BTG.savedata.gearlist)
	-- BTG.UpdateListGertBox()
	-- BTG.UpdateListDaddyBox()
end
----------------------------------------
-- TEST End
----------------------------------------







function BTG.MatchItemFilter(itemlink)
	local findmax = 1
	local re = {
		match_keyword = false,
		match_equiptype = false,
		match_equiptrait = false,
		match_weapontype = false,
		match_weapontrait = false,
		match = false,
		filterid = '',
		price = '',
	}
	-- 取得物品資料
	local itemName = GetItemLinkName(itemlink)
	local itemType = GetItemLinkItemType(itemlink) -- 1 武器 2 裝備
	local itemTrait = GetItemLinkTraitInfo(itemlink) -- 1 - 8 + 26 武器 11 - 18 + 25 裝備
	if itemType == 1 then
		local itemKind = GetItemLinkWeaponType(itemlink) -- 1 單手斧 2 單手槌 3 單手劍 14 盾 11 匕首 8 弓 9 回杖 12 火杖 13 冰杖 15 電杖 4 雙手劍 5 雙手斧 6 雙手槌
	elseif itemType == 2 then
		local itemKind = GetItemLinkEquipType(itemlink) -- 1 頭 3 身 8 腰 9 褲 4 肩 10 腳 13 手 2 項鍊 12 戒指
	end
	-- 整理資料
	local str_search = string.lower(itemName)
	
	-- 不是 武器 裝備 不比對
	if itemType == 1 or itemType == 2 then
		if debug_mode then d('itemType :'..itemType) end
		-- 輪巡 gearlist
		for k,filter in pairs(BTG.savedata.gearlist) do
			if findmax < 1 then break end -- 如果已經找到了 就不找了

			-- 整理資料
			local str_keyword = string.lower(filter.keyword)
			local need_equiptype = table.getn(filter.equiptype)
			local need_equiptrait = table.getn(filter.equiptrait)
			local need_weapontype = table.getn(filter.weapontype)
			local need_weapontrait = table.getn(filter.weapontrait)

			-- 只處理 對應 如果沒有勾選 就直接當成比對成功
			if itemType == 1 then
				if need_weapontype == 0 then re.match_weapontype = true end
				if need_weapontrait == 0 then re.match_weapontrait = true end
				re.match_equiptype = true
				re.match_equiptrait = true
			elseif itemType == 2 then
				if need_equiptype == 0 then re.match_equiptype = true end
				if need_equiptrait == 0 then re.match_equiptrait = true end
				re.match_weapontype = true
				re.match_weapontrait = true
			end

			-- 只判斷有文字的
			if filter.keyword ~= '' then 
				re.match_keyword = (string.match(str_search, str_keyword) ~= nil)
				-- 字串需要優先成立
				if re.match_keyword then
					d('match_keyword : true , keyword = '..str_keyword)
					-- 裝備位置
					if itemType == 1 then
						if need_weapontype > 0 then 
							re.match_weapontype = in_array( itemKind , filter.weapontype )
						end
						if need_weapontrait > 0 then 
							re.match_weapontrait = in_array( itemTrait , filter.weapontrait )
						end
					elseif itemType == 2 then
						if need_equiptype > 0 then 
							re.match_equiptype = in_array( itemKind , filter.equiptype )
						end
						if need_equiptrait > 0 then 
							re.match_equiptrait = in_array( itemTrait , filter.equiptrait )
						end
					end
				end
			end
			-- 若全部成立 修改 match 值
			if re.match_keyword and  re.match_equiptype and  re.match_equiptrait and  re.match_weapontype and  re.match_weapontrait then
				re.match = true
				re.filterid = k
				re.price = filter.price
			else
				-- 洗掉
				re.match_equiptype = false
				re.match_equiptrait = false
				re.match_weapontype = false
				re.match_weapontrait = false
				re.match = false
				re.filterid = ''
				re.price = ''
			end 	
			if debug_mode then d(' - - - - - - - - - - - ') end
		end
	end
	if debug_mode then d('===============================') end
	return re;
end
----------------------------------------
-- listen Loot EVENT , copy LuiExtended
----------------------------------------
function BTG.OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId)
	-- local icon
	-- local equipType = 1
	-- -- fix Icon for missing quest items
	-- if lootType == LOOT_TYPE_QUEST_ITEM then
	-- 	icon = questItemIcon
	-- elseif lootType == LOOT_TYPE_COLLECTIBLE then
	-- 	local collectibleId = GetCollectibleIdFromLink(itemName)
	-- 	local _,_,collectibleIcon = GetCollectibleInfo(collectibleId)
	-- 	icon = collectibleIcon
	-- else
	-- 	-- get Icon and Equipment Type
	-- 	local itemIcon,_,_,itemEquipType,_ = GetItemLinkInfo(itemName)
	-- 	icon = itemIcon
	-- 	equipType = itemEquipType
	-- end
	-- -- create Icon string if icon exists and corresponding setting is ON
	-- icon = ( 1 and icon and icon ~= '' ) and ('|t16:16:'..icon..'|t') or ''
	-- if lootedBySelf then
	-- 	-- Rough Ruby Ash
	-- 	-- receivedBy = ojelly^Fx //JJ-L
	-- 	-- receivedBy = rolycc^Fx //JJ-L
	-- 	printToChat( strformat("|cff9900<<1>> [<<4>><<t:3>>|c0B610B]<<2[// x|cBEF781$d]>>|r", (receivedBy == nil) and "JJ-R" or isPickpocketLoot and "JJ-P" or "JJ-L", quantity, itemName, icon ) )
	-- elseif 1 and lootType == LOOT_TYPE_ITEM then
	-- 	local quality = GetItemLinkQuality(itemName)
	-- 	if ( equipType ~= 0 ) and ( quality >= 3 ) then
	-- 		printToChat( strformat("|cff9900<<1>> Got: [<<4>><<t:3>>|c32CE41]<<2[// x|cBEF781$d]>>|r", receivedBy, quantity, itemName, icon ) )
	-- 	end
	-- 	if ( equipType ~= 0 ) and ( quality == 0 ) then
	-- 		printToChat( strformat("|cff9900<<1>> Q0 : [<<4>><<t:3>>|c32CE41]<<2[// x|cBEF781$d]>>|r", receivedBy, quantity, itemName, icon ) )
	-- 	end
	-- 	if ( equipType ~= 0 ) and ( quality == 1 ) then
	-- 		-- 白的
	-- 		printToChat( strformat("|cff9900<<1>> Q1 : [<<4>><<t:3>>|c32CE41]<<2[// x|cBEF781$d]>>|r", receivedBy, quantity, itemName, icon ) )
	-- 	end
	-- 	if ( equipType ~= 0 ) and ( quality == 2 ) then
	-- 		-- 綠的
	-- 		printToChat( strformat("|cff9900<<1>> Q2 : [<<4>><<t:3>>|c32CE41]<<2[// x|cBEF781$d]>>|r", receivedBy, quantity, itemName, icon ) )
	-- 	end
	-- end

	-- d('test - '..itemName..' : '..itemId)
	-- local str_itemName = GetItemLinkName(itemName);
	-- d('str - '..str_itemName)

	-- d(GetItemInfo(itemId)) -- ok
	-- d(GetItemLinkInfo(itemName)) -- ok
	-- BTGCombatTipViewLabel:SetText(itemName)
	-- d(icon)
	
	-- if str_itemName == 'rough ruby ash' then
	-- 	d('yes loot him')
	-- 	BTGCombatTipViewLabel:SetText('yes loot him')
	-- end
	-- if str_itemName == 'rubedite ore' then
	-- 	d('yes loot rubedite')
	-- 	BTGCombatTipViewLabel:SetText('yes loot rubedite')
	-- end



	-- 比對字串
	local re = BTG.MatchItemFilter(itemName)
	local name = 'yourself'
	if receivedBy ~= nil then
		name = receivedBy
	end
	if re.match then
		BTG.AddDaddyListRow(name , itemName)
		BTGLootTipView:SetHidden(false)
	end

end








function BTG.OnAddOnLoaded(event, addonName)
	if addonName == BTG.name then
		BTG:Initialize()
	end
end
EM:RegisterForEvent(BTG.ename, EVENT_ADD_ON_LOADED, BTG.OnAddOnLoaded);








