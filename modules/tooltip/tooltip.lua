local Roflui = ...

function Roflui.SetupTooltip()
	print("Creating tooltip")
	
	local f = UI.CreateFrame("Frame", "Tooltip", Roflui.context)
	f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100)
	f:SetWidth(200)
	f:SetHeight(200)
	f:SetBackgroundColor(0, 0, 0, .9)
	f:SetLayer(999)
	f:SetVisible(false)
	
	Roflui.tooltip = f
end

function Roflui.UpdateTooltip()
	t, unit, buff = Inspect.Tooltip()
	print(tostring(t))
	if t == nil then
		--Roflui.tooltip:SetVisible(false)
	else
		--Roflui.tooltip:SetVisible(true)
	end
end

function Roflui.MouseAnchor()
	if Roflui.tooltip:GetVisible() then
		mouse = Inspect.Mouse()
		Roflui.tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouse.x, mouse.y + 10)
	end
end