import os
import json
import platform
import subprocess
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

# ==========================================
# 1. 共通ユーティリティ & スタイル定義
# ==========================================
FONT_NAME = "BIZ UDPゴシック"

FONT_TITLE = Font(name=FONT_NAME, size=16, bold=True, color="FFFFFF")
FONT_SECTION = Font(name=FONT_NAME, size=12, bold=True)
FONT_HEADER = Font(name=FONT_NAME, size=10, bold=True, color="FFFFFF")
FONT_REGULAR = Font(name=FONT_NAME, size=10, bold=False)

FILL_TITLE = PatternFill(start_color="2F5597", end_color="2F5597", fill_type="solid")
FILL_HEADER = PatternFill(start_color="2F5597", end_color="2F5597", fill_type="solid")
FILL_ZEBRA = PatternFill(start_color="F2F4F8", end_color="F2F4F8", fill_type="solid")
FILL_FAULT = PatternFill(start_color="FFF2CC", end_color="FFF2CC", fill_type="solid")

THIN_BORDER = Border(
    left=Side(style='thin', color='BFBFBF'),
    right=Side(style='thin', color='BFBFBF'),
    top=Side(style='thin', color='BFBFBF'),
    bottom=Side(style='thin', color='BFBFBF')
)

def auto_fit_columns(ws):
    """全角文字・改行を完全に考慮したインテリジェント幅調整"""
    ws.views.sheetView[0].showGridLines = True
    for col in ws.columns:
        max_len = 0
        col_letter = get_column_letter(col[0].column)
        for cell in col:
            if cell.value is not None:
                lines = str(cell.value).split('\n')
                for line in lines:
                    length = sum(2 if ord(c) > 128 else 1 for c in line)
                    if length > max_len:
                        max_len = length
        ws.column_dimensions[col_letter].width = max(max_len + 4, 12)

def draw_sheet_title(ws, title_text):
    """共通上部大型ヘッダーの描画"""
    ws.merge_cells("A1:E1")
    title_cell = ws["A1"]
    title_cell.value = title_text
    title_cell.font = FONT_TITLE
    title_cell.fill = FILL_TITLE
    title_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 40

def render_table(ws, start_row, section_title, headers, rows, is_test_sheet=False):
    """データ構造と描画ロジックを分離したクリーン描画エンジン"""
    ws.cell(row=start_row, column=1, value=section_title).font = FONT_SECTION
    
    header_row = start_row + 1
    for col_idx, header in enumerate(headers, 1):
        cell = ws.cell(row=header_row, column=col_idx, value=header)
        cell.font = FONT_HEADER
        cell.fill = FILL_HEADER
        cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[header_row].height = 24
    
    current_row = header_row + 1
    for r_idx, row_data in enumerate(rows):
        ws.row_dimensions[current_row].height = 20
        use_fault_fill = is_test_sheet and row_data[0] in ["TC-04", "TC-05", "TC-06"]
        
        for c_idx, val in enumerate(row_data, 1):
            cell = ws.cell(row=current_row, column=c_idx, value=val)
            cell.font = FONT_REGULAR
            cell.border = THIN_BORDER
            
            if "Formula_" in str(val) or "<p>" in str(val) or "•" in str(val) or "\n" in str(val) or len(str(val)) > 30:
                cell.alignment = Alignment(wrap_text=True, vertical="top")
            else:
                cell.alignment = Alignment(vertical="center")
                
            if use_fault_fill:
                cell.fill = FILL_FAULT
            elif r_idx % 2 == 1:
                cell.fill = FILL_ZEBRA
                
        current_row += 1
    return current_row + 1

