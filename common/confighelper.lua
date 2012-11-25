local Roflui = ...

function GetConfigValue(...)
	local config = Roflui.config
	for i,v in ipairs(arg) do
		if config[v] == nil then
			return nil
		end
		config = config[v]
	end
	
	return config
end