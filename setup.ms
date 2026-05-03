VERSION = "20260429"
//------------------------------------------------------------------------------
//- ↓ 設定 ここから -----------------------------------------------------------

//-------------------
// 1.インストール先
//-------------------
// 1.1.フォルダ名
InstName = "setup-sample"

//-------------------
// 2.ショートカット
//-------------------
// 2.1.表示名
ShortcutName = "セットアップ・サンプル"

// 2.2.[ショートカット名. 実行ファイル, アイコン]
//   注意：二次配列 [] 最後の "," は必須!!
ShortcutItem = [
	["01アプリケーション", "c:\windows\system32\notepad.exe", "c:\windows\system32\SHELL32.dll, 24"],
	["02テキスト", "sample.txt", "sample.ico"],
	["03あああ", "sample.txt"],
]
//- ↑ 設定 ここまで -----------------------------------------------------------
//------------------------------------------------------------------------------

// 初期設定
//   実ファイルの格納先を %LOCALAPPDATA% に設定しています。
//   "C:\Program Files\" などを要求するなら、別のセキュリティ対応インストーラーを使用することをお勧めします。
InstDir      = env.LOCALAPPDATA + "\" + InstName
ShortcutDir  = env.APPDATA + "\Microsoft\Windows\Start Menu\Programs\" + ShortcutName
SetupFileDir = ".\setup-files"

// 関数
ESC = char(27) + "["

E1 = function(esc = "0m", text = "")
	if text then
		text = text + ESC + "0m"
	end if
	print (ESC + esc + text), ""
end function

E2 = function(esc = "0m", text = "")
	E1(esc, text)
	print
end function

CLEAR = function()
	// print (ESC + "2J" + ESC + "H"), ""
	exec("PowerShell -Command ""Clear-Host""")
end function

P1 = function(text = "")
	print text, ""
end function

P2 = function(text = "")
	print text
end function

//-------------
// 前処理開始
//-------------
CLEAR

E1("97;44m", " セットアップ ")
E2("34;47m", " " + ShortcutName + " ")
P2

// ファイル存在チェック
errorCnt = 0
for i1 in ShortcutItem.indexes
	if ShortcutItem[i1].len < 2 then
		E1("91m", "NG ")
		P1(ShortcutItem[i1][0] + " ")
		E2("95m", "No file name!")
		errorCnt = errorCnt + 1
	else
		if not file.exists(ShortcutItem[i1][1]) then
			fn = SetupFileDir + "\" + ShortcutItem[i1][1]
			if not file.exists(fn) then
				E1("91m", "NG ")
				P1(ShortcutItem[i1][0] + " ")
				E2("95m", ShortcutItem[i1][1] + "?")
				errorCnt = errorCnt + 1
			end if
		end if
	end if
end for

// 中止
if errorCnt > 0 then
	P2
	E1("95m", "2.2.ShortcutItem")
	E2("37m", " を見直してください")
	exit
end if

// 続行
E2("93m", "1.インストール場所")
E2("37m", "    " + InstDir)
P2
E2("93m", "2.1.ショートカット場所")
E2("37m", "    " + ShortcutDir)
P2
E2("93m", "2.2.ショートカット・アイテム")
E2("95m", "    ショートカット名")
E2("96m", "    実行ファイル")
E2("92m", "    アイコンファイル")

for i1 in ShortcutItem.indexes
	P2
	E2("95m", "    " + ShortcutItem[i1][0])
	E2("96m", "    " + ShortcutItem[i1][1])
	if ShortcutItem[i1].len > 2 then
		E2("92m", "    " + ShortcutItem[i1][2])
	end if
end for

// 注意
if file.exists(InstDir) and file.info(InstDir).isDirectory then
	P2
	E2("91m", "注意：")
	E2("96m", "    " + InstDir)
	P2 "    が既に存在します。"
	P2 "    必要に応じて、バックアップしてください。"
	E2("91m", "    同名ファイルは上書きされます。")
end if

//-------------------
// インストール開始
//-------------------
P2
E1("93m", "インストールしますか? [Y/n] ")
	inputStr = input
	P2
	if inputStr != "y" and inputStr != "Y" then
		P2 "中止しました"
		exit
	end if

P2 "インストール中..."

// インストールフォルダへコピー
file.makedir InstDir
	src  = SetupFileDir + "\*"
	dest = InstDir
exec("PowerShell -Command ""Copy-Item -Path '" + src + "' -Destination '" + dest + "' -Recurse -Force""")

//---------------------
// ショートカット作成
//---------------------
file.makedir ShortcutDir

for i1 in ShortcutItem.indexes
	shortcutPath = ShortcutDir + "\" + ShortcutItem[i1][0] + ".lnk"

	targetPath = ShortcutItem[i1][1]
		if not file.exists(targetPath) then
			targetPath = InstDir + "\" + targetPath
		end if

	iconPath = ""
		if ShortcutItem[i1].len > 2 then
			fn = ShortcutItem[i1][2].split(",")[0]
			if file.exists(fn) then
				iconPath = ShortcutItem[i1][2]
			else
				iconPath = InstDir + "\" + ShortcutItem[i1][2]
			end if
		end if

	psCommand = "" +
		"$s = New-Object -ComObject WScript.Shell; " +
		"$lnk = $s.CreateShortcut('" + shortcutPath + "'); " +
		"$lnk.TargetPath = '" + targetPath + "'; " +
		"$lnk.IconLocation = '" + iconPath + "'; " +
		"$lnk.Save()"

	exec("PowerShell -Command """ + psCommand + """")
end for

//-------------------------------
// アンインストールファイル作成
//-------------------------------
// 01.bat
UnistallFn01 = "unistall-" + InstName + "_01.bat"
	UninstallBatch01 = [
		"@echo off",
		"echo [" + ShortcutName + "]",
		"echo.",
		"echo - " + InstDir,
		"echo - " + ShortcutDir,
		"echo.",
		"set /p input=""アンインストールしますか? [Y/n] """,
		"if /i not ""%input%"" == ""Y"" (",
		"  echo 中止します...",
		"  sleep 2",
		"  exit /b",
		")",
		"echo アンインストール開始...",
		"rmdir /S /Q """ + InstDir + """",
		"rmdir /S /Q """ + ShortcutDir + """",
		"echo 終了",
		"sleep 2",
		"del ""%~f0%""",
	]

	file.writeLines(UnistallFn01, UninstallBatch01)

	exec("PowerShell -Command ""Move-Item -Path " + UnistallFn01 + " " + InstDir + """ -Force")

// 00.bat
UnistallFn00 = "unistall-" + InstName + ".bat"
	UninstallBatch00 = [
		"@echo off",
		"copy """ + InstDir + "\" + UnistallFn01 + """ ""%TEMP%""",
		"cd ""%TEMP%""",
		"cls",
		UnistallFn01,
	]

	file.writeLines(UnistallFn00, UninstallBatch00)

	exec("PowerShell -Command ""Move-Item -Path " + UnistallFn00 + " " + InstDir + """ -Force")

	shortcutPath = ShortcutDir + "\99アンインストール.lnk"

	targetPath = InstDir + "\" + UnistallFn00
		psCommand = "" +
			"$s = New-Object -ComObject WScript.Shell; " +
			"$lnk = $s.CreateShortcut('" + shortcutPath + "'); " +
			"$lnk.TargetPath = '" + targetPath + "'; " +
			"$lnk.Save()"
		exec("PowerShell -Command """ + psCommand + """")

//-------
// 終了
//-------
P2 "インストール完了"