# ==========================================
# 2. Mermaidグラフィックレンダリングエンジン
# ==========================================
def generate_mermaid_image():
    """OS識別・Puppeteerサンドボックス回避ロジック"""
    mermaid_text = """graph TD
    Start[トリガー: 依頼タスク回答の保存時<br/>状況 = '承認済み' かつ 更新時のみ] --> Dec_OwnerType{親タスクの所有者は<br/>User（ユーザー）か？}
    Dec_OwnerType -- YES --> Ass_UserAddresses[数式: Formula_ToAddresses<br/>所有者 + マネージャーのEmailを結合]
    Dec_OwnerType -- NO --> Ass_QueueAddresses[数式: Formula_ToAddresses<br/>キューの送信先Emailを抽出/Null安全]
    Ass_UserAddresses --> Ass_CombineCc[数式: Formula_CcAddresses<br/>CC1〜CC10を1ノードで一括結合]
    Ass_QueueAddresses --> Ass_CombineCc
    Ass_CombineCc --> Act_SendEmail[コアアクション:<br/>メールを送信]
    Act_SendEmail -->|正常完了| End_Success([フロー正常終了])
    Act_SendEmail -.->|障害発生| Act_CreateFaultLog[障害処理:<br/>エラーログレコードの作成]
    Act_CreateFaultLog --> End_Fault([フロー異常終了])
"""
    config_path = "puppeteerConfig.json"
    mmd_path = "flow.mmd"
    png_path = "flow.png"
    
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump({"args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"]}, f)
    with open(mmd_path, "w", encoding="utf-8") as f:
        f.write(mermaid_text)
        
    cmd = "mmdc.cmd" if platform.system() == "Windows" else "mmdc"
    shell_opt = True if platform.system() == "Windows" else False
    
    try:
        subprocess.run([cmd, "-i", mmd_path, "-o", png_path, "-p", config_path], capture_output=True, text=True, shell=shell_opt, check=True)
    except Exception:
        pass
    finally:
        for path in [config_path, mmd_path]:
            if os.path.exists(path): os.remove(path)

# ==========================================
# 3. 設計書メタデータ定義 (テンプレート完全準拠)
# ==========================================
# シート1: 1. 基本情報
DATA_S1_INFO = {
    "section": "### 1. 基本情報",
    "headers": ["基本情報項目", "設定値", "補足・設計根拠"],
    "rows": [
        ["機能名", "依頼タスク回答：承認時完了メール通知フロー", "要件に基づくメール配信の自動化仕様"],
        ["概要・目的", "状況が「承認済み」になった場合、関係者（ToおよびCc）に自動で完了メール通知を行う。", "業務完了のリアルタイム同期と効率化"],
        ["対象オブジェクト", "依頼タスク回答 (RequestTaskAnswer__c)", "新設のカスタムオブジェクト"],
        ["トリガー（起動条件）", "更新された", "Status__cの「承認済み」への変更を検知するため"],
        ["実行タイミング", "保存後 (アクションと関連レコード)", "外部アクション（メール送信）および他レコードの作成を伴うため"]
    ]
}

# シート1: 2. エントリ条件（テキスト項目）
DATA_S1_ENTRY_TEXT = {
    "section": "### 2. エントリ条件 (プロパティ設定)",
    "headers": ["エントリ条件項目", "設定値", "補足・設計根拠"],
    "rows": [
        ["条件の要件", "すべての条件に一致 (AND)", "確実な絞り込みのため"],
        ["フローを実行するタイミング", "条件の要件に一致するようにレコードを更新したときのみ", "【ガードレール】他項目変更時の重複送信・無限ループを完全に防止"]
    ]
}

# シート1: 2. エントリ条件（テーブル項目）※完全一致
DATA_S1_ENTRY_TABLE = {
    "section": "### 2. エントリ条件 (判定テーブル)",
    "headers": ["項目ラベル", "API参照名", "演算子", "値 / 数式"],
    "rows": [
        ["状況", "Status__c", "次の文字列と一致する", "承認済み"]
    ]
}

