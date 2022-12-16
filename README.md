# terraform tfstate + S3 + SSE-C メモ

tfstateには秘匿すべき重要な情報が含まれていることが多いです。そのため、tfstateの管理には注意を要します。
しかしながら、利便性などを考えると、S3設置機能を利用したくなる場合もあると思います。
terraform tfstateをS3に置く場合、tfstateをSSE-Cで暗号化することでセキュリティを強化できます。このコードはそのサンプルコードです。

# 準備

* 事前にawscliに対象のAWSにアクセス権のあるアクセスキーを設定してあることを前提とします。プロファイル付きで設定している場合
`export AWS_DEFAULT_PROFILE=hogehoge` などでexportしてください。

* tfenvの利用をおすすめします。

# 実行

## 1-init

1-initではバケットの作成とこの後で使うMakefile、および実際にBackendで使うterraformファイルを生成します。SSE-Cで利用するランダムな文字列もここで生成します。生成されたものは上の階層の etc フォルダに保存されます。

利用前に config.tf を作成します。 config.tf.example を編集してご利用ください。

ここで生成される terraform.tfstate はローカルに作成されます。

実行例

    $ cd 1-init
    $ cp config.tf.example config.tf
    $ vim config.tf
    $ terraform init
    $ terraform plan
    $ terraform apply
    $ cd ..

## 2-updown-test

SSE-Cを利用してファイルのアップロードとダウンロードを行います。アップロードされたファイルがAWSコンソールからダウンロードできないことを確認し、またこのツールでダウンロードされた `var/download.txt` がきちんと表示されるか確認してください。

    $ cd 2-updown-test
    $ make
    $ make clean
    $ cd ..

## 3-sse-c-tfstate

SSE-Cを利用したtfstateの具体的な利用方法です。バックエンドの設定はfile()などで読み込めないため別途コピーする必要があります。ここでは backend.tf という形でファイルを分離し、Makefileでファイルを ../etc からコピーしています。実際の運用時にセキュアに扱うならば、このファイルの扱いがポイントとなります。

このterraformで行うことは、 var/hello.txt を生成するだけですが、applyするとS3上にtfstateが保存されます。S3上のファイルがAWSコンソールからダウンロードできないことを確認してください。

ポイントとしては、backendで設定する sse_customer_key はbase64でエンコードしたものである必要があります。また、エンコード前のデータはちょうど256ビット(32バイト)である必要があります。

AWSCLIプロファイルを明示する場合、backend.tfの backend "s3" に profile を追記してください。

    $ cd 3-sse-c-tfstate
    $ make
    $ vim backend.tf
    $ terraform init
    $ terraform plan
    $ terraform apply
    $ more var/hello.txt
    $ cd ..

backend.tf を手作業で設定する場合は以下の項目を追加します。

    terraform {
      backend "s3" {
        encrypt          = true
        profile          = "myprofile" // AWSCLIプロファイルを使用する場合
        bucket           = "バケット名"
        sse_customer_key = "Base64されたSSE-Cキー"
        region           = "リージョン"
        key              = "tfstateのキー(S3上のパス)"
      }

## 4-fetch-tfstate

先述のterraform apply で作成された tfstateをダウンロードする方法です。実行後にきちんと var/terraform.tfstate として内容が確認できるかを確認してください。

    $ cd 4-fetch-tfstate
    $ make
    $ cat var/terraform.tfstate
    $ cd ..

## お掃除

S3のバケットはバージョニングを有効にしてあるので awscliから消すことは難しいです。pythonでコードを書くか、AWSコンソールで空にしてから、 1-init で `terraform destroy` を実行しましょう。

