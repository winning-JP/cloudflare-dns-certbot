#!/bin/bash

# パッケージをインストールする関数
install_packages() {
    local required_packages=("dialog" "certbot" "python3-certbot-dns-cloudflare")

    for package in "${required_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            sudo apt-get install -y "$package"
        else
            echo "$package は既にインストールされています。"
        fi
    done
}

# スクリプトがroot (スーパーユーザー) として実行されているかチェック
if [ "$(id -u)" -ne 0 ]; then
    echo "このスクリプトをroot (スーパーユーザー) として実行してください。"
    echo "Run this script as root (super user)."
    exit 1
fi

# 必要なパッケージをインストール
install_packages

# Cloudflare APIキー、メールアドレス、ドメイン名、そして保存先ディレクトリの入力を求める関数
input_cloudflare_credentials_domain_and_directory() {
    echo "Select Language:"
    echo "1) 日本語 / Japanese"
    echo "2) English / 英語"
    read -p "Enter the number corresponding to your language choice: " LANG_SELECT

    case "$LANG_SELECT" in
    1)
        TITLE="インストール中止"
        MSG_CANCEL="インストールがキャンセルされました。"
        MSG_CONFIRM="以下の設定でシェルスクリプトを生成しますか？"
        MSG_EXECUTE="生成されたシェルスクリプトを実行しますか？"
        MSG_EXECUTION_CANCEL="実行がキャンセルされました。\n\nシェルスクリプトの場所: $(pwd)/ssl.sh\nシェルスクリプトを実行するコマンド: ./ssl.sh"
        Cloudflare_API="Cloudflare APIキーを入力してください: "
        Cloudflare_MAIL="Cloudflareメールアドレスを入力してください: "
        DOMAIN_NAME="ドメイン名を入力してください: "
        SAVE_DIR="保存先ディレクトリを入力してください（フルパスを指定してください。例: /home/user/certificates）: "
        MSG_CONF_CONFIRM="設定の確認"
        MSG_EXEC_CONFIRM="実行確認"
        ;;
    2)
        TITLE="Installation Cancelled"
        MSG_CANCEL="The installation has been cancelled."
        MSG_CONFIRM="Do you want to generate the shell script with the following settings?"
        MSG_EXECUTE="Do you want to execute the generated shell script?"
        MSG_EXECUTION_CANCEL="The execution has been cancelled.\n\nShell script location: $(pwd)/ssl.sh\nCommand to execute the shell script: ./ssl.sh"
        Cloudflare_API="Please enter your Cloudflare API key: "
        Cloudflare_MAIL="Please enter your Cloudflare email address: "
        DOMAIN_NAME="Please enter the domain name: "
        SAVE_DIR="Please enter the destination directory to save certificates (provide the full path, e.g., /home/user/certificates): "
        MSG_CONF_CONFIRM="Configuration Confirmation"
        MSG_EXEC_CONFIRM="Execution Confirmation"
        ;;
    *)
        echo "Invalid language selection."
        exit 1
        ;;
    esac

    read -p "$Cloudflare_API" CLOUDFLARE_API_KEY
    if [ -z "$CLOUDFLARE_API_KEY" ]; then
        echo "$MSG_CANCEL"
        exit 1
    fi

    read -p "$Cloudflare_MAIL" CLOUDFLARE_EMAIL
    if [ -z "$CLOUDFLARE_EMAIL" ]; then
        echo "$MSG_CANCEL"
        exit 1
    fi

    read -p "$DOMAIN_NAME" DOMAIN
    if [ -z "$DOMAIN" ]; then
        echo "$MSG_CANCEL"
        exit 1
    fi

    read -p "$SAVE_DIR" SAVE_DIR_ROOT
    if [ -z "$SAVE_DIR_ROOT" ]; then
        SAVE_DIR_ROOT=$(pwd) # ディレクトリが空欄の場合、シェルを実行している場所にディレクトリを作成
    fi
}

