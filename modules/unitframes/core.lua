-- Unitframes
local Roflui = ...

local config = Roflui.config
function Roflui.SetupUnitframes()
	Roflui.uf = {}
	Roflui.PlayerFrame()
	Roflui.TargetFrame()
	Roflui.TargetOfTargetFrame()
end

UF = {}
UF.__index = UF

function UF:UnitChanged()
	unit = Inspect.Unit.Detail(self.unit)
	if unit ~= nil then
		if self.unit == "player" then
			if self.bars["calling"] == nil then
				self:CreateCallingBar()
				self:UpdateCallingBar()
			end
		end
		
		if not self.frame:GetVisible() then
			self.frame:SetVisible(true)
		end
		self:UpdateHealth()
		self:UpdateName()
		self:SetPowerColor()
		self:UpdatePower()
		self:UpdateCast()
		self:UpdateCombat()
		if self.bars["buffs"] ~= nil then
			self.bars["buffs"]:UnitChanged()
		end
		if self.bars["timers"] ~= nil then
			self.bars["timers"]:UnitChanged()
		end
	else
		self.frame:SetVisible(false)
	end
end

function UF:UpdateCombat()
	if self.bars["combat"] == nil then return end
	unit = Inspect.Unit.Detail(self.unit)
	if unit.combat then
		self.bars["combat"]:SetVisible(true)
	else
		self.bars["combat"]:SetVisible(false)
	end
end

function UF:UpdateCallingBar()
	if self.bars["calling"] == nil then
		return
	end
	
	unit = Inspect.Unit.Detail(self.unit)
	
	if unit.calling == "warrior" or unit.calling == "rogue" then
		local _units = {}
		_units["warrior"] = 3
		_units["rogue"] = 5
		
		for i = 1, _units[unit.calling] do
			if unit.combo >= i then
				self.bars["calling"]["power"..i]:SetVisible(true)
			else
				self.bars["calling"]["power"..i]:SetVisible(false)
			end
		end
	elseif unit.calling == "mage" then
		self.bars["calling"]["chargebg"]:SetWidth(math.floor(self.bars["calling"]["charge"]:GetWidth() * (1 - (unit.charge / 100))))
	end
end

function UF:CreateCallingBar()

	calling = Inspect.Unit.Detail(self.unit).calling

	bar = UI.CreateFrame("Frame", self.unit, self.frame)
	bar:SetPoint("CENTER", self.frame, "TOPCENTER", 0, 0)
	bar:SetWidth(200)
	bar:SetHeight(12)
	bar:SetLayer(100)
	
	-- Warrior and rogue, since they use same combo system
	if calling == "warrior" or calling == "rogue" then
		local _pos
		
		if calling == "warrior" then
			_pos = {-50, 0, 50}
		else
			_pos = {-94, -47, 0, 47, 94}
		end
		
		for i = 1,table.getn(_pos) do
			b1 = UI.CreateFrame("Frame", "powerb1"..i, bar)
			b1:SetPoint("CENTER", bar, "CENTER", _pos[i], 0)
			b1:SetWidth(45)
			b1:SetHeight(12)
			b1:SetBackgroundColor(.0, .0, .0, 1)
			
			b2 = UI.CreateFrame("Frame", "powerb2"..i, b1)
			b2:SetPoint("CENTER", b1, "CENTER", 0, 0)
			b2:SetWidth(b1:GetWidth()-2)
			b2:SetHeight(b1:GetHeight()-2)
			b2:SetBackgroundColor(.4, .4, .4, 1)
			
			b3 = UI.CreateFrame("Frame", "powerb3"..i, b2)
			b3:SetPoint("CENTER", b2, "CENTER", 0, 0)
			b3:SetWidth(b2:GetWidth()-2)
			b3:SetHeight(b2:GetHeight()-2)
			b3:SetBackgroundColor(.15, .15, .15, 1)
			
			f = UI.CreateFrame("Frame", "power"..i, b3)
			f:SetPoint("CENTER", b3, "CENTER", 0, 0)
			f:SetWidth(b3:GetWidth()-2)
			f:SetHeight(b3:GetHeight()-2)
			f:SetBackgroundColor(.7, .23, .24, 1)
			
			bar["power"..i] = f
		end
	elseif calling == "mage" then
		bar:SetBackgroundColor(0, 0, 0, 1)
		
		b1 = UI.CreateFrame("Frame", "powerframe", bar)
		b1:SetPoint("CENTER", bar, "CENTER", 0, 0)
		b1:SetWidth(bar:GetWidth()-2)
		b1:SetHeight(bar:GetHeight()-2)
		b1:SetBackgroundColor(.4, .4, .4, 1)
		
		b2 = UI.CreateFrame("Frame", "powerinside", b1)
		b2:SetPoint("CENTER", b1, "CENTER", 0, 0)
		b2:SetWidth(b1:GetWidth()-2)
		b2:SetHeight(b1:GetHeight()-2)
		b2:SetBackgroundColor(0, 0, 0, 1)
		
		f = UI.CreateFrame("Frame", "charge", b2)
		f:SetPoint("CENTER", b2, "CENTER", 0, 0)
		f:SetWidth(b2:GetWidth()-2)
		f:SetHeight(b2:GetHeight()-2)
		f:SetBackgroundColor(.7, .23, .24, 1)
		
		f2 = UI.CreateFrame("Frame", "chargebg", f)
		f2:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
		f2:SetWidth(f:GetWidth() / 2)
		f2:SetHeight(f:GetHeight())
		f2:SetBackgroundColor(0, 0, 0, .7)
		
		bar["charge"] = f
		bar["chargebg"] = f2
	end
	
	self.bars["calling"] = bar
