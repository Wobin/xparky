local defaultBar = {}

local reg = LibStub("AceConfigRegistry-3.0")
local event = LibStub("AceEvent-3.0")
local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }
local angles = {[180] = { 1,0,1,1,0,0,0,1}, [0] = {0,1,0,0,1,1,1,0}, [270] = {1,1,0,1,1,0,0,0}, [90] = {0,0,1,0,0,1,1,1}}

XparkyBar = {}

local Bar = XparkyBar
--[[ Base Bar functions ]] --
local function cloneTable(t)
	local clone = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			clone[i] = cloneTable(v)
		else
			clone[i] = v
		end
	end
	return clone
end

local mouser = CreateFrame("Frame")
local tb = {A = "top", B = "bottom", 
				SideA = function(frame) return MouseIsOver(frame, 0, frame:GetHeight()/2, 0, 0) end, 
				SideB = function(frame) return MouseIsOver(frame, 0 - frame:GetHeight()/2, 0, 0, 0) end, 
			}
local lr = {A = "left", B = "right",
				SideA = function(frame) return MouseIsOver(frame, 0, 0, 0, 0 - frame:GetWidth()/2) end, 
				SideB = function(frame) return MouseIsOver(frame, 0, 0, frame:GetHeight()/2, 0) end, 
			}
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
	local side
	if mouser.side.SideA(frame) then
		side = mouser.side.A
	else
		side = mouser.side.B
	end
    self.tooltip:SetText(name .. " ("..side..")", 1.0, 0.82, 0)
    self.tooltip:Show()
    
    if IsMouseButtonDown("LeftButton") then
        self:Stop()
        if not type(frame.GetName) == 'function' or not frame:GetName() then
            Xparky:Print("This frame has no global name, and cannot be added via the mouse")
        else
        	mouser.bar:AttachBarToFrame(name, side)
        	mouser.bar:ConstructBar()
			mouser.bar = nil
			mouser.side = nil
        	reg:NotifyChange("Xparky")
        end
    end
end

function mouser:Start(angle)
	if angle == 90 or angle == 270 then
		mouser.side = lr
	else
		mouser.side = tb
	end
	Xparky:Print(mouser.bar.Name)
    self:SetScript("OnUpdate", self.OnUpdate)
end

function mouser:Stop()
    self.tooltip:Hide()
    self:SetScript("OnUpdate", nil)
end
hooksecurefunc(_G.GameMenuFrame, "Show", function() mouser:Stop() end)

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

local BaseBar = {
				Direction = "forward",
				Thickness = 8,
				Spark = 1,
				ShowLabel = true,
				TextureFile = "Interface\\AddOns\\Xparky\\Textures\\texture.tga",
				Spark1File =  "Interface\\AddOns\\Xparky\\Textures\\glow.tga",
				Spark2File =  "Interface\\AddOns\\Xparky\\Textures\\glow2.tga",

			}

function BaseBar:AttachBarToFrame(frame, side)
	Xparky:Print("Attach "..self.Name.." to "..frame.." on the "..side.." side")
	self.Attach = frame
	self.Attached = side
	Xparky.db.profile.Bars[self.Name].Attach = frame
	Xparky.db.profile.Bars[self.Name].Attached = side
end

