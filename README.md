# 1.このプログラムについて

## 1.1.バッチ型の簡易なWindows用インストーラです。
* インストール／アンインストール共、開始時のみの確認 [Y/n] のみで実行します。
* 必要に応じて、スクリプトを書き換えてください。

## 1.2.ユーザー権限のインストール作業に特化しています。  
* `C:\Program Files`等、**セキュリティが厳格なフォルダへのインストール作業は想定していません。**

## 1.3.MiniScript（miniscript.exe）を使用します。
* 最新版は以下から入手してください。
    * https://miniscript.org/files/miniscript-win.zip
* 公式サイトなど
    * [HP](https://miniscript.org/)
    * [Quick Reference](https://miniscript.org/files/MiniScript-QuickRef.pdf)
    * [User's Manual](https://miniscript.org/files/MiniScript-Manual.pdf)

# 2.説明

## 2.1.設定ファイル
* `setup.ms`上部の「設定 ここから...ここまで」をテキストエディタで修正してください。

## 2.2.インストールするファイル
* インストールするファイル／フォルダは、`setup-files`フォルダへ格納してください。
* 2.1.設定ファイルの設定有無にかかわらず、インストール・フォルダへ全コピーされます。

## 2.3.インストール実行
* `setup.bat`を実行してください。

## 2.4.注意
* インストール／アンインストール共、既存のファイル／フォルダを、上書き／一括削除（ゴミ箱に移動しない）します。
* **ユーザー自身の責任で、必要に応じてバックアップしてください。**
