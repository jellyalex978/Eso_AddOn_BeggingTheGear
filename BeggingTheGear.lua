BTG = {}
BTG.ename = 'BTG'
BTG.name = 'BeggingTheGear' -- sugar daddy
BTG.version = '1.0.2'
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
	if act == 1 then
		local isay = "BTG :: "..zo_strformat("<<1>>", daddy.username).." !!  Can I have your "..zo_strformat("<<1>>", daddy.itemlink).." , if you don't need?"
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
			local isay = "BTG :: "..zo_strformat("<<1>>", daddy.username).." !!  Can I offer $"..zo_strformat("<<1>>", re.price).." to buy your "..zo_strformat("<<1>>", daddy.itemlink).." , if you don't need ?"
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
		d(BTG.MatchItemFilter(itemlink))
	end
end
----------------------------------------
-- TEST End
----------------------------------------


----------------------------------------
-- listen Loot EVENT Start
----------------------------------------
function BTG.OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId)
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

function BTG.MatchItemFilter(itemlink)
	local findmax = 1
	local re = {
		match = false, -- 回傳 最終結果判斷
		itemname = '',
		itemtype = '',
		itemkind = '',
		itemtrait = '',
		price = '',
		filterid = '',
		z_res = {},
	}
	-- 取得物品資料
	local itemName = GetItemLinkName(itemlink)
	re.itemname = itemName
	local itemType = GetItemLinkItemType(itemlink) -- 1 武器 2 裝備
	re.itemtype = itemType
	local itemTrait = GetItemLinkTraitInfo(itemlink) -- 1 - 8 + 26 武器 11 - 18 + 25 裝備
	re.itemtrait = itemTrait
	local itemKind = 0
	if itemType == 1 then
		itemKind = GetItemLinkWeaponType(itemlink) -- 1 單手斧 2 單手槌 3 單手劍 14 盾 11 匕首 8 弓 9 回杖 12 火杖 13 冰杖 15 電杖 4 雙手劍 5 雙手斧 6 雙手槌
	elseif itemType == 2 then
		itemKind = GetItemLinkEquipType(itemlink) -- 1 頭 3 身 8 腰 9 褲 4 肩 10 腳 13 手 2 項鍊 12 戒指
	end
	re.itemkind = itemKind

	-- 整理資料
	local str2search = string.lower(itemName)

	-- 不是 武器 裝備 不比對
	if itemType == 1 or itemType == 2 then
		-- 輪巡 gearlist
		for k,filter in pairs(BTG.savedata.gearlist) do
			if findmax < 1 then break end -- 如果已經找到了 就不找了

			-- 整理資料
			-- organized materials (@Rhyono)
			local str4keyword = string.lower(filter.keyword)
			local need_equiptype = table.getn(filter.equiptype)
			local need_equiptrait = table.getn(filter.equiptrait)
			local need_weapontype = table.getn(filter.weapontype)
			local need_weapontrait = table.getn(filter.weapontrait)

			local match_1_keyword = false
			local match_1_equiptype = false
			local match_1_equiptrait = false
			local match_1_weapontype = false
			local match_1_weapontrait = false

			local res = {
				word = str2search,
				key = str4keyword,
				m_search = match_1_keyword,
				m_e_type = match_1_equiptype,
				m_e_trait = match_1_equiptrait,
				m_w_type = match_1_weapontype,
				m_w_trait = match_1_weapontrait,
				n_e_type = need_equiptype,
				n_e_trait = need_equiptrait,
				n_w_type = need_weapontype,
				n_w_trait = need_weapontrait,
			}

			-- 只處理 對應 如果沒有勾選 就直接當成比對成功
			--  Only deal with the corresponding check if there is no direct success as a match (@Rhyono)
			if itemType == 1 then
				-- if need_weapontype == 0 then match_1_weapontype = true end (@Jelly ! bug)

				--Check if any equipment is set; skip auto match weapon (@Rhyono)
				if need_weapontype == 0 and need_equiptype ~= 0 then
					--If any weapon traits set, still set true (@Rhyono)
					if need_weapontrait ~= 0 then
						match_1_weapontype = true
					else	
						match_1_weapontype = false
					end	
				else
					match_1_weapontype = true
				end	
				
				if need_weapontrait == 0 then match_1_weapontrait = true end
				match_1_equiptype = true
				match_1_equiptrait = true
			elseif itemType == 2 then
				--if need_equiptype == 0 then match_1_equiptype = true end (@Jelly ! bug)

				--Check if any weapon is set; skip auto match equipment (@Rhyono)
				if need_weapontype ~= 0 and need_equiptype == 0 then 
					--If any equipment traits set, still set true (@Rhyono)
					if need_equiptrait ~= 0 then
						match_1_equiptype = true
					else	
						match_1_equiptype = false
					end						
				else
					match_1_equiptype = true
				end

				if need_equiptrait == 0 then match_1_equiptrait = true end
				match_1_weapontype = true
				match_1_weapontrait = true
			end

			-- 只判斷有文字的
			-- Only judge the text (@Rhyono)
			if str4keyword ~= '' then
				match_1_keyword = (string.match(str2search, str4keyword) ~= nil)

				-- 字串需要優先成立
				-- String needs priority (@Rhyono)
				if match_1_keyword then
					-- 裝備位置
					-- Equipment location (@Rhyono)
					if itemType == 1 then
						if need_weapontype > 0 then
							match_1_weapontype = in_array( itemKind , filter.weapontype )
						end
						if need_weapontrait > 0 then
							match_1_weapontrait = in_array( itemTrait , filter.weapontrait )
						end
					elseif itemType == 2 then
						if need_equiptype > 0 then
							match_1_equiptype = in_array( itemKind , filter.equiptype )
						end
						if need_equiptrait > 0 then
							match_1_equiptrait = in_array( itemTrait , filter.equiptrait )
						end
					end
				end
			end

			-- 存單一比對狀態
			-- Save a single match state (@Rhyono)
			res.m_search = match_1_keyword
			res.m_e_type = match_1_equiptype
			res.m_e_trait = match_1_equiptrait
			res.m_w_type = match_1_weapontype
			res.m_w_trait = match_1_weapontrait
			table.insert(re.z_res, res)

			-- 若全部成立 修改 match 值
			if match_1_keyword and match_1_equiptype and match_1_equiptrait and match_1_weapontype and match_1_weapontrait then
				re.match = true
				re.filterid = k
				re.price = filter.price
				findmax = 0
			else
				-- 洗掉
				re.match = false
				re.filterid = ''
				re.price = ''
			end
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
    BTG.gearlistCTL = SLGD:New(BTG.savedata)
    BTG.daddylistCTL = SLDD:New(BTG.savedata)

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
	ZO_PreHookHandler(BTGPanelView,'OnHide', function() BTG.toggleBTGLootTipView(0) end)
	ZO_PreHookHandler(BTGLootTipView,'OnMouseEnter', function() BTG.conmoveBTGLootTipView(1) end)
	ZO_PreHookHandler(BTGLootTipView,'OnMouseExit', function() BTG.conmoveBTGLootTipView(0) end)
	
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
end
EM:RegisterForEvent(BTG.ename, EVENT_ADD_ON_LOADED, BTG.OnAddOnLoaded);








