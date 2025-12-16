//
//  DiaryView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]

    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    ContentUnavailableView("尚無日記", systemImage: "camera.macro", description: Text("記錄下毛孩的可愛瞬間吧！"))
                }

                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(entry.date.formatted(date: .numeric, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        if let data = entry.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                        }

                        Text(entry.content)
                            .font(.body)
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("毛孩日記")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Label("新增", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDiaryView()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
}

struct AddDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State private var content: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("照片")) {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label(selectedImageData == nil ? "選擇照片" : "更換照片", systemImage: "photo")
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }

                Section(header: Text("心情記事")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                    if content.isEmpty {
                        Text("寫點什麼...")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
            }
            .navigationTitle("新增日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        let newEntry = DiaryEntry(content: content, imageData: selectedImageData)
                        modelContext.insert(newEntry)
                        dismiss()
                    }
                    .disabled(content.isEmpty && selectedImageData == nil)
                }
            }
        }
    }
}

#Preview {
    DiaryView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}

