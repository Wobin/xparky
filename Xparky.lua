--[[
--	Xparky is a rewrite of FuXPFu to use Ace3 and deFu it
--	Mouse frame selection shamelessly stolen from Dash (Kyhax)
--]]

local Xparky = LibStub("AceAddon-3.0"):NewAddon("Xparky", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Xparky")
local reg = LibStub("AceConfigRegistry-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local _G = getfenv(0)
local options = {}
local db 
local factionTable = {}

local XPBar, NoXPBar, RepBar, NoRepBar, RestBar, Shadow, Anchor, Lego

local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }

local default = {
	profile = {
		barColours = {
			XPBar = { Red = 0, Green = 0.4, Blue = 0.9, Alpha = 1 },
			NoXPBar = { Red = 0.3, Green = 0.3, Blue = 0.3, Alpha = 1 },
			RepBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
			NoRepBar = { Red = 0, Green = 0.3, Blue = 1, Alpha = 1 },
			RestBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
		},
		WatchedFaction = false,
		Faction = 0,
		ScreenWidth = 100,
		LegoWidth = 50,
		ShowXP = true,
		ShowRep = false,
		ShowShadow = true,
		Thickness = 2,
		Spark = 1,
		Spark2 = 1,
		Attach = "bottom",
		Inside = false,
		ConnectedFrame = "LegoXparky",
		xOffset = 0,
		yOffset = 0,
		Strata = 5,
		MouseHide = false,
		MouseTooltip = true,
		Lego = true,
		LegoToGo = false,
		LegoDB = {
			width = 32,
			height = 32,
			showText = true,
			showIcon = false,
			scale = 1,
			group = nil
		},
		Bars = {
			BarNames = { "XparkyXPBar", "XparkyRepBar" },
			XparkyXPBar = {
				Type = "XP",
				Colours = {
					XPBar = { Red = 0, Green = 0.4, Blue = 0.9, Alpha = 1 },
					NoXPBar = { Red = 0.3, Green = 0.3, Blue = 0.3, Alpha = 1 },
					RestBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
				},
				ConnectedFrame = "LegoXparky",
				Attach = "bottom",
				Direction = "forward",
				Thickness = 2,
				Spark = 1,
			},
			XparkyRepBar = {
				Type = "Rep",
				Colours = {
					RepBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
					NoRepBar = { Red = 0, Green = 0.3, Blue = 1, Alpha = 1 },
				},
				ConnectedFrame = "XparkyXPBar",
				Attach = "bottom",
				Direction = "forward",
				Thickness = 2,
				Spark = 1,
				Faction = 2,
			}
		}
	}
}

local mouser = CreateFrame("Frame")
mouser.tooltip = _G.GameTooltip
mouser.setCursor = _G.SetCursor

function mouser:OnUpdate(elap)
    if IsMouseButtonDown("RightButton") then
        return self:Stop()
    end

    local frame = GetMouseFocus()
    local name = frame and frame:GetName() or tostring(frame)
    
    SetCursor("CAST_CURSOR")
    if not frame then return end
    self.tooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
    self.tooltip:SetText(name, 1.0, 0.82, 0)
    self.tooltip:Show()
    
    if IsMouseButtonDown("LeftButton") then
        self:Stop()
        if not type(frame.GetName) == 'function' or not frame:GetName() then
            Xparky:Print(L["This frame has no global name, and cannot be added via the mouse"])
        else
        	db.ConnectedFrame = name
        	Xparky:AttachBar()
        	reg:NotifyChange("Xparky")
        end
    end
end

function mouser:Start()
    self:SetScript("OnUpdate", self.OnUpdate)
end

function mouser:Stop()
    self.tooltip:Hide()
    self:SetScript("OnUpdate", nil)
end
hooksecurefunc(_G.GameMenuFrame, "Show", function() mouser:Stop() end)



--[[ Local helper functions --]]
--
local function getHex(Bar)
	local Colours
	if(type(Bar) == "string") then
		Colours = db.barColours[Bar]
		return string.format("|r|cff%02x%02x%02x", Colours.Red*255, Colours.Green*255, Colours.Blue*255)
	elseif(type(Bar) == "number") then
		Colours = FACTION_BAR_COLORS[Bar]
		if Colours then
			return string.format("|r|cff%02x%02x%02x", Colours.r*255, Colours.g*255, Colours.b*255)
		else return "" end
	else
		return ""
	end
end

function Xparky:RescanFactions()
	Xparky:ScheduleTimer("getFactions", 0.1, Xparky)
end

function Xparky:getFactions()
	local WatchedFaction = GetWatchedFactionInfo()
	for factionIndex = 1, GetNumFactions() do
		local name, _, _, _, _, _, _, _,isHeader, _, isWatched = GetFactionInfo(factionIndex)
		if not isHeader then
			if WatchedFaction == name then
				if db.Faction ~= factionIndex then
					db.Faction = factionIndex;
					self:UpdateBars()
				end
			end
			factionTable[factionIndex] = name
		end
	end
	if GetNumFactions() == 0 then
		self:ScheduleTimer("getFactions", 1)
	end
end


local function SetColour(Bar, texture) 
	local Setting = db.barColours[Bar.Name]
	if Setting then
		texture:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
		if Bar.Spark then
			Bar.Spark:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
			Bar.Spark2:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
		end
	end
end

local function Width(Bar, Size)
	if db.Attach == "top" or db.Attach == "bottom" then
		if not Size then
			return Bar:GetWidth()
		end
		Bar:SetWidth(Size)
	else
		if not Size then 
			return Bar:GetHeight()
		end
		Bar:SetHeight(Size)
	end
end

local function Height(Bar, Size)
	if db.Attach == "top" or db.Attach == "bottom" then
		if not Size then
			return Bar:GetHeight()
		end
		Bar:SetHeight(Size)
	else
		if not Size then
			return Bar:GetWidth()
		end
		Bar:SetWidth(Size)
	end
end

local function CreateBar(Bar, Spark)
	local tex = Bar:CreateTexture(Bar.Name .. "Texture", "OVERLAY")
	tex:SetTexture(Bar.TextureFile)
	tex:ClearAllPoints()
	tex:SetAllPoints(Bar)
	tex:Show()
	Bar.Texture = tex
	Height(Bar, db.Thickness)
	if Spark then
		local spark = Bar:CreateTexture(Bar.Name .. "Spark", "OVERLAY")
		spark:SetTexture(Bar.Spark1File)
		Height(spark, db.Thickness * 5)
		spark:SetBlendMode("ADD")
		spark:SetParent(Bar)
		spark:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark = spark

		local spark2 = Bar:CreateTexture(Bar.Name .. "Spark2", "OVERLAY")
		spark2:SetTexture(Bar.Spark2File)
		Height(spark2, db.Thickness * 5)
		spark2:SetBlendMode("ADD")
		spark2:SetParent(Bar)
		spark2:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark2 = spark2
	end
	SetColour(Bar, tex)
	Bar:ClearAllPoints()
	Width(Bar, 100)
	return Bar
end

local function GenerateBar(BarName, Spark)
	local Bar = CreateFrame("Frame", BarName .. "Xparky", Anchor)
	Bar.Name = BarName
	Bar.TextureFile = "Interface\\AddOns\\Xparky\\Textures\\texture.tga"
	Bar.Spark1File =  "Interface\\AddOns\\Xparky\\Textures\\glow.tga"
	Bar.Spark2File =  "Interface\\AddOns\\Xparky\\Textures\\glow2.tga"
	return CreateBar(Bar, Spark)
end

local function MouseOver()
	if db.MouseTooltip then
		GameTooltip:SetOwner(Anchor, "ANCHOR_CURSOR")
		Xparky:UpdateBars(nil, true)
		if GetMouseFocus() == Anchor then
			GameTooltip:Show()
		end
	end
	if db.MouseHide then
		Xparky:ConnectBars()
	end
end

local function HideBars()
	XPBar:Hide()
	RestBar:Hide()
	NoXPBar:Hide()
	RepBar:Hide()
	NoRepBar:Hide()
	Shadow:Hide()
end


local function MouseOut()
	if db.MouseTooltip then
		if GameTooltip:IsOwned(Anchor) then
			GameTooltip:SetOwner(UIParent)
			GameTooltip:Hide()
		end
	end
	if db.MouseHide then
		HideBars()
	end
end

local function SetStrata()
	XPBar:SetFrameStrata(Strata[db.Strata])
	NoXPBar:SetFrameStrata(Strata[db.Strata])
	RestBar:SetFrameStrata(Strata[db.Strata])
	RepBar:SetFrameStrata(Strata[db.Strata])
	NoRepBar:SetFrameStrata(Strata[db.Strata])
	Shadow:SetFrameStrata(Strata[db.Strata])
end

function Xparky:OnInitialize()
	Xparky.db = LibStub("AceDB-3.0"):New("XparkyDB", default, "profile")
	db = Xparky.db.profile
	reg:RegisterOptionsTable("Xparky", options)
	self:RegisterChatCommand("xparky", function() dialog:Open("Xparky") end)
	if db.Lego then
		self:ShowLegoBlock()
	end
	Xparky:InitializeBars()
	Xparky:ConnectBars()
	Xparky:AttachBar()
	Xparky:InitialiseEvents()
	Xparky:getFactions()
	self:ScheduleTimer("UpdateBars", 0.1, self)
	Anchor:EnableMouse(true)
	
	if db.MouseTooltip or db.MouseHide then 
	    Anchor:SetScript("OnEnter",MouseOver)
		Anchor:SetScript("OnLeave",MouseOut) 
		if db.MouseHide then
			HideBars()
		end
	end


end


function Xparky:InitializeBars()
	Anchor = CreateFrame("Frame", "XparkyXPAnchor", Lego or UIParent)
	Anchor:SetWidth(1)
	Anchor:SetHeight(1)
	Anchor:Show()
	XPBar = GenerateBar("XPBar", true)
	NoXPBar = GenerateBar("NoXPBar")
	RepBar = GenerateBar("RepBar", true)
	NoRepBar = GenerateBar("NoRepBar")
	RestBar = GenerateBar("RestBar")
	Shadow = GenerateBar("XPShadow")
	Shadow.Texture:SetTexture("Interface\\AddOns\\Xparky\\Textures\\border.tga")
	Shadow.Texture:SetVertexColor(0, 0, 0, 1)
	Shadow.Texture:SetHeight(5)
end

function Xparky:ConnectBars()
	local Base = Anchor
	local TabA, SlotB, TabC, SlotD
	local tlx, tly, trx, try, blx, bly, brx, bry,stlx, stly, strx, stry, sblx, sbly, sbrx, sbry

	if (db.Attach == "bottom" and not db.Inside) or (db.Attach == "top" and db.Inside) then
		TabA = "TOPLEFT"
		SlotB = "BOTTOMLEFT"
		tlx, tly, trx, try, blx, bly, brx, bry = 1, 0, 1, 1, 0, 0, 0, 1
		stlx, stly, strx, stry, sblx, sbly, sbrx, sbry = 0, 1, 0, 0, 1, 1, 1, 0
	end
	
	if (db.Attach == "top" and not db.Inside) or (db.Attach == "bottom" and db.Inside) then
		TabA = "BOTTOMLEFT"
		SlotB = "TOPLEFT"
		tlx, tly, trx, try, blx, bly, brx, bry = 0, 1, 0, 0, 1, 1, 1, 0
		stlx, stly, strx, stry, sblx, sbly, sbrx, sbry = 0, 1, 0, 0, 1, 1, 1, 0
	end

	if (db.Attach == "left" and not db.Inside) or (db.Attach == "right" and db.Inside) then
		TabA = "TOPRIGHT"
		SlotB = "TOPLEFT"
		tlx, tly, trx, try, blx, bly, brx, bry = 1, 1, 0, 1, 1, 0, 0, 0
		stlx, stly, strx, stry, sblx, sbly, sbrx, sbry = 0, 0, 1, 0, 0, 1, 1, 1
	end

	if (db.Attach == "right" and not db.Inside) or (db.Attach == "left" and db.Inside) then
		TabA = "TOPLEFT"
		SlotB = "TOPRIGHT"
		tlx, tly, trx, try, blx, bly, brx, bry = 0, 0, 1, 0, 0, 1, 1, 1
		stlx, stly, strx, stry, sblx, sbly, sbrx, sbry = 0, 0, 1, 0, 0, 1, 1, 1
	end

	if db.Attach == "bottom" or db.Attach == "top" then
		TabC = "LEFT"
		SlotD = "RIGHT"
	end

	if db.Attach == "left" or db.Attach == "right" then
		TabC = "TOP"
		SlotD = "BOTTOM"
	end

	local barEnd, x, y = "", 0, 0
	if db.Attach == "top" or db.Attach == "bottom" then
		barEnd = "RIGHT"
		x = 10
		y = 0
	end

	if db.Attach == "left" or db.Attach == "right" then
		barEnd = "BOTTOM"
		x = 0
		y = -10
	end

	XPBar:Hide()
	RestBar:Hide()
	NoXPBar:Hide()

	if db.ShowXP then
		XPBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		XPBar.Spark:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		XPBar.Spark2:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		NoXPBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		RestBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)

		XPBar:ClearAllPoints()
		XPBar:SetPoint(TabA, Base, Base == Anchor and TabA or SlotB)
		XPBar:SetFrameLevel( NoXPBar:GetFrameLevel() + 1)
		XPBar.Spark:ClearAllPoints()
		XPBar.Spark:SetPoint(barEnd, XPBar, barEnd, x, y)
		XPBar.Spark:SetParent(XPBar)
		XPBar.Spark2:ClearAllPoints()
		XPBar.Spark2:SetPoint(barEnd, XPBar, barEnd, x, y)
		XPBar.Spark2:SetParent(XPBar)
		RestBar:ClearAllPoints()
		RestBar:SetPoint(TabC, XPBar, SlotD)
		NoXPBar:ClearAllPoints()
		NoXPBar:SetPoint(TabC, RestBar, SlotD)
		XPBar:Show()
		RestBar:Show()
		NoXPBar:Show()
		Base = XPBar
	end 
	
	RepBar:Hide()
	NoRepBar:Hide()
	
	if db.ShowRep then
		RepBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		NoRepBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		RepBar.Spark:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		RepBar.Spark2:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)

		RepBar:ClearAllPoints()
		RepBar:SetPoint(TabA, Base, Base == Anchor and TabA or SlotB )
		RepBar.Spark:ClearAllPoints()
		RepBar.Spark2:ClearAllPoints()
		RepBar.Spark:SetPoint(barEnd, RepBar, barEnd, x, y)
		RepBar.Spark2:SetPoint(barEnd, RepBar, barEnd, x, y)
		NoRepBar:ClearAllPoints()
		NoRepBar:SetPoint(TabC, RepBar, SlotD)
		RepBar:SetFrameLevel( NoRepBar:GetFrameLevel() + 1)
		RepBar:Show()
		NoRepBar:Show() 
		Base = RepBar
	end
	
	Shadow:Hide()

	if db.ShowShadow then
		Shadow:ClearAllPoints()
		Shadow:SetPoint(TabA, Base, Base == Anchor and TabA or SlotB)
		Shadow.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		Shadow:Show()
	end
	SetStrata()