# シート3: 3. リソース定義 ※完全一致
DATA_S3_RESOURCES = {
    "section": "### 3. リソース定義",
    "headers": ["リソース種別", "API参照名", "データ型", "コレクション", "説明・初期値・計算式"],
    "rows": [
        ["数式", "Formula_ToAddresses", "テキスト", "×", 
         "IF(\n    BEGINS({!$Record.RequestTask__r.OwnerId}, '005'),\n    {!$Record.RequestTask__r.Owner:User.Email} &\n    IF(NOT(ISBLANK({!$Record.RequestTask__r.Owner:User.ManagerId})), ',' & {!$Record.RequestTask__r.Owner:User.Manager.Email}, ''),\n    {!$Record.RequestTask__r.Owner:Group.Email}\n)"],
        ["数式", "Formula_CcAddresses", "テキスト", "×", 
         "SUBSTITUTE(\n    IF(NOT(ISBLANK({!$Record.CC1__c})), ',' & {!$Record.CC1__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC2__c})), ',' & {!$Record.CC2__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC3__c})), ',' & {!$Record.CC3__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC4__c})), ',' & {!$Record.CC4__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC5__c})), ',' & {!$Record.CC5__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC6__c})), ',' & {!$Record.CC6__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC7__c})), ',' & {!$Record.CC7__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC8__c})), ',' & {!$Record.CC8__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC9__c})), ',' & {!$Record.CC9__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC10__c})), ',' & {!$Record.CC10__r.Email}, ''),\n    ',', '', 1\n)"],
        ["テキストテンプレート", "tt_EmailBody", "テキスト", "×", 
         "<p>関係者各位</p><p>依頼のありましたタスクにつきまして、回答が承認され対応が完了いたしました。</p><hr><p>■ 依頼タスク内容</p><ul><li><b>親タスク名:</b> {!$Record.RequestTask__r.Name}</li></ul>"]
    ]
}

# シート3: 4. 処理ロジック（ステップ定義）※完全一致
DATA_S3_STEPS = {
    "section": "### 4. 処理ロジック（ステップ定義）",
    "headers": ["ステップ名", "対象オブジェクト/コレクション", "条件（抽出/処理）", "処理内容/項目マッピング"],
    "rows": [
        ["メールを送信", "N/A (コアアクション)", "エントリ条件合致時", 
         "• 送信本文 = {!tt_EmailBody}\n• 件名 = 【完了報告】依頼タスク回答が承認されました\n• 受信者（To） = {!Formula_ToAddresses}\n• 受信者（Cc） = {!Formula_CcAddresses}\n• リッチテキスト本文として送信 = $GlobalConstant.True"],
        ["レコードを作成", "ApplicationLog__c", "【障害パス】メール送信失敗時", 
         "• エラーメッセージ = {!$Flow.FaultMessage}\n• 発生箇所 = RequestTaskAnswer_Flow"]
    ]
}

# シート3: 4. 処理ロジック（分岐（決定）ロジック）※完全一致
DATA_S3_DECISIONS = {
    "section": "### 4. 処理ロジック（分岐（決定）ロジック）",
    "headers": ["決定要素名", "分岐名", "条件", "遷移先"],
    "rows": [
        ["Dec_OwnerType\n(親タスク所有者種別判定)", "分岐1: User宛先生成", "項目: {!$Record.RequestTask__r.OwnerId}\n演算子: 次の文字列で始まる\n値: 005", "Ass_UserAddresses\n(所有者+マネージャーのEmail結合)"],
        ["Dec_OwnerType\n(親タスク所有者種別判定)", "デフォルト", "上記以外 (Queue等の場合)", "Ass_QueueAddresses\n(キューのEmailのみを抽出/Null安全)"]
    ]
}

# シート4: 5. テスト仕様書
DATA_S4_TEST = {
    "section": "### 5. テスト観点カタログ（検証マトリクス）",
    "headers": ["ケースID", "検証種別", "事前状態", "変更後状態", "条件マトリクス", "期待される動作（合格基準）", "ガードレール検証分類"],
    "rows": [
        ["TC-01", "正常系起動確認", "未申請", "承認済み", "所有者:User(マネージャーあり)\nCC1~CC10:すべて入力", "Toに2名、Ccに10名のアドレスが正確にマッピングされ、メールが1通正常配信されること。", "同値分割・正常系"],
        ["TC-02", "起動抑制の検証", "承認済み", "承認済み", "CC項目のみを後行変更", "フローが起動しないこと（Only when...制御が有効に機能しているか）。", "トリガー再帰起動抑制"],
        ["TC-03", "対象外ステータス", "未申請", "却下", "任意", "トリガー条件に合致せず、メール送信処理が完全にスキップされること。", "正常系フィルタ"],
        ["TC-04", "Null安全検証1", "未申請", "承認済み", "所有者:User\nマネージャー:未設定(Null)\nCC項目:すべて空欄", "マネージャー不在でもNull Pointer Exceptionを起こさず、所有者のみ(To)に送信され正常終了すること。", "境界値ハイライト"],
        ["TC-05", "Null安全検証2", "未申請", "承認済み", "所有者:キュー(Queue)", "ユーザー固有のマネージャー参照を数式で安全にバイパスし、キューアドレスへ正常送信されること。", "境界値ハイライト"],
        ["TC-06", "障害パス検証", "未申請", "承認済み", "宛先Emailのドメイン形式が不正", "配信エラー時にフローがクラッシュせず、障害パス経由でログレコードが作成され、正常終了すること。", "障害時ハンドリング"],
        ["TC-07", "バルク処理更新", "未申請", "承認済み", "データローダによる200件の同時更新", "SOQLの制限エラーを起こさず、一括処理（Bulkify）されて全件のキュー処理が完了すること。", "一括処理・Bulkify"]
    ]
}

