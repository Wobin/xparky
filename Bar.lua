local defaultBar = {}

local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }

XparkyBar = {}

local Bar = XparkyBar

--[[ Base Bar functions ]] --

BaseBar = {
				Attach = "bottom",
				Direction = "forward",
				Thickness = 5,
				Spark = 1,
				TextureFile = "Interface\\AddOns\\Xparky\\Textures\\texture.tga",
				Spark1File =  "Interface\\AddOns\\Xparky\\Textures\\glow.tga",
				Spark2File =  "Interface\\AddOns\\Xparky\\Textures\\glow2.tga",
}

function BaseBar:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	if o.Name then
		o.Anchor = CreateFrame("Frame", o.Name .. "Xparky", UIParent)
		o.Anchor:SetWidth(1)
		o.Anchor:SetHeight(1)
		o.Anchor:Show()
		if o.Type then
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
	return o
end

function BaseBar:Width(Size)
	if self.Attach == "top" or self.Attach == "bottom" then
		if not Size then
			return self.Anchor:GetWidth()
		end
		self.Anchor:SetWidth(Size)
		if self.SparkBase then
			self.SparkBase:SetWidth(128)
			self.SparkOverlay:SetWidth(128)
		end
	else
		if not Size then 
			return self.Anchor:GetHeight()
		end
		self.Anchor:SetHeight(Size)
		if self.SparkBase then
			self.SparkBase:SetHeight(128)
			self.SparkOverlay:SetHeight(128)
		end
	end
end

function BaseBar:Height(Size)
	if self.Attach == "top" or self.Attach == "bottom" then
		if not Size then
			return self.Anchor:GetHeight()
		end
		self.Anchor:SetHeight(Size)
		if self.SparkBase then
			self.SparkBase:SetHeight(Size * 5)
			self.SparkOverlay:SetHeight(Size * 5)
		end
	else
		if not Size then
			return self.Anchor:GetWidth()
		end
		self.Anchor:SetWidth(Size)
		if self.SparkBase then
			self.SparkBase:SetWidth(Size * 5)
			self.SparkOverlay:SetWidth(Size * 5)
		end
	end
end

function BaseBar:SetStrata()
	self.Anchor:SetFrameStrata(Strata[self.Strata])
end

function BaseBar:Rotate(deg)
	local angle = math.rad(deg)
	local cos, sin = math.cos(angle), math.sin(angle)

	self.Texture:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
	if self.SparkBase then
		self.SparkBase:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
		self.SparkOverlay:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0)
	end
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
	self:Height(self.Thickness)
	self:Width(100)
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

--[[ XP Bar Functions ]]--

XPBar = BaseBar:new{
				Type = "XP",
				Colours = {
					XPBar = { Red = 0, Green = 0.4, Blue = 0.9, Alpha = 1 },
					NoXPBar = { Red = 0.3, Green = 0.3, Blue = 0.3, Alpha = 1 },
					RestBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
				},
				ConnectedFrame = "LegoXparky",
				BarOrder = { [1] = "XPBar", [2] = "RestBar", [3] = "NoXPBar" },
				BarWidth = 900,
			}

function XPBar:new(o)
	-- Bar
	o = BaseBar:new(o)
	setmetatable(o, self)
	local x = BaseBar:new{Name = "XP"..o.Name, HasSpark = true}
	setmetatable(x, self)
	-- RestBar
	local r = BaseBar:new{Name = "Rest"..o.Name}
	setmetatable(r, self)
	-- NoXP
	local n = BaseBar:new{Name = "NoXP"..o.Name}
	setmetatable(n, self)
	
	self.__index = self

	o:Height(self.Thickness)
	o:Width(300)
	
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
	local Rest, CurrXP, MaxXP = GetXPExhaustion(), UnitXP("player"), UnitXPMax("player")
	local Percent = (BarWidth/MaxXP)

	self.Sections[1]:Width(Percent * CurrXP)
	self.Sections[3]:Width(Percent * MaxXP-CurrXP)
	if Rest > (MaxXP - CurrXP) then
		self.Sections[2]:Width(Percent * (Rest - MaxXP - CurrXP))
	else
		self.Sections[2]:Width(Percent * Rest)
	end

