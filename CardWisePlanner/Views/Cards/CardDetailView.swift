import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var repository: CardRepository
    let card: CreditCardAccount
    @State private var notes: String

    init(card: CreditCardAccount) {
        self.card = card
        _notes = State(initialValue: card.notes)
    }

    var body: some View {
        Form {
            Section("Overview") {
                HStack {
                    Text("Issuer")
                    Spacer()
                    Text(card.issuer)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Network")
                    Spacer()
                    Text(card.network)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Statement close")
                    Spacer()
                    Text("Day \(card.statementCloseDay)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Payment due")
                    Spacer()
                    Text("Day \(card.dueDay)")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle(card.displayName)
        .toolbar {
            Button("Save") {
                try? repository.upsert(card) { card in
                    card.notes = notes
                }
            }
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
