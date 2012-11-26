-- Unitframes
local Roflui = ...

local config = Roflui.config
function Roflui.SetupUnitframes()
	Roflui.uf = {}
	Roflui.PlayerFrame()
	Roflui.TargetFrame()
end

UF = {}
UF.__index = UF

function UF:UnitChanged()
	unit = Inspect.Unit.Detail(self.unit)
	if unit ~= nil then
		if not self.frame:GetVisible()then
			self.frame:SetVisible(true)
		end
		self:UpdateHealth()
		self:UpdateName()
	else
		self.frame:SetVisible(false)
	end
end

function UF:UpdateHealth()
	unit = Inspect.Unit.Detail(self.unit)
	if unit ~= nil then
		p = unit.health / unit.healthMax
		self.bars["healthbg"]:SetWidth(math.floor((1-p) * self.bars["health"]:GetWidth()))
		
		local text = tostring(unit.health)
		
		if unit.health > 1000000 then
			div = unit.health / 100000
			
			text = string.format("%.1fm", (unit.health / 100000))
		elseif unit.health > 10000 then
			text = string.format("%.1fk", (unit.health / 1000))
		end

		if unit.health ~= unit.healthMax then
			text = text .. " - " .. string.format("%.1f%%", (p * 100))
		end
		
		self.texts["health"]:SetText(text)
	end
end

function UF:GetUnitColor()
	unit = Inspect.Unit.Detail(self.unit)
	r = 1
	g = 1
	b = 1
	if unit ~= nil then
		if unit.calling ~= nil then
			colors = Roflui.config.colors[unit.calling]
			r = colors.r
			g = colors.g
			b = colors.b
		end
	end

	return r, g, b
end

function UF:UpdateName()
	unit = Inspect.Unit.Detail(self.unit)
	if unit ~= nil then
		if self.texts["name"] ~= nil then
			self.texts["name"]:SetText(unit.name)
			r,g,b = self:GetUnitColor()
			self.texts["name"]:SetFontColor(r,g,b,1)
		end
	end
end

function UF:UpdatePower()
	
end

function UF:SetPowerColor()
	
end

function Roflui.PlayerFrame()
	dp("Creating player")
	base = Roflui.CreateFrameBase("player")
	base.width = config.player.width
	base.height = config.player.height
	base.x = config.player.x
	base.y = config.player.y
	base.anchorAt = config.player.anchorAt
	base.anchorTo = config.player.anchorTo
	base.fontSize = config.player.fontSize
	
	base.frame = Roflui.CreateFrame(base)

	base.bars["health"], base.bars["healthbg"] = Roflui.CreateHealthBar(base)
	base.bars["power"] = Roflui.CreatePowerBar(base)
	base.texts["health"] = Roflui.CreateHealthText(base)
	base.texts["power"], base.texts["powershadow"] = Roflui.CreatePowerText(base)
	base.texts["name"] = Roflui.CreateNameText(base)
	
	Roflui.uf["player"] = base
end

function Roflui.TargetFrame()
	dp("Creating target")
	base = Roflui.CreateFrameBase("player.target")
	base.width = config.target.width
	base.height = config.target.height
	base.x = config.target.x
	base.y = config.target.y
	base.anchorAt = config.target.anchorAt
	base.anchorTo = config.target.anchorTo
	base.fontSize = config.player.fontSize
	
	base.frame = Roflui.CreateFrame(base)

	base.bars["health"], base.bars["healthbg"] = Roflui.CreateHealthBar(base)
	base.bars["power"] = Roflui.CreatePowerBar(base)
	base.texts["health"] = Roflui.CreateHealthText(base)
	base.texts["power"], base.texts["powershadow"] = Roflui.CreatePowerText(base)
	base.texts["name"] = Roflui.CreateNameText(base)
	
	base.frame:SetVisible(false)
	
	Roflui.uf["player.target"] = base
end

