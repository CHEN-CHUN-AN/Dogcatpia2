//
//  PetCareWidget.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import WidgetKit
import SwiftUI
import SwiftData

struct PetCareEntry: TimelineEntry {
    let date: Date
    let record: EnvironmentRecord?
}

struct Provider: TimelineProvider {

    @MainActor
    static let container: ModelContainer? = {
        try? ModelContainer(for: EnvironmentRecord.self)
    }()

    func placeholder(in context: Context) -> PetCareEntry {
        .init(date: .now, record: nil)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (PetCareEntry) -> Void) {
        completion(.init(date: .now, record: nil))
    }

    @MainActor
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<PetCareEntry>) -> Void) {

        let ctx = Self.container?.mainContext

        var descriptor = FetchDescriptor<EnvironmentRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        let record = try? ctx?.fetch(descriptor).first
        let entry = PetCareEntry(date: .now, record: record)

        completion(
            Timeline(entries: [entry],
                     policy: .after(.now + 300))
        )
    }
}


struct PetCareWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "PetCareWidget",
            provider: Provider()
        ) { entry in
            PetCareWidgetView(entry: entry)
        }
    }
}
