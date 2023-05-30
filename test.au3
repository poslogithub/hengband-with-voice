#include <AutoItConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
;
; AutoIt Version: 3.0
; Language:       English
; Platform:       Win9x/NT
; Author:         Jonathan Bennett (jon at autoitscript dot com)
; Modified:       mLipok, seadoggie01, argumentum
;
; Script Function:
;   Plays with the calculator.
;

_Example()
Exit
; Finished!

Func _Example()
	; 変愚蛮怒
	Local $nWindowState
	Local $posWindow
	Local $nWindowShadowWidth = 8
	Local $nTitleBarHeight = 23
	Local $nMenuBarHeight = 20
	Local $nCharWidth = 8
	Local $nCharHeight = 16
	Local $nLineX1
	Local $nLineY1
	Local $nLineX2
	Local $nLineY2
	Local $sText
	Local $sLastText = ""
	Local $posMouse

	; SeikaSay2
	Local $sSeikaSay2Path = "C:\Program Files\510Product\SeikaSay2\SeikaSay2.exe"
	Local $nCid = 1707
	Local $sSeikaSay2Command

	; デバッグ用
	Local $fLog = FileOpen("log.txt", $FO_OVERWRITE + $FO_UTF8)

    ; 変愚蛮怒のウィンドウハンドラを取得
    $hWindow = WinGetHandle("[CLASS:ANGBAND]")
	if @error Then
		MsgBox(0, "", "変愚蛮怒のウィンドウが見つかりませんでした。\r\n終了します。")
		Return
	EndIf
	WinWaitActive($hWindow)
	; メインループ
	While True
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
		$nLineX1 = $posWindow[0] + $nWindowShadowWidth + $nCharWidth / 2
		$nLineY1 = $posWindow[1] + $nWindowShadowWidth + $nTitleBarHeight + $nMenuBarHeight + $nCharHeight / 2
		$nLineX2 = $posWindow[0] + $posWindow[2] - $nWindowShadowWidth * 2 - $nCharWidth / 2
		$nLineY2 = $posWindow[1] + $nWindowShadowWidth + $nTitleBarHeight + $nMenuBarHeight + $nCharHeight / 2

		; 1行目の文字列を取得
		$posMouse = MouseGetPos()
		MouseClickDrag($MOUSE_CLICK_LEFT, $nLineX1, $nLineY1, $nLineX2, $nLineY2, 0)
		MouseMove($posMouse[0], $posMouse[1], 0)
		$sText = ClipGet()
		$sText = StringStripWS($sText, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
		FileWriteLine($fLog, $sText)

		; 発話に不適な文字列ならば空振りする
		If Not _IsSpeakText($sText) Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; 発話に不適な部分を削除する
		$sText = _ModiryText($sText)

		; 前回取得した文字列と同じなら空振りする
		If $sText == $sLastText Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; 発話
		FileWriteLine($fLog, $sText)
		$sLastText = $sText
		$sSeikaSay2Command = @ComSpec & " /c " & """" & $sSeikaSay2Path & """ -cid " & $nCid & " -t " & $sText
		RunWait($sSeikaSay2Command, "", @SW_HIDE)
		;MsgBox(0, "", $sText)

	WEnd

	FileClose($fLog)

EndFunc   ;==>_Example

Func _IsSpeakText($sText)	; 発話すべき文字列か否かを返す
	If StringRegExp($sText, "-続く-$") Or StringRegExp($sText, "-more-$") Or StringRegExp($sText, "。$") Or StringRegExp($sText, "\\.$") Or StringRegExp($sText, "！$") Or StringRegExp($sText, "!$") Then
		Return True
	EndIf

	Return False
	
EndFunc   ;==>_IsSpeakText

Func _ModiryText($sText)	; 文字列から発話に不適な部分を削除する
	; 「-続く-」を削除
	$sText = StringRegExpReplace($sText, "-続く-$", "")
	$sText = StringRegExpReplace($sText, "-more-$", "")

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
	$sText = StringRegExpReplace($sText, "\\(.*\\)", "")
	$sText = StringRegExpReplace($sText, "\\[.*\\]", "")

	; アスタリスクを削除
	$sText = StringReplace($sText, "*", "")

	; 不要な空白を削除
	$sText = StringStripWS($sText, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Return $sText

EndFunc   ;==>_ModiryText
