//webインターフェース
//ここで決めた値は、request.txtに書き込む

<?php
// ブラウザに「これはUTF-8だよ」と強制的に伝える命令
header('Content-Type: text/html; charset=UTF-8');

// 注文票ファイルの場所
$requestFile = "/var/www/html/test/request.txt";

// フォームが送信された時の処理
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // 入力データを受け取る
    $lat = $_POST['lat'];
    $long = $_POST['long'];
    $date = $_POST['datetime'];

    // データのチェック
    if ($lat != "" && $long != "" && $date != "") {
        // 秒を追加してStellariumの形式に合わせる
        $date_formatted = $date . ":00";

        // 注文内容をまとめる（経度,緯度,日時）
        $data = $long . "," . $lat . "," . $date_formatted;

        // 注文票ファイルに書き込む
        file_put_contents($requestFile, $data);

        $message = "設定を送信しました！星空を生成中です...";
    }
}
?>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>星空コントローラー</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f0f0f0; }
        .control-panel { background: white; padding: 20px; border-radius: 8px; max-width: 400px; margin: 0 auto; box-shadow: 0 2px 5px rgba(0,0,0,0.2); }
        input { width: 100%; padding: 8px; margin: 5px 0 15px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #00082F; color: white; border: none; font-size: 16px; cursor: pointer; }
        button:hover { background: #001a5c; }
    </style>
</head>
<body>

<div class="control-panel">
    <h2>📡 星空生成司令室</h2>

    <?php if (isset($message)) echo "<p style='color:green;'>$message</p>"; ?>

    <form method="post">
        <label>緯度 (Latitude):</label>
        <input type="number" step="0.01" name="lat" value="35.68" required>

        <label>経度 (Longitude):</label>
        <input type="number" step="0.01" name="long" value="139.75" required>

        <label>日時 (Date & Time):</label>
        <input type="datetime-local" name="datetime" value="2026-01-01T21:00" required>

        <button type="submit">この条件で生成！</button>
    </form>

    <p><small>※送信後、反映まで30秒ほどかかります</small></p>
    <p><a href="index.html" target="_blank">→ 星空システムを見る</a></p>
</div>

</body>
</html>