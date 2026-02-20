##新しい値がwebインターフェースから来てるか、見張りをする。
##来てたら、stellariumでの生成、imagemagickでの成形をする


#!/bin/bash

# --- 設定 ---
REQUEST_FILE="/var/www/html/test/request.txt"
TEMPLATE_FILE="/home/j2110/template.ssc"
# make_circle_v4.sh が使っているsscファイル名に合わせます
TARGET_SSC="/home/j2110/planisphere_circle-6.ssc"
MAKER_SCRIPT="./make_circle.sh"

echo "=== 監視を開始します (Ctrl+Cで停止) ==="

# 【重要】開始時にファイルをリセットして、書き込み許可を与える
touch "$REQUEST_FILE"
chmod 666 "$REQUEST_FILE"

while true; do
# 毎回、念のために書き込み許可を強制する（これでロックを防ぐ！）
    chmod 666 "$REQUEST_FILE"

    # 注文票があるかチェック
    if [ -s "$REQUEST_FILE" ]; then
        echo "★ 注文を受信しました！"

        # 1. 中身を読み取る (経度,緯度,日時)
        # カンマ区切りで変数を読み込むテクニックです
        IFS=',' read -r LONG LAT DATE < "$REQUEST_FILE"

        echo "・設定: 緯度=$LAT, 経度=$LONG, 日時=$DATE"

        # 2. テンプレートの穴埋めをして、新しいsscを作る
        # sedコマンドで __LAT__ などを実際の数字に置換します
        sed -e "s/__LAT__/$LAT/g" \
            -e "s/__LONG__/$LONG/g" \
            -e "s/__DATE__/$DATE/g" \
            "$TEMPLATE_FILE" > "$TARGET_SSC"

        echo "・スクリプト(ssc)を更新しました"

   # 3. 画像生成を実行
        # ファイルがあるか確認してから実行する安全策
        if [ -f "$MAKER_SCRIPT" ]; then
            bash "$MAKER_SCRIPT"
        else
            echo "【エラー】生成スクリプト($MAKER_SCRIPT)が見つかりません！名前を確認してください。"
        fi

        # 4. ファイルを「削除」せず「空っぽ」にします
        # これなら権限エラーが起きません
        > "$REQUEST_FILE"

        echo "--- 完了！次の注文を待っています ---"
    fi

    # 1秒休憩
    sleep 1
done