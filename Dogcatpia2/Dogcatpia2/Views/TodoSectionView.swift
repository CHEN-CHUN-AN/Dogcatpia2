//
//  TodoSectionView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData

struct TodoSectionView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]
    @State private var newTodoTitle = ""
    @State private var isAdding = false
    @State private var hasReminder = false
    @State private var reminderDate = Date()

    let suggestions = ["遛狗", "餵食", "換水", "梳毛", "剪指甲", "洗澡"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("待辦事項")
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        isAdding.toggle()
                    }
                }) {
                    Image(systemName: isAdding ? "minus.circle.fill" : "plus.circle.fill")
                        .font(.title2)
                }
            }

            if isAdding {
                VStack(alignment: .leading, spacing: 12) {
                    // 範例建議
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    newTodoTitle = suggestion
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                            }
                        }
                    }

                    TextField("輸入事項 (例如: 遛狗)", text: $newTodoTitle)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Toggle("設定提醒", isOn: $hasReminder)
                            .labelsHidden()
                        Text("設定提醒")
                            .font(.subheadline)

                        if hasReminder {
                            DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }

                        Spacer()

                        Button("新增") {
                            addTodo()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTodoTitle.isEmpty)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }

            if todos.isEmpty {
                Text("目前沒有待辦事項")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 8)
            } else {
                ForEach(todos) { todo in
                    HStack {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.isCompleted ? .green : .gray)
                            .onTapGesture {
                                toggleTodo(todo)
                            }

                        VStack(alignment: .leading) {
                            Text(todo.title)
                                .strikethrough(todo.isCompleted)
                                .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                            if let reminder = todo.reminderTime {
                                Text(reminder.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Button(action: { deleteTodo(todo) }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func addTodo() {
        let reminder = hasReminder ? reminderDate : nil
        let todo = TodoItem(title: newTodoTitle, reminderTime: reminder)
        context.insert(todo)

        if let reminderTime = reminder {
            NotificationService.shared.scheduleReminder(id: todo.id, title: todo.title, date: reminderTime)
        }

        // Reset fields
        newTodoTitle = ""
        hasReminder = false
        reminderDate = Date()
        withAnimation {
            isAdding = false
        }
    }

    private func toggleTodo(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        if todo.isCompleted {
            NotificationService.shared.cancelReminder(id: todo.id)
        } else if let reminder = todo.reminderTime, reminder > Date() {
            NotificationService.shared.scheduleReminder(id: todo.id, title: todo.title, date: reminder)
        }
    }

    private func deleteTodo(_ todo: TodoItem) {
        NotificationService.shared.cancelReminder(id: todo.id)
        context.delete(todo)
    }
}

#Preview {
    TodoSectionView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