end
do

	local timeout = 0

	function Xparky:AttachBar(Bar)
		local Foundation = db.ConnectedFrame and getglobal(db.ConnectedFrame) or nil
		if Foundation then
			Anchor:ClearAllPoints()

			if db.Attach == "bottom" then
				if db.Inside then
					Anchor:SetPoint("BOTTOMLEFT", Foundation, "BOTTOMLEFT", db.xOffset, db.yOffset )
				else
					Anchor:SetPoint("TOPLEFT", Foundation, "BOTTOMLEFT", db.xOffset, db.yOffset )
				end
			elseif db.Attach == "top" then
				if db.Inside then
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPLEFT", db.xOffset, db.yOffset )
				else
					Anchor:SetPoint("BOTTOMLEFT", Foundation, "TOPLEFT", db.xOffset, db.yOffset )
				end
			elseif db.Attach == "left" then
				if db.Inside then
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPLEFT", db.xOffset, db.yOffset )
				else
					Anchor:SetPoint("TOPRIGHT", Foundation, "TOPLEFT", db.xOffset, db.yOffset )
				end
			elseif db.Attach == "right" then
				if db.Inside then
					Anchor:SetPoint("TOPRIGHT", Foundation, "TOPRIGHT", db.xOffset, db.yOffset )
				else
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPRIGHT", db.xOffset, db.yOffset )
				end
			end

			Anchor:SetParent(Foundation)
			self:ConnectBars()
			self:UpdateBars()
		else
			if timeout > 5 then
				self:Print(L["Cannot find frame specified"])
				timeout = 0
				return
			end
			self:ScheduleTimer("AttachBar", 1, self)
			timeout = timeout + 1
		end 
	end
 
