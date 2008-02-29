local defaultBar = {}

function Xparky:NewBar(Type, Bar)
	if not Bar then
		if Type == "XP" then
			Bar = default.profile.Bars.XparkyXPBar
		else
			Bar = default.profile.Bars.XparkyRepBar
		end
	end
	Bar.Frames = {}
	Bar.Frames.Anchor = 
	local Bar = CreateFrame("Frame", BarName .. "Xparky", Anchor)
end


