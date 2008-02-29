local options = Xparky.options
Xparky.factionTable = {}

options.type = "group"
options.name  = "Xparky"
options.get  = function( k )  return db[k.arg] end
options.set  = function( k, v ) db[k.arg] = v; Xparky:UpdateBars(k.arg) end
options.args = {}

options.args.bars = {
	type = "group",
	name = L["Bars"],
	desc = L["Bar Modifications"],
	order = 1,
	args = {
		showxpbar = {
			order = 1,
			name = L["Show XP Bar"],
			desc = L["Whether to show the XP bar or not"],
			type = "toggle",
			arg = "ShowXP"
		},
		showrepbar = {
			order = 2,
			name = L["Show Reputation Bar"],
			desc = L["Whether to show the Reputation bar or not"],
			type = "toggle",
			arg = "ShowRep"
		},
		showshadow = {
			order = 3,
			name = L["Show Shadow"],
			desc = L["Attach a shadow to the bars"],
			type = "toggle",
			arg = "ShowShadow"
		},
		showtogo = {
			order = 4,
			name = L["XP/Rep to go"],
			desc = L["Show the amount present or the amount to go"],
			type = "toggle",
			arg = "LegoToGo"
		},
		showlego = {
			order = 5,
			name = L["Show Legoblock"],
			desc = L["Give a textbox with xp/rep details"],
			type = "toggle",
			arg = "Lego"
		},
		space = {
			order = 6,
			name = "    ",
			desc = "",
			type = "description"
		},
		xpspark = {
			order = 7,
			name = L["XP Spark Intensity"],
			desc = L["How strong the XP spark is"],
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark",
		},
		repspark = {
			order = 8,
			name = L["Reputation Spark Intensity"],
			desc = L["How strong the Reputation spark is"],
			type = "range",
			min = 0.1, max = 1, step = 0.05,
			arg = "Spark2"
		},
		thick = {
			order = 9,
			name = L["Bar Thickness"],
			desc = L["How thick the bars are"],
			type = "range",
			min = 1.5, max = 8, step = 0.1,
			arg = "Thickness"
		},
		spacer = {
			order = 10,
			name = "",
			type = "description"
		},
		hide = {
			order = 11,
			name = L["Hide Bars"],
			desc = L["Hide the bars til you mouseover them"],
			type = "toggle",
			arg = "MouseHide",
		},
		tooltip = {
			order = 12,
			name = L["Show Tooltip"],
			desc = L["Show a tooltip with the XP/Rep info when moused over"],
			type = "toggle",
			arg = "MouseTooltip",
		},
		colours = {
			type = "group",
			name = L["Colours"],
			desc = L["Colours of the bars"],
			order = 13,
			get = function(info)
				local t = db.barColours[info.arg] or { Red = 1, Green = 1, Blue = 1, Alpha = 1}
				return t.Red, t.Green, t.Blue, t.Alpha
			end,
			set = function(info, r, g ,b, a)
				local t = db.barColours[info.arg]
				t.Red = r
				t.Green = g
				t.Blue = b
				t.Alpha = a
				Xparky:UpdateBars(info.arg)
			end,
			args = {
				colourXP = {
					order = 1,
					name = L["Experience Bar"],
					desc = L["Colour of the full XP bar"],
					type = "color",
					hasAlpha = true,
					arg = "XPBar"
				},
				colourNoXP = {
					order = 2,
					name = L["Empty Experience Bar"],
					desc = L["Colour of the empty XP bar"],
					type = "color",
					hasAlpha = true,
					arg = "NoXPBar"
				},
				colourRested = {
					order = 3,
					name = L["Rested Bar"],
					desc = L["Colour of the Rested XP bar"],
					type = "color",
					hasAlpha = true,
					arg  = "RestBar"
				},
				space = {
					order = 4,
					name = "",
					desc  = "",
					type = "description"
				},
				colourRep = {
					order = 5,
					name = L["Reputation Bar"],
					desc = L["Colour of the full Reputation bar"],
					type = "color",
					hasAlpha = true,
					arg = "RepBar"
				},
				colourNoRep = {
					order = 6,
					name = L["Empty Reputation Bar"],
					desc = L["Colour of the empty Reputation bar"],
					type = "color",
					hasAlpha = true,
					arg = "NoRepBar"
				},
			},
		},
	},
}
options.args.framelink = {
	type = "group",
	name = L["Frame Link"],
	order = 1,
	args = {
		attach = {
			order = 1,
			type = "execute",
			name = L["Hook to frame"],
			desc = L["Click here to activate the frame selector"],
			func = function() mouser:Start() end
		},
		space = {
			order = 2,
			name = "",
			desc = "",
			type = "description"
		},
		attached = {
			order = 3,
			type = "input",
			name = L["Frame Connected to"],
			desc = L["The name of the frame to connect to"],
			arg = "ConnectedFrame",
			set = function(k,v) db.ConnectedFrame = v; db.Detached = false; Xparky:AttachBar() end
		},
		attachto = {
			order = 4,
			name = L["Attach to:"],
			desc = L["Which side to attach to"],
			type = "select",
			values = { top = L["Top"], bottom = L["Bottom"], left = L["Left"], right = L["Right"] },
			arg = "Attach"
		},
		insideframe = {
			order = 5,
			name = L["Inside Frame?"],
			desc = L["Attach to the inside of the frame"],
			type = "toggle",
			arg = "Inside"
		},
		spacer = {
			order = 6,
			name = L["Bar Strata"],
			desc = L["Set the Bar Strata so it appears above or below other frames"],
			type = "select",
			values = Strata,
			arg = "Strata"
		},
		xoffset = {
			order = 7,
			name = L["X offset"],
			desc = L["How far on the X axis to offset the bars"],
			type = "input",
			arg = "xOffset"
		},
		yoffset = {
			order = 8,
			name = L["Y offset"],
			desc = L["How far on the Y axis to offset the bars"],
			type = "input",
			arg = "yOffset"
		},
	},
}

options.args.help = {
	type = "group",
	order = 100,
	name = L["Documentation"],
	args = {
		desc = {
			type = "group",
			name = L["Description"],
			args = {
				text = {
					type = "description",
					name = L["DESCRIPTION"],
					order = 1
				},
			},
		},
		faq = { 
			type = "group",
			name = L["FAQ"],
			args = {
				text = {
					type = "description",
					name = L["FAQ_TEXT"],
					order = 2
				},
			},
		},
		about = {
			type = "group",
			name = L["About"],
			args = {
				text = {
					type = "description",
					name = L["ADDON_INFO"],
					order = 3
				}
			}
		}
	}
}

options.args.factions = {
	type = "group",
	order = 2,
	name = L["Factions"],
	args = {
		factionlist = {
			name = L["Faction Selected"],
			desc = L["List of Factions to watch"],
			type = "select",
			values = Xparky.factionTable,
			arg = "Faction",
			set = function(k, v) db.Faction = tonumber(v); SetWatchedFactionIndex(tonumber(v)); Xparky:ScheduleTimer("UpdateBars", 1); end 
		}
	}
}
