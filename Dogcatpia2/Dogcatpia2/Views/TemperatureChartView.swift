//
//  TemperatureChartView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import Charts
import SwiftData

struct TemperatureChartView: View {

    @Query private var records: [EnvironmentRecord]

    init() {
        let startOfDay = DateService.startOfToday()
        _records = Query(filter: #Predicate<EnvironmentRecord> { record in
            record.timestamp >= startOfDay
        }, sort: \EnvironmentRecord.timestamp)
    }

    var body: some View {
        Chart {
            ForEach(records) { r in
                LineMark(
                    x: .value("時間", r.timestamp),
                    y: .value("溫度", r.temperature)
                )
                .foregroundStyle(.orange)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartForegroundStyleScale([
            "溫度": .orange
        ])
        .frame(height: 200)
    }
}


