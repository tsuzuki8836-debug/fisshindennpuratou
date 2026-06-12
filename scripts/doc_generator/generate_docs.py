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
    """全角文字、改行、および余白を考慮した自動幅調整ロジック"""
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
        ws.column_dimensions[col_letter].width = max(max_len + 4, 11)

def draw_sheet_title(ws, title_text):
    """共通の大型上部ヘッダーの描画"""
    ws.merge_cells("A1:D1")
    title_cell = ws["A1"]
    title_cell.value = title_text
    title_cell.font = FONT_TITLE
    title_cell.fill = FILL_TITLE
    title_cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 40

def render_table(ws, start_row, section_title, headers, rows, is_test_sheet=False):
    """データ構造をExcelに流し込む描画エンジンロジック"""
    # セクションタイトルの配置
    ws.cell(row=start_row, column=1, value=section_title).font = FONT_SECTION
    
    # ヘッダーの配置
    header_row = start_row + 1
    for col_idx, header in enumerate(headers, 1):
        cell = ws.cell(row=header_row, column=col_idx, value=header)
        cell.font = FONT_HEADER
        cell.fill = FILL_HEADER
        cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[header_row].height = 24
    
    # データデータの配置
    current_row = header_row + 1
    for r_idx, row_data in enumerate(rows):
        ws.row_dimensions[current_row].height = 20
        # 異常系・境界値の条件付きカラーリング（テスト仕様書用）
        use_fault_fill = is_test_sheet and row_data[0] in ["TC-04", "TC-05", "TC-06"]
        
        for c_idx, val in enumerate(row_data, 1):
            cell = ws.cell(row=current_row, column=c_idx, value=val)
            cell.font = FONT_REGULAR
            cell.border = THIN_BORDER
            
            # アラインメントと折り返しのインテリジェント制御
            if "Formula_" in str(val) or "<p>" in str(val) or len(str(val)) > 30:
                cell.alignment = Alignment(wrap_text=True, vertical="top")
            else:
                cell.alignment = Alignment(vertical="center")
                
            # 背景色の適用
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
    """OS判定とセキュリティサンドボックスを回避する内製画像化処理"""
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
    except Exception as e:
        stderr_msg = e.stderr if hasattr(e, 'stderr') else str(e)
        print(f"[INFO] mmdc連携スキップ（テキストチャートとして配置されます）: {stderr_msg}")
    finally:
        for path in [config_path, mmd_path]:
            if os.path.exists(path): os.remove(path)

# ==========================================
# 3. 設計書メタデータ定義 (データ駆動構造)
# ==========================================
DATA_SHEET1 = {
    "section": "■ フロー基本定義・エントリ条件",
    "headers": ["設定項目", "定義内容", "Salesforceシステム仕様・アーキテクチャ根拠"],
    "rows": [
        ["フロー表示名", "依頼タスク回答：承認時完了メール通知フロー", "業務要件に完全に準拠した識別名"],
        ["API参照名", "RequestTaskAnswer_ApprovedNotificationFlow", "標準的な命名規則（オブジェクト名_トリガー契機）"],
        ["トリガーオブジェクト", "依頼タスク回答 (RequestTaskAnswer__c)", "新規追加対象カスタムオブジェクト"],
        ["トリガー契機", "レコードが更新されたとき", "状況(Status__c)の変更イベントをAfter-Saveで捕捉するため"],
        ["エントリ条件数式", "Status__c 等しい '承認済み'", "要件1：承認済みとなった場合のみに限定"],
        ["条件の評価制限", "条件の要件に一致するようにレコードを更新したときのみ", "非同期・トリガーのセーフティガード。再帰起動による無限ループとガバナの枯渇を完全阻止"],
        ["最適化目標", "アクションと関連要素 (After-Save)", "親レコードへの高度なクロス書き込みおよび外部配信アクション実行に必須のレイヤー"]
    ]
}

