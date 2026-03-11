import SwiftUI
import Charts

// MARK: - Budget Main View
struct BudgetView: View {
    @ObservedObject var vm: BudgetViewModel
    @EnvironmentObject var localization: LocalizationManager
    @State private var showAddSheet = false
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Month picker
                    MonthPickerView(selectedMonth: $vm.selectedMonth)

                    // Summary cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: localization.string("budget.income"),  value: vm.monthlyIncome.currencyString,  icon: "arrow.down.circle.fill", color: .pastelGreen)
                        StatCard(title: localization.string("budget.expenses"), value: vm.totalExpenses.currencyString, icon: "arrow.up.circle.fill",   color: .pastelPeach)
                        StatCard(title: localization.string("budget.balance"),  value: vm.balance.currencyString,        icon: "equal.circle.fill",      color: .pastelMint)
                    }

                    // 50/30/20 section
                    rule502030Card
                    
                    // Savings Goals
                    SavingsGoalView()

                    // Charts
                    HStack(alignment: .top, spacing: 16) {
                        categoryPieChart.frame(maxWidth: .infinity)
                        dailyBarChart.frame(maxWidth: .infinity)
                    }

                    // Transactions list
                    transactionsList
                }
                .padding(28)
            }

            // Floating add button
            FloatingAddButton { showAddSheet = true }
                .padding(28)
        }
        .sheet(isPresented: $showAddSheet) {
            AddExpenseSheet(vm: vm)
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { appeared = true }
        }
    }

    // MARK: 50/30/20 card
    private var rule502030Card: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: localization.string("budget.rule.title"))
                Spacer()
                Text(L("budget.income.label", vm.baseIncome.currencyString))
                    .font(.appCaption).foregroundStyle(.secondary)
            }

            BucketRow(label: L("budget.needs.row", vm.needsBudget.currencyString),
                      spent: vm.needsSpent, budget: vm.needsBudget, color: .needsColor)
            BucketRow(label: L("budget.wants.row", vm.wantsBudget.currencyString),
                      spent: vm.wantsSpent, budget: vm.wantsBudget, color: .wantsColor)
            BucketRow(label: L("budget.savings.row", vm.savingsBudget.currencyString),
                      spent: vm.savingsProgress, budget: vm.savingsBudget, color: .savingsColor, isSavings: true)
        }
        .cardStyle()
    }

    // MARK: Pie Chart
    private var categoryPieChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localization.string("budget.category.title"))
            if vm.categoryTotals.isEmpty {
                Text(localization.string("budget.noexpenses")).font(.appCaption).foregroundStyle(.secondary).frame(height: 160)
            } else {
                Chart(vm.categoryTotals, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(Color.forCategory(item.category))
                    .annotation(position: .overlay) {
                        if item.amount / (vm.totalExpenses + 0.0001) > 0.12 {
                            Text(item.category)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: 160)
                .chartLegend(.hidden)
            }
        }
        .cardStyle()
    }

    // MARK: Bar Chart
    private var dailyBarChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localization.string("budget.last7days"))
            Chart(vm.dailySpending, id: \.date) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(colors: [.accentPrimary, .accentSecondary],
                                   startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US")), centered: true)
                        .font(.appCaption)
                }
            }
            .frame(height: 160)
        }
        .cardStyle()
    }

    // MARK: Transactions
    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localization.string("budget.transactions"))
            if vm.monthEntries.isEmpty {
                EmptyStateView(icon: "tray", title: localization.string("budget.notransactions.title"),
                               subtitle: localization.string("budget.notransactions.subtitle"))
                    .frame(height: 120)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(vm.monthEntries) { entry in
                        TransactionRow(entry: entry, onDelete: { vm.deleteEntry(entry) })
                    }
                }
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let entry: ExpenseEntry
    let onDelete: () -> Void

    @State private var hovered = false
    @State private var appeared = false

    var isIncome: Bool { entry.type == "Income" }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.forCategory(entry.category ?? "Other").opacity(0.25))
                    .frame(width: 40, height: 40)
                Image(systemName: ExpenseCategory(rawValue: entry.category ?? "Other")?.icon ?? "circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.forCategory(entry.category ?? "Other"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.note?.isEmpty == false ? entry.note! : (entry.category ?? ""))
                    .font(.appBody).fontWeight(.medium)
                HStack(spacing: 6) {
                    TagChip(text: entry.category ?? "Other", color: Color.forCategory(entry.category ?? "Other"))
                    if let date = entry.date {
                        Text(date.dayMonthYear)
                            .font(.appCaption).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text((isIncome ? "+" : "-") + entry.amount.currencyString)
                .font(.appBody)
                .fontWeight(.semibold)
                .foregroundStyle(isIncome ? Color.accentPrimary : Color.accentSecondary)

            if hovered {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(color: AppStyle.shadowColor, radius: 4, x: 0, y: 2)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hovered)
        .onHover { hovered = $0 }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.05)) { appeared = true }
        }
    }
}

