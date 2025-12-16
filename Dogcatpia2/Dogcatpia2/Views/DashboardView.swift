//
//  DashboardView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext) private var context
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        TabView {
            // Tab 1: 首頁 (環境監控)
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Picker("模式", selection: $vm.pet) {
                            ForEach(PetType.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // 溫濕度卡片
                        HStack(spacing: 16) {
                            InfoCardView(
                                title: "溫度",
                                value: "\(vm.temperature) °C",
                                icon: "thermometer"
                            )

                            InfoCardView(
                                title: "濕度",
                                value: "\(vm.humidity) %",
                                icon: "drop"
                            )
                        }
                        .padding(.horizontal)

                        // 舒適度提示
                        let status = vm.pet.comfortStatus(temp: vm.temperature, humidity: vm.humidity)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: status.isComfortable ? "face.smiling" : "exclamationmark.triangle")
                                    .font(.title)
                                    .foregroundStyle(status.isComfortable ? .green : .orange)

                                Text(status.message)
                                    .font(.headline)
                                    .foregroundStyle(status.isComfortable ? .primary : .secondary)
                            }

                            Text(status.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(status.isComfortable ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        Button("更新資料") {
                            Task { await vm.refresh(context: context) }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("🐾 毛孩環境")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .tabItem {
                Label("首頁", systemImage: "house.fill")
            }

            // Tab 2: 歷史紀錄
            NavigationStack {
                VStack {
                    TemperatureChartView()
                        .padding()
                    Spacer()
                }
                .navigationTitle("歷史紀錄")
            }
            .tabItem {
                Label("紀錄", systemImage: "chart.xyaxis.line")
            }

            // Tab 3: 待辦事項
            NavigationStack {
                ScrollView {
                    TodoSectionView()
                        .padding()
                }
                .navigationTitle("待辦事項")
            }
            .tabItem {
                Label("待辦", systemImage: "checklist")
            }

            // Tab 4: 毛孩日記
            DiaryView()
                .tabItem {
                    Label("日記", systemImage: "book.closed.fill")
                }

            // Tab 5: 遛狗天氣
            NavigationStack {
                DogWalkingWeatherView()
            }
            .tabItem {
                Label("天氣", systemImage: "cloud.sun.fill")
            }
        }
        .alert("錯誤", isPresented: Binding<Bool>(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