end

--[[ RepBar Functions ]] --

RepBar = BaseBar:new{
				Type = "Rep",
				Colours = {
					RepBar = { Red = 1, Green = 0.2, Blue = 1, Alpha = 1 },
					NoRepBar = { Red = 0, Green = 0.3, Blue = 1, Alpha = 1 },
				},
				ConnectedFrame = "XparkyXPBar",
				BarOrder = { [1] = "RepBar", [2] = "NoRepBar" },
				Faction = 2,
				BarWidth = 300,
			}



function RepBar:new(o)
	o = BaseBar:new(o)
	setmetatable(o, self)
	local r = BaseBar:new{Name = "Rep"..o.Name, HasSpark = true}
	setmetatable(r, self)
	local n = BaseBar:new{Name = "NoRep"..o.Name}
	setmetatable(n, self)

	self.__index = self
	o.Sections = {[1] = r, [2] = n}
	
	o:Height(self.Thickness)
	o:Width(200)
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
	local name, description, standingID, bottomValue, topValue, earnedValue = GetFactionInfo(self.Faction) 
	local Percent = BarWidth/(topValue - bottomValue)

	self.Sections[1]:Width(Percent * (earnedValue - bottomValue))
	self.Sections[2]:Width(Percent * (topValue - earnedValue))

end

--[[ Generic Bar Functions ]] -- 

XparkyBar = {}

function BaseBar:ConstructBar()
	local Attached = nil

	if not self.Sections then return end
	
	if not MyBar then MyBar = Bars end
	
	local FrameAnchorFrom, FrameAnchorTo
	local BarAnchorFrom, BarAnchorTo, x, y
	
	local tlx, tly, trx, try, blx, bly, brx, bry,stlx, stly, strx, stry, sblx, sbly, sbrx, sbry
	
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
		x = 10
		y = 0
		BarAnchorFrom = "LEFT"
		BarAnchorTo = "RIGHT"
	end

	if self.Rotate == 90  then
		x = 0
		y = 10
		BarAnchorFrom = "TOP"
		BarAnchorTo = "BOTTOM"
	end

	if self.Rotate == 180  then
		x = 0
		y = -10
		BarAnchorFrom = "RIGHT"
		BarAnchorTo = "LEFT"
	end

	if self.Rotate == 270  then
		x = -10
		y = 0
		BarAnchorFrom = "BOTTOM"
		BarAnchorTo = "TOP"
	end

	for i, Bar in ipairs(self.Sections) do
		Bar:SetColour(i)
		
		Bar.Anchor:Rotate
		if not Attached then
			Bar.Anchor:ClearAllPoints()
			Bar.Anchor:SetPoint(BarAnchorFrom, self.Anchor, BarAnchorTo)
		else
			Bar.Anchor:ClearAllPoints()
			Bar.Anchor:SetPoint(BarAnchorFrom, Attached, BarAnchorTo)
		end
		Bar.Anchor:Show()
		Bar.Anchor:SetParent(self.Anchor)
		
		if Bar.SparkBase then
			Bar.SparkBase:ClearAllPoints()
			Bar.SparkOverlay:ClearAllPoints()
			Bar.SparkBase:SetPoint(BarAnchorTo, Bar.Anchor, BarAnchorTo, x, y)
			Bar.SparkOverlay:SetPoint(BarAnchorTo, Bar.Anchor, BarAnchorTo, x, y)
		end
		Attached = Bar.Anchor
	end
end

function XparkyBar:New(Bar)
	if Bar.Type == "XP" then
		Bar = XPBar:new(Bar)
	else
		Bar = RepBar:new(Bar)
	end
	Bar:ConstructBar()
	Bar:Update()
	Bar.Anchor:ClearAllPoints()
	Bar.Anchor:SetPoint("CENTER", UIParent)
	return Bar
end



