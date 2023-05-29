#include <AutoItConstants.au3>
#include <Constants.au3>
#include <MsgBoxConstants.au3>
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
	Local $nFirstLineX1
	Local $nFirstLineY1
	Local $nFirstLineX2
	Local $nFirstLineY2
	Local $sFirstLine
	Local $sLastFirstLine = ""

	; SeikaSay2
	Local $sSeikaSay2Path = "C:\\Program Files\\510Product\\SeikaSay2\\SeikaSay2.exe"
	Local $nCid = 1707

	; 1行目の矩形の座標

    ; 変愚蛮怒のウィンドウハンドラを取得
    $hWindow = WinGetHandle("[CLASS:ANGBAND]")
	if @error Then
		MsgBox(0, "", "変愚蛮怒のウィンドウが見つかりませんでした。\r\n終了します。")
		Return
	EndIf
	WinWaitActive($hWindow)
	; メインループ
	While True
		ConsoleWrite("メインループ")
		$nWindowState = WinGetState($hWindow)
		ConsoleWrite($nWindowState)

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
		$nFirstLineX1 = $posWindow[0] + $nWindowShadowWidth + $nCharWidth / 2
		$nFirstLineY1 = $posWindow[1] + $nWindowShadowWidth + $nTitleBarHeight + $nMenuBarHeight + $nCharHeight / 2
		$nFirstLineX2 = $posWindow[0] + $posWindow[2] - $nWindowShadowWidth * 2 - $nCharWidth / 2
		$nFirstLineY2 = $posWindow[1] + $nWindowShadowWidth + $nTitleBarHeight + $nMenuBarHeight + $nCharHeight / 2

		; 1行目の文字列を取得
		MouseClickDrag($MOUSE_CLICK_LEFT, $nFirstLineX1, $nFirstLineY1, $nFirstLineX2, $nFirstLineY2, 0)
		$sFirstLine = ClipGet()

		; 前回取得した文字列と同じなら空振りする
		If $sFirstLine == $sLastFirstLine Then
			Sleep(1000)
			ContinueLoop
		EndIf

		; 発話除外チェック（未実装）

		; 発話
		RunWait($sSeikaSay2Path & " -cid " & $nCid & " """ & $sFirstLine & """")
		;MsgBox(0, "", $sFirstLine)

	WEnd
EndFunc   ;==>_Example
