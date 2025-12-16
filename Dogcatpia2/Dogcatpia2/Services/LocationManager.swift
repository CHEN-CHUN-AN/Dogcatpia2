//
//  LocationManager.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation
import MapKit
import Combine

struct LocationItem: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

class LocationManager: NSObject, ObservableObject {
    @Published var searchResults: [LocationItem] = []
    private var cancellables = Set<AnyCancellable>()

    func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response else { return }

            self.searchResults = response.mapItems.map { item in
                LocationItem(
                    name: item.name ?? item.placemark.title ?? "未知地點",
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
            }
        }
    }
}

