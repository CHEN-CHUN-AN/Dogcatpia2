//
//  WelcomeView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI

struct WelcomeView: View {
    var onStart: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "pawprint.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("動物放城市")
                    .font(.system(size: 40, weight: .bold))

                Text("一個城市寵物的照護app")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onStart) {
                Text("開始")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    WelcomeView(onStart: {})
}
