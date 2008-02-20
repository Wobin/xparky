--[[
--	Xparky is a rewrite of FuXPFu to use Ace3 and deFu it
--	Mouse frame selection shamelessly stolen from Dash (Kyhax)
--]]

Xparky = LibStub("AceAddon-3.0"):NewAddon("Xparky", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Xparky")
local reg = LibStub("AceConfigRegistry-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local _G = getfenv(0)
local options = {}
local db 
local factionTable = {}

local XPBar, NoXPBar, RepBar, NoRepBar, RestBar, Shadow, XPAnchor, RepAnchor, Lego

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
		XPBar = { 
			Foundation = "LegoXparky",
			Side = "bottom",
			Inside = false,
		},
		RepBar = {
			Foundation = "XPBar",
			Side = "bottom",
			Inside = "false"
		},
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


options.type = "group"
options.name  = "Xparky"
options.get  = function( k )  return db[k.arg] end
options.set  = function( k, v ) db[k.arg] = v; Xparky:UpdateBars(k.arg) end
options.args = {}

options.args.bars = {
	type = "group",
	name = L["Bars"],
	desc = L["Bar Modifications"],
	args = {
		showxpbar = {
			order = 1,
			name = L["Show XP Bar"],
			desc = L["Whether to show the XP bar or not"],
			type = "toggle",
			arg = "ShowXP"
		},
		showrepbar = {
			order = 2,
			name = L["Show Reputation Bar"],
			desc = L["Whether to show the Reputation bar or not"],
			type = "toggle",
			arg = "ShowRep"
		},
		showshadow = {
			order = 3,
			name = L["Show Shadow"],
			desc = L["Attach a shadow to the bars"],
			type = "toggle",
			arg = "ShowShadow"
		},
		showlego = {
			order = 4,
			name = L["Show Legoblock"],
			desc = L["Give a textbox with xp/rep details"],
			type = "toggle",
			arg = "Lego"
		},
		space = {
			order = 4,
			name = "    ",
			desc = "",
			type = "description"
		},
		xpspark = {
			order = 5,
			name = L["XP Spark Intensity"],
			desc = L["How strong the XP spark is"],
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark",
		},
		repspark = {
			order = 6,
			name = L["Reputation Spark Intensity"],
			desc = L["How strong the Reputation spark is"],
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark2"
		},
		thick = {
			order = 7,
			name = L["Bar Thickness"],
			desc = L["How thick the bars are"],
			type = "range",
			min = 1.5, max = 8, step = 0.1,
			arg = "Thickness"
		},
		colours = {
			type = "group",
			name = L["Colours"],
			desc = L["Colours of the bars"],
			order = 8,
			get = function(info)
				local t = db.barColours[info.arg] or { Red = 1, Green = 1, Blue = 1, Alpha = 1}
				return t.Red, t.Green, t.Blue, t.Alpha
			end,
			set = function(info, r, g ,b, a)
				local t = db.barColours[info.arg]
				t.Red = r
				t.Green = g
				t.Blue = b
				t.Alpha = a
				Xparky:UpdateBars(info.arg)
			end,
			args = {
				colourXP = {
					order = 1,
					name = L["Experience Bar"],
					desc = L["Colour of the full XP bar"],
					type = "color",
					hasAlpha = true,
					arg = "XPBar"
				},
				colourNoXP = {
					order = 2,
					name = L["Empty Experience Bar"],
					desc = L["Colour of the empty XP bar"],
					type = "color",
					hasAlpha = true,
					arg = "NoXPBar"
				},
				colourRested = {
					order = 3,
					name = L["Rested Bar"],
					desc = L["Colour of the Rested XP bar"],
					type = "color",
					hasAlpha = true,
					arg  = "RestBar"
				},
				space = {
					order = 4,
					name = "",
					desc  = "",
					type = "description"
				},
				colourRep = {
					order = 5,
					name = L["Reputation Bar"],
					desc = L["Colour of the full Reputation bar"],
					type = "color",
					hasAlpha = true,
					arg = "RepBar"
				},
				colourNoRep = {
					order = 6,
					name = L["Empty Reputation Bar"],
					desc = L["Colour of the empty Reputation bar"],
					type = "color",
					hasAlpha = true,
					arg = "NoRepBar"
				},
			},
		},
	},
}
option.args.framelink = {
	type = "group",
	name = L["Frame Link"],
	order = 1,
	args = {
		attach = {
			order = 1,
			type = "execute",
			name = L["Hook to frame"],
			desc = L["Click here to activate the frame selector"],
			func = function() mouser:Start() end
		},
		space = {
			order = 2,
			name = "",
			desc = "",
			type = "description"
		},
		attached = {
			order = 3,
			type = "input",
			name = L["Frame Connected to"],
			desc = L["The name of the frame to connect to"],
			arg = "ConnectedFrame",
			set = function(k,v) db.ConnectedFrame = v; db.Detached = false; Xparky:AttachBar() end
		},
		attachto = {
			order = 4,
			name = L["Attach to:"],
			desc = L["Which side to attach to"],
			type = "select",
			values = { top = L["Top"], bottom = L["Bottom"], left = L["Left"], right = L["Right"] },
			arg = "Attach"
		},
		insideframe = {
			order = 5,
			name = L["Inside Frame?"],
			desc = L["Attach to the inside of the frame"],
			type = "toggle",
			arg = "Inside"
		},
	},
},

option.args.faq = {
	name = L["Help"],
	desc = L["Help information"],
	type = "group",
	order = 100,
	args = {
		Basic = {
			type = "description",
			name = L["DESCRIPTION"],
			order = 1
		},
		FAQ = {
			type = "description",
			name = L["FAQ_TEXT"],
			order = 2,
		},
		Info = {
			type = "description",
			name = L["ADDON_INFO"],
			order = 3
		}
	}
}
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
end

options.args.factions = {
	type = "group",
	name = L["Factions"],
	args = {
		factionlist = {
			name = L["Faction Selected"],
			desc = L["List of Factions to watch"],
			type = "select",
			values = factionTable,
			arg = "Faction",
			set = function(k, v) db.Faction = tonumber(v); SetWatchedFactionIndex(tonumber(v)); end 
		}
	}
}

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
	local tex = Bar:CreateTexture(Bar.Texture, "OVERLAY")
	tex:SetTexture(Bar.Texture)
	tex:ClearAllPoints()
	tex:SetAllPoints(Bar)
	tex:Show()
	Bar.Texture = tex
	Height(Bar, db.Thickness)
	if Spark then
		local spark = Bar:CreateTexture(Bar.Name .. "Spark", "OVERLAY")
		spark:SetTexture(Bar.Spark1)
		Width(spark, 128)
		Height(spark, db.Thickness * 5)
		spark:SetBlendMode("ADD")
		spark:SetParent(Bar)
		spark:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark = spark

		local spark2 = Bar:CreateTexture(Bar.Name .. "Spark2", "OVERLAY")
		spark2:SetTexture(Bar.Spark2)
		Width(spark2, 128)
		Height(spark2, db.Thickness * 5)
		spark2:SetBlendMode("ADD")
		spark2:SetParent(Bar)
		spark2:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark2 = spark2
	end
	SetColour(Bar, tex)
	Bar:ClearAllPoints()
	Width(Bar, 100)
	Bar:SetFrameStrata("DIALOG")
	return Bar
end

local function GenerateBar(BarName, Spark, Anchor)
	local Bar = CreateFrame("Frame", BarName .. "Xparky", Anchor)
	Bar.Name = BarName
	Bar.Texture = "Interface\\AddOns\\Xparky\\Textures\\texture.tga"
	Bar.Spark1 =  "Interface\\AddOns\\Xparky\\Textures\\glow.tga"
	Bar.Spark2 =  "Interface\\AddOns\\Xparky\\Textures\\glow2.tga"
	return CreateBar(Bar, Spark)
end


function Xparky:InitializeBars()
	XPAnchor = CreateFrame("Frame", "XparkyXPAnchor", Lego or UIParent)
	XPAnchor:SetWidth(1)
	XPAnchor:SetHeight(1)
	XPAnchor:Show()
	RepAnchor = CreateFrame("Frame", "XparkyRepAnchor", Lego or UIParent)
	RepAnchor:SetWidth(1)
	RepAnchor:SetHeight(1)
	RepAnchor:Show()
	XPBar = GenerateBar("XPBar", true, XPAnchor)
	NoXPBar = GenerateBar("NoXPBar", false, XPAnchor)
	RepBar = GenerateBar("RepBar", true, RepAnchor)
	NoRepBar = GenerateBar("NoRepBar", false, RepAnchor)
	RestBar = GenerateBar("RestBar", false, XPAnchor)
	XPShadow = GenerateBar("XPShadow", false, XPAnchor)
	XPShadow.Texture:SetTexture("Interface\\AddOns\\Xparky\\Textures\\border.tga")
	XPShadow.Texture:SetVertexColor(0, 0, 0, 1)
	XPShadow.Texture:SetHeight(5)
	RepShadow = GenerateBar("RepShadow", false, RepAnchor)
	RepShadow.Texture:SetTexture("Interface\\AddOns\\Xparky\\Textures\\border.tga")
	RepShadow.Texture:SetVertexColor(0, 0, 0, 1)
	RepShadow.Texture:SetHeight(5)
end

function Xparky:ConnectBars()
	local Base = XPAnchor
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
		x = 5
		y = 0
	else
		barEnd = "BOTTOM"
		x = 0
		y = -5
	end

	XPBar:Hide()
	RestBar:Hide()
	NoXPBar:Hide()

	if db.ShowXP then
		XPBar:ClearAllPoints()
		XPBar:SetPoint(TabA, Base, SlotB)
		XPBar:SetFrameLevel( NoXPBar:GetFrameLevel() + 1)
		XPBar.Spark:ClearAllPoints()
		XPBar.Spark:SetPoint(barEnd, Base, barEnd, x, y)
		XPBar.Spark2:ClearAllPoints()
		XPBar.Spark2:SetPoint(barEnd, Base, barEnd, x, y)
		RestBar:ClearAllPoints()
		RestBar:SetPoint(TabC, XPBar, SlotD)
		NoXPBar:ClearAllPoints()
		NoXPBar:SetPoint(TabC, RestBar, SlotD)
		XPBar:Show()
		RestBar:Show()
		NoXPBar:Show()
		XPBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		XPBar.Spark:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		XPBar.Spark2:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		NoXPBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		RestBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		Base = XPBar
	end 
	
	RepBar:Hide()
	NoRepBar:Hide()
	
	if db.ShowRep then
		RepBar:ClearAllPoints()
		RepBar:SetPoint(TabA, Base, SlotB )
		RepBar.Spark:SetPoint(barEnd, RepBar, barEnd, x, y)
		RepBar.Spark2:SetPoint(barEnd, RepBar, barEnd, x, y)
		NoRepBar:ClearAllPoints()
		NoRepBar:SetPoint(TabC, RepBar, SlotD)
		RepBar:SetFrameLevel( NoRepBar:GetFrameLevel() + 1)
		RepBar:Show()
		NoRepBar:Show() 
		RepBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		NoRepBar.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		RepBar.Spark:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		RepBar.Spark2:SetTexCoord(stlx, stly, strx, stry, sblx, sbly, sbrx, sbry)
		Base = RepBar
	end
	
	Shadow:Hide()

	if db.ShowShadow then
		Shadow:ClearAllPoints()
		Shadow:SetPoint(TabA, Base, SlotB)
		Shadow.Texture:SetTexCoord(tlx, tly, trx, try, blx, bly, brx, bry)
		Shadow:Show()
	end
end
do

	local timeout = 0

	function Xparky:AttachBar(Bar)
		local Foundation = db.ConnectedFrame and getglobal(db.ConnectedFrame) or nil
		if Foundation then
			Anchor:ClearAllPoints()

			if db.Attach == "bottom" then
				if db.Inside then
					Anchor:SetPoint("BOTTOMLEFT", Foundation, "BOTTOMLEFT")
				else
					Anchor:SetPoint("TOPLEFT", Foundation, "BOTTOMLEFT", 0, -1)
				end
			elseif db.Attach == "top" then
				if db.Inside then
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPLEFT")
				else
					Anchor:SetPoint("BOTTOMLEFT", Foundation, "TOPLEFT", 0, 1)
				end
			elseif db.Attach == "left" then
				if db.Inside then
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPLEFT")
				else
					Anchor:SetPoint("TOPRIGHT", Foundation, "TOPLEFT", 0, 1)
				end
			elseif db.Attach == "right" then
				if db.Inside then
					Anchor:SetPoint("TOPRIGHT", Foundation, "TOPRIGHT")
				else
					Anchor:SetPoint("TOPLEFT", Foundation, "TOPRIGHT", 0, 1)
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
	self:RegisterBucketEvent("UPDATE_EXHAUSTION", 60, "UpdateBars")
	self:RegisterBucketEvent("UPDATE_FACTION", 5, "UpdateBars")
	hooksecurefunc("SetWatchedFactionIndex", Xparky.RescanFactions)
	
end



function Xparky:UpdateBars(dimensions)
	local total =  Width(Anchor:GetParent(), nil)
	local currentXP, maxXP, restXP, remainXP, repName, repLevel, minRep, maxRep, currentRep
	local xpString, repString

	if db.ShowXP then
		currentXP = UnitXP("player")
		maxXP = UnitXPMax("player")
		restXP = GetXPExhaustion() or 0
		remainXP = maxXP - (currentXP + restXP)
		if remainXP < 0 then
			remainXP = 0
		end

		Width(XPBar, (currentXP/maxXP)*total)
		if (restXP + currentXP)/maxXP > 1 then
			Width(RestBar, total - Width(XPBar, nil))
		else
			Width(RestBar, (restXP/maxXP)*total + 0.001)
		end
		Width( NoXPBar, (remainXP/maxXP)*total)
		if db.LegoToGo then
			xpString = getHex("NoXPBar")..maxXP-currentXP.. L["xp to go"]
		else
			xpString = getHex("XPBar") .. currentXP.."|r/"..getHex("NoXPBar") .. maxXP .. "|r - ["..string.format("%d%%", (currentXP/maxXP)*100).."] ("..string.format("%2d%%",((restXP)/maxXP)*100)..")"
		end
	end

	if db.ShowRep then
		repName, repLevel, minRep, maxRep, currentRep = GetWatchedFactionInfo(tonumber(db.Faction))
		Width(RepBar, ((currentRep - minRep)/(maxRep-minRep))*total)
		Width(NoRepBar, ((maxRep - currentRep)/(maxRep - minRep))*total)
		if db.LegoToGo then
			repString = getHex("NoRepBar") .. maxRep - currentRep .. L[" rep to go - "]..getHex(repLevel).."(".. repName..")"
		else
			repString = getHex("RepBar").. currentRep.."|r/"..getHex("NoRepBar") .. maxRep .."|r"
		end
	end
	
	if db.ShowShadow then
		Width(Shadow, total)
	end

	if db.Lego and Lego then
		Lego:SetText((xpString or "") .. (xpString and "\n" or "")..(repString or ""))
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
		end
	end
end

function Xparky:ShowLegoBlock()
	if not Lego then
		Lego = LibStub("LegoBlock-Beta1"):New("Xparky")
		Lego:SetDB(db.LegoDB)
		Lego:SetScript("OnClick", function() db.LegoToGo = not db.LegoToGo; self:AttachBar(); self:AttachBar() end)
	end
	Lego:Show()
	if Anchor then self:AttachBar() end
end