end

function UF:AnimateCast()
	local castbar = Inspect.Unit.Castbar(self.unit)
	if castbar then
		remaining = castbar.remaining
		duration = castbar.duration
		
		if not castbar.channeled then
			remaining = duration - remaining
		end
		
		if remaining and duration then
			cast = self.bars["cast"]
			
			width = math.ceil((cast.background:GetWidth() - 2)* (remaining / duration))
			cast.bar:SetWidth(width)
			cast.text:SetText(castbar.abilityName)
			cast.span:SetText(string.format("%.2f/%.2f", remaining, duration))
		end
	end
end

function UF:Update()
	if self.casting then
		self:AnimateCast()
	end
	if self.bars["buffs"] ~= nil then
		self.bars["buffs"]:Update()
	end
	if self.bars["timers"] ~= nil then
		self.bars["timers"]:Update()
	end
end

function UF:UpdateCast()
	if self.bars["cast"] == nil then
		return
	end
	
	local cast = Inspect.Unit.Castbar(self.unit)
	if cast then
		self.bars["cast"]:SetVisible(true)
		self.casting = true
	else
		self.casting = false
		self.bars["cast"]:SetVisible(false)
	end
end

function UF:UpdateHealth()
	unit = Inspect.Unit.Detail(self.unit)
	if unit ~= nil then
		p = unit.health / unit.healthMax
		self.bars["healthbg"]:SetWidth(math.floor((1-p) * self.bars["health"]:GetWidth()))
		
		local text = tostring(unit.health)
		
		if unit.health > 1000000 then
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

-- Probably should do a neutral check for energy/power/mana?
function UF:UpdatePower()
	if self.bars["power"] == nil then return end
	unit = Inspect.Unit.Detail(self.unit)
	if unit == nil then return end
	
	if unit.calling == "warrior" then
		self.bars["powerbg"]:SetWidth(math.floor(self.bars["power"]:GetWidth() * (1 - (unit.power / 100))))
		self.texts["power"]:SetText(tostring(unit.power))
	elseif unit.calling == "rogue" then
		self.bars["powerbg"]:SetWidth(math.floor(self.bars["power"]:GetWidth() * (1 - (unit.energy / unit.energyMax))))
		self.texts["power"]:SetText(tostring(unit.energy))
	elseif unit.calling == "cleric" or unit.calling == "mage" then
		self.bars["powerbg"]:SetWidth(math.floor(self.bars["power"]:GetWidth() * (1 - (unit.mana / unit.manaMax))))
		self.texts["power"]:SetText(tostring(unit.mana))
	end
	
