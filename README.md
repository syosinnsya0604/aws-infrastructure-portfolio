# aws-infrastructure-portfolio

## 障害試験：RDS接続障害と復旧

### 目的

ECS上のアプリケーションからRDSへの通信障害を意図的に発生させ、障害発生時の挙動、ログによる原因調査、Terraformによる復旧手順を確認した。

### 障害の再現

RDSのSecurity Groupから、ECSのSecurity Groupを送信元とするTCP/5432のIngressルールを一時的に削除した。

これにより以下の通信を遮断した。

```text
ECS (Fargate)
    ↓
TCP/5432
    ×
RDS (PostgreSQL)
```

### 発生した事象

障害発生後、ALB経由で `/health` にアクセスしたところ、HTTP 504 Gateway Timeoutが発生した。

CloudWatch Logsを確認したところ、以下の事象を確認した。

* Gunicornで `WORKER TIMEOUT` が発生
* `/health` 内のDB接続処理で停止
* `psycopg.OperationalError` によるPostgreSQL接続失敗
* Gunicorn Workerが起動できず終了
* ECSサービスが `Desired: 1` に対して `Running: 0` となった

これにより、RDSへの接続障害がアプリケーションの正常性に影響していることをログから特定した。

### 復旧

Terraformを実行したところ、手動削除したSecurity Groupルールとの差分を検知した。

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

`terraform apply` により、ECSからRDSへのTCP/5432通信ルールを再作成した。

その後、ECSサービスに対して新しいデプロイを実行し、タスクを再起動した。

復旧後のECSサービス：

```text
Running: 1
Desired: 1
Pending: 0
```

最終的に `/health` を再確認し、以下の応答を確認した。

```text
HTTP Status: 200
{"database":"ok","status":"ok"}
```

### 結果

障害の発生から原因調査、IaC（Infrastructure as Code：インフラ構成のコード管理）による設定復旧、ECSサービスの復旧、アプリケーションとDBの正常性確認までの一連の障害対応を実施できた。

また、DB接続障害時にアプリケーションの起動自体が失敗する設計上の課題も確認できたため、今後の改善点としてDB接続タイムアウトや起動処理の分離を検討する。
