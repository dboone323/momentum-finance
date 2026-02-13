import SwiftUI

public struct DataManagementSection: View {
    @Binding var dataRetentionDays: Int
    @Binding var showingDeleteConfirmation: Bool

    public var body: some View {
        Section {
            Picker("Keep data for", selection: self.$dataRetentionDays) {
                Text("30 days").tag(30)
                Text("90 days").tag(90)
                Text("1 year").tag(365)
                Text("Forever").tag(0)
            }

            Button(role: .destructive) {
                self.showingDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete All Data")
                }
                .foregroundColor(.red)
            }
            .alert("Delete All Data", isPresented: self.$showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Handle data deletion
                }
            } message: {
                Text(
                    "This action cannot be undone. All your financial data will be permanently deleted."
                )
            }
        } header: {
            Text("Data Management")
        }
    }
}