function BaseBar:new(o)
	setmetatable(o, self)
	if o.Name then
		o.Anchor = CreateFrame("Frame", o.Name .. "Xparky", UIParent)
		o.Anchor:SetWidth(1)
		o.Anchor:SetHeight(self.Thickness)
		o.Anchor:Show()

		if o.BarType then
			o.Options = {
					type = "group",
					handler = o,
					name = o.Name,
					set = function(info,v) 
							Xparky.db.profile.Bars[info.handler.Name][info.arg] = v;
							info.handler[info.arg] = v
							info.handler:ConstructBar()
							if info.type ~= "range" then
								reg:NotifyChange("Xparky")
							end
						end,
					get = function(info) return info.handler[info.arg] end,
					args = {
						barname = {
							type = "header",
							order = 1,
							name = o.Name
						},
						width = {
							type = "range",
							name = "Bar Length",
							desc = "How long the bar is",
							min = 0.1, max = 2000, step = 1,
							arg = "BarWidth",
							hidden = function(info) return info.handler.Attach and info.handler.Attach ~= "" end,
							order = 2,
						},
						spacer = {
							type = "description",
							name = "",
							desc = "",
							hidden = function(info) return not info.handler.Attach or info.handler.Attach == "" end,
							order = 2,
						},
						thickness = {
							type = "range",
							name = "Bar Thickness",
							desc = "How thick the bar is",
							min = 0.1, max = 32, step = 0.5,
							arg = "Thickness",
							order = 3
						},
						spark = {
							type = "range",
							name = "Spark intensity",
							desc = "Alpha of the spark",
							min = 0, max = 1, step = 0.05,
							arg = "Spark",
							order = 4,
						},
						rotation = {
							type = "select",
							name = "Bar Rotation",
							desc = "Angle at which the bar runs",
							values = {[0] = 0, [90] = 90, [180] = 180, [270] = 270},
							order = 5,
							arg = "Rotate"
						},
						label = {
							type = "toggle",
							name = "Show Label",
							desc = "Show the bar label",
							arg = "ShowLabel",
						},
						attach = {
							type = "execute",
							name = "Attach to frame",
							func = function(info) mouser.bar = info.handler; mouser:Start(info.handler.Rotate) end,
							order = 6,
						},
						attached = {
							type = "input",
							name = "Attached to frame",
							arg = "Attach",
							order = 7,
						},
						side = {
							type = "select",
							name = "Side of frame",
							arg = "Attached",
							hidden = function(info) return info.handler.Attach and info.handler.Attach ~= "" end,
							values = function(info) if info.handler.Rotate == 90 or info.handler.Rotate == 270 then return { left = "Left", right = "Right" } else return {top = "Top", bottom = "Bottom" } end end,
						},
						xoffset = {
							type = "input",
							name = "X offset",
							desc = "Offset from the frame in the X axis",
							arg = "Xoffset",
							order = 8,
							hidden = function(info) return not info.handler.Attach or info.handler.Attach == "" end,
						},
						yoffset = {
							type = "input",
							name = "Y offset",
							desc = "Offset from the frame in the Y axis",
							arg = "Yoffset",
							order = 9,
							hidden = function(info) return not info.handler.Attach or info.handler.Attach == "" end,
						},
						colours = {
							type = "group",
							inline = true,
							name = "Colours",
							desc = "Colours of the sections",
							order = 10,
							get = function(info)
									local t = info.handler.Colours[info.arg] or { Red = 1, Green = 1, Blue = 1, Alpha = 1}
									return t.Red, t.Green, t.Blue, t.Alpha
									end,
							set = function(info, r, g ,b, a)
									local t = info.handler.Colours[info.arg]
									if not Xparky.db.profile.Bars[info.handler.Name].Colours then 
										Xparky.db.profile.Bars[info.handler.Name].Colours = {}
									end
									if not Xparky.db.profile.Bars[info.handler.Name].Colours[info.arg] then 
										Xparky.db.profile.Bars[info.handler.Name].Colours[info.arg] = {} 
									end
									local dbt = Xparky.db.profile.Bars[info.handler.Name].Colours[info.arg]
									t.Red, t.Green, t.Blue, t.Alpha = r, g, b, a
									dbt.Red, dbt.Green, dbt.Blue, dbt.Alpha = r, g, b, a
									info.handler:ConstructBar()
									end,
							args = {}
						},
						delete = {
							type = "execute",
							name = "Delete Bar",
							desc = "Delete this bar",
							func = function(info) 
										Xparky.db.profile.Bars[info.handler.Name] = nil
										XparkyBar.Bars[info.handler.Name].Anchor:Hide()
										XparkyBar.Bars[info.handler.Name] = nil
										Xparky:GenerateBarList()
									end,
						},
					}
				}
		if o.MouseTooltip or o.MouseHide then 
		    o.Anchor:SetScript("OnEnter",function(self) self.Bar:MouseOver() end)
			o.Anchor:SetScript("OnLeave",function(self) self.Bar:MouseOut() end) 
			if o.MouseHide then
				o:HideBars()
			end
		end 


			o.Label = o.Anchor:CreateFontString(o.Name.."Label","OVERLAY", "GameFontNormal")
			o.Label:SetText(o.Name)
			o.Anchor.Bar = o
			o.Anchor:EnableMouse(true)
			o.Anchor:RegisterForDrag("LeftButton")
			o.Anchor:SetMovable(true)
			o.Anchor:SetScript("OnDragStart", function(self)
				self:StartMoving()
			end)
			o.Anchor:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
			end)
		else
			o:CreateTextures()
		end
	end 
	
	if o.Colours then
		local count = 1
		for i,v in pairs(o.Colours) do
			o.Options.args.colours.args[i] = {
				order = count,
				name = i,
				desc = "Colour of the "..i.." bar",
				type = "color",
				hasAlpha = true,
				arg = i
			}
			count = count + 1
		end
	end
	event:Embed(o)
	for _,v in ipairs(o.Events) do
		o:RegisterEvent(v, "ConstructBar")
	end
	self.__index = self
	return o
