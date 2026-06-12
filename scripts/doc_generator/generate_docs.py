import os
import subprocess
import openpyxl
import platform
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.drawing.image import Image

# ==========================================
# 1. 定義：埋め込みたいMermaidコード
# ==========================================
mermaid_template = """graph TD
    classDef startEnd fill:#f9f,stroke:#333,stroke-width:2px;
    classDef process fill:#bbf,stroke:#333,stroke-width:1px;
    classDef decision fill:#ff9,stroke:#333,stroke-width:1px;
    classDef fault fill:#fbb,stroke:#333,stroke-width:1px;

    Start([開始: 作成/更新]) --> EntryCheck{状況 = '申請中'}
    EntryCheck -- Yes --> ScheduledPath[24時間待機パス]
    EntryCheck -- No --> EndSkip([終了])
    
    subgraph 24時間後
        ScheduledPath --> GetPI[Get: ProcessInstance]
        GetPI --> DecPI{Pendingプロセス存在?}
        DecPI -- Yes --> GetWI[Get: Workitem]
        DecPI -- No --> EndCancel([自動キャンセル])
        GetWI --> AssignAddr[宛先: ActorId割当]
        AssignAddr --> SendEmail[Send: メール送信]
        SendEmail --> EndSuccess([正常終了])
    end
    
    GetPI -->|エラー| FaultPath[障害パス: Fault]
    GetWI -->|エラー| FaultPath
    FaultPath --> SendFault[管理者通知] --> EndFault([異常終了])

    class Start,EndSkip,EndCancel,EndSuccess,EndFault startEnd;
    class ScheduledPath,AssignAddr,SendEmail,SendFault process;
    class EntryCheck,DecPI decision;
    class GetPI,GetWI,FaultPath fault;
"""

def publish_excel_with_diagram():
    mmd_file = "temp_flow.mmd"
    png_file = "temp_flow.png"
    p_config = "puppeteerConfig.json"
    excel_file = "Flw_RequestTaskAnswerUnapprovedRemind_v3.0.xlsx"

    try:
        # ==========================================
        # 2. 自動変換：Mermaidテキスト ──► PNG画像
        # ==========================================
        print("💡 1/4: Mermaidの一時テキストファイルを生成中...")
        with open(mmd_file, "w", encoding="utf-8") as f:
            f.write(mermaid_template)

        # Linux環境でのブラウザクラッシュを完全に防ぐ設定
        with open(p_config, "w", encoding="utf-8") as pf:
            pf.write('{"args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"]}')

        print("💡 2/4: Mermaid変換エンジンを実行中...")
        is_windows = platform.system() == "Windows"
        
        # CI環境（Linux）での実行速度と安定性を最大化するため、npxを排し、事前インストールされたmmdcを直接叩く設計に変更
        cmd_name = "mmdc.cmd" if is_windows else "mmdc"

        try:
            # capture_output=True を指定し、裏側で起きたエラー文をPython側で完全に捕捉する
            result = subprocess.run(
                [cmd_name, "-i", mmd_file, "-o", png_file, "-w", "1000", "-b", "transparent", "-p", p_config], 
                shell=is_windows,
                capture_output=True,
                text=True,
                check=True
            )
            print(f"  ──► 画像生成成功: {png_file}")
            
        except subprocess.CalledProcessError as e:
            # ★可観測性（Observability）の導入: エラー発生時、GitHub Actionsのログ画面にMermaidの生のエラーログを強制出力させるガードレール
            print("\n❌【致命的エラー】Mermaidの画像レンダリングに失敗しました。詳細ログは以下を確認してください：")
            print("====================================================")
            print(f"STDOUT:\n{e.stdout}")
            print(f"STDERR:\n{e.stderr}")
            print("====================================================")
            raise e # 呼び出し元（Actions）に失敗を明示的に通知

        # ==========================================
        # 3. Excel生成：基本スタイルと器の作成
        # ==========================================
        print("💡 3/4: Excelワークブックを構築中...")
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "2.処理フロー図"
        ws.views.sheetView[0].showGridLines = True

        font_title = Font(name="Meiryo UI", size=16, bold=True, color="1F4E79")
        font_comment = Font(name="Meiryo UI", size=9, italic=True, color="595959")

        ws.cell(row=2, column=2, value="2. 視覚的処理フロー図").font = font_title
        ws.cell(row=3, column=2, value="※ 本フロー図は、Mermaidコードからパイプラインによって自動レンダリングされて挿入されています。").font = font_comment

        # ==========================================
        # 4. 画像挿入：生成したPNGをExcelへマッピング
        # ==========================================
        print("💡 4/4: レンダリング画像をExcelシートにインサート中...")
        if os.path.exists(png_file):
            img = Image(png_file)
            ws.add_image(img, "B5")

        # 保守用テキストソースの格納
        ws.cell(row=5, column=18, value="【保守用】Mermaidテキストソース").font = Font(name="Meiryo UI", size=10, bold=True)
        cell_source = ws.cell(row=6, column=18, value=mermaid_template)
        cell_source.font = Font(name="Consolas", size=9, color="595959")
        cell_source.alignment = Alignment(vertical="top", wrap_text=True)
        ws.column_dimensions['R'].width = 50

        wb.save(excel_file)
        print(f"✨【パブリッシュ完了】画像入りExcelが生成されました: {excel_file}")

    finally:
        # 5. クリーンアップ
        for temp_f in [mmd_file, png_file, p_config]:
            if os.path.exists(temp_f):
                os.remove(temp_f)
        print("🧹 一時ゴミファイルをクリーンアップしました。")

if __name__ == "__main__":
    publish_excel_with_diagram()