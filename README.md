# Cloudflare DNS SSL 自動化スクリプト

これは、CertbotとCloudflare DNSバリデーションを使用してLet's EncryptからSSL証明書を取得するプロセスを自動化するBashスクリプトです。Cloudflareで管理されているドメインのSSL証明書のセットアップを簡略化します。

## 目次

- [概要](#概要)
- [要件](#要件)
- [使用方法](#使用方法)
- [インストール](#インストール)
- [設定](#設定)
- [ライセンス](#ライセンス)

## 概要

このスクリプトは、以下の主なタスクを自動化します：

- 必要なパッケージのインストール：dialog、certbot、python3-certbot-dns-cloudflareなどのパッケージをインストールします。
- Cloudflareの認証情報入力：CloudflareのAPIキーとメールアドレスを入力してもらい、ドメイン名と証明書保存先ディレクトリを指定してもらいます。
- シェルスクリプト生成：入力された情報を元に、ssl.shという名前のシェルスクリプトを生成します。
- SSL証明書の取得：生成されたssl.shスクリプトを実行し、Cloudflare DNSバリデーションを使用してLet's EncryptからSSL証明書を取得します。

このスクリプトを使用することで、手動での設定作業を減らし、効率的にSSL証明書のセットアップを行うことができます。また、シェルスクリプトを生成するため、後から再利用することも可能です。

**注意：** このスクリプトを実行する前に、CloudflareのAPIキーとメールアドレスを取得し、対象のドメインがCloudflareで管理されていることを確認してください。また、スクリプトを実行するサーバーにはスーパーユーザー権限（root）が必要です。

## 要件

- Linuxベースのシステム（Ubuntuでテスト済み）
- Bashシェル
- CloudflareのAPIキーとメールアドレス
- Cloudflareで管理されているドメイン

## 使用方法

1. このリポジトリをローカルマシンにクローンします：`git clone https://github.com/winning-JP/cloudflare-dns-certbot.git`

2. プロジェクトディレクトリに移動します：`cd cloudflare-dns-certbot`

3. メインスクリプトをスーパーユーザー（root）として実行するように設定を変更します：`chmod +x setup.sh`

4. メインスクリプトをスーパーユーザー（root）として実行します：`sudo ./setup.sh`

5. ユーザーのCloudflareの認証情報、ドメイン名、証明書保存先ディレクトリを入力します。

6. 設定を確認し、生成された`ssl.sh`スクリプトを実行します。

## インストール

スクリプトを実行する前に、必要なパッケージがインストールされていることを確認します：

`sudo apt-get update`

`sudo apt-get install -y dialog certbot python3-certbot-dns-cloudflare`

## 設定

スクリプトは以下の情報をユーザーに入力してもらいます：

- Cloudflare APIキー：Cloudflareのアカウントから取得します。
- Cloudflareメールアドレス：Cloudflareのアカウントに関連付けられたメールアドレスを使用します。
- ドメイン名：SSL証明書を取得するドメイン名を入力します。
- 保存先ディレクトリ：証明書を保存するディレクトリのフルパスを指定します。空欄の場合、シェルを実行している場所に保存されます。

## ライセンス

このプロジェクトはMITライセンスのもとで提供されています
- 詳細は[LICENSE](LICENSE)ファイルをご覧ください。