end

function BaseBar:Width(Size)
	if self.Rotate == 0 or self.Rotate == 180 then
		if not Size then
			return self.Anchor:GetWidth()
		end
		self.Anchor:SetWidth(Size)
		if self.SparkBase then
			self.SparkBase:SetWidth(Size)
			self.SparkOverlay:SetWidth(Size)
		end 
	else
		if not Size then 
			return self.Anchor:GetHeight()
		end
		self.Anchor:SetHeight(Size)
		if self.SparkBase then
			self.SparkBase:SetHeight(Size)
			self.SparkOverlay:SetHeight(Size)
		end
	end
end

function BaseBar:Height(Size)
	if self.Rotate == 0 or self.Rotate == 180 then
		if not Size then
			return self.Anchor:GetHeight()
		end
		self.Anchor:SetHeight(Size)
		if self.SparkBase then
			self.SparkBase:SetHeight(Size * 10)
			self.SparkOverlay:SetHeight(Size * 10)
		end
	else
		if not Size then
			return self.Anchor:GetWidth()
		end
		self.Anchor:SetWidth(Size)
		if self.SparkBase then
			self.SparkBase:SetWidth(Size * 10)
			self.SparkOverlay:SetWidth(Size * 10)
		end
	end
end

function BaseBar:SetStrata()
	self.Anchor:SetFrameStrata(Strata[self.Strata])
end

function BaseBar:RotateBar(deg, texture)

	if not texture and self.SparkBase then
		self.SparkBase:SetTexture(self.Spark1File)
		self:RotateBar(deg, self.SparkBase)
		self.SparkBase:SetTexture(self.SparkOverlay)
		self:RotateBar(deg, self.SparkOverlay)
	end
	
	if not texture then 
		texture = self.Texture 
		self.Texture:SetTexture(self.TextureFile)
	end 
	local coords = angles[deg]
	texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4], coords[5], coords[6], coords[7], coords[8] )
end

function BaseBar:CreateTextures()
	local tex = self.Anchor:CreateTexture(self.Name .. "Texture", "ARTWORK")
	tex:SetTexture(self.TextureFile)
	tex:ClearAllPoints()
	tex:SetAllPoints(self.Anchor)
	tex:Show()
	self.Texture = tex
	if self.HasSpark then -- if we have a type, it'll have a spark
		local sparkBase = self.Anchor:CreateTexture(self.Name .. "Spark", "OVERLAY")
		sparkBase:SetTexture(self.Spark1File)
		sparkBase:SetBlendMode("ADD")
		sparkBase:SetParent(self.Anchor)
		sparkBase:SetAlpha(self.Spark)
		self.SparkBase = sparkBase

		local sparkOverlay = self.Anchor:CreateTexture(self.Name .. "Spark2", "OVERLAY")
		sparkOverlay:SetTexture(self.Spark2File)
		sparkOverlay:SetBlendMode("ADD")
		sparkOverlay:SetParent(self.Anchor)
		sparkOverlay:SetAlpha(self.Spark)
		self.SparkOverlay = sparkOverlay

	end
	self.Anchor:ClearAllPoints()
	return self.Anchor
end

