//
//  EntryDetailView.swift
//  CraftJournal
//
//  Created by iMac14 on 9/29/26.
//

import SwiftUI
import UIKit

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                if let photoData = entry.photo,
                   let uiImage = UIImage(data: photoData) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let date = entry.date {
                    Text(date, style: .date)
                }
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text("Notes")
                        .font(.headline)
                    
                    Text(notes)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
