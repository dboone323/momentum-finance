import MomentumFinanceCore
import SwiftData
import SwiftUI

public struct ImportExportSection: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    @State private var importResult: ImportResult?
    @State private var showingImportResult = false
    @State private var isExporting = false
    @State private var isImporting = false

    public var body: some View {
        Section {
            Button(
                action: {
                    self.showingExportSheet = true
                },
                label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Data")
                        Spacer()
                        if self.isExporting {
                            ProgressView()
                        }
                    }
                }
            )
            .disabled(self.isExporting)

            Button(
                action: {
                    self.showingImportPicker = true
                },
                label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import Data")
                        Spacer()
                        if self.isImporting {
                            ProgressView()
                        }
                    }
                }
            )
            .disabled(self.isImporting)
        } header: {
            Text("Import & Export")
        }
        .sheet(isPresented: self.$showingExportSheet) {
            DataExportView()
        }
        .sheet(isPresented: self.$showingImportPicker) {
            DataImportView()
        }
        .sheet(isPresented: self.$showingImportResult) {
            if let result = importResult {
                ImportResultView(result: result) { self.showingImportResult = false }
            }
        }
        .onChange(of: self.exportURL) { _, newURL in
            if let url = newURL {
                self.shareExportedFile(url)
            }
        }
    }

    private func shareExportedFile(_ url: URL) {
        #if os(iOS)
            let activityVC = UIActivityViewController(
                activityItems: [url], applicationActivities: nil
            )
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController
            {
                rootVC.present(activityVC, animated: true)
            }
        #else
            // On macOS, you might want to show a save panel or open the file
            NSWorkspace.shared.open(url)
        #endif
    }
}