function BaseBar:SetColour(index)
	local Setting = self.Colours[self.BarOrder[index]]
	if Setting then
		self.Texture:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
		if self.SparkBase then
			self.SparkBase:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, self.Spark)
			self.SparkOverlay:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, self.Spark)
		end
	end
end

local function GetXY(Width, Rotate)
	if Rotate == 0 then
		return 0.08 * Width , 0
	elseif Rotate == 90 then
		return 0, -(0.08 * Width)
	elseif Rotate == 180 then
		return -(0.08 * Width), 0
	elseif Rotate == 270 then
		return 0, 0.08 * Width
	end
end

local Connections = {	["bottom"] = {"TOPLEFT", "BOTTOMLEFT"},
						["top"] = { "BOTTOMLEFT", "TOPLEFT"},
						["left"] = { "TOPRIGHT", "TOPLEFT"},
						["right"] = { "TOPLEFT", "TOPRIGHT"},
						[0] = { "LEFT", "RIGHT" },
						[90] = { "TOP", "BOTTOM" },
						[180] = { "RIGHT", "LEFT"},
						[270] = { "BOTTOM", "TOP"}
					}

function BaseBar:ConstructBar()
	local Attached = nil

	if not self.Sections then return end
	
	local FrameAnchorFrom, FrameAnchorTo
	local BarAnchorFrom, BarAnchorTo, x, y
	
	FrameAnchorFrom = Connections[self.Attached][1]
	FrameAnchorTo = Connections[self.Attached][2]
	BarAnchorFrom = Connections[self.Rotate][1]
	BarAnchorTo = Connections[self.Rotate][2]

	-- Adjust the width of all the sections according to bar type and values
	self:Update()

	-- Reattach to parent anchor correctly
	self.Anchor:ClearAllPoints()
	Attached = self.Attach and getglobal(self.Attach) or nil
	self.Anchor:SetParent(Attached or UIParent)
	if Attached then
		self.Anchor:SetPoint(FrameAnchorFrom, Attached, FrameAnchorTo, tonumber(self.Xoffset) or 0, tonumber(self.Yoffset) or 0)
	end
	
	Attached = self.Anchor

	-- Attach each section according to orientation
	for i, Bar in ipairs(self.Sections) do
		
		Bar:SetColour(i)
		Bar:RotateBar(self.Rotate)
		Bar.Anchor:ClearAllPoints()
		if Attached == self.Anchor then -- If we're attaching the first section
			Bar.Anchor:SetPoint(BarAnchorFrom, Attached, BarAnchorFrom) -- attach to the base background bar
		else
			Bar.Anchor:SetPoint(BarAnchorFrom, Attached, BarAnchorTo) -- attach to the end of the previous section
		end
		Bar.Anchor:SetParent(self.Anchor)
		Bar.Anchor:Show()
		
		if Bar.SparkBase then -- attach the spark to the end of the initial bar
			local x,y = GetXY(Bar:Width(), self.Rotate)	
			Bar.SparkBase:ClearAllPoints()
			Bar.SparkOverlay:ClearAllPoints()
			Bar.SparkBase:SetPoint(BarAnchorTo, Bar.Anchor, BarAnchorTo, x, y)
			Bar.SparkOverlay:SetPoint(BarAnchorTo, Bar.Anchor, BarAnchorTo, x, y)
		end
		Attached = Bar.Anchor
	end
end
--[[ XP Bar Functions ]]--

local XPBar = BaseBar:new{
				BarType = "XP",
				Colours = {
					XPBar = { Red = 0, Green = 0.4, Blue = 0.9, Alpha = 1 },
					NoXPBar = { Red = 0.3, Green = 0.3, Blue = 0.3, Alpha = 1 },
					RestBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
				},
				Events = {"PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION" },
				Rotate = 0,
				BarOrder = { [1] = "XPBar", [2] = "RestBar", [3] = "NoXPBar" },
				BarWidth = 900,
			}

