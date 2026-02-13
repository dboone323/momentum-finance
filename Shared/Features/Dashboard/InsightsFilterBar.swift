import MomentumFinanceCore
import SwiftUI

public struct InsightsFilterBar: View {
    @Binding var filterPriority: InsightPriority?
    @Binding var filterType: InsightType?

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Priority Filter
                Menu {
                    Button(action: { self.filterPriority = nil }) {
                        Label("All Priorities", systemImage: "line.3.horizontal.decrease.circle")
                    }

                    ForEach(InsightPriority.allCases, id: \.self) { priority in
                        Button(action: { self.filterPriority = priority }) {
                            Label(priority.rawValue, systemImage: "circle.fill")
                                .foregroundColor(priority.color)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(self.filterPriority?.rawValue ?? "Priority")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        self.filterPriority != nil
                            ? Color.blue.opacity(0.1)
                            : Color.gray.opacity(0.1)
                    )
                    .cornerRadius(8)
                    .foregroundColor(self.filterPriority != nil ? .blue : .primary)
                }
                .accessibilityLabel("Filter by Priority")

                // Type Filter
                Menu {
                    Button(action: { self.filterType = nil }) {
                        Label("All Types", systemImage: "tag")
                    }

                    ForEach(InsightType.allCases, id: \.self) { type in
                        Button(action: { self.filterType = type }) {
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "tag")
                        Text(self.filterType?.rawValue ?? "Type")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        self.filterType != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                    )
                    .cornerRadius(8)
                    .foregroundColor(self.filterType != nil ? .blue : .primary)
                }
                .accessibilityLabel("Filter by Type")
            }
            .padding()
        }
    }

    public init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        self._filterPriority = filterPriority
        self._filterType = filterType
    }
}
