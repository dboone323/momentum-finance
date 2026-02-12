import SwiftUI

struct ImportResultModalView: View {
    let result: ImportResult
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(
                    systemName: result.success
                        ? "checkmark.circle.fill"
                        : "exclamationmark.triangle.fill"
                )
                .font(.system(size: 60))
                .foregroundColor(result.success ? .green : .orange)

                Text(result.success ? "Import Successful" : "Import Completed with Issues")
                    .font(.title)
                    .bold()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Imported items:")
                        Spacer()
                        Text("\(result.itemsImported)")
                            .bold()
                    }

                    HStack {
                        Text("Failed items:")
                        Spacer()
                        Text("\(result.itemsFailed)")
                            .foregroundColor(result.itemsFailed > 0 ? .red : .primary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                if !result.validationErrors.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Validation Errors")
                            .font(.headline)
                            .padding(.horizontal)

                        List(result.validationErrors) { error in
                            VStack(alignment: .leading) {
                                Text(error.message)
                                    .font(.subheadline)
                                if let field = error.field {
                                    Text("Field: \(field)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                if !result.errors.isEmpty {
                    VStack(alignment: .leading) {
                        Text("System Errors")
                            .font(.headline)
                            .padding(.horizontal)

                        List(result.errors, id: \.self) { error in
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }

                if !result.warnings.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Warnings")
                            .font(.headline)
                            .padding(.horizontal)

                        List(result.warnings, id: \.self) { warning in
                            Text(warning)
                                .font(.subheadline)
                        }
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Import Result")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
