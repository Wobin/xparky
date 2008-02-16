--[[
--	Xparky is a rewrite of FuXPFu to use Ace3 and deFu it
--	Mouse frame selection shamelessly stolen from Dash (Kyhax)
--]]

local Xparky = LibStub("AceAddon-3.0"):NewAddon("Xparky", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
--local L = LibStub("AceLocale-3.0"):GetLocale("Xparky")
local reg = LibStub("AceConfigRegistry-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local _G = getfenv(0)
local options = {}
local db 
local factionTable = {}

local XPBar, NoXPBar, RepBar, NoRepBar, RestBar, Shadow, Anchor

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
		ShowXP = true,
		ShowRep = false,
		ShowShadow = true,
		Thickness = 2,
		Spark = 1,
		Spark2 = 1,
		Attach = "bottom"
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
            Xparky:Print("This frame has no global name, and cannot be added via the mouse")
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
options.name = "Xparky"
options.get  = function( k )  return db[k.arg] end
options.set  = function( k, v ) db[k.arg] = v; Xparky:UpdateBars(k.arg) end
options.args = {}

options.args.bars = {
	type = "group",
	name = "Bars",
	desc = "Bar Modifications",
	guiInline = true,
	args = {
		showxpbar = {
			order = 1,
			name = "Show XP Bar",
			desc = "Whether to show the XP bar or not",
			type = "toggle",
			arg = "ShowXP"
		},
		showrepbar = {
			order = 2,
			name = "Show Reputation Bar",
			desc = "Whether to show the Reputation bar or not",
			type = "toggle",
			arg = "ShowRep"
		},
		showshadow = {
			order = 3,
			name = "Show Shadow",
			desc = "Attach a shadow to the bars",
			type = "toggle",
			arg = "ShowShadow"
		},
		space = {
			order = 4,
			name = "    ",
			desc = "",
			type = "description"
		},

		xpspark = {
			order = 5,
			name = "XP Spark Intensity",
			desc = "How strong the XP spark is",
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark",
		},
		repspark = {
			order = 6,
			name = "Reputation Spark Intensity",
			desc = "How strong the Reputation spark is",
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark2"
		},
		thick = {
			order = 7,
			name = "Bar Thickness",
			desc = "How thick the bars are",
			type = "range",
			min = 1.5, max = 8, step = 0.1,
			arg = "Thickness"
		},
		attach = {
			order = 8,
			type = "execute",
			name = "Hook to frame",
			desc = "Click here to activate the frame selector",
			func = function() mouser:Start() end
		},
		attached = {
			order = 9,
			type = "input",
			name = "Frame Connected to",
			arg = "ConnectedFrame"
		},
		attachto = {
			order = 10,
			name = "Attach to:",
			desc = "Which side to attach to",
			type = "select",
			values = { top = "Top", bottom = "Bottom" },
			arg = "Attach"
		},
		colours = {
			type = "group",
			name = "Colours",
			desc = "Colours of the bars",
			order = 11,
			guiInline = true,
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
					name = "Experience Bar",
					desc = "Colour of the full XP bar",
					type = "color",
					hasAlpha = true,
					arg = "XPBar"
				},
				colourNoXP = {
					order = 2,
					name  = "Empty Experience Bar",
					desc  = "Colour of the empty XP bar",
					type = "color",
					hasAlpha = true,
					arg = "NoXPBar"
				},
				colourRested = {
					order = 3,
					name = "Rested Bar",
					desc = "Colour of the Rested XP bar",
					type = "color",
					hasAlpha = true,
					arg  = "RestBar"
				},
				space = {
					order = 4,
					name = "",
					desc = "",
					type = "description"
				},
				colourRep = {
					order = 5,
					name = "Reputation Bar",
					desc = "Colour of the full Reputation bar",
					type = "color",
					hasAlpha = true,
					arg = "RepBar"
				},
				colourNoRep = {
					order = 6,
					name = "Empty Reputation Bar",
					desc = "Colour of the empty Reputation bar",
					type = "color",
					hasAlpha = true,
					arg = "NoRepBar"
				},
			}
		}
	}
}

function Xparky:RescanFactions()
	Xparky:ScheduleTimer("getFactions", 1, Xparky)
end

function Xparky:getFactions()
	local WatchedFaction = GetWatchedFactionInfo()
	self:Print("Scanning Factions")
	for factionIndex = 1, GetNumFactions() do
		local name, _, _, _, _, _, _, _,isHeader, _, isWatched = GetFactionInfo(factionIndex)
		if not isHeader then
			if WatchedFaction == name then
				db.Faction = factionIndex;
			end
			factionTable[factionIndex] = name
		end
	end