function XPBar:new(o)
	-- Bar
	o = BaseBar:new(o)
	setmetatable(o, self)
	local x = BaseBar:new{Name = "XP"..o.Name, HasSpark = true, Rotate = o.Rotate}
	setmetatable(x, self)
	-- RestBar
	local r = BaseBar:new{Name = "Rest"..o.Name, Rotate = o.Rotate}
	setmetatable(r, self)
	-- NoXP
	local n = BaseBar:new{Name = "NoXP"..o.Name, Rotate = o.Rotate}
	setmetatable(n, self)
	
	if not o.Colours then o.Colours = {} end

	for i,v in pairs(self.Colours) do
		if not o.Colours[i] then
			o.Colours[i] = cloneTable(v)
		end
	end

	self.__index = self


	
	x.Colours, r.Colours, n.Colours = o.Colours, o.Colours, o.Colours

	o.Sections = {[1] = x, [2] = r, [3] = n}
	return o
end

function XPBar:Update()
	local BarWidth
	local Attached = self.Attach and getglobal(self.Attach) or nil
	if not Attached then
		BarWidth = self.BarWidth
	else
		if self.Rotation == 0 or self.Rotation == 180 then
			BarWidth = Attached:GetWidth()
		else
			BarWidth = Attached:GetHeight()
		end
	end
	local Rest, CurrXP, MaxXP = GetXPExhaustion() or 0, UnitXP("player") or 0, UnitXPMax("player") or 0
	local Percent = (BarWidth/MaxXP)

	self.Sections[1]:Height(self.Thickness)
	self.Sections[2]:Height(self.Thickness)
	self.Sections[3]:Height(self.Thickness)
	
	self:Width(BarWidth)
	self:Height(self.Thickness)
	self.Label:Hide()
	if self.ShowLabel then
		self.Label:SetParent(self.Sections[3].Anchor)
		self.Label:SetTextHeight(self.Thickness)
		self.Label:SetText(self.Name)
		self.Label:ClearAllPoints()
		self.Label:SetPoint("CENTER", self.Anchor, "CENTER")
		self.Label:Show()
	end

	self.Sections[1]:Width(Percent * CurrXP)
	if Rest > (MaxXP - CurrXP) then
		self.Sections[2]:Width(Percent * (MaxXP - CurrXP))
		self.Sections[3]:Width(0)
	else
		self.Sections[2]:Width(Percent * Rest)
		self.Sections[3]:Width(Percent * (MaxXP-CurrXP))
	end

	self.Anchor:SetFrameLevel(self.Sections[3].Anchor:GetFrameLevel() + 1)
end

--[[ RepBar Functions ]] --

local RepBar = BaseBar:new{
				BarType = "Rep",
				Colours = {
					RepBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
					NoRepBar = { Red = 0, Green = 0.3, Blue = 1, Alpha = 1 },
				},
				Events = {"UPDATE_FACTION"},
				BarOrder = { [1] = "RepBar", [2] = "NoRepBar" },
				Faction = 6,

				Rotate = 0,
				BarWidth = 300,
			}



function RepBar:new(o)
	o = BaseBar:new(o)
	setmetatable(o, self)
	local r = BaseBar:new{Name = "Rep"..o.Name, HasSpark = true, Rotate = o.Rotate, Faction = o.Faction}
	setmetatable(r, self)
	local n = BaseBar:new{Name = "NoRep"..o.Name, Rotate = o.Rotate, Faction = o.Faction}
	setmetatable(n, self)


	self.__index = self
	o.Sections = {[1] = r, [2] = n}
	return o
end

function RepBar:Update()
	local BarWidth
	local Attached = getglobal(self.Attached) or self.Attached
	if not Attached or Attached:GetName() == UIParent then
		BarWidth = self.BarWidth
	else
		BarWidth = Attached:GetWidth()
	end
	
	self.Sections[1]:Height(self.Thickness)
	self.Sections[2]:Height(self.Thickness)
	self:Width(BarWidth)
	self:Height(self.Thickness)
	self.Label:Hide()

	if self.ShowLabel then	
		self.Label:SetTextHeight(self.Thickness)
		self.Label:SetParent(self.Sections[2].Anchor)
		self.Label:ClearAllPoints()
		self.Label:SetPoint("CENTER", self.Anchor, "CENTER")
		self.Label:Show()
	end

	local name, description, standingID, bottomValue, topValue, earnedValue = GetFactionInfo(self.Faction) 
	local Percent = BarWidth/(topValue - bottomValue)
	self.Sections[1]:Width(Percent * (earnedValue - bottomValue))
	self.Sections[2]:Width(Percent * (topValue - earnedValue))
	self.Anchor:SetFrameLevel(self.Sections[2].Anchor:GetFrameLevel() + 2)

