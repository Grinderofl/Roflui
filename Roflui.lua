-- Main initialization

local Roflui = ...

function Roflui.OnLoad(addon)
	if addon == "Roflui" then
		print("Addon loaded")
		Roflui.context = UI.CreateContext("Roflui")
		Roflui.context:SetSecureMode("restricted")
		
		if Roflui.config.unitframes then
			Roflui.SetupUnitframes()
			table.insert(Event.System.Update.Begin, {Roflui.Update, "Roflui", "Animation"})
		end
		
		if Roflui.config.tooltip then
			Roflui.SetupTooltip()
			table.insert(Event.Tooltip, {Roflui.UpdateTooltip, "Roflui", "Tooltip"})
			table.insert(Event.System.Update.Begin, {Roflui.MouseAnchor, "Roflui", "Mouse anchor"}) 
		end
		
	end
end

function Roflui.Update()
	for n, f in pairs(Roflui.uf) do
		f:Update()
	end
end

--[[function Roflui.PerformEvents(units, callback)
	local fuid = -1
	for name, frame in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(name)
		if fuid then
			for unit, value in pairs(units) do
				if unit == fuid then
					frame:callback
				end
			end
		end
	end
end--]]

function Roflui.Available(units)
	--Roflui.PerformEvents(units, UnitChanged())
	---[[
	local fuid = -1
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UnitChanged()
				end
			end
		end
	end
	--]]
end

function Roflui.UpdateCombat(units)
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UpdateCombat()
				end
			end
		end
	end
end

function Roflui.UpdateHealth(units)
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UpdateHealth()
				end
			end
		end
	end
end

function Roflui.UpdatePower(units)
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UpdatePower()
				end
			end
		end
	end
end

function Roflui.UpdateCallingBar(units)
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UpdateCallingBar()
				end
			end
		end
	end
end

function Roflui.UpdateCast(units)
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			for u,v in pairs(units) do
				if u == fuid then
					f:UpdateCast()
				end
			end
		end
	end
end

function Roflui.BuffsChanged(id, buffs)
	local fuid = -1
	
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			if id == fuid then
				if f.bars["buffs"] ~= nil then
					f.bars["buffs"]:UpdateBuffs();
				end
				if f.bars["timers"] ~= nil then
					--f.bars["timers"]:UpdateBuffs();
				end
			end
		end
	end
end

function Roflui.BuffRemoved(id, buffs)
	local fuid = -1
	
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			if id == fuid then
				if f.bars["buffs"] ~= nil then
					for b in pairs(buffs) do
						f.bars["buffs"]:RemoveBuff(b);
					end
				end
				if f.bars["timers"] ~= nil then
					for b in pairs(buffs) do
						f.bars["timers"]:RemoveTimer(b);
					end
				end
			end
		end
	end
end

function Roflui.BuffAdded(id, buffs)
	local fuid = -1
	
	for n, f in pairs(Roflui.uf) do
		fuid = Inspect.Unit.Lookup(n)
		if fuid then
			if id == fuid then
				if f.bars["buffs"] ~= nil then
					local details = Inspect.Buff.Detail(id, buffs)
					for k,b in pairs(details) do
						f.bars["buffs"]:AddBuff(k, b);
					end
				end
				if f.bars["timers"] ~= nil then
					local details = Inspect.Buff.Detail(id, buffs)
					for k,b in pairs(details) do
						f.bars["timers"]:AddTimer(k, b);
					end
				end				
			end
		end
	end
end

function Roflui.SetupEvents()
	table.insert(Event.Addon.Load.End, { Roflui.OnLoad, "Roflui", "Addon loaded"})
	
	-- Load player specific stuff
	table.insert(Event.Unit.Availability.Full, { Roflui.Available, "Roflui", "Unit available"})
	
	-- Castbar management
	table.insert(Event.Unit.Castbar, { Roflui.UpdateCast, "Roflui", "Updating castbars"})

	-- Health
	table.insert(Event.Unit.Detail.Health, { Roflui.UpdateHealth, "Roflui", "Update health"})
	table.insert(Event.Unit.Detail.HealthMax, { Roflui.UpdateHealth, "Roflui", "Update health max"})	
	
	-- Power
	table.insert(Event.Unit.Detail.Power, { Roflui.UpdatePower, "Roflui", "Update power"})
	table.insert(Event.Unit.Detail.Energy, { Roflui.UpdatePower, "Roflui", "Update power"})
	table.insert(Event.Unit.Detail.EnergyMax, { Roflui.UpdatePower, "Roflui", "Update power"})
	table.insert(Event.Unit.Detail.Mana, { Roflui.UpdatePower, "Roflui", "Update power"})
	table.insert(Event.Unit.Detail.ManaMax, { Roflui.UpdatePower, "Roflui", "Update power"})
	
	-- Calling specifics
	table.insert(Event.Unit.Detail.Combo, { Roflui.UpdateCallingBar, "Roflui", "Update combo"})
	table.insert(Event.Unit.Detail.Charge, { Roflui.UpdateCallingBar, "Roflui", "Update combo"})
	
	-- Other stuff
	table.insert(Event.Unit.Detail.Combat, {Roflui.UpdateCombat, "Roflui", "Update combat"})
	
	--[[
	--TODO:
	table.insert(Event.Unit.Detail.Planar, {Roflui.UpdatePlanar, "Roflui", "Update planars"})
	table.insert(Event.Unit.Detail.PlanarMax, {Roflui.UpdatePlanar, "Roflui", "Update planars"})
	table.insert(Event.Unit.Detail.Vitality, {Roflui.UpdatePlanar, "Roflui", "Update planars"})
	table.insert(Event.Unit.Detail.Combat, {Roflui.UpdateCombat, "Roflui", "Update planars"})
	table.insert(Event.Unit.Detail.Aggro, { Roflui.UpdateAggro, "Roflui", "Update combo"})
	
	--]]
	
	table.insert(Event.Buff.Add, {Roflui.BuffAdded, "Roflui", "Buff added"})
	table.insert(Event.Buff.Change, {Roflui.BuffsChanged, "Roflui", "Buffs changed"})
	table.insert(Event.Buff.Remove, {Roflui.BuffRemoved, "Roflui", "Buff removed"})
end


Roflui.SetupEvents()