import SwiftUI

struct CalendarNoteSheet: View {
    enum Mode {
        case add(defaultType: BillingEventType)
        case edit(event: BillingEvent)
    }

    let date: Date
    let mode: Mode
    let onSave: (BillingEventType, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note: String
    @State private var selectedType: BillingEventType

    init(date: Date, mode: Mode, onSave: @escaping (BillingEventType, String) -> Void) {
        self.date = date
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .add(let defaultType):
            _selectedType = State(initialValue: defaultType)
            _note = State(initialValue: "")
        case .edit(let event):
            _selectedType = State(initialValue: event.type)
            _note = State(initialValue: event.note)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    Text(date.formatted(date: .long, time: .omitted))
                        .foregroundStyle(.secondary)
                }

                Section("Kind") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(BillingEventType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .disabled(isEditingExisting)
                }

                Section("Note") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(isEditingExisting ? "Edit Note" : "Add Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selectedType, note)
                        dismiss()
                    }
                    .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var isEditingExisting: Bool {
        if case .edit = mode { return true }
        return false
    }
}

#Preview {
    CalendarNoteSheet(date: .now, mode: .add(defaultType: .customNote)) { _, _ in }
}
