local Roflui = ...

Timers = {}
Timers.__index = Timers

function Roflui.CreateTimers(base)
	local timers = {}
	setmetatable(timers, Timers)
	
	timers.active = {}
	timers.inactive = {}
	timers.buffs = base.timerbuffs
	timers.debuffs = base.timerdebuffs
	timers.max = base.maxbuffs
	timers.unit = base.unit
	timers.resync = false
	timers.mineonly = base.mytimers
	timers.unitId = nil
	
	local frame = UI.CreateFrame("Frame", "Timers", base.frame)
	frame:SetWidth(base.width)
	--frame:SetBackgroundColor(0, 0, 0, .5)
	
	timers.frame = frame
	
	return timers
end

function Timers:UnitChanged()
	self.unitId = Inspect.Unit.Lookup(self.unit)
	for k, v in pairs(self.active) do
		self:RemoveTimer(k)
	end
	
	local list = Inspect.Buff.List(self.unitId)
	if list == nil then	return end
	
	local details = Inspect.Buff.Detail(self.unitId, list)
	for k, v in pairs(details) do
		self:AddTimer(k,v)
	end
end

function Timers:Tick()
	for id, timer in pairs(self.active) do
		timer:Tick(id, self.unitId)
	end
end

function Timers:Update()
	if not self.resync then self:Tick() return end
	self.resync = false
	
	local last = nil
	local bs = {}
	for id, timer in pairs(self.active) do
		--if table.getn(bs) == self.max then break end
		table.insert(bs, timer)
	end
	
	for _, bar in ipairs(bs) do
		if not last then
			bar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
		else
			bar:SetPoint("BOTTOMLEFT", last, "TOPLEFT", 0, -1)
		end
		last = bar
	end
end

function Timers:AddTimer(id, detail)
	self.resync = true
	if self.active[id] then
		self:RemoveTimer(id)
	end
	
	local timer = table.remove(self.inactive)
	if not timer then
		timer = self:CreateTimer()
	end
	
	if timer:SetBuff(detail, self) then
		self.active[id] = timer
	else
		table.insert(self.inactive, timer)
	end
end

function Timers:RemoveTimer(id)
	if self.active[id] then
		self.resync = true
		local bar = self.active[id]
		self.active[id] = nil
		table.insert(self.inactive, bar)
		bar:SetVisible(false)
	end
end

function Timers:CreateTimer()
	timer = UI.CreateFrame("Frame", "MyBuff", self.frame)
	timer:SetHeight(20)
	timer:SetWidth(self.frame:GetWidth())
	--timer:SetBackgroundColor(1, .15, .15, .5)
	
	iconbg1 = UI.CreateFrame("Frame", "IconBg1", timer)
	iconbg1:SetPoint("TOPLEFT", timer, "TOPLEFT", 0, 0)
	iconbg1:SetBackgroundColor(0, 0, 0, .7)
	iconbg1:SetWidth(timer:GetHeight())
	iconbg1:SetHeight(timer:GetHeight())
	
	iconbg2 = UI.CreateFrame("Frame", "IconBg2", iconbg1)
	iconbg2:SetPoint("CENTER", iconbg1, "CENTER", 0, 0)
	iconbg2:SetBackgroundColor(.6, .6, .6, .7)
	iconbg2:SetWidth(iconbg1:GetHeight()-2)
	iconbg2:SetHeight(iconbg1:GetWidth()-2)
	
	icon = UI.CreateFrame("Texture", "Icon", iconbg2)
	icon:SetPoint("CENTER", iconbg2, "CENTER", 0, 0)
	icon:SetWidth(iconbg2:GetWidth()-2)
	icon:SetHeight(iconbg2:GetHeight()-2)
	timer.icon = icon
	
	barbg1 = UI.CreateFrame("Frame", "BarBg1", timer)
	barbg1:SetPoint("TOPLEFT", timer, "TOPLEFT", timer:GetHeight()+2, 0)
	barbg1:SetHeight(timer:GetHeight())
	barbg1:SetWidth(timer:GetWidth()-timer:GetHeight()-2)
	barbg1:SetBackgroundColor(0, 0, 0, .7)
	
	barbg2 = UI.CreateFrame("Frame", "IconBg2", barbg1)
	barbg2:SetPoint("TOPLEFT", barbg1, "TOPLEFT", 1, 1)
	barbg2:SetBackgroundColor(.6, .6, .6, .7)
	barbg2:SetWidth(barbg1:GetWidth()-2)
	barbg2:SetHeight(barbg1:GetHeight()-2)
	
	barbg3 = UI.CreateFrame("Frame", "IconBg2", barbg2)
	barbg3:SetPoint("TOPLEFT", barbg2, "TOPLEFT", 1, 1)
	barbg3:SetBackgroundColor(.15, .15, .15, .4)
	barbg3:SetWidth(barbg2:GetWidth()-2)
	barbg3:SetHeight(barbg2:GetHeight()-2)
	
	bar = UI.CreateFrame("Frame", "Bar", barbg3)
	bar:SetPoint("TOPLEFT", barbg3, "TOPLEFT", 0, 0)
	bar:SetHeight(barbg3:GetHeight())
	bar:SetWidth(barbg3:GetWidth()/2)
	bar:SetBackgroundColor(0, 0, 0, .9)
	
	text = UI.CreateFrame("Text", "Txt", bar)
	text:SetPoint("CENTERLEFT", bar, "CENTERLEFT", 1, 0)
	text:SetText("Text")
	text:SetFontColor(1, 1, 1, 1)
	text:SetFontSize(11)
	
	timeText = UI.CreateFrame("Text", "Time", bar)
	timeText:SetPoint("CENTERRIGHT", barbg3, "CENTERRIGHT", -1, 0)
	timeText:SetText("Time")
	timeText:SetFontColor(1, 1, 1, 1)
	timeText:SetFontSize(11)
	
	timer.bar = bar
	timer.barbg = barbg3
	timer.text = text
	timer.time = timeText
	
	function timer:SetBuff(detail, base)
		self.detail = detail
		if detail.debuff then
			if not base.debuffs then return end
			if base.mineonly then 
				caster = Inspect.Unit.Detail(detail.caster).name
				unit = Inspect.Unit.Detail("player").name
				if caster ~= unit then return end
			end
			--self:SetBackgroundColor(.8, .3, .3, 1)
		else
			if not base.buffs then return end
			--self:SetBackgroundColor(.6, .6, .6, 1)
		end
		--self.icon:SetHeight(self:GetHeight()-2)
		--self.icon:SetWidth(self.icon:GetHeight())
		self.icon:SetTexture("Rift", detail.icon)
		self:SetVisible(true)
		
		return true
	end
	
	function timer:Tick(id, unit)
		buff = Inspect.Buff.Detail(unit, id)
		if buff == nil then return end
		self.text:SetText(buff.name)
				
		if buff.duration == nil then
			self.time:SetText("")
			self.bar:SetWidth(0)
		else
			local width = self.barbg:GetWidth()
			local percent = buff.remaining / buff.duration
			local length = math.floor(width*percent)
			self.bar:SetWidth(length)
			self.time:SetText(tostring(buff.remaining))
			
			if buff.remaining >= 3600 then
			  self.time:SetText(string.format("%d:%02d:%02d", math.floor(buff.remaining / 3600), math.floor(buff.remaining / 60) % 60, math.floor(buff.remaining) % 60))
			else
			  self.time:SetText(string.format("%d:%02d", math.floor(buff.remaining / 60), math.floor(buff.remaining) % 60))
			end
			
		end
		
	end
	
	return timer
end