function Roflui.CreateHealthBar(base)

	local fbg = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg:SetPoint("TOPLEFT", base.frame, "TOPLEFT", 1, 1)
	fbg:SetWidth(base.width - 2)
	fbg:SetHeight(math.floor(base.height * .8)-3)
	fbg:SetBackgroundColor(.4, .4, .4, 1)
	fbg:SetLayer(8)
	
	local fbg2 = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg2:SetPoint("TOPLEFT", fbg, "TOPLEFT", 1, 1)
	fbg2:SetWidth(fbg:GetWidth() - 2)
	fbg2:SetHeight(fbg:GetHeight() - 2)
	fbg2:SetBackgroundColor(0, 0, 0, 1)
	fbg2:SetLayer(9)

	local f = UI.CreateFrame("Frame", base.unit, base.frame)
	f:SetPoint("TOPLEFT", fbg2, "TOPLEFT", 1, 1)
	f:SetWidth(fbg2:GetWidth() - 2)
	f:SetHeight(fbg2:GetHeight() - 2)
	f:SetBackgroundColor(.2, .2, .2, 1)
	f:SetLayer(10)
	
	local fb = UI.CreateFrame("Frame", base.unit, f)
	fb:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	fb:SetWidth(f:GetWidth() / 2)
	fb:SetHeight(f:GetHeight())
	fb:SetBackgroundColor(0, 0, 0, .7)
	f:SetLayer(11)
	
	return f, fb
end

function Roflui.CreatePowerBar(base)

	local fbg = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg:SetPoint("BOTTOMLEFT", base.frame, "BOTTOMLEFT", 1, -1)
	fbg:SetWidth(base.width - 2)
	fbg:SetHeight(base.height - (math.floor(base.height * .8)))
	fbg:SetBackgroundColor(.4, .4, .4, 1)
	fbg:SetLayer(8)
	
	local fbg2 = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg2:SetPoint("BOTTOMLEFT", fbg, "BOTTOMLEFT", 1, -1)
	fbg2:SetWidth(fbg:GetWidth() -  2)
	fbg2:SetHeight(fbg:GetHeight() - 2)
	fbg2:SetBackgroundColor(0, 0, 0, 1)
	fbg2:SetLayer(9)
	
	local f = UI.CreateFrame("Frame", base.unit, base.frame)
	f:SetPoint("BOTTOMLEFT", fbg2, "BOTTOMLEFT", 1, -1)
	f:SetWidth(fbg2:GetWidth() - 2)
	f:SetHeight(fbg2:GetHeight() - 2)
	f:SetBackgroundColor(.6, .6, .6, 1)
	f:SetLayer(10)
	
	return f
end

function Roflui.CreateHealthText(base)

	local text = Text.Create(base.frame)
	text:SetPoint("CENTERLEFT", base.bars["health"], "CENTERLEFT", 2, 1)
	text:SetFont("Roflui", config.defaultFont)
	text:SetFontSize(base.fontSize)
	text:SetShadowColor(0, 0, 0, 1)
	text:SetFontColor(0, 1, 0, 1)
	text:SetText("Health")
	text:SetLayer(30)

	return text
end

function Roflui.CreatePowerText(base)
	local t = UI.CreateFrame("Text", base.unit, base.frame)
	t:SetPoint("CENTERRIGHT", base.bars["health"], "CENTERRIGHT", 0, 1)
	t:SetFont("Roflui", config.defaultFont)
	t:SetFontSize(base.fontSize)
	t:SetFontColor(0, 0, 0, 1)
	t:SetText("Power")
	t:SetLayer(30)
	
	local tb = UI.CreateFrame("Text", base.unit, base.frame)
	tb:SetPoint("CENTERRIGHT", base.bars["health"], "CENTERRIGHT", -1, 0)
	tb:SetFont("Roflui", config.defaultFont)
	tb:SetFontSize(base.fontSize)
	tb:SetFontColor(.6, .6, .6, 1)
	tb:SetText("Power")
	tb:SetLayer(31)
	
	return t, tb
end

function Roflui.CreateNameText(base)
	local t = Text.Create(base.frame)
	t:SetPoint("CENTER", base.bars["health"], "CENTER", 1, 1)
	t:SetFont("Roflui", config.defaultFont)
	t:SetFontSize(base.fontSize)
	t:SetFontColor(.7, .7, .8, 1)
	t:SetShadowColor(0, 0, 0, 1)
	t:SetText("Names")
	t:SetLayer(30)
	
	return t
end

function Roflui.CreateFrame(base)
	local f = UI.CreateFrame("Frame", base.unit, Roflui.context)
	f:SetPoint(base.anchorAt, UIParent, base.anchorTo, base.x, base.y)
	f:SetBackgroundColor(0, 0, 0, 1)
	f:SetWidth(base.width)
	f:SetHeight(base.height)
	
	return f
end

function Roflui.CreateFrameBase(unit)
	local base = {}
	setmetatable(base, UF)
	
	base.unit = unit
	base.bars = {}
	base.texts = {}
	
	base.unitChangedEventTable = nil
	base.unitChangedEventTable = Library.LibUnitChange.Register(base.unit)
	table.insert(base.unitChangedEventTable, {function() base:UnitChanged() end, "Roflui", base.unit.." changed"})
	
	return base
end