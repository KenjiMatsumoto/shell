#共通関数定義

#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名
function schema_all_drop_object()
{
        sqlplus -s /nolog<<ENDofSQL
                --Oracle接続
                conn $1/$1@$2
                set heading off
                set pagesize 5000

                --全てのオブジェクトをDropする
                DECLARE
                        CURSOR drop_sqllist IS
                        SELECT
                                'Drop ' || object_type || ' ' || object_name || '' sqlString
                        FROM
                                user_objects
                        WHERE
                                object_name not like 'SYS%' AND
                                object_type not in ('INDEX' ,'TRIGGER','PACKAGE BODY','TABLE PARTITION');
                BEGIN
                        FOR rec IN drop_sqllist LOOP
                                EXECUTE IMMEDIATE rec.sqlString;
                        END LOOP;
                EXCEPTION
                        when others then
                        dbms_output.put_line('エラー発生！！');
                END;
                /
        quit
#↓SQL終了文字の前に空白やタブを入れるとエラーとなる為、要注意
ENDofSQL
}

#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名
function Invalid_object_count()
{
        ret=`sqlplus -s /nolog<<ENDofSQL
                --Oracle接続
                conn $1/$1@$2
                set heading off
                set pagesize 5000

                --Invalidがたっているオブジェクト件数取得
                select count(*) INVALID_CHECK from user_objects where status ='INVALID';
        quit
#↓SQL終了文字の前に空白やタブを入れるとエラーとなる為、要注意
ENDofSQL`
echo $ret
}

#Invalidオブジェクトのリコンパイル関数
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名
function Invalid_object_replace()
{
        sqlplus -s /nolog<<ENDofSQL
        --Oracle接続
        conn $1/$1@$2

        set serveroutput on
        declare
                CURSOR CUR1 IS select object_name,object_type from user_objects where status ='INVALID' and object_type in ('PROCEDURE','VIEW','PACKAGE','SYNONYM','FUNCTION');
        begin
                FOR CUR_RECORD IN CUR1 LOOP
                        dbms_output.put_line('alter '||CUR_RECORD.object_type||' '|| CUR_RECORD.object_name||' compile');
                        EXECUTE IMMEDIATE 'alter '||CUR_RECORD.object_type||' '|| CUR_RECORD.object_name||' compile';
                END LOOP;
        end;
        /
quit
ENDofSQL
}

#ある特定のオブジェクトの削除実行関数
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名
function drop_object_item()
{
        sqlplus -s /nolog<<ENDofSQL
                --Oracle接続
                conn $1/$1@$2
                set heading off
                set pagesize 5000

                --全てのオブジェクトをDropする
                DECLARE
                        CURSOR drop_sqllist IS
                        SELECT
                                'Drop ' || object_type || ' ' || object_name || '' sqlString
                        FROM
                                user_objects
                        WHERE
                                object_name not like 'SYS%' AND
                                object_name in ('hoge','fuga');
                BEGIN
                        FOR rec IN drop_sqllist LOOP
                                EXECUTE IMMEDIATE rec.sqlString;
                        END LOOP;
                EXCEPTION
                        when others then
                        dbms_output.put_line('エラー発生！！');
                END;
                /
        quit
#↓SQL終了文字の前に空白やタブを入れるとエラーとなる為、要注意
ENDofSQL
}

#テーブル名リネーム関数
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名
function table_rename()
{
        sqlplus -s /nolog<<ENDofSQL
                --Oracle接続
                conn $1/$1@$2
                set heading off
                set pagesize 5000

                --全てのオブジェクトをDropする
                ALTER TABLE hoge_TBL RENAME TO fuga_TBL;

        quit
#↓SQL終了文字の前に空白やタブを入れるとエラーとなる為、要注意
ENDofSQL
}

#参照権限を引数3のスキーマへ付与
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名　引数3⇒参照権限付与先スキーマ
function reference_authority()
{
        #参照権限をスキーマへ付与
        sqlplus -s /nolog<<EndofSQL
        --Oracle接続
        conn $1/$1@$2
        GRANT SELECT ON tbl_name TO $3;
        quit
EndofSQL
}

#該当のviewのDDL出力関数
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名　引数3⇒出力SQLファイル名　引数4⇒DDL出力するView名
function make_view_ddl()
{
        #ViewのDDL出力
        sqlplus -s /nolog<<EndofSQL
                --Oracle接続
                conn $1/$1@$2
                set long 20000
                set longc 3000
                set linesize 3000
                set pagesize 0
                set trimspool on
                set feedback off
                spool $3
                select dbms_metadata.get_ddl('VIEW',view_name) || ';' from user_views where view_name = '$4';
                spool off
        quit
EndofSQL
}

#該当のviewのコメントをDDLに出力
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名　引数3⇒出力SQLファイル名　引数4⇒DDL出力するView名
function make_view_comment_ddl()
{
        #ViewのDDL出力
        sqlplus -s /nolog<<EndofSQL
                --Oracle接続
                conn $1/$1@$2
                set long 20000
                set longc 3000
                set linesize 3000
                set pagesize 0
                set trimspool on
                set feedback off
                spool $3
                select 'COMMENT ON TABLE ' || TABLE_NAME || ' IS ' || q'<'>' || COMMENTS || q'<'>' || ';' from user_tab_comments where table_name = '$4';
                select 'COMMENT ON COLUMN ' || TABLE_NAME || '.' || COLUMN_NAME || ' IS ' || q'<'>' || COMMENTS || q'<'>' || ';' from user_col_comments where table_name = '$4';
                spool off
        quit
EndofSQL
}

#SQLファイルの実行関数
#引数1⇒ユーザー名＆パスワード　引数2⇒接続サービス名　引数3⇒実行SQLファイル名
function excute_sql_file()
{
        sqlplus -s /nolog<<EndofSQL
                --Oracle接続
                conn $1/$1@$2
                @$3
        quit
EndofSQL
}

#スキーマ選択関数
function schema_select()
{
        echo -e "$1\n　1：hoge\n　2：hoge2\n　3：hoge3\n　4：hoge4\n　5：hoge5\n【入力なしの場合、hoge】"
        read SCHEMANUMBER
        #スキーマ名のセット
        case "$SCHEMANUMBER" in
                "" | "1")
                        SCHEMANAME="hoge1";;
                "2")
                        SCHEMANAME="hoge2";;
                "3")
                        SCHEMANAME="hoge3";;
                "4")
                        SCHEMANAME="hoge4";;
                "5")
                        DIRRECTORYOBJECT="HOGE_LOG"
                        SCHEMANAME="hoge5";;
                *)
                        echo "入力値が範囲外の為、エラー"
                        exit 1;;
        esac
}
