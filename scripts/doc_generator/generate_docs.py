import os
import json
import platform
import subprocess
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

def auto_fit_columns(ws):
    """全角文字と改行を正確に考慮した自動幅調整ロジック"""
    ws.views.sheetView[0].showGridLines = True
    for col in ws.columns:
        max_len = 0
        col_letter = get_column_letter(col[0].column)
        for cell in col:
            if cell.value is not None:
                lines = str(cell.value).split('\n')
                for line in lines:
                    # 全角を2バイト、半角を1バイトとして計算
                    length = sum(2 if ord(c) > 128 else 1 for c in line)
                    if length > max_len:
                        max_len = length
        ws.column_dimensions[col_letter].width = max(max_len + 4, 11)

def generate_mermaid_image():
    """OS判定・Puppeteerクラッシュ対策を完備した自己完結型画像化ロジック"""
    mermaid_text = """graph TD
    Start[トリガー: 依頼タスク回答の保存時<br/>状況 = '承認済み' かつ 更新時のみ] --> Dec_ExistParent{親の依頼タスクは<br/>存在するか？}
    Dec_ExistParent -- YES --> Ass_PrepareEmails[変数割り当て:<br/>To宛先 / Cc宛先リストの構築]
    Dec_ExistParent -- NO --> Act_LogError_NoParent[障害処理:<br/>エラーログを記録 / フロー終了]
    Ass_PrepareEmails --> Act_SendEmail[コアアクション:<br/>メールを送信]
    Act_SendEmail -->|正常完了| End_Success([フロー正常終了])
    Act_SendEmail -.->|障害発生| Act_CreateFaultLog[障害処理:<br/>カスタムエラーログレコードの作成]
    Act_CreateFaultLog --> End_Fault([フロー異常終了])
"""
    config_path = "puppeteerConfig.json"
    mmd_path = "flow.mmd"
    png_path = "flow.png"
    
    # Puppeteerサンドボックス回避設定の動的生成
    config_data = {"args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"]}
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config_data, f)
        
    with open(mmd_path, "w", encoding="utf-8") as f:
        f.write(mermaid_text)
        
    # OS自動判定
    current_os = platform.system()
    cmd = "mmdc.cmd" if current_os == "Windows" else "mmdc"
    shell_opt = True if current_os == "Windows" else False
    
    try:
        subprocess.run(
            [cmd, "-i", mmd_path, "-o", png_path, "-p", config_path],
            capture_output=True, text=True, shell=shell_opt, check=True
        )
        print("[SUCCESS] Mermaidフロー図(PNG)を正常に自動生成しました。")
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        stderr_msg = e.stderr if hasattr(e, 'stderr') else str(e)
        print(f"[WARNING] mmdcの呼び出しに失敗したため、画像挿入をスキップします。詳細:\n{stderr_msg}")
    finally:
        # 冪等性を保つための確実なクリーンアップ
        for path in [config_path, mmd_path]:
            if os.path.exists(path):
                os.remove(path)