end

--[[ Honour Bar Functions ]]--

local HonourBar = BaseBar:new{
				BarType = "Honour",
				Colours = {
					HonourBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
					TargetBar = { Red = 0.2, Green = 1, Blue = 1, Alpha = 1 },
					NoHonourBar = { Red = 0, Green = 0.3, Blue = 1, Alpha = 1 },
				},
				Events = {"HONOR_CURRENCY_UPDATE"},
				BarOrder = { [1] = "HonourBar", [2] = "TargetBar", [3] = "NoHonourBar" },
				Rotate = 0,
				Target = 8000,
				BarWidth = 300,
			}
			
function HonourBar:new(o)
	o = BaseBar:new(o)
	setmetatable(o, self)
	local r = BaseBar:new{Name = "Honour"..o.Name, HasSpark = true, Rotate = o.Rotate}
	setmetatable(r, self)
	local t = BaseBar:new{Name = "Target"..o.Name, HasSpark = true, Rotate = o.Rotate }
	setmetatable(t, self)
	local n = BaseBar:new{Name = "NoHonour"..o.Name, Rotate = o.Rotate}
	setmetatable(n, self)

	o.Options.args.target = {
		type = "input",
		name = "Target Honour",
		desc = "Point at which to switch colours from the Honour Bar to the Target Bar, ie, when you've reached your target",
		arg = "Target"
	}
	o.Options.args.maxlimit = {
		type = "toggle",
		name = "Max Limit",
		desc = "Show the max limit of the honour cap at 75k, otherwise, the bar limit will be the Target value"
		arg = "MaxLimit"
	}

	self.__index = self
	o.Sections = {[1] = r, [2] = t, [3] = n}
	return o
end

function HonourBar:Update()
	local BarWidth
	local Attached = getglobal(self.Attached) or self.Attached
	if not Attached or Attached:GetName() == UIParent then
		BarWidth = self.BarWidth
	else
		BarWidth = Attached:GetWidth()
	end
	
	self.Sections[1]:Height(self.Thickness)
	self.Sections[2]:Height(self.Thickness)
	self.Sections[3]:Height(self.Thickness)
	self:Width(BarWidth)
	self:Height(self.Thickness)
	self.Label:Hide()

	if self.ShowLabel then	
		self.Label:SetTextHeight(self.Thickness)
		self.Label:SetParent(self.Sections[3].Anchor)
		self.Label:ClearAllPoints()
		self.Label:SetPoint("CENTER", self.Anchor, "CENTER")
		self.Label:Show()
	end
	local max, current = self.Target, GetHonorCurrency()
	if self.MaxLimit then
		max = 75000
	end

	local Percent = BarWidth/max
	self.Sections[1]:Width(Percent * current)
	self.Sections[2]:Width(Percent * current)
	self.Sections[3]:Width(Percent * (max - current))
	self.Anchor:SetFrameLevel(self.Sections[3].Anchor:GetFrameLevel() + 2)

	if current >= self.Target then
		self.Sections[1]:Width(0)
	else
		self.Sections[2]:Width(0)
	end
end

--[[ Generic Bar Functions ]] -- 

XparkyBar = {}

local MakeBar = { ["XP"] = XPBar, ["Rep"] = RepBar, ["Honour"] = HonourBar }


function XparkyBar:New(Bar)
	if self.Bars and self.Bars[Bar.Name] then 
		self.Bars[Bar.Name]:ConstructBar() 
		return 
	end
	
	Bar = MakeBar[Bar.BarType]:new(cloneTable(Bar))
	Bar:ConstructBar()
	Bar.Anchor:ClearAllPoints()
	Bar.Anchor:SetPoint("CENTER", UIParent)

	if not self.Bars then self.Bars = {} end
	
	self.Bars[Bar.Name] = Bar
	return Bar
end



