import os
import subprocess
import openpyxl
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
    excel_file = "Flw_RequestTaskAnswerUnapprovedRemind_v3.0.xlsx"

    try:
        # ==========================================
        # 2. 自動変換：Mermaidテキスト ──► PNG画像
        # ==========================================
        print("💡 1/4: Mermaidの一時テキストファイルを生成中...")
        with open(mmd_file, "w", encoding="utf-8") as f:
            f.write(mermaid_template)

        print("💡 2/4: mermaid-cli をバックグラウンドで起動してレンダリング中...")
        
        # WindowsとMac/Linuxでコマンド名を動的に切り替え、PATH解決を確実にするガードレール
        import platform
        is_windows = platform.system() == "Windows"
        cmd_name = "mmdc.cmd" if is_windows else "mmdc"

        subprocess.run(
            [cmd_name, "-i", mmd_file, "-o", png_file, "-w", "1000", "-b", "transparent"], 
            shell=is_windows,  # Windowsの場合はシェル（cmd.exe）経由で実行させてファイル未検出を完全回避
            check=True
        )
        print(f"  ──► 画像生成成功: {png_file}")

        # ==========================================
        # 3. Excel生成：基本スタイルと器の作成
        # ==========================================
        print("💡 3/4: Excelワークブックを構築中...")
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "2.処理フロー図"
        ws.views.sheetView[0].showGridLines = True  # 枠線の表示

        # 共通デザインスタイル（カスタム指示のPolishルールに準拠）
        font_title = Font(name="Meiryo UI", size=16, bold=True, color="1F4E79")
        font_body = Font(name="Meiryo UI", size=10, bold=False, color="000000")
        font_comment = Font(name="Meiryo UI", size=9, italic=True, color="595959")
        fill_zebra = PatternFill(start_color="F2F4F8", end_color="F2F4F8", fill_type="solid")

        # タイトルと説明の配置
        ws.cell(row=2, column=2, value="2. 視覚的処理フロー図").font = font_title
        ws.cell(row=3, column=2, value="※ 本フロー図は、Mermaidコードからパイプラインによって自動レンダリングされて挿入されています。").font = font_comment

        # ==========================================
        # 4. 画像挿入：生成したPNGをExcelへマッピング
        # ==========================================
        print("💡 4/4: レンダリング画像をExcelシートにインサート中...")
        if os.path.exists(png_file):
            img = Image(png_file)
            # 画像を「B5セル」の左上を起点として配置
            ws.add_image(img, "B5")

        # 念のため、バックアップ用として元のテキストコードも右側に小さく配置しておく（メンテナンス性向上）
        ws.cell(row=5, column=18, value="【保守用】Mermaidテキストソース").font = Font(name="Meiryo UI", size=10, bold=True)
        cell_source = ws.cell(row=6, column=18, value=mermaid_template)
        cell_source.font = Font(name="Consolas", size=9, color="595959")
        cell_source.alignment = Alignment(vertical="top", wrap_text=True)
        ws.column_dimensions['R'].width = 50

        # Excelの保存
        wb.save(excel_file)
        print(f"✨【パブリッシュ完了】画像入りExcelが生成されました: {excel_file}")

    finally:
        # ==========================================
        # 5. 後片付け：不要になった一時ファイルの削除
        # ==========================================
        if os.path.exists(mmd_file):
            os.remove(mmd_file)
        if os.path.exists(png_file):
            os.remove(png_file)
        print("🧹 一時ゴミファイルをクリーンアップしました。")

if __name__ == "__main__":
    publish_excel_with_diagram()

# debug: force run