end

options.args.factions = {
	type = "group",
	name = "Faction Selected",
	desc = "List of Factions to watch",
	type = "select",
	values = factionTable,
	arg = "Faction",
	set = function(k, v) db.Faction = tonumber(v); SetWatchedFactionIndex(tonumber(v)) end 
}

function Xparky:OnInitialize()
	Xparky.db = LibStub("AceDB-3.0"):New("XparkyDB", default, "profile")
	db = Xparky.db.profile
	reg:RegisterOptionsTable("Xparky", options)
	self:RegisterChatCommand("xparky", function() dialog:Open("Xparky") end)
	Xparky:getFactions()
	Xparky:InitializeBars()
	Xparky:ConnectBars()
	Xparky:AttachBar()
	Xparky:InitialiseEvents()
end

local function SetColour(Bar, texture) 
	local Setting = db.barColours[Bar.Name]
	if Setting then
		texture:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
	end
end

local function CreateBar(Bar, Spark)
	local tex = Bar:CreateTexture(Bar.Texture)
	tex:SetTexture(Bar.Texture)
	SetColour(Bar, tex)
	tex:ClearAllPoints()
	tex:SetAllPoints(Bar)
	tex:Show()
	Bar.Tex = tex
	Bar:SetHeight(db.Thickness)
	if Spark then
		local spark = Bar:CreateTexture(Bar.Name .. "Spark", "OVERLAY")
		spark:SetTexture(Bar.Spark1)
		spark:SetWidth(128)
		spark:SetHeight(db.Thickness * 8)
		SetColour(Bar, spark)
		spark:SetBlendMode("ADD")
		spark:SetParent(Bar)
		spark:SetPoint("RIGHT", Bar, "RIGHT", 15, 0)
		spark:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark = spark
		local spark2 = Bar:CreateTexture(Bar.Name .. "Spark2", "OVERLAY")
		spark2:SetTexture(Bar.Spark2)
		spark2:SetWidth(128)
		spark2:SetHeight(db.Thickness * 8)
		SetColour(Bar, spark2)
		spark2:SetBlendMode("ADD")
		spark2:SetParent(Bar)
		spark2:SetPoint("RIGHT", Bar, "RIGHT", 15, 0)
		spark2:SetAlpha(Bar.Name == "XPBar" and db.Spark or db.Spark2)
		Bar.Spark2 = spark2
	end
	Bar:ClearAllPoints()
	Bar:SetWidth(100)
	Bar:SetFrameStrata("HIGH")
	return Bar
end

local function GenerateBar(BarName, Spark)
	local Bar = CreateFrame("Frame", BarName .. "Xparky", Anchor)
	Bar.Name = BarName
	Bar.Texture = "Interface\\AddOns\\Xparky\\Textures\\texture.tga"
	Bar.Spark1 =  "Interface\\AddOns\\Xparky\\Textures\\glow.tga"
	Bar.Spark2 =  "Interface\\AddOns\\Xparky\\Textures\\glow2.tga"
	return CreateBar(Bar, Spark)
end



function Xparky:InitializeBars()
	Anchor = CreateFrame("Frame", "XparkyAnchor", UIParent)
	Anchor:SetWidth(1)
	Anchor:SetHeight(1)
	Anchor:Show()
	XPBar = GenerateBar("XPBar", true)
	NoXPBar = GenerateBar("NoXPBar")
	RepBar = GenerateBar("RepBar", true)
	NoRepBar = GenerateBar("NoRepBar")
	RestBar = GenerateBar("RestBar")
	Shadow = GenerateBar("Shadow")
	Shadow.Tex:SetTexture("Interface\\AddOns\\Xparky\\Textures\\border.tga")
	Shadow.Tex:SetVertexColor(0, 0, 0, 1)
	Shadow.Tex:SetHeight(5)
	Shadow.Tex:SetTexCoord(0,1,0,1)
end

