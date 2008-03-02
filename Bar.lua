local defaultBar = {}

local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }

XparkyBar = {}

local Bar = XparkyBar

--[[ Base Bar functions ]] --

BaseBar = {
				Attach = "bottom",
				Direction = "forward",
				Thickness = 80,
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
		o:CreateTextures()
	end 
	return o
end

function BaseBar:Width(Size)
	if self.Attach == "top" or self.Attach == "bottom" then
		if not Size then
			return self.Anchor:GetWidth()
		end
		self.Anchor:SetWidth(Size)
	else
		if not Size then 
			return self.Anchor:GetHeight()
		end
		self.Anchor:SetHeight(Size)
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

function BaseBar:CreateTextures()
	local tex = self.Anchor:CreateTexture(self.Name .. "Texture", "OVERLAY")
	tex:SetTexture(self.TextureFile)
	tex:ClearAllPoints()
	tex:SetAllPoints(self.Anchor)
	tex:Show()
	self.Texture = tex
	if self.Type then -- if we have a type, it'll have a spark
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
	self:Height(self.Thickness)
	self.Anchor:ClearAllPoints()
	self:Width(100)
	return self.Anchor
end

function BaseBar:SetColour(index)
	local Setting = self.Colours[self.BarOrder[index]]
	if Setting then
		self.Texture:SetVertexColor(Setting.Red, Setting.Green, Setting.Blue, Setting.Alpha)
		if self.SparkBase then
			Xparky:Print("Recolouring Spark")
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
			}

function XPBar:new(o)
	-- XPBar
	o = BaseBar:new(o)
	setmetatable(o, self)
	-- RestBar
	local r = BaseBar:new{Name = "Rest"..o.Name}
	setmetatable(r, self)
	-- NoXP
	local n = BaseBar:new{Name = "NoXP"..o.Name}
	setmetatable(n, self)
	
	self.__index = self

	o.Sections = {[1] = o, [2] = r, [3] = n}
	return o
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
			}



function RepBar:new(o)
	o = BaseBar:new(o)
	setmetatable(o, self)
	local n = BaseBar:new{Name = "NoRep"..o.Name}
	setmetatable(n, self)

	self.__index = self
	o.Sections = {[1] = o, [2] = n}
	return o
end

--[[ Generic Bar Functions ]] -- 

XparkyBar = {}

function XparkyBar:ConstructBar(BarInfo)
	local Attached = BarInfo.Anchor
	for i, Bar in ipairs(BarInfo.Sections) do
		if not MyBar then MyBar = Bar end
		Bar:SetColour(i)
		if Bar.Anchor ~= Attached then
			Bar.Anchor:ClearAllPoints()
			Bar.Anchor:SetPoint("LEFT", Attached, "RIGHT")
			Bar.Anchor:Show()
		end
		if Bar.SparkBase then
			Xparky:Print("Repointing spark")
			Bar.SparkBase:ClearAllPoints()
			Bar.SparkOverlay:ClearAllPoints()
			Bar.SparkBase:SetPoint("RIGHT", Bar.Anchor, "RIGHT", 10, 0)
			Bar.SparkOverlay:SetPoint("RIGHT", Bar.Anchor, "RIGHT", 10, 0)
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
	self:ConstructBar(Bar)
	Bar.Anchor:ClearAllPoints()
	Bar.Anchor:SetPoint("CENTER", UIParent)
	return Bar
end



