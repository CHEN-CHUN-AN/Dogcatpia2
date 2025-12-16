//
//  LocationSearchView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI

struct LocationSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""

    var onSelect: (LocationItem) -> Void

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    Section("熱門城市") {
                        ForEach(popularCities) { city in
                            Button {
                                onSelect(city)
                                dismiss()
                            } label: {
                                Text(city.name)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                } else {
                    ForEach(locationManager.searchResults) { item in
                        Button {
                            onSelect(item)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("\(item.latitude), \(item.longitude)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "搜尋城市或地點")
            .onChange(of: searchText) {
                if !searchText.isEmpty {
                    locationManager.search(query: searchText)
                }
            }
            .navigationTitle("選擇地點")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private var popularCities: [LocationItem] {
        [
            LocationItem(name: "台北市", latitude: 25.0330, longitude: 121.5654),
            LocationItem(name: "新北市", latitude: 25.0120, longitude: 121.4657),
            LocationItem(name: "台中市", latitude: 24.1477, longitude: 120.6736),
            LocationItem(name: "高雄市", latitude: 22.6273, longitude: 120.3014),
            LocationItem(name: "台南市", latitude: 22.9997, longitude: 120.2270),
            LocationItem(name: "桃園市", latitude: 24.9936, longitude: 121.3010)
        ]
    }
}

