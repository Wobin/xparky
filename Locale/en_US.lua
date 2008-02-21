local L = LibStub("AceLocale-3.0"):NewLocale("Xparky", "enUS", true)

if L then
	L["This frame has no global name, and cannot be added via the mouse"] = true
	L["Bars"] = true
	L["Bar Modifications"] = true

	L["Show XP Bar"] = true
	L["Whether to show the XP bar or not"] = true

	L["Show Reputation Bar"] = true
	L["Whether to show the Reputation bar or not"] = true

	L["Show Shadow"] = true
	L["Attach a shadow to the bars"] = true
	
	L["Show Legoblock"] = true
	L["Give a textbox with xp/rep details"] = true

	L["XP Spark Intensity"] = true
	L["How strong the XP spark is"] = true
	L["Reputation Spark Intensity"] = true
	L["How strong the Reputation spark is"] = true

	L["Bar Thickness"] = true
	L["How thick the bars are"] = true
	
	L["Hide Bars"] = true
	L["Hide the bars til you mouseover them"] = true
	L["Show Tooltip"] = true
	L["Show a tooltip with the XP/Rep info when moused over"] = true

	L["Attachment Method"] = true
	L["Frame Link"] = true
	L["Hook to frame"] = true
	L["Click here to activate the frame selector"] = true
	L["Frame Connected to"] = true
	L["The name of the frame to connect to"] = true
	L["Cannot find frame specified"] = true
	L["Attach to:"] = true
	L["Which side to attach to"] = true
	L["Top"] = true
	L["Bottom"] = true
	L["Left"] = true
	L["Right"] = true
	L["Inside Frame?"] = true
	L["Attach to the inside of the frame"] = true
	L["X offset"] = true
	L["How far on the X axis to offset the bars"] = true
	L["Y offset"] = true
	L["How far on the Y axis to offset the bars"] = true

	L["Colours"] = true
	L["Colours of the bars"] = true
	L["Experience Bar"] = true
	L["Colour of the full XP bar"] = true
	L["Empty Experience Bar"] = true
	L["Colour of the empty XP bar"] = true
	L["Rested Bar"] = true
	L["Colour of the Rested XP bar"] = true
	L["Reputation Bar"] = true
	L["Colour of the full Reputation bar"] = true
	L["Empty Reputation Bar"] = true
	L["Colour of the empty Reputation bar"] = true

	L["Factions"] = true
	L["Faction Selected"] = true
	L["List of Factions to watch"] = true

	L["xp to go"] = true
	L[" rep to go - "] = true

	L["Documentation"] = true
	L["Description"] = true
	L["About"] = true
	L["FAQ"] = true
	L["DESCRIPTION"] =
[[ Xparky is a xp/rep bar that is designed to be a replacement for FuXPFu, a bar that previously attached to the FuBar. 

Xparky has been rewritten to allow for a more dynamic assignment of bar locations, permitting the user to attach the bars to any side of any named frame on the screen. Xparky bars can also be placed inside a specified frame to allow for setups that include attaching to the inside edge of the WorldFrame for the minimalist approach.  ]] 
	L["FAQ_TEXT"] = 
[[
Xparky is fairly simple to set up and run. When you start it, it will create a LegoBlock with the xp bar attached to the bottom. 

To change the frame the bars are connected to select: Bars->Frame Link in the Xparky config window.

You can then either type in the frame name or use the button to activate the mouse selector and select your frame by clicking on it with the active cursor.

Set the side you wish the bars to be on as well as if you want the bars on the inside or outside of the frame.

Bar colours can be selected in Bars->Colours and the appropriate settings therein.

You can hide or show the various screen aspects in the first Buttons panel.
]]
	L["ADDON_INFO"] =
[[
Name: Xparky
Version: 1.1
Author: Wobin
Props: Bant, for the original textures and concept
]]

end