end

function UF:SetPowerColor()
	unit = Inspect.Unit.Detail(self.unit)
	if self.bars["power"] == nil then
		return
	end
	
	if unit.calling == "warrior" then
		self.bars["power"]:SetBackgroundColor(.7, .7, .7, 1)
	elseif unit.calling == "rogue" then
		self.bars["power"]:SetBackgroundColor(1, .96, .41, 1)
	else
		self.bars["power"]:SetBackgroundColor(.3, .6, .7, 1)
	end
	
	--[[
	if unit.manaMax ~= nil then
		self.bars["power"]:SetBackgroundColor(.3, .6, .7, 1)
	elseif unit.energyMax ~= nil then
		self.bars["power"]:SetBackgroundColor(1, .96, .41, 1)
	elseif unit.powerMax ~= nil then
		self.bars["power"]:SetBackgroundColor(1, 1, 1, 1)
	end
	--]]
end

function UF:UpdateOptional(tar, show)
	
	optional = Roflui.uf[tar].bars["optional"]
	if optional == nil then return end
	
	unit = Inspect.Unit.Detail(tar)
	
	optional:SetVisible(show)
	optional.vitality:SetText(unit.vitality .. "%")
	optional.planar:SetText(unit.planar .. " / " .. unit.planarMax)
end

function Roflui.PlayerFrame()
	base = Roflui.CreateFrameBase("player")
	base.width = config.player.width
	base.height = config.player.height
	base.x = config.player.x
	base.y = config.player.y
	base.anchorAt = config.player.anchorAt
	base.anchorTo = config.player.anchorTo
	base.fontSize = config.player.fontSize
	
	base.frame = Roflui.CreateFrame(base)
	base.buffs = false
	base.debuffs = true
	base.mydebuffs = false
	base.maxbuffs = 8
	
	base.mytimers = true
	base.timerbuffs = true
	base.timerdebuffs = true
	base.maxduration = 30
	base.noduration = false

	base.bars["health"], base.bars["healthbg"] = Roflui.CreateHealthBar(base)
	base.bars["power"], base.bars["powerbg"] = Roflui.CreatePowerBar(base)
	base.bars["cast"] = Roflui.CreateCastBar(base)
	base.bars["buffs"] = Roflui.CreateBuffBar(base)
	base.bars["buffs"].frame:SetPoint("BOTTOMLEFT", base.frame, "TOPLEFT", 0, -5)
	base.bars["timers"] = Roflui.CreateTimers(base)
	base.bars["timers"].frame:SetPoint("BOTTOMLEFT", base.frame, "TOPLEFT", 0, -50)
	base.bars["combat"] = Roflui.CreateCombatBar(base)
	base.bars["optional"] = Roflui.CreateOptionalBar(base)
	
	base.texts["health"] = Roflui.CreateHealthText(base)
	base.texts["power"] = Roflui.CreatePowerText(base)
	base.texts["name"] = Roflui.CreateNameText(base)
	
	base.frame:SetSecureMode("restricted")
	base.frame.Event.LeftClick = "target @player"
	base.frame.Event.RightClick = function() Command.Unit.Menu("player") end
	base.frame.Event.MouseIn = function() base:UpdateOptional("player", true) end
	base.frame.Event.MouseOut = function() base:UpdateOptional("player", false) end
	base.frame:SetMouseoverUnit("player")
	
	Roflui.uf["player"] = base
end

