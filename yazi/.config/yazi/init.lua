-- Show the owner (user:group) of the hovered file on the right side of the status bar
Status:children_add(function()
	local h = cx.active.current.hovered
	-- Skip if nothing is hovered or not on a Unix system
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	-- Resolve uid/gid to names, fallback to numeric ID if name is unavailable
	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)
