import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var repository: CardRepository
    let card: CreditCardAccount
    @State private var notes: String
    @State private var saveError: String?

    init(card: CreditCardAccount) {
        self.card = card
        _notes = State(initialValue: card.notes)
    }

    var body: some View {
        Form {
            Section("Overview") {
                infoRow(label: "Issuer", value: card.issuer)
                infoRow(label: "Network", value: card.network)
                infoRow(label: "Statement close", value: "Day \(card.statementCloseDay)")
                infoRow(label: "Payment due", value: "Day \(card.dueDay)")
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }

            if let saveError {
                Section {
                    Text(saveError)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(card.displayName)
        .toolbar {
            Button("Save") { Task { await saveChanges() } }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    private func saveChanges() async {
        do {
            try repository.upsert(card) { card in
                card.notes = notes
            }
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: SampleData.makeCards().first!)
            .modelContainer(PreviewData.container)
            .environmentObject(PreviewData.repository())
    }
}