function Xparky:ConnectBars()
	local Base = Anchor
	local TabA = "TOPLEFT"
	local SlotB = "BOTTOMLEFT"
	Shadow.Tex:SetTexCoord(0,1,0,1)

	if db.Attach == "top" then
		TabA = "BOTTOMLEFT"
		SlotB = "TOPLEFT"
		Shadow.Tex:SetTexCoord(1,0,1,0)
	end

	XPBar:Hide()
	RestBar:Hide()
	NoXPBar:Hide()

	if db.ShowXP then
		XPBar:ClearAllPoints()
		XPBar:SetPoint(TabA, Base, SlotB)
		XPBar:SetFrameLevel( NoXPBar:GetFrameLevel() + 1)
		RestBar:ClearAllPoints()
		RestBar:SetPoint("LEFT", XPBar, "RIGHT")
		NoXPBar:ClearAllPoints()
		NoXPBar:SetPoint("LEFT", RestBar, "RIGHT")
		XPBar:Show()
		RestBar:Show()
		NoXPBar:Show()
		Base = XPBar
	end 
	
	RepBar:Hide()
	NoRepBar:Hide()
	
	if db.ShowRep then
		RepBar:ClearAllPoints()
		RepBar:SetPoint(TabA, Base, SlotB )
		NoRepBar:ClearAllPoints()
		NoRepBar:SetPoint("LEFT", RepBar, "RIGHT")
		RepBar:SetFrameLevel( NoRepBar:GetFrameLevel() + 1)
		RepBar:Show()
		NoRepBar:Show()
		Base = RepBar
	end
	
	Shadow:Hide()

	if db.ShowShadow then
		Shadow:ClearAllPoints()
		Shadow:SetPoint(TabA, Base, SlotB)
		Shadow:Show()
	end
end

function Xparky:AttachBar()
	local Foundation = db.ConnectedFrame and getglobal(db.ConnectedFrame) or nil
	if Foundation then
		Anchor:ClearAllPoints()
		if db.Attach == "bottom" then
			Anchor:SetPoint("TOPLEFT", Foundation, "BOTTOMLEFT", 0, 1)
		else
			Anchor:SetPoint("BOTTOMLEFT", Foundation, "TOPLEFT",0, -1)
		end
		Anchor:SetParent(Foundation)
		self:ConnectBars()
		self:UpdateBars()
	else
		self:ScheduleTimer("AttachBar", 1, self)
	end 
end

function Xparky:InitialiseEvents()
	self:RegisterEvent("PLAYER_XP_UPDATE", "UpdateBars")
	self:RegisterBucketEvent("UPDATE_EXHAUSTION", 60, "UpdateBars")
	self:RegisterBucketEvent("UPDATE_FACTION", 5, "UpdateBars")
	hooksecurefunc("SetWatchedFactionIndex", Xparky.RescanFactions)
	
end

function Xparky:UpdateBars(dimensions)
	local total = Anchor:GetParent():GetWidth()
	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")
	local restXP = GetXPExhaustion() or 0
	local remainXP = maxXP - (currentXP + restXP)
	if remainXP < 0 then
		remainXP = 0
	end

	XPBar:SetWidth((currentXP/maxXP)*total)
	if (restXP + currentXP)/maxXP > 1 then
		RestBar:SetWidth(total - XPBar:GetWidth())
	else
		RestBar:SetWidth((restXP/maxXP)*total + 0.001)
	end
	NoXPBar:SetWidth((remainXP/maxXP)*total)

	local minRep, maxRep, currentRep = select(3, GetWatchedFactionInfo(tonumber(db.Faction)))
	RepBar:SetWidth(((currentRep - minRep)/(maxRep-minRep))*total)
	NoRepBar:SetWidth(((maxRep - currentRep)/(maxRep - minRep))*total)
	Shadow:SetWidth(total)
	if type(dimensions) == "string" then	
		if dimensions == "Thickness" then
			XPBar:SetHeight(db.Thickness)
			NoXPBar:SetHeight(db.Thickness)
			RestBar:SetHeight(db.Thickness)
			RepBar:SetHeight(db.Thickness)
			NoRepBar:SetHeight(db.Thickness)
			XPBar.Spark:SetHeight(db.Thickness * 8)
			XPBar.Spark2:SetHeight(db.Thickness * 8)
			RepBar.Spark:SetHeight(db.Thickness * 8)
			RepBar.Spark2:SetHeight(db.Thickness * 8)
		elseif string.match(dimensions, "Bar") then
			local Bar = getglobal(dimensions .. "Xparky")
			SetColour(Bar, Bar.Tex)
		elseif string.match(dimensions, "Spark") then
			if dimensions == "Spark" then
				XPBar.Spark:SetAlpha(db.Spark)
			elseif dimensions == "Spark2" then
				RepBar.Spark:SetAlpha(db.Spark2)
			end
		elseif dimensions == "Attach" then
			self:AttachBar()
		elseif string.match(dimensions, "Show") then
			self:ConnectBars()
		end
	end
end


