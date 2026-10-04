//
//  ContentView.swift
//  CraftJournal
//
//  Created by iMac14 on 9/29/26.
//


import SwiftUI
import CoreData
import UIKit

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false

    // Search
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {

                // M3: Empty journal message
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries",
                        systemImage: "book.closed",
                        description: Text(
                            "Start your craft journal by adding an entry."
                        )
                    )

                // C2: No search results
                } else if filteredEntries.isEmpty {
                    ContentUnavailableView.search(text: searchText)

                // Display journal entries
                } else {
                    ForEach(filteredEntries) { entry in
                        NavigationLink {
                            EntryDetailView(entry: entry)
                        } label: {
                            EntryRow(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Craft Journal")

            // M3: Entry count
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Craft Journal")
                            .font(.headline)

                        Text(
                            "\(entries.count) \(entries.count == 1 ? "entry" : "entries")"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                // Add entry button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }

            // Display AddEntryView
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }

            // C2: Search entries by title
            .searchable(
                text: $searchText,
                prompt: "Search entries"
            )
        }
    }

    // Delete entries
    private func deleteEntries(offsets: IndexSet) {

        // Map visible rows to their actual Core Data objects.
        let entriesToDelete = offsets.map {
            filteredEntries[$0]
        }

        entriesToDelete.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }

    // C2: Filter entries by title
    private var filteredEntries: [CraftEntry] {

        if searchText.isEmpty {
            return Array(entries)
        }

        return entries.filter { entry in
            (entry.title ?? "")
                .localizedCaseInsensitiveContains(searchText)
        }
    }
}

// Journal row
struct EntryRow: View {

    @ObservedObject var entry: CraftEntry

    var body: some View {
        HStack(spacing: 12) {

            // Display saved photo
            if let data = entry.photo,
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                    .clipped()

            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            // Entry information
            VStack(alignment: .leading, spacing: 4) {

                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // M1: Display location
                if let location = entry.location,
                   !location.isEmpty {

                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // C4: Favourite button
            Button {
                entry.isFavourite.toggle()

                do {
                    try entry.managedObjectContext?.save()
                } catch {
                    print("Could not save favorite: \(error)")
                }

            } label: {
                Image(
                    systemName: entry.isFavourite
                        ? "star.fill"
                        : "star"
                )
                .foregroundStyle(
                    entry.isFavourite ? .yellow : .secondary
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
