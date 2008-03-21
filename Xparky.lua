--[[
--	Xparky is a rewrite of FuXPFu to use Ace3 and deFu it
--	Mouse frame selection shamelessly stolen from Dash (Kyhax)
--]]

Xparky = LibStub("AceAddon-3.0"):NewAddon("Xparky", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Xparky")
local reg = LibStub("AceConfigRegistry-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local _G = getfenv(0)
Xparky.options = {}
local options = Xparky.options  
local factionTable = {}

local XPBar, NoXPBar, RepBar, NoRepBar, RestBar, Shadow, Anchor, Lego


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



Xparky.db = LibStub("AceDB-3.0"):New("XparkyDB", default, "profile")
local db  = Xparky.db.profile

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

function Xparky:OnInitialize()
	--db = Xparky.db.profile
	reg:RegisterOptionsTable("Xparky", options)
	self:RegisterChatCommand("xparky", function() dialog:Open("Xparky") end)
	if db.Lego then
	--	self:ShowLegoBlock()
	end
	Frog = XparkyBar:New{Name="Frog", Type="XP", Rotate = 0}
	Womble = XparkyBar:New{Name="Womble", Type="Rep", Faction=6, Rotate = 90}
	Cabbage = XparkyBar:New{Name="Cabbage", Type="Rep", Faction=2, Rotate =	270}
	Bing = XparkyBar:New{Name="Bing", Type="Rep", Faction=4, Rotate = 180}

	Xparky:getFactions()
	--self:ScheduleTimer("UpdateBars", 0.1, self)
	--Anchor:EnableMouse(true)
	
--[[	if db.MouseTooltip or db.MouseHide then 
	    Anchor:SetScript("OnEnter",MouseOver)
		Anchor:SetScript("OnLeave",MouseOut) 
		if db.MouseHide then
			HideBars()
		end
	end --]]


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