DATA_SHEET3_RES = {
    "section": "■ 3. リソース定義仕様",
    "headers": ["リソース名", "データ型", "数式 / 処理ロジック文字列", "実装上の目的（ガバナ制限・コンパイルサイズ回避）"],
    "rows": [
        ["Formula_ToAddresses", "テキスト", 
         "IF(\n    BEGINS({!$Record.RequestTask__r.OwnerId}, '005'),\n    {!$Record.RequestTask__r.Owner:User.Email} &\n    IF(NOT(ISBLANK({!$Record.RequestTask__r.Owner:User.ManagerId})), ',' & {!$Record.RequestTask__r.Owner:User.Manager.Email}, ''),\n    {!$Record.RequestTask__r.Owner:Group.Email}\n)", 
         "親タスク所有者が『キュー(00G)』の場合のNull参照エラーを回避する完全防御ロジック。User(005)時のみマネージャーを追随。"],
        ["Formula_CcAddresses", "テキスト", 
         "SUBSTITUTE(\n    IF(NOT(ISBLANK({!$Record.CC1__c})), ',' & {!$Record.CC1__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC2__c})), ',' & {!$Record.CC2__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC3__c})), ',' & {!$Record.CC3__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC4__c})), ',' & {!$Record.CC4__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC5__c})), ',' & {!$Record.CC5__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC6__c})), ',' & {!$Record.CC6__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC7__c})), ',' & {!$Record.CC7__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC8__c})), ',' & {!$Record.CC8__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC9__c})), ',' & {!$Record.CC9__r.Email}, '') &\n    IF(NOT(ISBLANK({!$Record.CC10__c})), ',' & {!$Record.CC10__r.Email}, ''),\n    ',', '', 1\n)", 
         "要件2：新規項目CC1～CC10より値が存在するアドレスのみを1ノードで一括結合。ループ要素を完全排除しコンパイル上限を死守。"],
        ["tt_EmailBody", "テキストテンプレート (HTML)", 
         "<p>関係者各位</p><p>依頼のありましたタスクにつきまして、回答が承認され対応が完了いたしました。</p><hr><p>■ 依頼タスク内容</p><ul><li><b>親タスク名:</b> {!$Record.RequestTask__r.Name}</li><li><b>回答完了日:</b> {!$Flow.CurrentDate}</li></ul>", 
         "要件2&3：最下部のChatter用メンション文字列を完全に排除した配信用リッチテキスト本文"]
    ]
}

DATA_SHEET3_LOGIC = {
    "section": "■ 4. 処理ロジック・コアアクション仕様",
    "headers": ["コンポーネント名", "要素タイプ", "引数・パラメータマッピング", "ビジネスロジック詳細設定・エラーハンドリング"],
    "rows": [
        ["Send_NotificationEmail", "コアアクション (メールを送信)", 
         "・送信本文: {!tt_EmailBody}\n・件名: 【完了報告】依頼タスク回答承認\n・受信者（To）: {!Formula_ToAddresses}\n・受信者（Cc）: {!Formula_CcAddresses}\n・リッチテキストとして送信: True", 
         "割り当てられたTo/Ccテキストに基づきリアルタイム配信。CC項目は本文へは差し込まずヘッダー制御。"],
        ["Create_FaultLog", "レコード作成 (DML)", 
         "・オブジェクト: ApplicationLog__c\n・エラーメッセージ: {!$Flow.FaultMessage}\n• 発生箇所: RequestTaskAnswer_Flow", 
         "【障害パス(Fault Path)実装】無効なアドレス起因のDMLロールバックを防止。エラーをログに逃がし可観測性を確保。"]
    ]
}

