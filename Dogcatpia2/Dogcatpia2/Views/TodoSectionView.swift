//
//  TodoSectionView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData

enum TodoSortOption: String, CaseIterable {
    case manual = "自訂排序"
    case dateNewest = "最新優先"
    case dateOldest = "最舊優先"
    case alphabetical = "按名稱"
}

struct TodoSectionView: View {
    @Environment(\.modelContext) private var context
    @Query private var todos: [TodoItem]
    @State private var newTodoTitle = ""
    @State private var isAdding = false
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var sortOption: TodoSortOption = .manual
    @State private var editingTodo: TodoItem?

    let suggestions = ["遛狗", "餵食", "換水", "梳毛", "剪指甲", "洗澡", "吃藥", "看獸醫"]

    private var sortedTodos: [TodoItem] {
        let incomplete = todos.filter { !$0.isCompleted }
        let completed = todos.filter { $0.isCompleted }

        let sortedIncomplete: [TodoItem]
        switch sortOption {
        case .manual:
            sortedIncomplete = incomplete.sorted { $0.sortOrder < $1.sortOrder }
        case .dateNewest:
            sortedIncomplete = incomplete.sorted { $0.createdAt > $1.createdAt }
        case .dateOldest:
            sortedIncomplete = incomplete.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical:
            sortedIncomplete = incomplete.sorted { $0.title < $1.title }
        }

        return sortedIncomplete + completed.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題列
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text("待辦事項")
                        .font(.title2.bold())
                }

                Spacer()

                // 排序選單
                Menu {
                    ForEach(TodoSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isAdding.toggle()
                    }
                }) {
                    Image(systemName: isAdding ? "xmark.circle.fill" : "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(isAdding ? .red : .blue)
                }
            }

            // 統計資訊
            if !todos.isEmpty {
                HStack(spacing: 16) {
                    Label("\(todos.filter { !$0.isCompleted }.count) 待完成", systemImage: "circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Label("\(todos.filter { $0.isCompleted }.count) 已完成", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            // 新增區塊
            if isAdding {
                VStack(alignment: .leading, spacing: 14) {
                    Text("快速選擇")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // 建議標籤
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button {
                                newTodoTitle = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        newTodoTitle == suggestion
                                        ? Color.blue.opacity(0.2)
                                        : Color.gray.opacity(0.1)
                                    )
                                    .foregroundStyle(newTodoTitle == suggestion ? .blue : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("或輸入自訂事項...", text: $newTodoTitle)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    // 提醒設定
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $hasReminder) {
                            Label("設定提醒", systemImage: "bell")
                                .font(.subheadline)
                        }
                        .tint(.blue)

                        if hasReminder {
                            DatePicker("提醒時間", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .font(.subheadline)
                        }
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button {
                        addTodo()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("新增事項")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(newTodoTitle.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }

            // 待辦清單
            if todos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("目前沒有待辦事項")
                        .foregroundStyle(.secondary)
                    Text("點擊右上角 + 新增")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 10) {
                    ForEach(sortedTodos) { todo in
                        TodoRowView(
                            todo: todo,
                            onToggle: { toggleTodo(todo) },
                            onDelete: { deleteTodo(todo) },
                            onEdit: { editingTodo = todo }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .sheet(item: $editingTodo) { todo in
            EditTodoSheet(todo: todo)
        }
    }

    private func addTodo() {
        let reminder = hasReminder ? reminderDate : nil
        let maxOrder = todos.map { $0.sortOrder }.max() ?? 0
        let todo = TodoItem(title: newTodoTitle, reminderTime: reminder, sortOrder: maxOrder + 1)
        context.insert(todo)

        if let reminderTime = reminder {
            NotificationService.shared.scheduleReminder(id: todo.id, title: todo.title, date: reminderTime)
        }

        // Reset fields
        newTodoTitle = ""
        hasReminder = false
        reminderDate = Date()
        withAnimation(.spring(response: 0.3)) {
            isAdding = false
        }
    }

    private func toggleTodo(_ todo: TodoItem) {
        withAnimation(.spring(response: 0.3)) {
            todo.isCompleted.toggle()
        }
        if todo.isCompleted {
            NotificationService.shared.cancelReminder(id: todo.id)
        } else if let reminder = todo.reminderTime, reminder > Date() {
            NotificationService.shared.scheduleReminder(id: todo.id, title: todo.title, date: reminder)
        }
    }

    private func deleteTodo(_ todo: TodoItem) {
        withAnimation(.spring(response: 0.3)) {
            NotificationService.shared.cancelReminder(id: todo.id)
            context.delete(todo)
        }
    }
}

// MARK: - Todo Row View
struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 完成按鈕
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            // 內容
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                if let reminder = todo.reminderTime {
                    HStack(spacing: 4) {
                        Image(systemName: reminder < Date() ? "bell.slash" : "bell.fill")
                            .font(.caption2)
                        Text(DateService.reminderDisplay(reminder))
                            .font(.caption2)
                    }
                    .foregroundStyle(reminder < Date() ? .red : .blue)
                }
            }

            Spacer()

            // 操作按鈕
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(todo.isCompleted ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(todo.isCompleted ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Edit Todo Sheet
struct EditTodoSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var todo: TodoItem
    @State private var title: String = ""
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("事項名稱") {
                    TextField("輸入事項", text: $title)
                }

                Section("提醒") {
                    Toggle("設定提醒", isOn: $hasReminder)

                    if hasReminder {
                        DatePicker("提醒時間", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section {
                    Button("刪除此事項", role: .destructive) {
                        NotificationService.shared.cancelReminder(id: todo.id)
                        context.delete(todo)
                        dismiss()
                    }
                }
            }
            .navigationTitle("編輯事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveTodo()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                title = todo.title
                hasReminder = todo.reminderTime != nil
                reminderDate = todo.reminderTime ?? Date()
            }
        }
    }

    private func saveTodo() {
        todo.title = title

        // 更新提醒
        NotificationService.shared.cancelReminder(id: todo.id)

        if hasReminder {
            todo.reminderTime = reminderDate
            NotificationService.shared.scheduleReminder(id: todo.id, title: title, date: reminderDate)
        } else {
            todo.reminderTime = nil
        }
    }
}

#Preview {
    TodoSectionView()
        .modelContainer(for: TodoItem.self, inMemory: true)
        .padding()
}