# ==========================================
# 4. メインExcelドキュメント生成処理
# ==========================================
def main():
    wb = Workbook()
    
    # --- シート1: 1.基本情報・トリガー仕様 ---
    ws1 = wb.active
    ws1.title = "1.基本情報・トリガー仕様"
    draw_sheet_title(ws1, "Salesforceフロー設計書（基本情報・エントリ条件）")
    next_row = render_table(ws1, 3, DATA_S1_INFO["section"], DATA_S1_INFO["headers"], DATA_S1_INFO["rows"])
    next_row = render_table(ws1, next_row, DATA_S1_ENTRY_TEXT["section"], DATA_S1_ENTRY_TEXT["headers"], DATA_S1_ENTRY_TEXT["rows"])
    render_table(ws1, next_row, DATA_S1_ENTRY_TABLE["section"], DATA_S1_ENTRY_TABLE["headers"], DATA_S1_ENTRY_TABLE["rows"])
    auto_fit_columns(ws1)
    
    # --- シート2: 2.処理フロー図 ---
    ws2 = wb.create_sheet(title="2.処理フロー図")
    ws2["A1"] = "### 2. 処理フロー図"
    ws2["A1"].font = FONT_SECTION
    generate_mermaid_image()
    if os.path.exists("flow.png"):
        from openpyxl.drawing.image import Image as OpenpyxlImage
        ws2.add_image(OpenpyxlImage("flow.png"), "A3")
    else:
        ws2["A3"] = "（Mermaid画像が生成されなかったため、テキストの定義を参照してください）"
        ws2["A3"].font = FONT_REGULAR
    ws2.views.sheetView[0].showGridLines = True
        
    # --- シート3: 3.リソース定義・処理ロジック ---
    ws3 = wb.create_sheet(title="3.リソース定義・処理ロジック")
    draw_sheet_title(ws3, "フロー詳細設計（リソース定義およびビジネスロジック仕様）")
    next_row = render_table(ws3, 3, DATA_S3_RESOURCES["section"], DATA_S3_RESOURCES["headers"], DATA_S3_RESOURCES["rows"])
    next_row = render_table(ws3, next_row, DATA_S3_STEPS["section"], DATA_S3_STEPS["headers"], DATA_S3_STEPS["rows"])
    render_table(ws3, next_row, DATA_S3_DECISIONS["section"], DATA_S3_DECISIONS["headers"], DATA_S3_DECISIONS["rows"])
    auto_fit_columns(ws3)
    
    # --- シート4: 4.テスト仕様書 ---
    ws4 = wb.create_sheet(title="4.テスト仕様書")
    draw_sheet_title(ws4, "高品質検証仕様書（テンプレート補随マトリクス）")
    render_table(ws4, 3, DATA_S4_TEST["section"], DATA_S4_TEST["headers"], DATA_S4_TEST["rows"], is_test_sheet=True)
    auto_fit_columns(ws4)
    
    # 保存ファイル出力
    filename = "RequestTaskAnswerFlow_TemplateStrictDoc.xlsx"
    wb.save(filename)
    if os.path.exists("flow.png"): os.remove("flow.png")
    print(f"[SUCCESS] テンプレートの列構成に100%合致したExcelを生成しました: {filename}")

if __name__ == "__main__":
    main()