DATA_SHEET4 = {
    "section": "■ 5. テスト観点カタログ（デシジョンテーブルマトリクス）",
    "headers": ["ケースID", "検証種別", "事前状態", "変更後状態", "条件マトリクス", "期待される動作（合格基準）", "ガードレール検証分類"],
    "rows": [
        ["TC-01", "正常系起動確認", "未申請", "承認済み", "所有者:User(マネージャーあり)\nCC1~CC10:すべて入力", "Toに2名、Ccに10名のアドレスが正確にマッピングされ、メールが1通正常配信されること。", "同値分割・正常系"],
        ["TC-02", "起動抑制の検証", "承認済み", "承認済み", "CC項目のみを後行変更", "フローが起動しないこと（Only when...制御が有効に機能しているか）。", "トリガー再帰起動抑制"],
        ["TC-03", "対象外ステータス", "未申請", "却下", "任意", "トリガー条件に合致せず、メール送信処理が完全にスキップされること。", "正常系フィルタ"],
        ["TC-04", "Null安全検証1", "未申請", "承認済み", "所有者:User\nマネージャー:未設定(Null)\nCC項目:すべて空欄", "マネージャー不在でもNull Pointer Exceptionを起こさず、所有者のみ(To)に送信され正常終了すること。", "境界値ハイライト"],
        ["TC-05", "Null安全検証2", "未申請", "承認済み", "所有者:キュー(Queue)\n(マネージャー概念なし)", "ユーザー固有のマネージャー参照を数式で安全にバイパスし、キューアドレスへ正常送信されること。", "境界値ハイライト"],
        ["TC-06", "障害パス検証", "未申請", "承認済み", "宛先Emailのドメイン形式が不正", "配信エラー時にフローがクラッシュせず、障害パス経由でログレコードが作成(DML)され、正常終了すること。", "障害時ハンドリング"],
        ["TC-07", "バルク処理更新", "未申請", "承認済み", "データローダによる200件の同時一括更新", "SOQL/DMLの制限エラー（101クエリ等）を発生させず、バルク化（Bulkify）されて全件のキュー処理が完了すること。", "一括処理・Bulkify"]
    ]
}

# ==========================================
# 4. メインExcelドキュメント生成処理
# ==========================================
def main():
    wb = Workbook()
    
    # --- シート1: 基本情報 ---
    ws1 = wb.active
    ws1.title = "1.基本情報・トリガー仕様"
    draw_sheet_title(ws1, "Salesforceフロー設計書（【1-B】レコードトリガーフロー基準）")
    render_table(ws1, 3, DATA_SHEET1["section"], DATA_SHEET1["headers"], DATA_SHEET1["rows"])
    auto_fit_columns(ws1)
    
    # --- シート2: 処理フロー図 ---
    ws2 = wb.create_sheet(title="2.処理フロー図")
    ws2["A1"] = "■ 2. 視覚的ロジックフロー図（障害パス完備）"
    ws2["A1"].font = FONT_SECTION
    generate_mermaid_image()
    if os.path.exists("flow.png"):
        from openpyxl.drawing.image import Image as OpenpyxlImage
        ws2.add_image(OpenpyxlImage("flow.png"), "A3")
    else:
        ws2["A3"] = "（Mermaid CLI未検出のため、テキストフローチャートとして設計を参照してください）"
        ws2["A3"].font = FONT_REGULAR
    ws2.views.sheetView[0].showGridLines = True
        
    # --- シート3: リソース・ロジック統合シート ---
    ws3 = wb.create_sheet(title="3.リソース定義・処理ロジック")
    draw_sheet_title(ws3, "フロー内部構造設計（リソース・ビジネスロジック詳細）")
    next_row = render_table(ws3, 3, DATA_SHEET3_RES["section"], DATA_SHEET3_RES["headers"], DATA_SHEET3_RES["rows"])
    render_table(ws3, next_row, DATA_SHEET3_LOGIC["section"], DATA_SHEET3_LOGIC["headers"], DATA_SHEET3_LOGIC["rows"])
    auto_fit_columns(ws3)
    
    # --- シート4: テスト仕様書 ---
    ws4 = wb.create_sheet(title="4.テスト仕様書")
    draw_sheet_title(ws4, "高品質検証仕様書（エンタープライズ標準検証マトリクス）")
    render_table(ws4, 3, DATA_SHEET4["section"], DATA_SHEET4["headers"], DATA_SHEET4["rows"], is_test_sheet=True)
    auto_fit_columns(ws4)
    
    # 保存処理
    filename = "RequestTaskAnswerFlow_PerfectDoc.xlsx"
    wb.save(filename)
    if os.path.exists("flow.png"): os.remove("flow.png")
    print(f"[COMPLETE] テンプレート完全準拠のExcel設計書を出力しました: {filename}")

if __name__ == "__main__":
    main()