function Roflui.TargetFrame()

	base = Roflui.CreateFrameBase("player.target")
	base.width = config.target.width
	base.height = config.target.height
	base.x = config.target.x
	base.y = config.target.y
	base.anchorAt = config.target.anchorAt
	base.anchorTo = config.target.anchorTo
	base.fontSize = config.player.fontSize
	
	base.buffs = true
	base.debuffs = true
	base.mydebuffs = false
	
	base.mytimers = true
	base.timerbuffs = true
	base.timerdebuffs = true
	
	base.maxbuffs = 8
	
	base.frame = Roflui.CreateFrame(base)
	
	base.bars["health"], base.bars["healthbg"] = Roflui.CreateHealthBar(base)
	base.bars["power"], base.bars["powerbg"] = Roflui.CreatePowerBar(base)
	base.bars["cast"] = Roflui.CreateCastBar(base)
	base.texts["health"] = Roflui.CreateHealthText(base)
	base.texts["power"] = Roflui.CreatePowerText(base)
	base.texts["name"] = Roflui.CreateNameText(base)
		
	base.bars["buffs"] = Roflui.CreateBuffBar(base)
	base.bars["buffs"].frame:SetPoint("BOTTOMLEFT", base.frame, "TOPLEFT", 0, -5)
	base.bars["timers"] = Roflui.CreateTimers(base)
	base.bars["timers"].frame:SetPoint("BOTTOMLEFT", base.frame, "TOPLEFT", 0, -50)
	base.frame.Event.RightClick = function() Command.Unit.Menu("player.target") end
	
	base.frame:SetVisible(false)
	
	Roflui.uf["player.target"] = base
end

function Roflui.TargetOfTargetFrame()

	base = Roflui.CreateFrameBase("player.target.target")
	base.width = config.targettarget.width
	base.height = config.targettarget.height
	base.x = config.targettarget.x
	base.y = config.targettarget.y
	base.anchorAt = config.targettarget.anchorAt
	base.anchorTo = config.targettarget.anchorTo
	base.fontSize = config.targettarget.fontSize
	
	base.frame = Roflui.CreateFrame(base)
	base.bars["health"], base.bars["healthbg"] = Roflui.CreateHealthBar(base, true)
	base.texts["health"] = Roflui.CreateHealthText(base)
	base.texts["name"] = Roflui.CreateNameText(base)
	
	base.frame:SetVisible(false)
	
	Roflui.uf["player.target.target"] = base
end

function Roflui.CreateCombatBar(base)
	local frame = UI.CreateFrame("Frame", base.unit, base.frame)
	frame:SetPoint("TOPLEFT", base.frame, "TOPLEFT", -2, -2)
	frame:SetBackgroundColor(.9, 0, 0, .5)
	frame:SetWidth(base.width + 4)
	frame:SetHeight(base.height + 4)
	frame:SetVisible(false)
	
	return frame
end

function Roflui.CreateOptionalBar(base)
	local fbg = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg:SetPoint("TOPLEFT", base.frame, "TOPLEFT", -8, -8)
	fbg:SetWidth(base.width + 16)
	fbg:SetHeight(base.height + 16)
	fbg:SetVisible(false)
	fbg:SetLayer(1000)
	
	local vit= Text.Create(fbg)
	vit:SetPoint("TOPLEFT", fbg, "TOPLEFT", 0, 0)
	vit:SetFontSize(base.fontSize)
	vit:SetShadowColor(0, 0, 0, 1)
	vit:SetFontColor(.8, .8, 8, 1)
	vit:SetLayer(30)
	vit:SetText("100%")

	local planar = Text.Create(fbg)
	planar:SetPoint("BOTTOMLEFT", fbg, "BOTTOMLEFT", 0, 0)
	planar:SetFontSize(base.fontSize)
	planar:SetShadowColor(0, 0, 0, 1)
	planar:SetFontColor(.4, .4, 8, 1)
	planar:SetLayer(30)
	planar:SetText("9/9")

	fbg.vitality = vit
	fbg.planar = planar
	
	base.bars["optional"] = fbg
	
	return fbg
end

function Roflui.CreateHealthBar(base, full)

	local fbg = UI.CreateFrame("Frame", base.unit, base.frame)
	fbg:SetPoint("TOPLEFT", base.frame, "TOPLEFT", 1, 1)
	fbg:SetWidth(base.width - 2)
	
	if full then
		fbg:SetHeight(base.height-2)
	else
		fbg:SetHeight(math.floor(base.height * .85)-3)
	end
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
	fbg:SetHeight(base.height - (math.floor(base.height * .85)))
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
	
	local fb = UI.CreateFrame("Frame", base.unit, f)
	fb:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	fb:SetWidth(f:GetWidth() / 2)
	fb:SetHeight(f:GetHeight())
	fb:SetBackgroundColor(0, 0, 0, .7)
	fb:SetLayer(11)
	
	return f, fb
