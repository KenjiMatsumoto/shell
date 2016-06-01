#!/bin/sh

#共通関数読み込み
. ./function/COMMON.fnc
. ./function/CONST.fnc

echo "【hogedmpのインポート実施】"

#スキーマ名セット
SCHEMANAME="hoge1"

#ドロップ実行
echo -e "hoge2のテーブル削除スクリプトが流れますがよろしいですか？\n※"$SCHEMANAME"に腹もちしているhoge2テーブルの削除スクリプト実施"
read

drop_object_item $SCHEMANAME $LOGINSERVER

#インポートするファイル名を指定
echo -e "インポートするdmpファイル名を指定して下さい。"
read FILENAME

#契ガイダンスマスタのテーブル名変更実施(一時的にTB_MST_GUIDANCE_WKへ変更)
table_rename $SCHEMANAME $LOGINSERVER

echo -e "以下のimpdpコマンドを実行しますが、よろしいですか？\nインポートコマンド：$ORACLE_HOME/bin/impdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$FILENAME" remap_schema=hoge:"$SCHEMANAME"\nよろしければENTERを押下して下さい。キャンセルする場合はCtrl+Cを押下して下さい。"
read

$ORACLE_HOME/bin/impdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$FILENAME" remap_schema=IZIZ01:"$SCHEMANAME"

echo -e "hogeMasterのテーブル名リプレイス(hogehugaへ)\n hogehugagaのテーブル名戻しを実施しますがよろしいですか？\nよろしければENTERを押下して下さい。キャンセルする場合はCtrl+Cを押下して下さい。"
read

#インポート完了後、礎ガイダンスマスタのテーブル名リプレイス(TB_MST_GUIDANCE_ISZへ)＆契ガイダンスマスタのテーブル名戻し(TB_MST_GUIDANCE_WKをTB_MST_GUIDANCEへ)を実施
table_rename $SCHEMANAME $LOGINSERVER

#全てのスキーマをhogeで腹もちしている特定テーブルを参照するように変更
for schema in ${SCHEMALIST[@]};
do

        #参照権限を付与
        reference_authority $SCHEMANAME $LOGINSERVER $schema

        for viewName in ${VIEWLIST[@]};
        do
                SQLFILENAME=$schema"_"$viewName"_REPLACE.sql"
                SQLCOMFILENAME=$schema"_"$viewName"_COMMENT.sql"

                #ViewのDDL出力
                make_view_ddl $schema $LOGINSERVER $SQLFILENAME $viewName

                #ViewのコメントDDL出力
                make_view_comment_ddl $schema $LOGINSERVER $SQLCOMFILENAME $viewName

                #Viewの内容書き換え 文字列置き換え処理　例：hoge→fuga
                sed -i -e "s/hoge/fuga/g" $SQLFILENAME
                sed -i -e "s/tbl_hogehoge/tbl_fugafuga/g" $SQLFILENAME

                #Viewの置き換え実行
                excute_sql_file $schema $LOGINSERVER $SQLFILENAME
                #Viewのコメント付与
                excute_sql_file $schema $LOGINSERVER $SQLCOMFILENAME

                #出力SQLファイルの削除
                rm -f $SQLFILENAME
        done

        #Invalidオブジェクトをリコンパイル実施
        Invalid_object_replace $schema $LOGINSERVER
done

echo "【一時置き換え完了】"
