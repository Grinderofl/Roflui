-- Reload UI

function Roflui.Reloadui()
	"/reloadui"
end

table.insert(Command.Slash.Register("rl"), { Roflui.Reloadui, "RoflUI", "Roflui Reload UI"})