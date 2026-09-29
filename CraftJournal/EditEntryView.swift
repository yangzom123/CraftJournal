//
//  EditEntryView.swift
//  CraftJournal
//
//  Created by iMac14 on 9/29/26.
//
import SwiftUI
import CoreData
import PhotosUI
import UIKit

struct EditEntryView: View {

    @ObservedObject var entry: CraftEntry

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var craftType: String
    @State private var location: String
    @State private var notes: String

    init(entry: CraftEntry) {
        self.entry = entry

        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _location = State(initialValue: entry.location ?? "")
        _notes = State(initialValue: entry.notes ?? "")
    }

    var body: some View {

        NavigationStack {

            Form {

                TextField("Title", text: $title)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                TextField("Location", text: $location)

                TextField(
                    "Notes",
                    text: $notes,
                    axis: .vertical
                )
            }

            .navigationTitle("Edit Entry")

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {

        entry.title = title
        entry.craftType = craftType
        entry.location = location
        entry.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not update entry: \(error)")
        }
    }
}