end

function Roflui.CreateCastBar(base)
	local frame = UI.CreateFrame("Frame", base.unit, base.frame)
	frame:SetPoint("TOPLEFT", base.frame, "BOTTOMLEFT", 0, 4)
	frame:SetWidth(base.width)
	frame:SetHeight(20)
	frame:SetBackgroundColor(0, 0, 0, 1)
	
	local fbg = UI.CreateFrame("Frame", base.unit, frame)
	fbg:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, 1)
	fbg:SetWidth(frame:GetWidth()-2)
	fbg:SetHeight(frame:GetHeight()-2)
	fbg:SetBackgroundColor(.4, .4, .4, 1)
	fbg:SetLayer(30)
	
	local fbg2 = UI.CreateFrame("Frame", base.unit, fbg)
	fbg2:SetPoint("TOPLEFT", fbg, "TOPLEFT", 1, 1)
	fbg2:SetWidth(fbg:GetWidth() -  2)
	fbg2:SetHeight(fbg:GetHeight() - 2)
	fbg2:SetBackgroundColor(0, 0, 0, 1)
	fbg2:SetLayer(40)
		
	local bar = UI.CreateFrame("Frame", base.unit, frame)
	bar:SetPoint("TOPLEFT", fbg2, "TOPLEFT", 1, 1)
	bar:SetWidth(fbg2:GetWidth()-2)
	bar:SetHeight(fbg2:GetHeight()-2)
	bar:SetBackgroundColor(.2, .2, .2, 1)
	bar:SetLayer(50)
	
	local text = UI.CreateFrame("Text", base.unit, frame)
	text:SetPoint("CENTERLEFT", fbg2, "CENTERLEFT", 2, 0)
	text:SetFontColor(.8, .8, .8, 1)
	text:SetFontSize(11)
	text:SetText("Casting something")
	text:SetLayer(60)
	
	local span = UI.CreateFrame("Text", base.unit, frame)
	span:SetPoint("CENTERRIGHT", fbg2, "CENTERRIGHT", -2, 0)
	span:SetFontColor(.8, .8, .8, 1)
	span:SetFontSize(11)
	span:SetText("1.4/1.5")
	span:SetLayer(60)
	
	frame:SetVisible(false)
	frame.background = fbg2
	frame.bar = bar
	frame.text = text
	frame.span = span
	return frame
end

function Roflui.CreateHealthText(base)

	local text = Text.Create(base.frame)
	text:SetPoint("CENTERLEFT", base.bars["health"], "CENTERLEFT", 2, 1)
	--text:SetFont("Roflui", config.defaultFont)
	text:SetFontSize(base.fontSize)
	text:SetShadowColor(0, 0, 0, 1)
	text:SetFontColor(0, 1, 0, 1)
	text:SetText("Health")
	text:SetLayer(30)
	--text:DisableShadow()

	return text
end

function Roflui.CreatePowerText(base)

	local text = Text.Create(base.frame)
	text:SetPoint("CENTERRIGHT", base.bars["health"], "CENTERRIGHT", -2, 1)
	text:SetFontSize(base.fontSize)
	text:SetFontColor(.8, .8, .8, 1)
	text:SetShadowColor(0, 0, 0, 1)
	text:SetText("Pow")
	text:SetLayer(30)

	return text
end

function Roflui.CreateNameText(base)
	local t = Text.Create(base.frame)
	t:SetPoint("CENTER", base.bars["health"], "CENTER", 1, 1)
	--t:SetFont("Roflui", config.defaultFont)
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
	base.casting = false
	
	base.bars = {}
	base.texts = {}
	
	base.unitChangedEventTable = nil
	base.unitChangedEventTable = Library.LibUnitChange.Register(base.unit)
	table.insert(base.unitChangedEventTable, {function() base:UnitChanged() end, "Roflui", base.unit.." changed"})
	
	return base
end