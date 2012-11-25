--[[
	Library to create outlined texts.
	Bit of a hacky one, until they decide to add
	support for text outlines
--]]

Text = {}
Text.__index = Text

_shadows = {"left", "right", "top", "bottom"}
_texts = {"left", "right", "top", "bottom", "text"}

function Text:DisableShadow()
	for k, shadow in pairs(_shadows) do
		self[shadow]:SetVisible(false)
	end
end

function Text:Texts()
	return {"left", "right", "top", "bottom", "text"}
end

function Text:Shadows()
	return {"left", "right", "top", "bottom"}
end

function Text.Create(parent)
	local text = {}
	setmetatable(text, Text)
	
	text["text"] = UI.CreateFrame("Text", "Text", parent)
	text["left"] = UI.CreateFrame("Text", "Text-left", parent)
	text["right"] = UI.CreateFrame("Text", "Text-right", parent)
	text["top"] = UI.CreateFrame("Text", "Text-top", parent)
	text["bottom"] = UI.CreateFrame("Text", "Text-bottom", parent)
	
	return text
end

function Text:SetText(str)
	for k, text in pairs(_texts) do
		self[text]:SetText(str)
	end
end

function Text:SetPoint(at, parent, to, x, y)
	self.left:SetPoint(at, parent, to, x-1, y)
	self.right:SetPoint(at, parent, to, x+1, y)
	self.top:SetPoint(at, parent, to, x, y-1)
	self.bottom:SetPoint(at, parent, to, x, y+1)
	self.text:SetPoint(at, parent, to, x, y)
end

function Text:SetFont(addon, font)
	for k,text in pairs(_texts) do
		self[text]:SetFont(addon, font)
	end
end

function Text:SetShadowColor(r, g, b, a)
	for k,shadow in pairs(_shadows) do
		self[shadow]:SetFontColor(r, g, b, a)
	end
end

function Text:SetFontColor(r, g, b, a)
	self.text:SetFontColor(r, g, b, a)
end

function Text:SetFontSize(size)
	for k,text in pairs(_texts) do
		self[text]:SetFontSize(size)
	end
end

function Text:SetLayer(layer)
	for k,shadow in pairs(_shadows) do
		self[shadow]:SetLayer(layer)
	end
	self.text:SetLayer(layer+1)
end