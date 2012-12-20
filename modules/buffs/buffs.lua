local Roflui = ...

Buff = {}
Buff.__index = Buff

function Roflui.CreateBuffBar(base)
	local buffs = {}
	setmetatable(buffs, Buff)
	
	buffs.activeBuffs = {}
	buffs.zombieBuffs = {}
	buffs.buffs = base.buffs
	buffs.debuffs = base.debuffs
	buffs.maxbuffs = base.maxbuffs
	buffs.unit = base.unit
	buffs.resync = false
	buffs.buff = nil
	buffs.mydebuffs = base.mydebuffs
	
	local frame = UI.CreateFrame("Frame", "Buffs", base.frame)
	frame:SetWidth(base.width)
	--frame:SetBackgroundColor(0, 0, 0, .5)
	frame:SetHeight(30)
	
	buffs.frame = frame
	
	return buffs
end

function Buff:UnitChanged()
	self.unitId = Inspect.Unit.Lookup(self.unit)
	for k, v in pairs(self.activeBuffs) do
		self:RemoveBuff(k)
	end
	
	local list = Inspect.Buff.List(self.unitId)
	if list == nil then
		return
	end
	
	local details = Inspect.Buff.Detail(self.unitId, list)
	for k, v in pairs(details) do
		self:AddBuff(k,v)
	end
end

function Buff:Update()
	if not self.resync then return end
	self.resync = false
	local last = nil

	local bs = {}
	-- Do sorting here
	for id, buff in pairs(self.activeBuffs) do
		if table.getn(bs) == self.maxbuffs then break end
		table.insert(bs, buff)
	end
	
	for _, bar in ipairs(bs) do
		if not last then
			bar:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
		else
			bar:SetPoint("BOTTOMLEFT", last, "BOTTOMRIGHT", 1, 0)
		end
		last = bar
	end
end

function Buff:AddBuff(id, detail)
	self.resync = true
	if self.activeBuffs[id] then
		self:RemoveBuff(id)
	end
	
	local buff = table.remove(self.zombieBuffs)
	if not buff then
		buff = self:CreateBuff()
	end
	
	if buff:SetBuff(detail, self) then
		self.activeBuffs[id] = buff
	else
		table.insert(self.zombieBuffs, buff)
	end
end

function Buff:UpdateBuffs(buffs)
	
end

function Buff:RemoveBuff(id)
	if self.activeBuffs[id] then
		self.resync = true
		local bar = self.activeBuffs[id]
		self.activeBuffs[id] = nil
		table.insert(self.zombieBuffs, bar)
		bar:SetVisible(false)
	end
end

function Buff:CreateBuff()
	buff = UI.CreateFrame("Frame", "MyBuff", self.frame)
	buff:SetHeight(30)
	buff:SetWidth(30)
	buff:SetBackgroundColor(.8, .3, .3, 1)
	icon = UI.CreateFrame("Texture", "Icon", buff)
	icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, 1)
	buff.icon = icon
	
	function buff:SetBuff(detail, base)
		self:SetVisible(false)
		self.detail = detail
		if detail.debuff then
			if not base.debuffs then return end
			if base.mydebuffs then 
				caster = Inspect.Unit.Detail(detail.caster).name
				unit = Inspect.Unit.Detail("player").name
				if caster ~= unit then return end
			end
			self:SetBackgroundColor(.8, .3, .3, 1)
		else
			if not base.buffs then return end
			self:SetBackgroundColor(.6, .6, .6, 1)
		end
		self.icon:SetHeight(self:GetHeight()-2)
		self.icon:SetWidth(self.icon:GetHeight())
		self.icon:SetTexture("Rift", detail.icon)
		self:SetVisible(true)
		
		return true
	end
	
	return buff
end

--[[
function Buff:CreateBuff(target)
	local buff = table.remove(self.zombieBuffs)
	
	if buff then
		buff:SetVisible(true)
	else
		buff = UI.CreateFrame("Frame", "MyBuff", self.frame)
		buff:SetBackgroundColor(.6, .6, .6, 1)
		buff:SetWidth(35)
		buff:SetHeight(35)
		
		icon = UI.CreateFrame("Texture", "Icon", buff)
		icon:SetPoint("TOPLEFT", buff, "TOPLEFT", 1, 1)
		icon:SetWidth(buff:GetWidth()-2)
		icon:SetHeight(buff:GetHeight()-2)
		buff.icon = icon
	end
	
	buff.icon:SetTexture("Rift", target.icon)
	return buff
end

function Buff:UpdateBuffs()
	print("Updating buffs for : " .. self.unit)
end

function Buff:RemoveBuff(buff)
	print("Buff removed" .. buff)
	b = self.activeBuffs[buff]
	
	if b ~= nil then
		print("Found a buff")
		b:SetVisible(false)
		table.insert(self.zombieBuffs, b)
	end
	self.activeBuffs[buff] = nil
	print("Number of actives: " .. table.getn(self.activeBuffs))
end

function Buff:AddBuff(buff)
	print("Buff added:" .. buff.name)
	
	if(self.activeBuffs[buff]) then
		self:RemoveBuff(buff)
	end
	
	if self.buffs then
		if not buff.debuff then
			local b = self:CreateBuff(buff)
			if table.getn(self.activeBuffs) > 0 then
				b:SetPoint("BOTTOMLEFT", self.activeBuffs[table.getn(self.activeBuffs)], "BOTTOMRIGHT", 1, 0)
			else
				b:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
			end
			b:SetWidth(35)
			b:SetBackgroundColor(.6, .6, .6, 1)
			id = buff.id
			print(id)
			self.activeBuffs[id] = b
			print(table.getn(self.activeBuffs))
		end
	end
	
	if self.debuffs then
		if buff.debuff then
			local b = self:CreateBuff(buff)
			if table.getn(self.activeBuffs) ~= 0 then
				b:SetPoint("BOTTOMLEFT", self.activeBuffs[table.getn(self.activeBuffs)], "BOTTOMRIGHT", 1, 0)
			else
				b:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0)
			end
			b:SetWidth(35)
			b:SetBackgroundColor(1, .3, .3, 1)
			table.insert(self.activeBuffs, b)
		end
	end
	
	print("Number of actives: " .. table.getn(self.activeBuffs))
end
--]]