-- Config


local Roflui = ...

Roflui.config = {
	defaultFont = "media/fonts/Homespun.ttf",
	unitframes = true,
	debug = true,
	player = {
		width = 250,
		height = 55,
		x = -250,
		y = 300,
		anchorAt = "CENTER",
		anchorTo = "CENTER",
		fontSize = 11
		},
	target = {
		width = 250,
		height = 55,
		x = 250,
		y = 300,
		anchorAt = "CENTER",
		anchorTo = "CENTER",
		fontSize = 11
	},
	colors = {
		["warrior"] 	= 	{r = 1, 	g = 1, 		b = 1		},
		["mage"] 	= 	{r = 0.58, 	g = 0.51, 	b = 0.79	},
		["rogue"] 	= 	{r = 1, 	g = 0.96, 	b = 0.41	},
		["cleric"] 		= 	{r = 0.41, 	g = 0.80, 	b = 0.94	}
	}
}