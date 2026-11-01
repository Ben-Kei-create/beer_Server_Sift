import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameStore.self) private var store

    @AppStorage(SoundPlayer.soundEnabledKey) private var soundEnabled = true
    @AppStorage(SoundPlayer.hapticsEnabledKey) private var hapticsEnabled = true
    @State private var showResetConfirmation = false

    private var versionText: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("サウンド") {
                    Toggle("効果音", isOn: $soundEnabled)
                    Toggle("触覚フィードバック", isOn: $hapticsEnabled)
                }

                Section("成績") {
                    Button("成績をリセット", role: .destructive) {
                        showResetConfirmation = true
                    }
                }

                Section("アプリについて") {
                    LabeledContent("バージョン", value: versionText)
                    Link(
                        "プライバシーポリシー",
                        destination: URL(string: "https://www.givetex.org/apps/beerquiz/privacy/")!
                    )
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
            .confirmationDialog("ハイスコア・累計成績・復習リストを消去します。", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("リセットする", role: .destructive) {
                    store.resetStats()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(GameStore())
}
