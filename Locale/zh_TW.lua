local L = LibStub("AceLocale-3.0"):NewLocale("Xparky", "zhTW")

if L then
	L["This frame has no global name, and cannot be added via the mouse"] = "這個表單沒有全局名稱，並且不能通過滑鼠增加。"
	L["Bars"] = "經驗/聲望條"
	L["Bar Modifications"] = "自定義經驗/聲望條"

	L["Show XP Bar"] = "顯示經驗條"
	L["Whether to show the XP bar or not"] = "選擇是否顯示經驗條。"

	L["Show Reputation Bar"] = "顯示聲望條"
	L["Whether to show the Reputation bar or not"] = "選擇是否顯示聲望條。"

	L["Show Shadow"] = "顯示陰影"
	L["Attach a shadow to the bars"] = "選擇是否在條下顯示陰影(更具立體感)"
	
	L["Show Legoblock"] = "顯示詳情版"
	L["Give a textbox with xp/rep details"] = "選擇是否顯示一個文本框，在裏面顯示經驗/聲望詳情。"
	
	L["XP/Rep to go"] = "經驗/聲望剩餘"
	L["Show the amount present or the amount to go"] = "選擇是顯示還有多少升到下一級別還是當前級別已經獲取的經驗/聲望。"

	L["XP Spark Intensity"] = "經驗條亮度"
	L["How strong the XP spark is"] = "選擇你希望的經驗條的亮度。"
	L["Reputation Spark Intensity"] = "聲望條亮度"
	L["How strong the Reputation spark is"] = "選擇你希望的聲望條的亮度。"

	L["Bar Thickness"] = "經驗/聲望條寬度"
	L["How thick the bars are"] = "選擇你希望經驗/聲望條有多寬。"
	
	L["Hide Bars"] = "自動隱藏"
	L["Hide the bars til you mouseover them"] = "自動隱藏條，直到你的滑鼠懸停在條上面。"
	L["Show Tooltip"] = "顯示提示"
	L["Show a tooltip with the XP/Rep info when moused over"] = "當滑鼠指向經驗/聲望條的時候顯示提示資訊。"

	L["Attachment Method"] = "吸附模式"
	L["Frame Link"] = "表單鏈結"
	L["Hook to frame"] = "掛鈎於表單"
	L["Click here to activate the frame selector"] = "點擊此處啟動表單選擇器。"
	L["Frame Connected to"] = "表單吸附於"
	L["The name of the frame to connect to"] = "吸附表單的名稱"
	L["Cannot find frame specified"] = "指定表單不存在！"
	L["Attach to:"] = "吸附於："
	L["Which side to attach to"] = "吸附位置"
	L["Top"] = "上"
	L["Bottom"] = "下"
	L["Left"] = "左"
	L["Right"] = "右"
	L["Inside Frame?"] = "表單內？"
	L["Attach to the inside of the frame"] = "吸附於表單內部。"
	L["Bar Strata"] = "經驗/聲望條層級"
	L["Set the Bar Strata so it appears above or below other frames"] = "設置經驗/聲望條的層級，以使其在其他表單的上面或者下面。"
	L["X offset"] = "X方向位移"
	L["How far on the X axis to offset the bars"] = "你想要經驗/聲望條在X方向上的位移(基於定位點)"
	L["Y offset"] = "Y方向位移"
	L["How far on the Y axis to offset the bars"] = "你想要經驗/聲望條在Y方向上的位移(基於定位點)"

	L["Colours"] = "顏色"
	L["Colours of the bars"] = "經驗/聲望條的顏色。"
	L["Experience Bar"] = "經驗條"
	L["Colour of the full XP bar"] = "已獲取的經驗的經驗條顏色。"
	L["Empty Experience Bar"] = "空經驗條"
	L["Colour of the empty XP bar"] = "未獲取的經驗的經驗條顏色。"
	L["Rested Bar"] = "休息條"
	L["Colour of the Rested XP bar"] = "雙倍經驗的經驗條顏色。"
	L["Reputation Bar"] = "聲望條"
	L["Colour of the full Reputation bar"] = "已獲取的聲望的聲望條顏色。"
	L["Empty Reputation Bar"] = "空聲望條"
	L["Colour of the empty Reputation bar"] = "未獲取的聲望的聲望條顏色。"

	L["Factions"] = "陣營"
	L["Faction Selected"] = "陣營選擇"
	L["List of Factions to watch"] = "選擇你想監視的陣營聲望。"

	L[" xp to go"] = "尚需經驗"
	L[" rep to go - "] = "尚需聲望 - "

	L["Documentation"] = "說明"
	L["Description"] = "描述"
	L["About"] = "關於"
	L["FAQ"] = "常見問題"
	L["DESCRIPTION"] =
[[ Xparky是一個為替代FuXPFu而設計的經驗/聲望條插件，而且一樣提供對Fubar的吸附。

Xparky已經為提供更多的位置進行了重新編寫，它允許使用者對經驗/聲望條進行多種多樣的設置。Xparky也允許你把經驗/聲望條鑲入某些特性的表單內，你甚至可以鑲入WorldFrame裏面！]] 
	L["FAQ_TEXT"] = 
[[
Xparky非常易於設置和運行，當你啟用後，他將會在螢幕下方創建一個經驗條，並附贈一個顯示面板。

你如果想更換經驗/聲望條所吸附的表單，你可以在Xparky的配置視窗中選擇：經驗/聲望條 -> 表單連接。

接下來你可以鍵入表單名或者使用按鈕來啟動表單滑鼠選擇器選擇你需要的表單，只需滑鼠輕輕一點即可。

設置你想要經驗/聲望條依附於表單哪一側，或者你想要其依附於表單外還是表單內。

經驗/聲望條的顏色可以通過經驗/聲望條 -> 顏色來打開相關設置。

你也可以在第一個按鈕面板中選擇相關的顯示特性。
]]
	L["ADDON_INFO"] =
[[
插件名: Xparky
版本: 1.1
作者: Wobin
特別感謝: Bant, 提供原始素材和幫助
簡體中文本地化: 阿依納伐@二區 泰蘭德
]]

end