def create_excel_report():
    wb = Workbook()
    
    # 共通スタイル定義
    font_name = "BIZ UDPゴシック"
    title_fill = PatternFill(start_color="2F5597", end_color="2F5597", fill_type="solid")
    header_fill = PatternFill(start_color="2F5597", end_color="2F5597", fill_type="solid")
    zebra_fill = PatternFill(start_color="F2F4F8", end_color="F2F4F8", fill_type="solid")
    fault_fill = PatternFill(start_color="FFF2CC", end_color="FFF2CC", fill_type="solid")
    
    title_font = Font(name=font_name, size=16, bold=True, color="FFFFFF")
    section_font = Font(name=font_name, size=12, bold=True)
    header_font = Font(name=font_name, size=10, bold=True, color="FFFFFF")
    bold_font = Font(name=font_name, size=10, bold=True)
    regular_font = Font(name=font_name, size=10, bold=False)
    
    thin_border = Border(
        left=Side(style='thin', color='BFBFBF'),
        right=Side(style='thin', color='BFBFBF'),
        top=Side(style='thin', color='BFBFBF'),
        bottom=Side(style='thin', color='BFBFBF')
    )
    
    # --- タブ1: 1.基本情報・トリガー仕様 ---
    ws1 = wb.active
    ws1.title = "1.基本情報・トリガー仕様"
    
    ws1.merge_cells("A1:C1")
    ws1["A1"] = "Salesforceフロー設計書（依頼タスク回答自動化）"
    ws1["A1"].font = title_font
    ws1["A1"].fill = title_fill
    ws1["A1"].alignment = Alignment(horizontal="center", vertical="center")
    ws1.row_dimensions[1].height = 40
    
    ws1["A3"] = "■ フロー基本定義"
    ws1["A3"].font = section_font
    
    headers1 = ["設定項目", "定義内容", "Salesforceシステム仕様・アーキテクチャ根拠"]
    for col_num, header in enumerate(headers1, 1):
        cell = ws1.cell(row=4, column=col_num, value=header)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal="center")
    
    specs1 = [
        ("フロー表示名", "依頼タスク回答：承認時完了メール通知フロー", "業務要件に準拠した分かりやすい表示名"),
        ("API参照名", "RequestTaskAnswer_ApprovedNotificationFlow", "オブジェクト名_トリガー契機の標準命名規則"),
        ("トリガーオブジェクト", "依頼タスク回答 (RequestTaskAnswer__c)", "新設の標準カスタムオブジェクト"),
        ("トリガー契機", "レコードが更新されたとき", "状況(Status__c)の更新イベントを補足するためAfter-Saveを採用"),
        ("エントリー条件", "Status__c 等しい '承認済み'", "要件1：承認済みとなった場合のみに限定"),
        ("条件の評価制限", "条件の要件に一致するようにレコードを更新したときのみ", "非同期・経時処理のセーフティガード。再帰起動による無限ループとガバナの枯渇を完全阻止"),
        ("最適化目標", "アクションと関連要素 (After-Save)", "関連オブジェクト（親タスク）へのアクセスおよび外部サービス（メール送信）実行のため")
    ]
    
    for row_num, row_data in enumerate(specs1, 5):
        for col_num, val in enumerate(row_data, 1):
            cell = ws1.cell(row=row_num, column=col_num, value=val)
            cell.font = regular_font
            cell.border = thin_border
            if row_num % 2 == 0:
                cell.fill = zebra_fill
    
    auto_fit_columns(ws1)
    
    # --- タブ2: 2.処理フロー図 ---
    ws2 = wb.create_sheet(title="2.処理フロー図")
    ws2["A1"] = "■ 視覚的ロジックフロー（正常系・障害系網羅）"
    ws2["A1"].font = section_font
    
    # スクリプト実行環境にmmdcがあれば画像挿入を実行
    generate_mermaid_image()
    if os.path.exists("flow.png"):
        from openpyxl.drawing.image import Image as OpenpyxlImage
        img = OpenpyxlImage("flow.png")
        ws2.add_image(img, "A3")
    else:
        ws2["A3"] = "（※環境に @mermaid-js/mermaid-cli がインストールされている場合、ここにフロー図イメージが自動挿入されます。未インストールの場合はMermaidテキスト定義を設計ドキュメントとして参照してください）"
        ws2["A3"].font = regular_font
        
    # --- タブ3: 3.アクション・数式詳細 ---
    ws3 = wb.create_sheet(title="3.アクション・数式詳細")
    ws3["A1"] = "■ リソース・配信用数式仕様"
    ws3["A1"].font = section_font
    
    headers3_1 = ["リソース名", "データ型", "数式 / 処理ロジック文字列", "実装上の目的（ガバナ制限回避）"]
    for col_num, header in enumerate(headers3_1, 1):
        cell = ws3.cell(row=3, column=col_num, value=header)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal="center")
        
    res_data = [
        ("Formula_ToAddresses", "テキスト", "{!$Record.RequestTask__r.Owner.Email} & ',' & {!$Record.RequestTask__r.Owner.Manager.Email}", "親の依頼タスクの所有者およびそのマネージャーのメールアドレスをカンマ区切りで動的結合"),
        ("Formula_CcAddresses", "テキスト", "BLANKVALUE({!$Record.CC1__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC2__c})), ',' & {!$Record.CC2__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC3__c})), ',' & {!$Record.CC3__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC4__c})), ',' & {!$Record.CC4__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC5__c})), ',' & {!$Record.CC5__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC6__c})), ',' & {!$Record.CC6__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC7__c})), ',' & {!$Record.CC7__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC8__c})), ',' & {!$Record.CC8__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC9__c})), ',' & {!$Record.CC9__r.Email}, '') & IF(NOT(ISBLANK({!$Record.CC10__c})), ',' & {!$Record.CC10__r.Email}, '')", "要件2：新規拡張項目CC1～CC10より、値が設定されている有効なメールアドレスのみを1ノードで一括抽出・整形（ループ内SOQLを完全排除）"),
        ("tt_EmailBody", "テキストテンプレート (HTML)", "<p>関係者各位</p><p>ご依頼のありましたタスクにつきまして、回答が承認され対応が完了いたしました。</p><hr><p>■ 依頼タスク内容</p><ul><li><b>親タスク名:</b> {!$Record.RequestTask__r.Name}</li><li><b>回答者:</b> {!$Record.Owner.LastName} {!$Record.Owner.FirstName}</li></ul><p>詳細はSalesforceシステムへログインの上、該当レコードをご確認ください。</p>", "要件2&3：最下部のChatter用メンション文字列を完全に排除した、クリーンな配信用メール本文")
    ]
    
    for row_num, row_data in enumerate(res_data, 4):
        for col_num, val in enumerate(row_data, 1):
            cell = ws3.cell(row=row_num, column=col_num, value=val)
            cell.font = regular_font
            cell.border = thin_border
            if row_num % 2 == 0:
                cell.fill = zebra_fill
            if col_num == 3:
                cell.alignment = Alignment(wrap_text=True)

    ws3["A9"] = "■ メール送信コアアクション定義 (`Send Email` Action)"
    ws3["A9"].font = section_font
    
    headers3_2 = ["引数（パラメータ）", "設定リソース / 固定値", "動作仕様"]
    for col_num, header in enumerate(headers3_2, 1):
        cell = ws3.cell(row=10, column=col_num, value=header)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal="center")
        
    action_data = [
        ("送信本文", "{!tt_EmailBody}", "定義されたHTMLテキストテンプレートを出力"),
        ("件名", "【完了報告】依頼タスク回答が承認されました（タスク: {!$Record.RequestTask__r.Name}）", "オブジェクトの動的名称を含むシステム通知共通タイトル"),
        ("受信者（To）", "{!Formula_ToAddresses}", "親タスク所有者およびそのマネージャー"),
        ("受信者（Cc）", "{!Formula_CcAddresses}", "CC1～CC10のカスタム参照ユーザー群"),
        ("リッチテキスト本文として送信", "$GlobalConstant.True", "HTMLタグによる整形表示を有効化")
    ]
    
    for row_num, row_data in enumerate(action_data, 11):
        for col_num, val in enumerate(row_data, 1):
            cell = ws3.cell(row=row_num, column=col_num, value=val)
            cell.font = regular_font
            cell.border = thin_border
            if row_num % 2 == 0:
                cell.fill = zebra_fill

    auto_fit_columns(ws3)

    # --- タブ4: 4.テスト仕様書 ---
    ws4 = wb.create_sheet(title="4.テスト仕様書")
    ws4["A1"] = "■ テスト観点カタログ（デシジョンテーブル・バルク検証）"
    ws4["A1"].font = section_font
    
    headers4 = ["ケースID", "検証種別", "事前状態 (Status__c)", "変更後状態 (Status__c)", "親タスク/CC項目条件", "期待される動作（合格基準）", "テスト分類"]
    for col_num, header in enumerate(headers4, 1):
        cell = ws4.cell(row=3, column=col_num, value=header)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal="center")
        
    test_cases = [
        ("TC-01", "正常系起動確認", "未申請", "承認済み", "親タスク所有者/マネージャー存在、CC1~CC10全入力", "Toに2名、Ccに10名のメールアドレスが正確にマッピングされ、メールが1通正常に配信されること。", "同値分割・正常系"),
        ("TC-02", "起動抑制確認", "承認済み", "承認済み", "CC項目のみ値を変更", "フローが起動しないこと（不要な多重配信が完全に抑制されていること）。", "境界値・トリガー制御"),
        ("TC-03", "対象外ステータス", "未申請", "却下", "任意", "フローが起動せず、メール送信アクションへ流れないこと。", "正常系・フィルタ"),
        ("TC-04", "Null安全検証", "未申請", "承認済み", "親マネージャー未設定、CC項目すべて空欄(Null)", "マネージャー不在でもエラー(Null Pointer)にならず、親所有者のみにTo送信されCcがスキップされて正常終了すること。", "異常系・境界値"),
        ("TC-05", "システム障害制御", "未申請", "承認済み", "宛先Emailのドメイン形式が不正", "メール送信アクションが失敗した際、フローがクラッシュせず障害パス(Fault Path)へ遷移し、エラーログがDML保存されること。", "障害時ハンドリング"),
        ("TC-06", "大量データ検証", "未申請", "承認済み", "データローダによる200件の同時一括更新", "ガバナ制限超過エラーを起こさず、200件のレコードに対する送信キュー処理がBulkify（一括化）して正常完了すること。", "ガバナ制限・Bulkify"),
        ("TC-07", "競合ロック検証", "未申請", "承認済み", "同一の親タスクに紐づく複数の子回答を同時承認", "親レコードのロック競合が起きた際も、デッドロックでクラッシュせずSalesforceの標準リトライアルゴリズムで正常に直列処理されること。", "同時実行ロック制御")
    ]
    
    for row_num, row_data in enumerate(test_cases, 4):
        for col_num, val in enumerate(row_data, 1):
            cell = ws4.cell(row=row_num, column=col_num, value=val)
            cell.font = regular_font
            cell.border = thin_border
            if "TC-04" in row_data[0] or "TC-05" in row_data[0]:
                cell.fill = fault_fill  # 境界値・異常系の薄黄色ハイライト
            elif row_num % 2 == 0:
                cell.fill = zebra_fill
            if col_num == 6:
                cell.alignment = Alignment(wrap_text=True)

    auto_fit_columns(ws4)
    
    # ファイル書き出し
    output_filename = "RequestTaskAnswerFlow_DesignDoc.xlsx"
    wb.save(output_filename)
    print(f"[COMPLETE] 高品質Excel設計書を書き出しました。ファイル名: {output_filename}")
    
    # クリーンアップ（画像が生成されていた場合）
    if os.path.exists("flow.png"):
        os.remove("flow.png")

if __name__ == "__main__":
    create_excel_report()