end

function Xparky:InitialiseEvents()
	self:RegisterEvent("PLAYER_XP_UPDATE", "UpdateBars")
	self:RegisterEvent("PLAYER_REGEN_DISABLED","DisableUpdate")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "EnableUpdate")
	self:RegisterBucketEvent("UPDATE_EXHAUSTION", 60, "UpdateBars")
	self:RegisterBucketEvent("UPDATE_FACTION", 5, "UpdateBars")
	hooksecurefunc("SetWatchedFactionIndex", Xparky.RescanFactions)
	if InCombatLockdown() then
		Xparky.UpdateMe = false
	else
		Xparky.UpdateMe = true
	end
end


function Xparky:DisableUpdate()
	Xparky.UpdateMe = false
end

function Xparky:EnableUpdate()
	Xparky.UpdateMe = true
end

function Xparky:UpdateBars(dimensions, returnTooltip)
	
	if not Xparky.UpdateMe then return end

	local total =  Width(Anchor:GetParent(), nil)
	local currentXP, maxXP, restXP, remainXP, repName, repLevel, minRep, maxRep, currentRep
	local xpString, repString, anchor

	anchor = 0

	if db.ShowXP then
		currentXP = UnitXP("player")
		maxXP = UnitXPMax("player")
		restXP = GetXPExhaustion() or 0
		remainXP = maxXP - (currentXP + restXP)
		if remainXP < 0 then
			remainXP = 0
		end

		Width(XPBar, (currentXP/maxXP)*total + 0.001)
		if (restXP + currentXP)/maxXP > 1 then
			Width(RestBar, total - Width(XPBar, nil) + 0.001)
		else
			Width(RestBar, (restXP/maxXP)*total + 0.001)
		end
		Width( NoXPBar, (remainXP/maxXP)*total + 0.001)

		Width( XPBar.Spark, Width(XPBar) < 20 and Width(XPBar) * 5 or 128)
		Width( XPBar.Spark2, Width(XPBar) < 20 and Width(XPBar) * 5 or 128)

		if db.LegoToGo then
			xpString = getHex("NoXPBar")..maxXP-currentXP.. L[" xp to go"]
		else
			xpString = getHex("XPBar") .. currentXP.."|r/"..getHex("NoXPBar") .. maxXP .. "|r - ["..string.format("%d%%", (currentXP/maxXP)*100).."] ("..string.format("%2d%%",((restXP)/maxXP)*100)..")"
		end
		anchor = db.Thickness

		
	end

	if db.ShowRep then
		repName, repLevel, minRep, maxRep, currentRep = GetWatchedFactionInfo()
		if repName then
			Width(RepBar, ((currentRep - minRep)/(maxRep-minRep))*total + 0.001)
			Width(NoRepBar, ((maxRep - currentRep)/(maxRep - minRep))*total + 0.001)
			if db.LegoToGo then
				repString = getHex("NoRepBar") .. maxRep - currentRep .. L[" rep to go - "]..getHex(repLevel).."(".. repName..")"
			else
				repString = getHex("RepBar").. currentRep - minRep.."|r/"..getHex("NoRepBar") .. maxRep .."|r"
			end
			Width(RepBar.Spark, Width(RepBar) < 20 and Width(RepBar) * 5 or  128)
			Width(RepBar.Spark2, Width(RepBar) < 20 and Width(RepBar) * 5 or  128)
			anchor = anchor + db.Thickness
		end
	end
	
	if db.ShowShadow then
		Width(Shadow, total)
		anchor = anchor + 5
	end

	Width(Anchor, total)
	Height(Anchor, anchor)
	
	if db.Lego and Lego then
		Lego:SetText((xpString or "") .. (xpString and "\n" or "")..(repString or ""))
	end

	if returnTooltip then
		if xpString then
	        GameTooltip:AddLine(xpString)
	    end
	    if repString then
	    	GameTooltip:AddLine(repString)
		end
		return
	end

	if type(dimensions) == "string" then	
		if dimensions == "Thickness" then
			Height(XPBar, db.Thickness)
			Height(NoXPBar, db.Thickness)
			Height(RestBar, db.Thickness)
			Height(RepBar, db.Thickness)
			Height(NoRepBar, db.Thickness)
			Height(XPBar.Spark, db.Thickness * 8)
			Height(XPBar.Spark2, db.Thickness * 8)
			Height(RepBar.Spark, db.Thickness * 8)
			Height(RepBar.Spark2, db.Thickness * 8)
			Height(Shadow, 5)
		elseif string.match(dimensions, "Bar") then
			local Bar = getglobal(dimensions .. "Xparky")
			SetColour(Bar, Bar.Texture)
		elseif string.match(dimensions, "Spark") then
			if dimensions == "Spark" then
				XPBar.Spark:SetAlpha(db.Spark)
			elseif dimensions == "Spark2" then
				RepBar.Spark:SetAlpha(db.Spark2)
			end
		elseif string.match(dimensions, "Show") then
			self:ConnectBars()
		elseif string.match(dimensions, "Offset") then
			self:AttachBar()
		elseif string.match(dimensions, "Mouse") then
			if not db.MouseTooltip and not db.MouseHide then
				Anchor:SetScript("OnEnter", nil)
				Anchor:SetScript("OnLeave", nil)
				Anchor:EnableMouse(false)
			else
				Anchor:SetScript("OnEnter", MouseOver)
				Anchor:SetScript("OnLeave",MouseOut) 
				Anchor:EnableMouse(true)
			end	
			if not db.MouseHide then
				Xparky:ConnectBars()
			else
				HideBars()
			end
		elseif string.match(dimensions,"ToGo") then
			self:AttachBar()
		elseif dimensions == "Attach" then
			self:UpdateBars("Thickness")
			self:AttachBar()
		elseif dimensions == "Inside" then
			self:AttachBar()
		elseif dimensions == "Lego" then
			if db.Lego then
				self:ShowLegoBlock()
			elseif Lego and Lego:IsVisible() then
				Lego:Hide()
			end
		elseif dimensions == "Strata" then
			SetStrata()
		end
	end
end

function Xparky:ShowLegoBlock()
	if not Lego then
		Lego = LibStub("LegoBlock-Beta1"):New("Xparky")
		Lego:SetDB(db.LegoDB)
		Lego:RegisterForClicks("LeftButtonUp","RightButtonUp")
		Lego:SetScript("OnClick", 
								function() 
									if IsShiftKeyDown() then
										local report = ""
										local st, sp = string.find(Lego.text:GetText(), "\n", 0, true)
										if GetMouseButtonClicked() == "LeftButton" then
											report = string.gsub(string.sub(Lego.text:GetText(), 0, st - 1), "|c%x%x%x%x%x%x%x%x", "")
										else
											report = string.gsub(string.sub(Lego.text:GetText(), sp + 1), "|c%x%x%x%x%x%x%x%x", "")
										end
										DEFAULT_CHAT_FRAME.editBox:SetText(string.gsub(report, "|r", ""))
										return
									end
									db.LegoToGo = not db.LegoToGo; 
									self:AttachBar(); 
									self:AttachBar() 
									reg:NotifyChange("Xparky") 
								end)
	end
	Lego:Show()
	if Anchor then self:AttachBar() end
end



