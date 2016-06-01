#!/bin/sh

#共通関数読み込み
. ./function/COMMON.fnc
. ./function/CONST.fnc

#スキーマ丸ごとでのエクスポート実行関数
function schema_exp()
{
        echo "【エクスポート実施】"
        #スキーマ名セット
        schema_select "エクスポート先のスキーマを選択して下さい。"

        echo -e "SUFFIXをセットして下さい。ex:テーブル取得の場合⇒TB スキーマ全て取得の場合⇒ALL等"
        read SUFFIX

        echo -e "以下のexpdpコマンドを実行しますが、よろしいですか？\n【コマンド】：$ORACLE_HOME/bin/expdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$SETDATE"_"$SCHEMANAME"_"$SUFFIX"_%U.dmp filesize=1G logfile="$SETDATE"_"$SCHEMANAME"_"$SUFFIX"_EXPDB.log COMPRESSION=ALL \nよろしければENTERを押下して下さい。キャンセルする場合はCtrl+Cを押下して下さい。"
        read

        #コマンド実行
        $ORACLE_HOME/bin/expdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$SETDATE"_"$SCHEMANAME"_"$SUFFIX"_%U.dmp filesize=1G logfile="$SETDATE"_"$SCHEMANAME"_"$SUFFIX"_EXPDB.log COMPRESSION=ALL
}

#スキーマ丸ごとでのインポート実行関数
function schema_imp()
{
        echo "【インポート実施】"
        BEFORESCHEMA="$SCHEMANAME"
        schema_select "インポート先のスキーマを選択して下さい。"

        echo -e "remap_schemaが必要ですか？ Yor入力なし"
        read RESULT

        if [ "$RESULT" = "Y" ]; then
                echo -e "元となるスキーマを指定して下さい。\n(指定がなければエクスポートした"$BEFORESCHEMA"スキーマが設定されます。)"
                read BEFOREREMAPSCHEMA
                if [ -z "$BEFOREREMAPSCHEMA" ]; then
                        BEFOREREMAPSCHEMA="$BEFORESCHEMA"
                fi

                OPTIONS="remap_schema=$BEFOREREMAPSCHEMA:$SCHEMANAME"
        else
                echo "オプションなし"
        fi

        #インポートするファイル名を指定
        echo -e "インポートするdmpファイル名を指定して下さい。ex:20160303_MBCG01_ALL_%U.dmp \n(指定がない場合は、先ほどエクスポートした"$SETDATE"_"$BEFORESCHEMA"_"$SUFFIX"_%U.dmpファイルをインポートします。)"
        read FILENAME

        if [ -z "$FILENAME" ]; then
                FILENAME="$SETDATE"_"$BEFORESCHEMA"_"$SUFFIX"_%U.dmp
        fi

        echo -e "$SCHEMANAME/$SCHEMANAME@$LOGINSERVERの全てのオブジェクトをDropするスクリプトが流れますが、よろしいですか？\nよろしければENTERをキャンセルする場合はCtrl+Cを押下して下さい。"
        read

        #ドロップ実行
        schema_all_drop_object $SCHEMANAME $LOGINSERVER

        echo -e "以下のimpdpコマンドを実行しますが、よろしいですか？\nインポートコマンド：$ORACLE_HOME/bin/impdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$FILENAME" "$OPTIONS"\nよろしければENTERを押下して下さい。キャンセルする場合はCtrl+Cを押下して下さい。"
        read

        $ORACLE_HOME/bin/impdp "$SCHEMANAME"/"$SCHEMANAME"@"$LOGINSERVER" DIRECTORY="$DIRRECTORYOBJECT" DUMPFILE="$FILENAME" "$OPTIONS"

        #Invalidオブジェクトの件数カウント
        RET=`Invalid_object_count $SCHEMANAME $LOGINSERVER`

        if [ $RET -ne 0 ]; then
                Invalid_object_replace $SCHEMANAME $LOGINSERVER
        fi

        echo "【完了】"
}
