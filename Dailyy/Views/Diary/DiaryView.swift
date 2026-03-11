import SwiftUI

// MARK: - Diary Main View
struct DiaryView: View {
    @ObservedObject var vm: DiaryViewModel
    @EnvironmentObject var localization: LocalizationManager
    @State private var showAddSheet = false
    @State private var selectedEntry: DiaryEntry?
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 0) {
            // Left: Entry list
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField(localization.string("diary.search.placeholder"), text: $vm.searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding([.horizontal, .top], 16)
                .padding(.bottom, 10)

                Divider()

                if vm.filteredEntries.isEmpty {
                    EmptyStateView(icon: "book", title: localization.string("diary.empty.title"),
                                   subtitle: localization.string("diary.empty.subtitle"))
                } else {
                    ScrollView {
                        MoodAnalyticsView(vm: vm)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        
                        LazyVStack(spacing: 1) {
                            ForEach(vm.filteredEntries) { entry in
                                DiaryRowItem(entry: entry, isSelected: selectedEntry?.id == entry.id) {
                                    withAnimation(.spring(response: 0.3)) { selectedEntry = entry }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 260)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Right: Editor / detail
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let entry = selectedEntry {
                        DiaryEditorView(entry: entry, vm: vm, onDelete: {
                            selectedEntry = nil
                        })
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 52, weight: .thin))
                                .foregroundStyle(.secondary)
                            Text(localization.string("diary.select.prompt"))
                                .font(.appBody).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                FloatingAddButton { showAddSheet = true }
                    .padding(28)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddDiarySheet(vm: vm, onCreated: { entry in
                selectedEntry = entry
            })
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { appeared = true }
        }
    }
}

// MARK: - Diary Row
struct DiaryRowItem: View {
    let entry: DiaryEntry
    let isSelected: Bool
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(entry.mood ?? "📓")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 3) {
                    if let date = entry.date {
                        Text(date.dayMonthYear)
                            .font(.appBody).fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    Text(entry.content ?? "")
                        .font(.appCaption).foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected
                ? Color.accentPrimary.opacity(0.12)
                : (hovered ? Color.accentPrimary.opacity(0.06) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: hovered)
        .onHover { hovered = $0 }
    }
}

// MARK: - Diary Editor
struct DiaryEditorView: View {
    let entry: DiaryEntry
    @ObservedObject var vm: DiaryViewModel
    let onDelete: () -> Void
    @EnvironmentObject var localization: LocalizationManager

    @State private var content: String = ""
    @State private var mood: String = ""
    @State private var isEditing = false

    var wordCount: Int {
        content.split { $0.isWhitespace }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toolbar
            HStack {
                Text(entry.date?.dayMonthYear ?? "").font(.appCaption).foregroundStyle(.secondary)
                Spacer()
                Text(L("diary.words", wordCount)).font(.appCaption).foregroundStyle(.secondary)
                if isEditing {
                    Button(localization.string("diary.save")) { save() }
                        .buttonStyle(.borderedProminent).tint(.accentPrimary)
                        .font(.appCaption)
                }
                Button(role: .destructive) {
                    vm.deleteEntry(entry)
                    onDelete()
                } label: {
                    Image(systemName: "trash").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Mood display
                    HStack(spacing: 8) {
                        Text(mood).font(.system(size: 36))
                        Picker("", selection: $mood) {
                            ForEach(Mood.allCases) { m in
                                Text("\(m.rawValue) \(m.label)").tag(m.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    // Content
                    TextEditor(text: $content)
                        .font(.appBody)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 300)
                        .onChange(of: content) { _, _ in isEditing = true }
                }
                .padding(28)
            }
        }
        .onAppear { loadEntry() }
        .onChange(of: entry.id) { _, _ in loadEntry() }
    }

    private func loadEntry() {
        content = entry.content ?? ""
        mood = entry.mood ?? Mood.happy.rawValue
        isEditing = false
    }

    private func save() {
        vm.updateEntry(entry, title: "", content: content, mood: mood)
        isEditing = false
    }
}

// MARK: - Add Diary Sheet
struct AddDiarySheet: View {
    @ObservedObject var vm: DiaryViewModel
    let onCreated: (DiaryEntry) -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager

    @State private var content = ""
    @State private var mood: Mood = .happy
    @State private var date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(localization.string("diary.add.title")).font(.appTitle)

            // Mood picker
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.string("diary.add.mood")).font(.appCaption).foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(Mood.allCases) { m in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { mood = m }
                        } label: {
                            VStack(spacing: 4) {
                                Text(m.rawValue).font(.system(size: 28))
                                Text(m.label).font(.system(size: 9, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(mood == m ? Color.accentPrimary.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(mood == m ? Color.accentPrimary : Color.clear, lineWidth: 1.5)
                            )
                            .scaleEffect(mood == m ? 1.05 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            DatePicker(localization.string("diary.add.date"), selection: $date, displayedComponents: .date)

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.string("diary.add.write")).font(.appCaption).foregroundStyle(.secondary)
                TextEditor(text: $content)
                    .font(.appBody)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            HStack {
                Button(localization.string("diary.add.cancel")) { dismiss() }
                    .buttonStyle(.plain).foregroundStyle(.secondary)
                Spacer()
                Button(localization.string("diary.add.save")) {
                    vm.addEntry(title: "", content: content, mood: mood.rawValue, date: date)
                    if let created = vm.entry(for: date) { onCreated(created) }
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent).tint(.accentPrimary)
                .disabled(content.isEmpty)
            }
        }
        .padding(28)
        .frame(width: 420, height: 560)
    }
}

#Preview {
    DiaryView(vm: DiaryViewModel(context: PersistenceController.preview.container.viewContext))
        .frame(width: 900, height: 600)
}
