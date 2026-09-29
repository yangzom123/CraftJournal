//
//  ContentView.swift
//  CraftJournal
//
//  Created by iMac14 on 9/29/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>
    
    @State private var showingAddEntry = false
    
    //Search
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredEntries) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryRow(entry: entry)
                    }
                }
                .onDelete(perform: deleteEntries)
                if entries.isEmpty {

                    ContentUnavailableView(
                        "No Entries",
                        systemImage: "book.closed",
                        description: Text("Start your craft journal by adding an entry.")
                    )

                } else {

                    List {
                        ForEach(entries) { entry in
                            // Your existing EntryRow
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Craft Journal")
                            .font(.headline)

                        Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
            
            .searchable(
                text: $searchText,
                prompt: "Search entries"
            )
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
    
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

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry
    
    var body: some View {
        HStack {
            if let data = entry.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let location = entry.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            
        }
    }
}
#Preview {
    ContentView()
        .environment(\.managedObjectContext,
PersistenceController.preview.container.viewContext)
}
