# jira_bulk_issues

ストーリーチケットと、そのサブタスクを一括で登録します。

## サンプルCSV

type, title, id, estimate, label  
story, ストーリー1  
sub, タイトル',10401,2h  
sub, タイトル',10401,2h  
sub, タイトル',10401,2h  
story, ストーリー2  
sub, タイトル,10401,2h  

※1行目のヘッダーは無視します  
※story行後、次のストーリーを検出するまでは、そのストーリーのサブタスクとします。  

## 呼び出し例

$ ruby issue.rb -u {user} -p {password} -c sample.csv -r test -f TST

-u Atlassianアカウントのユーザー名  
-p Atlassianアカウントのパスワード  
-c CSVファイル  
-r プロジェクト名。xxx.atlassian.net の「xxx」の部分  
-f チケットプレフィックス
