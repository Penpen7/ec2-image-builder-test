# ec2-image-builder-sample

1. レポジトリをcloneします
```
git clone https://github.com/Penpen7/ec2-image-builder-test.git
```
2. terraform実行に必要なS3バケットや認証情報を入れてください
```
cd ec2-image-builder-test
vim ec2/providers.tf
vim image-builder/providers.tf
```
3. terraform initで初期化、terraform applyでAWS環境に反映します
```
cd image-builder
terraform init
terraform apply
```
4. AWSコンソール画面に入り、EC2 Image Builderの画面を開き、パイプラインを実行します
5. パイプラインの実行が完了したら、AMIが作成されていることを確認します
6. 作成されたAMIを使ってEC2インスタンスを作成します
```
cd ../ec2
terraform init
terraform apply
```
7. 作成されたEC2インスタンスにセッションマネージャでログインします
8. slコマンドがインストールされていることを確認します
```
sl
```
9. 終わったら、terraform destroyで作成したリソースを削除します
```
cd ../ec2
terraform destroy
cd ../image-builder
terraform destroy
```
10. コンソール画面でバージニア北部と東京リージョンに作成されたAMIの登録解除を行い、スナップショットを削除します
