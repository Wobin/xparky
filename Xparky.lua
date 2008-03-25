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
local XPBar, NoXPBar, RepBar, NoRepBar, RestBar, Shadow, Anchor, Lego

Xparky.db = {}

local default = {
	profile = {
		LegoDB = {
			width = 32,
			height = 32,
			showText = true,
			showIcon = false,
			scale = 1,
			group = nil
		},
		Bars = {
			BarNames = { "XPBar", "RepBar" },
			XPBar = {
				Name = "XPBar",
				BarType = "XP",
			},
			RepBar = {
				Name = "RepBar",
				BarType = "Rep",
				Faction = 2,
			}
		}
	}
}



local db  



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
	Xparky.db = LibStub("AceDB-3.0"):New("XparkyDB", default)
	self:InitialiseOptions()
	
	db = Xparky.db.profile
	reg:RegisterOptionsTable("Xparky", options)
	self:RegisterChatCommand("xp", function() dialog:Open("Xparky") end)

	--Frog = XparkyBar:New{Name="Frog", Type="XP", Rotate = 0}
	Xparky:GenerateBars()
	Xparky:getFactions()
	Xparky:GenerateBarList()
	--Anchor:EnableMouse(true)
	
--[[	if db.MouseTooltip or db.MouseHide then 
	    Anchor:SetScript("OnEnter",MouseOver)
		Anchor:SetScript("OnLeave",MouseOut) 
		if db.MouseHide then
			HideBars()
		end
	end --]]


end

function Xparky:GenerateBars()
	for i,v in ipairs(db.Bars.BarNames) do
		XparkyBar:New(db.Bars[v])
	end
end


function Xparky:Compare()
	local first
	for i,v in ipairs(db.Bars.BarNames) do
		if not first then 
			first = db.Bars[v].Options 
		else
			if first == db.Bars[v].Options then
				Xparky:Print("Matching")
			end
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
