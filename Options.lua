local options = Xparky.options
local L = LibStub("AceLocale-3.0"):GetLocale("Xparky")
local reg = LibStub("AceConfigRegistry-3.0")
local db
local Strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }

currentBar = {Type = "XP"}

factionTable = {}
factionSort = {}

function Xparky:InitialiseOptions()
	db = Xparky.db.profile
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Xparky.db)
end

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
		CreateBars = {
			type = "group",
			name = "Create a new bar",
			order =  1,
			inline = true,
			set = function(k, v) currentBar[k.arg] = v; reg:NotifyChange("Xparky") end,
			get = function(k) return currentBar[k.arg] end,
			args = {
				type = {
					type = "select",
					name = "Bar Type",
					order = 1,
					values = { XP = "XP Bar", Rep = "Rep Bar" },
					arg = "Type",
				},
				name = {
					type = "input",
					name = "Bar Name",
					order = 3,
					width = "full",
					set = function(k,v) 
							if v == "" then 
								currentBar.Name = nil 
								return 
							end 
							currentBar.Name = string.gsub(v, " ", ""); 
							for i,name in ipairs(db.Bars.BarNames) do
								if name == currentBar.Name then
									Xparky:Print("There is a bar with that name already")
									currentBar.Name = nil
									return
								end
							end
							reg:NotifyChange("Xparky") 
						end,
					arg = "Name"
				},
				rep = {
					type = "select",
					name = "Faction",
					order = 2,
					hidden = function() return currentBar.Type ~= "Rep" end,
					values = factionSort,
					set = function(k,v) 
							currentBar.FactionIndex = v; 
							currentBar.Faction = factionSort[v]; 
							reg:NotifyChange("Xparky") 
						end,
					arg = "FactionIndex",
				},
				create = {
					type = "execute",
					name = "Create Bar",
					hidden = function() 
								return	(currentBar.Type == "XP" and not currentBar.Name) or 
										(currentBar.Type == "Rep" and (not currentBar.Name or not currentBar.Faction)) 
							end,
					func =	function(k,v) 
								if currentBar.Type == "XP" then
									table.insert(db.Bars.BarNames, currentBar.Name)
									db.Bars[currentBar.Name] = {Name = currentBar.Name, BarType = "XP" }
								elseif currentBar.Type == "Rep" then
									table.insert(db.Bars.BarNames, currentBar.Name)
									db.Bars[currentBar.Name] = {Name = currentBar.Name, BarType = "Rep", Faction = factionTable[currentBar.Faction] }
								end
								Xparky:GenerateBars()
							end
				},
			},
		},
	},
}

options.args.bars.args.barlist = {
	type = "group",
	name = "Bar List",
	order = 1,
	args = {}
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


function Xparky:getFactions()
	for factionIndex = 1, GetNumFactions() do
		local name, _, _, _, _, _, _, _,isHeader = GetFactionInfo(factionIndex)
		if not isHeader then
			factionTable[name] = factionIndex
			table.insert(factionSort, name)
		end
	end
	if GetNumFactions() == 0 then
		self:ScheduleTimer("getFactions", 1)
	else
		table.sort(factionSort, function(a,b) return a:gsub("The ", "") < b:gsub("The ", "") end)
	end
end

function getBaseMetatable(t)
	if not getmetatable(t) then
		return t
	else
		return getBaseMetatable(getmetatable(t))
	end
end


function Xparky:GenerateBarList()
	Xparky.options.args.bars.args.barlist.args = {}
	for i,BarName in ipairs(db.Bars.BarNames) do
		local Bar = XparkyBar.Bars[BarName]
		if Bar then
			Xparky.options.args.bars.args.barlist.args[Bar.Name] = Bar.Options
		else
			db.Bars.BarNames[i] = nil
		end
	end
	reg:NotifyChange("Xparky")
end


