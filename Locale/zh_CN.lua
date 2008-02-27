local L = LibStub("AceLocale-3.0"):NewLocale("Xparky", "zhCN")

if L then
	L["This frame has no global name, and cannot be added via the mouse"] = "这个窗体没有全局名称，并且不能通过鼠标增加。"
	L["Bars"] = "经验/声望条"
	L["Bar Modifications"] = "自定义经验/声望条"

	L["Show XP Bar"] = "显示经验条"
	L["Whether to show the XP bar or not"] = "选择是否显示经验条。"

	L["Show Reputation Bar"] = "显示声望条"
	L["Whether to show the Reputation bar or not"] = "选择是否显示声望条。"

	L["Show Shadow"] = "显示阴影"
	L["Attach a shadow to the bars"] = "选择是否在条下显示阴影(更具立体感)"
	
	L["Show Legoblock"] = "显示详情版"
	L["Give a textbox with xp/rep details"] = "选择是否显示一个文本框，在里面显示经验/声望详情。"
	
	L["XP/Rep to go"] = "经验/声望剩余"
	L["Show the amount present or the amount to go"] = "选择是显示还有多少升到下一级别还是当前级别已经获取的经验/声望。"

	L["XP Spark Intensity"] = "经验条亮度"
	L["How strong the XP spark is"] = "选择你希望的经验条的亮度。"
	L["Reputation Spark Intensity"] = "声望条亮度"
	L["How strong the Reputation spark is"] = "选择你希望的声望条的亮度。"

	L["Bar Thickness"] = "经验/声望条宽度"
	L["How thick the bars are"] = "选择你希望经验/声望条有多宽。"
	
	L["Hide Bars"] = "自动隐藏"
	L["Hide the bars til you mouseover them"] = "自动隐藏条，直到你的鼠标悬停在条上面。"
	L["Show Tooltip"] = "显示提示"
	L["Show a tooltip with the XP/Rep info when moused over"] = "当鼠标指向经验/声望条的时候显示提示信息。"

	L["Attachment Method"] = "吸附模式"
	L["Frame Link"] = "窗体链接"
	L["Hook to frame"] = "挂钩于窗体"
	L["Click here to activate the frame selector"] = "点击此处激活窗体选择器。"
	L["Frame Connected to"] = "窗体吸附于"
	L["The name of the frame to connect to"] = "吸附窗体的名称"
	L["Cannot find frame specified"] = "指定窗体不存在！"
	L["Attach to:"] = "吸附于："
	L["Which side to attach to"] = "吸附位置"
	L["Top"] = "上"
	L["Bottom"] = "下"
	L["Left"] = "左"
	L["Right"] = "右"
	L["Inside Frame?"] = "窗体内？"
	L["Attach to the inside of the frame"] = "吸附于窗体内部。"
	L["Bar Strata"] = "经验/声望条层级"
	L["Set the Bar Strata so it appears above or below other frames"] = "设置经验/声望条的层级，以使其在其他窗体的上面或者下面。"
	L["X offset"] = "X方向位移"
	L["How far on the X axis to offset the bars"] = "你想要经验/声望条在X方向上的位移(基于定位点)"
	L["Y offset"] = "Y方向位移"
	L["How far on the Y axis to offset the bars"] = "你想要经验/声望条在Y方向上的位移(基于定位点)"

	L["Colours"] = "颜色"
	L["Colours of the bars"] = "经验/声望条的颜色。"
	L["Experience Bar"] = "经验条"
	L["Colour of the full XP bar"] = "已获取的经验的经验条颜色。"
	L["Empty Experience Bar"] = "空经验条"
	L["Colour of the empty XP bar"] = "未获取的经验的经验条颜色。"
	L["Rested Bar"] = "休息条"
	L["Colour of the Rested XP bar"] = "双倍经验的经验条颜色。"
	L["Reputation Bar"] = "声望条"
	L["Colour of the full Reputation bar"] = "已获取的声望的声望条颜色。"
	L["Empty Reputation Bar"] = "空声望条"
	L["Colour of the empty Reputation bar"] = "未获取的声望的声望条颜色。"

	L["Factions"] = "阵营"
	L["Faction Selected"] = "阵营选择"
	L["List of Factions to watch"] = "选择你想监视的阵营声望。"

	L["xp to go"] = "尚需经验"
	L[" rep to go - "] = "尚需声望 - "

	L["Documentation"] = "说明"
	L["Description"] = "描述"
	L["About"] = "关于"
	L["FAQ"] = "常见问题"
	L["DESCRIPTION"] =
[[ Xparky是一个为替代FuXPFu而设计的经验/声望条插件，而且一样提供对Fubar的吸附。

Xparky已经为提供更多的位置进行了重新编写，它允许使用者对经验/声望条进行多种多样的设置。Xparky也允许你把经验/声望条镶入某些特性的窗体内，你甚至可以镶入WorldFrame里面！]] 
	L["FAQ_TEXT"] = 
[[
Xparky非常易于设置和运行，当你启用后，他将会在屏幕下方创建一个经验条，并附赠一个显示面板。

你如果想更换经验/声望条所吸附的窗体，你可以在Xparky的配置窗口中选择：经验/声望条 -> 窗体连接。

接下来你可以键入窗体名或者使用按钮来激活窗体鼠标选择器选择你需要的窗体，只需鼠标轻轻一点即可。

设置你想要经验/声望条依附于窗体哪一侧，或者你想要其依附于窗体外还是窗体内。

经验/声望条的颜色可以通过经验/声望条 -> 颜色来打开相关设置。

你也可以在第一个按钮面板中选择相关的显示特性。
]]
	L["ADDON_INFO"] =
[[
插件名: Xparky
版本: 1.1
作者: Wobin
特别感谢: Bant, 提供原始素材和帮助
简体中文本地化: 阿依纳伐@二区 泰兰德
]]

end
