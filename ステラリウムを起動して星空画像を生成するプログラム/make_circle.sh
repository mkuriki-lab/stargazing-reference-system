#stellariumで生成したものをimagemagckをつかい丸くする
#


#!/bin/bash

# ================= 設定 =================
# 指定されたパス
SCRIPT_PATH="/home/j2110/planisphere_circle-6.ssc"
INPUT_IMG="/home/j2110/planisphere_final-2-1.png"

# 完成品のファイル名
OUTPUT_IMG="/var/www/html/test/planisphere_round.png"
# ========================================

echo "=== 処理を開始します ==="

# 2. Stellariumを起動（最大30秒で強制終了させる保険付き）
echo "・Stellariumを起動して撮影中..."
timeout 30s stellarium --startup-script "$SCRIPT_PATH"

# 3. 待機：ファイルが生成されるのを監視します
echo "・画像の保存を待っています..."

# 20秒間、1秒ごとに「ファイルできた？」と確認するループ
count=0
while [ ! -f "$INPUT_IMG" ]; do
    sleep 1
    count=$((count+1))
    # 20秒経ってもファイルができない場合はあきらめる
    if [ $count -ge 20 ]; then
        echo "【エラー】20秒待機しましたが画像が生成されませんでした。"
        echo "確認: $INPUT_IMG のパスや、.ssc側の保存設定を確認してください。"
        exit 1
    fi
done

# ファイル認識後、書き込み完了を確実にするため念のため2秒待つ
sleep 2
echo "・画像を確認しました！ 加工します。"

# # 4. ImageMagickで丸く切り抜く（計算式エラー対策版）
# # まず画像の幅(W)を取得
# W=$(identify -format "%w" "$INPUT_IMG")
# # 半径(R)を計算 (幅 ÷ 2)
# R=$(($W / 2))

# # 切り抜き実行
# convert "$INPUT_IMG" \
#     -gravity center -crop 1:1 +repage \
#     \( +clone -alpha transparent -fill white -draw "circle $R,$R $R,0" \) \
#     -compose DstIn -composite \
#     "$OUTPUT_IMG"
# 画像の高さ(H)を測ります
H=$(identify -format "%h" "$INPUT_IMG")
# 画像の幅(W)を測ります
W=$(identify -format "%w" "$INPUT_IMG")

# デバッグ用表示
echo "画像のサイズ: 幅$W x 高さ$H"

# 短いほう（通常は高さ）を正方形のサイズ(S)にします
# これで横長の画像でも、真ん中の星空部分だけを狙います
if [ $W -lt $H ]; then
    S=$W
else
    S=$H
fi

# 半径(R)を計算
R=$(($S / 2))

echo "切り抜くサイズ: $S px (半径 $R px)"

# ImageMagickコマンド
# 1. -extent: 中心を基準に、高さx高さ の正方形にトリミングします（余計な横の黒帯をカット）
# 2. -draw: その正方形にピッタリ収まる円を描いて切り抜きます
convert "$INPUT_IMG" \
    -gravity center -extent "${S}x${S}" \
    \( +clone -alpha transparent -fill white -draw "circle $R,$R $R,0" \) \
    -compose DstIn -composite \
    "$OUTPUT_IMG"

# 5. 結果確認
if [ -f "$OUTPUT_IMG" ]; then
    echo "========================================"
    echo "【成功】完成しました！"
    echo "出力ファイル: $OUTPUT_IMG"
    echo "========================================"
else
    echo "【失敗】加工に失敗しました。"
fi