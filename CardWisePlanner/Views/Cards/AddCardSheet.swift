import SwiftUI

struct AddCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var repository: CardRepository

    @State private var name = ""
    @State private var issuer = ""
    @State private var network = "Visa"
    @State private var currencyCode = Locale.current.currency?.identifier ?? "USD"
    @State private var last4 = ""
    @State private var statementCloseDay = 15
    @State private var dueDay = 5
    @State private var billingLength = 30
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Card") {
                    TextField("Nickname", text: $name)
                    TextField("Issuer", text: $issuer)
                    TextField("Network", text: $network)
                    TextField("Currency", text: $currencyCode)
                    TextField("Last 4", text: $last4)
                        .keyboardType(.numberPad)
                }

                Section("Billing Cycle") {
                    Stepper("Statement closes day: \(statementCloseDay)", value: $statementCloseDay, in: 1...28)
                    Stepper("Due day: \(dueDay)", value: $dueDay, in: 1...28)
                    Stepper("Window length: \(billingLength) days", value: $billingLength, in: 15...45)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Add Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await saveCard() } }
                        .disabled(isSaving || issuer.isEmpty || last4.count < 4)
                }
            }
        }
    }

    private func saveCard() async {
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try repository.addCard(
                name: name,
                issuer: issuer,
                network: network,
                currencyCode: currencyCode,
                last4: last4.suffix(4).description,
                statementCloseDay: statementCloseDay,
                dueDay: dueDay,
                billingWindowLength: billingLength,
                notes: notes
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AddCardSheet()
        .modelContainer(PreviewData.container)
        .environmentObject(PreviewData.repository())
}
