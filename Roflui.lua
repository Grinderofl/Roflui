-- Main initialization

local Roflui = ...

function Roflui.OnLoad(addon)
	if addon == "Roflui" then
		print("Addon loaded")
		Roflui.context = UI.CreateContext("Roflui")
		Roflui.context:SetSecureMode("restricted")
		
		if Roflui.config.unitframes then
			Roflui.SetupUnitframes()
		end
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

function Roflui.UpdateHealth(units)
	---[[
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
	--]]
end

function Roflui.SetupEvents()
	table.insert(Event.Addon.Load.End, { Roflui.OnLoad, "Roflui", "Addon loaded"})
	table.insert(Event.Unit.Availability.Full, { Roflui.Available, "Roflui", "Unit available"})
	table.insert(Event.Unit.Detail.Health, { Roflui.UpdateHealth, "Roflui", "Update health"})
	table.insert(Event.Unit.Detail.HealthMax, { Roflui.UpdateHealth, "Roflui", "Update health max"})
end


Roflui.SetupEvents()