// MARK: - Month Picker
struct MonthPickerView: View {
    @Binding var selectedMonth: Date

    var body: some View {
        HStack(spacing: 14) {
            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)

            Text(selectedMonth, format: .dateTime.month(.wide).year().locale(Locale(identifier: "en_US")))
                .font(.appHeading)
                .frame(minWidth: 160)

            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Add Expense Sheet
struct AddExpenseSheet: View {
    @ObservedObject var vm: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager

    @State private var amount: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var type: TransactionType = .expense
    @State private var shakeAmount = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(localization.string("budget.add.title")).font(.appTitle).padding(.bottom, 4)

            // Type toggle
            Picker(localization.string("budget.add.type"), selection: $type) {
                ForEach(TransactionType.allCases) { t in
                    Text(t == .income ? localization.string("type.income") : localization.string("type.expense")).tag(t)
                }
            }
            .pickerStyle(.segmented)

            // Amount
            VStack(alignment: .leading, spacing: 6) {
                Label(localization.string("budget.add.amount"), systemImage: "dollarsign.circle").font(.appCaption).foregroundStyle(.secondary)
                TextField("0.00", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .font(.appMono)
                    .offset(x: shakeAmount ? -6 : 0)
            }

            // Category
            if type == .expense {
                VStack(alignment: .leading, spacing: 6) {
                    Label(localization.string("budget.add.category"), systemImage: "tag").font(.appCaption).foregroundStyle(.secondary)
                    Picker(localization.string("budget.add.category"), selection: $category) {
                        ForEach(ExpenseCategory.allCases) { c in
                            Label(c.rawValue, systemImage: c.icon).tag(c)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            // Note
            VStack(alignment: .leading, spacing: 6) {
                Label(localization.string("budget.add.note"), systemImage: "text.bubble").font(.appCaption).foregroundStyle(.secondary)
                TextField(localization.string("budget.add.note.placeholder"), text: $note)
                    .textFieldStyle(.roundedBorder)
            }

            // Date
            VStack(alignment: .leading, spacing: 6) {
                Label(localization.string("budget.add.date"), systemImage: "calendar").font(.appCaption).foregroundStyle(.secondary)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
            }

            Spacer()

            // Buttons
            HStack {
                Button(localization.string("budget.add.cancel")) { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(localization.string("budget.add.add")) { submit() }
                    .keyboardShortcut(.return)
                    .buttonStyle(.borderedProminent)
                    .tint(.accentPrimary)
            }
        }
        .padding(28)
        .frame(width: 380, height: 460)
    }

    private func submit() {
        guard let amt = Double(amount.replacingOccurrences(of: ",", with: ".")), amt > 0 else {
            withAnimation(.default.repeatCount(3, autoreverses: true)) { shakeAmount = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { shakeAmount = false }
            return
        }
        vm.addEntry(amount: amt,
                    category: type == .expense ? category.rawValue : "Other",
                    note: note, date: date, type: type.rawValue)
        dismiss()
    }
}

#Preview {
    BudgetView(vm: BudgetViewModel(context: PersistenceController.preview.container.viewContext))
        .frame(width: 900, height: 700)
}
