#include <AutoItConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

; iniファイルのセクション名とキー名
Local Const $sIniFileName = "config.ini"
Local Const $sIniSectionAssistantSeika = "AssistantSeika"
Local Const $sIniKeySeikaSay2Path = "SeikaSay2Path"
Local Const $sIniKeyCid = "cid"
Local Const $sIniSectionWindow = "Window"
Local Const $sIniKeyTitle = "title"
Local Const $sIniKeyMouseClickDragX1 = "MouseClickDragX1"
Local Const $sIniKeyMouseClickDragY1 = "MouseClickDragY1"
Local Const $sIniKeyMouseClickDragX2 = "MouseClickDragX2"
Local Const $sIniKeyMouseClickDragY2 = "MouseClickDragY2"


_Main()
Exit

Func _Main()
	; 変愚蛮怒
	Local $nWindowState
	Local $posWindow
	; Local $nWindowShadowWidth = 8
	; Local $nTitleBarHeight = 23
	; Local $nMenuBarHeight = 20
	; Local $nCharWidth = 8
	; Local $nCharHeight = 16
	Local $nLineX1
	Local $nLineY1
	Local $nLineX2
	Local $nLineY2
	Local $sText
	Local $sLastText = ""
	Local $posMouse

	; 設定ファイル読込
	IniReadSectionNames($sIniFileName)
	If @error Then
		_AbnormalEnd($sIniFileName & " ファイルが見つかりませんでした。終了します。")
	EndIf
	
	; 設定ファイル読込：SeikaSay2
	Local $sSeikaSay2Path = _IniRead($sIniSectionAssistantSeika, $sIniKeySeikaSay2Path)
	Local $sCid = _IniRead($sIniSectionAssistantSeika, $sIniKeyCid)
	Local $sSeikaSay2Command

	; 設定ファイル読込：1行目の相対座標
	Local $nMouseClickDragX1 = Number(_IniRead($sIniSectionWindow, $sIniKeyMouseClickDragX1))
	Local $nMouseClickDragY1 = Number(_IniRead($sIniSectionWindow, $sIniKeyMouseClickDragY1))
	Local $nMouseClickDragX2 = Number(_IniRead($sIniSectionWindow, $sIniKeyMouseClickDragX2))
	Local $nMouseClickDragY2 = Number(_IniRead($sIniSectionWindow, $sIniKeyMouseClickDragY2))

    ; 変愚蛮怒のウィンドウハンドラを取得、見つからなかったら終了
	Local $sWindowTitle = _IniRead($sIniSectionWindow, $sIniKeyTitle)
    $hWindow = WinGetHandle($sWindowTitle)
	if @error Then
		_AbnormalEnd("変愚蛮怒のウィンドウが見つかりませんでした。\r\n終了します。")
	EndIf
	WinWaitActive($hWindow)	; 変愚蛮怒のウィンドウをアクティブ化を待つ

	; ログファイルを開く（デバッグ用なんでそのうち消すかも）
	Local $fLog = FileOpen("log.txt", $FO_OVERWRITE + $FO_UTF8)

	; メインループ
	While True
		; ウィンドウの状態取得
		$nWindowState = WinGetState($hWindow)
		; ウィンドウが存在しなければループを抜ける
		If @error Then
			ExitLoop
		EndIf
		; ウィンドウが存在しない、不可視である、操作不可である、非アクティブである、最小化されている、のいずれかに合致したら空振りする
		If BitAND($nWindowState, 15) <> 15 Or BitAND($nWindowState, 32) == 32 Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; 1行目の矩形の座標を決定
		$posWindow = WinGetPos($hWindow)
		$nLineX1 = $posWindow[0] + $nMouseClickDragX1
		$nLineY1 = $posWindow[1] + $nMouseClickDragY1
		$nLineX2 = $posWindow[0] + $posWindow[2] - $nMouseClickDragX2
		$nLineY2 = $posWindow[1] + $nMouseClickDragY2

		; 1行目の文字列を取得
		$posMouse = MouseGetPos()
		MouseClickDrag($MOUSE_CLICK_PRIMARY, $nLineX1, $nLineY1, $nLineX2, $nLineY2, 0)
		MouseMove($posMouse[0], $posMouse[1], 0)
		$sText = ClipGet()
		$sText = StringStripWS($sText, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
		FileWriteLine($fLog, $sText)

		; 発話に不適な部分を削除する
		$sText = _ModiryText($sText)
		FileWriteLine($fLog, $sText)

		; 発話に不適な文字列ならば空振りする
		If Not _IsSpeakText($sText) Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; -続く- みたいな文字列を削除する
		$sText = _DeleteMoreFromText($sText)
		FileWriteLine($fLog, $sText)

		; 前回取得した文字列と同じなら空振りする
		If $sText == $sLastText Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; 発話
		FileWriteLine($fLog, $sText)
		$sLastText = $sText
		$sSeikaSay2Command = @ComSpec & " /c " & """" & $sSeikaSay2Path & """ -cid " & $sCid & " -t " & $sText
		RunWait($sSeikaSay2Command, "", @SW_HIDE)

	WEnd

	FileClose($fLog)

EndFunc   ;==>_Main

Func _IsSpeakText($sText)	; 発話すべき文字列か否かを返す
	If StringRegExp($sText, "-続く-$") Or StringRegExp($sText, "-more-$") Or StringRegExp($sText, "。$") Or StringRegExp($sText, "\.$") Or StringRegExp($sText, "！$") Or StringRegExp($sText, "!$") Then
		Return True
	EndIf

	Return False
	
EndFunc   ;==>_IsSpeakText

Func _DeleteMoreFromText($sText)
	; 「-続く-」を削除
	$sText = StringRegExpReplace($sText, "-続く-$", "")
	$sText = StringRegExpReplace($sText, "-more-$", "")

	Return $sText
EndFunc   ;==>_DeleteMoreFromText

Func _ModiryText($sText)	; 文字列から発話に不適な部分を削除する
	; エゴの括弧を削除
	$sText = StringReplace($sText, "(聖戦者)", " 聖戦者 ")
	$sText = StringReplace($sText, "(防衛者)", " 防衛者 ")
	$sText = StringReplace($sText, "(祝福)", " 祝福 ")
	$sText = StringReplace($sText, "(混沌)", " 混沌 ")
	$sText = StringReplace($sText, "(吸血)", " 吸血 ")
	$sText = StringReplace($sText, "(トランプ)", " トランプ ")
	$sText = StringReplace($sText, "(パターン)", " パターン ")
	$sText = StringReplace($sText, "(悪魔)", " 悪魔 ")
	$sText = StringReplace($sText, "(妖刀)", " 妖刀 ")
	$sText = StringReplace($sText, "(貪食)", " 貪食 ")
	$sText = StringReplace($sText, "(復讐者)", " 復讐者 ")

	; 括弧を中身ごと削除
	$sText = StringRegExpReplace($sText, "\(.*?\)", "")
	$sText = StringRegExpReplace($sText, "\[.*?\]", "")
	$sText = StringRegExpReplace($sText, "\{.*?\}", "")

	; 不要な文字を削除
	$sText = StringReplace($sText, "*", "")
	$sText = StringReplace($sText, ":", "")
	$sText = StringReplace($sText, "ESC", "")

	; 不要な空白を削除
	$sText = StringStripWS($sText, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Return $sText

EndFunc   ;==>_ModiryText

Func _AbnormalEnd($sMessage)	; メッセージダイアログを表示して終了する
	MsgBox(16, Default, $sMessage)
	Exit
EndFunc   ;==>_AbnormalEnd

Func _IniRead($sIniSection, $sIniKey)
	Local $sValue = IniRead($sIniFileName, $sIniSection, $sIniKey, "")
	If $sValue == "" Then
		_AbnormalEnd($sIniFileName & " ファイルのセクション " & $sIniSection & " のキー " & $sIniKey & "が見つかりませんでした。終了します。")
	EndIf
	return $sValue
EndFunc   ;==>_IniRead