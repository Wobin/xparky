local defaultBar = {}

local reg = LibStub("AceConfigRegistry-3.0")
local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }
local angles = {[180] = { 1,0,1,1,0,0,0,1}, [0] = {0,1,0,0,1,1,1,0}, [270] = {1,1,0,1,1,0,0,0}, [90] = {0,0,1,0,0,1,1,1}}

XparkyBar = {}

local Bar = XparkyBar
--[[ Base Bar functions ]] --
local function cloneTable(t)
	local clone = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			clone[i] = cloneTable(t)
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
        	mouser.bar:SetConnectedFrame(name, side)
        	mouser.bar:ConstructBar()
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
	Xparky:Print("Attach "..self.Name.." to "..frame:GetName().." on the "..side.." side")
	self.Attach = frame:GetName()
	self.Attached = side
	mouser.bar = nil
	mouser.side = nil
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
							reg:NotifyChange("Xparky")
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
							min = 0, max = 1, step = 0.5,
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
							hidden = function(info) return info.handler.Attach and info.handler.Attach ~= "" end,
						},
						yoffset = {
							type = "input",
							name = "Y offset",
							desc = "Offset from the frame in the Y axis",
							arg = "Yoffset",
							order = 9,
							hidden = function(info) return info.handler.Attach and info.handler.Attach ~= "" end,
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
									local dbt = Xparky.db.profile[info.handler.Name].Colours[info.arg]
									t.Red, t.Green, t.Blue, t.Alpha = r, g, b, a
									dbt.Red, dbt.Green, dbt.Blue, dbt.Alpha = r, g, b, a
									info.handler:ConstructBar()
									end,
							args = {}
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
			self.SparkBase:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
			self.SparkOverlay:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
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

function BaseBar:ConstructBar()
	local Attached = self.Attached or nil

	if not self.Sections then return end
	
	local FrameAnchorFrom, FrameAnchorTo
	local BarAnchorFrom, BarAnchorTo, x, y
	
	if (self.Attach == "bottom") then
		FrameAnchorFrom = "TOPLEFT"
		FrameAnchorTo = "BOTTOMLEFT"
	end

	if (self.Attach == "top" ) then
		FrameAnchorFrom = "BOTTOMLEFT"
		FrameAnchorTo = "TOPLEFT"
	end
	if (self.Attach == "left" ) then
		FrameAnchorFrom = "TOPRIGHT"
		FrameAnchorTo = "TOPLEFT"
	end

	if (self.Attach == "right" ) then
		FrameAnchorFrom = "TOPLEFT"
		FrameAnchorTo = "TOPRIGHT"
	end
	
	if self.Rotate == 0  then
		BarAnchorFrom = "LEFT"
		BarAnchorTo = "RIGHT"
	end

	if self.Rotate == 90  then
		BarAnchorFrom = "TOP"
		BarAnchorTo = "BOTTOM"
	end

	if self.Rotate == 180  then
		BarAnchorFrom = "RIGHT"
		BarAnchorTo = "LEFT"
	end

	if self.Rotate == 270  then
		BarAnchorFrom = "BOTTOM"
		BarAnchorTo = "TOP"
	end
	
	self:Update()

	for i, Bar in ipairs(self.Sections) do
		Bar:SetColour(i)
		
		Bar:RotateBar(self.Rotate)
		if not Attached then
			Bar.Anchor:ClearAllPoints()
			Bar.Anchor:SetPoint(BarAnchorFrom, self.Anchor, BarAnchorFrom)
		else
			Bar.Anchor:ClearAllPoints()
			Bar.Anchor:SetPoint(BarAnchorFrom, Attached, BarAnchorTo)
		end
		Bar.Anchor:Show()
		Bar.Anchor:SetParent(self.Anchor)
		
		if Bar.SparkBase then
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
				ConnectedFrame = "LegoXparky",
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
	if self.Colours then
		local count = 1
		for i,v in pairs(self.Colours) do
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

	self.__index = self

	o.Sections = {[1] = x, [2] = r, [3] = n}
	return o
end

function XPBar:Update()
	local BarWidth
	local Attached = getglobal(self.Attached) or self.Attached
	if not Attached or Attached:GetName() == UIParent then
		BarWidth = self.BarWidth
	else
		BarWidth = Attached:GetWidth()
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
				ConnectedFrame = "XparkyXPBar",
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
	if o.Colours or self.Colours then

		local count = 1
		for i,v in pairs(o.Colours or self.Colours) do
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

--[[ Generic Bar Functions ]] -- 

XparkyBar = {}



function XparkyBar:New(Bar)
	if self.Bars and self.Bars[Bar.Name] then 
		self.Bars[Bar.Name]:ConstructBar() 
		return 
	end
	
	if Bar.BarType == "XP" then
		Bar = XPBar:new(cloneTable(Bar))
	else
		Bar = RepBar:new(cloneTable(Bar))
	end
	Bar:ConstructBar()
	Bar.Anchor:ClearAllPoints()
	Bar.Anchor:SetPoint("CENTER", UIParent)

	if not self.Bars then self.Bars = {} end
	
	self.Bars[Bar.Name] = Bar
	return Bar
end



