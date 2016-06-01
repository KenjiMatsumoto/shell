#!/bin/sh

#共通関数読み込み
. ./function/COMMON.fnc
. ./function/CONST.fnc

echo "【参照への戻しを実施】"

SCHEMANAME="fugafuga"

#全てのスキーマに対してhugaテーブルを参照するように変更
for schema in ${SCHEMALIST[@]};
do
        for viewName in ${VIEWLIST[@]};
        do
                SQLFILENAME=$schema"_"$viewName"_REPLACE.sql"
                SQLCOMFILENAME=$schema"_"$viewName"_COMMENT.sql"

                #ViewのDDL出力
                make_view_ddl $schema $LOGINSERVER $SQLFILENAME $viewName

                #ViewのコメントDDL出力
                make_view_comment_ddl $schema $LOGINSERVER $SQLCOMFILENAME $viewName

                #Viewの内容書き換え
                sed -i -e "3,$ s/MBCG01/IZIZ01/g" $SQLFILENAME
                sed -i -e "s/TB_MST_GUIDANCE_ISZ/TB_MST_GUIDANCE/g" $SQLFILENAME

                #Viewの置き換え実行
                excute_sql_file $schema $LOGINSERVER $SQLFILENAME
                #Viewのコメント付与
                excute_sql_file $schema $LOGINSERVER $SQLCOMFILENAME

                #出力SQLファイルの削除
                rm -f $SQLFILENAME
        done
        #Invalidオブジェクトをリコンパイル実施
        Invalid_object_replace $SCHEMANAME $LOGINSERVER
done

#テーブルのドロップ実行
drop_object_item $SCHEMANAME $LOGINSERVER

echo "【戻し完了】"
