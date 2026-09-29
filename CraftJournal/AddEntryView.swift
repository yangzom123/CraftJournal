//
//  AddEntryView.swift
//  CraftJournal
//
//  Created by iMac14 on 9/29/26.
//

import SwiftUI
import CoreData
import PhotosUI
import UIKit

struct AddEntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var craftType = crafts[0]
    @State private var notes = ""

    // Camera
    @State private var image: UIImage?
    @State private var showingCamera = false

    // Photo Library
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {

        NavigationStack {

            Form {

                TextField("Title", text: $title)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                Section("Photo") {

                    // Show selected photo
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                    }

                    // Take photo using camera
                    Button {
                        showingCamera = true
                    } label: {
                        Label(
                            "Take Photo",
                            systemImage: "camera"
                        )
                    }
                    .disabled(
                        !UIImagePickerController
                            .isSourceTypeAvailable(.camera)
                    )

                    // Choose photo from library
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Choose from Photos",
                            systemImage: "photo"
                        )
                    }
                }

                TextField(
                    "Notes",
                    text: $notes,
                    axis: .vertical
                )
            }

            .navigationTitle("New Entry")

            // Camera
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image)
                    .ignoresSafeArea()
            }

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
                        saveEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }

            // Photo Picker
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?
                        .loadTransferable(type: Data.self) {

                        image = UIImage(data: data)
                    }
                }
            }
        }
    }

    private func saveEntry() {

        let entry = CraftEntry(context: viewContext)

        entry.id = UUID()
        entry.title = title
        entry.craftType = craftType
        entry.date = Date()
        entry.notes = notes

        // Save either camera photo or library photo
        entry.photo = image?.jpegData(
            compressionQuality: 0.7
        )

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save: \(error)")
        }
    }
}