# シェルスクリプトを生成する関数
generate_shell_script() {
    echo "#!/bin/bash" >"ssl.sh"
    echo "" >>"ssl.sh"
    echo "# Cloudflare APIキーを設定" >>"ssl.sh"
    echo "CLOUDFLARE_API_KEY=\"$CLOUDFLARE_API_KEY\"" >>"ssl.sh"
    echo "CLOUDFLARE_EMAIL=\"$CLOUDFLARE_EMAIL\"" >>"ssl.sh"
    echo "" >>"ssl.sh"
    echo "# 取得したいドメイン名を指定" >>"ssl.sh"
    echo "DOMAIN=\"$DOMAIN\"" >>"ssl.sh"
    echo "" >>"ssl.sh"
    echo "# 日付を取得" >>"ssl.sh"
    echo "DATE=\$(date +%Y-%m-%d)" >>"ssl.sh"
    echo "" >>"ssl.sh"
    echo "# 保存先ディレクトリを指定（日付フォルダー）" >>"ssl.sh"
    echo "SAVE_DIR=\"$SAVE_DIR_ROOT/\$DATE/\"" >>"ssl.sh"
    echo "" >>"ssl.sh"
    echo "# 証明書のコピー先を指定" >>"ssl.sh"
    echo "CERT_SAVE_DIR=\"\$SAVE_DIR/config/live/\$DOMAIN/\"" >>"ssl.sh"
    echo "" >>"ssl.sh"
    cat >>"ssl.sh" <<EOL
# 作業用のディレクトリを作成
mkdir -p "\$SAVE_DIR"

# cloudflare.iniファイルを作成
cat > "\$SAVE_DIR/cloudflare.ini" <<CONFIG
dns_cloudflare_api_key = \$CLOUDFLARE_API_KEY
dns_cloudflare_email = \$CLOUDFLARE_EMAIL
CONFIG

# Certbotを使用してSSL証明書の取得
certbot certonly \\
    --non-interactive \\
    --agree-tos \\
    --email "\$CLOUDFLARE_EMAIL" \\
    --dns-cloudflare \\
    --dns-cloudflare-credentials "\$SAVE_DIR/cloudflare.ini" \\
    -d "\$DOMAIN" --cert-name "\$DOMAIN" \\
    --config-dir "\$SAVE_DIR/config" \\
    --work-dir "\$SAVE_DIR/work" \\
    --logs-dir "\$SAVE_DIR/logs"

# 証明書ファイルを移動
cp "\$CERT_SAVE_DIR/cert.pem" "\$SAVE_DIR/server.crt"
cp "\$CERT_SAVE_DIR/privkey.pem" "\$SAVE_DIR/server.key"
EOL
}

# メイン処理
main() {
    # Cloudflare APIキー、メールアドレス、ドメイン名、そして保存先ディレクトリの入力
    input_cloudflare_credentials_domain_and_directory

    # 確認画面を表示 / Show confirmation dialog
    if [ $LANG_SELECT -eq 1 ]; then
        # 日本語の場合 / For Japanese
        dialog --stdout --title "$MSG_CONF_CONFIRM" --yesno \
            "$MSG_CONFIRM\n\n\
    Cloudflare APIキー: $CLOUDFLARE_API_KEY\n\
    Cloudflareメールアドレス: $CLOUDFLARE_EMAIL\n\
    ドメイン名: $DOMAIN\n\
    保存先ディレクトリ: $SAVE_DIR_ROOT\n\n\
    ※生成されるシェルスクリプトはssl.shです。" 14 70
    else
        # 英語の場合 / For English
        dialog --stdout --title "$MSG_CONF_CONFIRM" --yesno \
            "$MSG_CONFIRM\n\n\
    Cloudflare API Key: $CLOUDFLARE_API_KEY\n\
    Cloudflare Email Address: $CLOUDFLARE_EMAIL\n\
    Domain: $DOMAIN\n\
    Save Directory: $SAVE_DIR_ROOT\n\n\
    The generated shell script is named ssl.sh." 14 70
    fi

    # 確認結果によって処理を分岐 / Process based on the confirmation result
    if [ $? -eq 0 ]; then
        # Yesが選択された場合はシェルスクリプトを実行確認
        # If Yes is selected, prompt for execution confirmation
        if [ $LANG_SELECT -eq 1 ]; then
            # 日本語の場合 / For Japanese
            # シェルスクリプトを生成
            generate_shell_script
            dialog --stdout --title "$MSG_EXEC_CONFIRM" --yesno "$MSG_EXECUTE" 7 40
        else
            # 英語の場合 / For English
            # シェルスクリプトを生成
            generate_shell_script
            dialog --stdout --title "$MSG_EXEC_CONFIRM" --yesno "$MSG_EXECUTE" 7 40
        fi

        if [ $? -eq 0 ]; then
            # Yesが選択された場合はシェルスクリプトを実行
            # If Yes is selected, execute the shell script
            if [ $LANG_SELECT -eq 1 ]; then
                # 日本語の場合 / For Japanese
                echo "シェルスクリプトの生成が完了しました。"
            else
                # 英語の場合 / For English
                echo "Shell script generation completed."
            fi
            ./ssl.sh
        else
            # Noが選択された場合は中止メッセージを表示
            # If No is selected, show cancellation message
            if [ $LANG_SELECT -eq 1 ]; then
                # 日本語の場合 / For Japanese
                dialog --title "$TITLE" --msgbox "$MSG_EXECUTION_CANCEL" 10 60
            else
                # 英語の場合 / For English
                dialog --title "$TITLE" --msgbox "$MSG_EXECUTION_CANCEL" 10 60
            fi
            exit 1
        fi
    else
        # Noが選択された場合は中止メッセージを表示
        # If No is selected, show cancellation message
        if [ $LANG_SELECT -eq 1 ]; then
            # 日本語の場合 / For Japanese
            dialog --title "$TITLE" --msgbox "$MSG_CANCEL" 5 40
        else
            # 英語の場合 / For English
            dialog --title "$TITLE" --msgbox "$MSG_CANCEL" 5 40
        fi
        exit 1
    fi
}

main
