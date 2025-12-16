//
//  InfoCardView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI

struct InfoCardView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(title).font(.caption)
                Text(value).font(.title.bold())
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
