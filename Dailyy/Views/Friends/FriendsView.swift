import SwiftUI

// MARK: - Friends Main View
struct FriendsView: View {
    @ObservedObject var vm: FriendsViewModel
    @EnvironmentObject var localization: LocalizationManager
    @State private var showAddSheet = false
    @State private var editingFriend: Friend?
    @State private var appeared = false

    let avatarEmojis = ["🌸","🌺","🦋","🌈","⭐️","🦄","🐣","🌻","🍀","🎀","🐧","🦊","🐼","🌝","🍓"]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Search friends…", text: $vm.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(10)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: AppStyle.shadowColor, radius: 4, x: 0, y: 2)

                    // Upcoming birthdays section
                    if !vm.upcomingBirthdays.isEmpty {
                        upcomingSection
                    }

                    // All friends grid
                    SectionHeader(title: L("friends.all", vm.filteredFriends.count))

                    if vm.filteredFriends.isEmpty {
                        EmptyStateView(icon: "person.2", title: localization.string("friends.empty.title"),
                                       subtitle: localization.string("friends.empty.subtitle"))
                            .frame(height: 200)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 260))], spacing: 16) {
                            ForEach(vm.filteredFriends) { friend in
                                FriendCard(friend: friend, onEdit: { editingFriend = friend },
                                           onDelete: { vm.deleteFriend(friend) })
                            }
                        }
                    }
                }
                .padding(28)
            }

            FloatingAddButton { showAddSheet = true }
                .padding(28)
        }
        .sheet(isPresented: $showAddSheet) {
            FriendFormSheet(vm: vm, friend: nil, avatarEmojis: avatarEmojis)
        }
        .sheet(item: $editingFriend) { friend in
            FriendFormSheet(vm: vm, friend: friend, avatarEmojis: avatarEmojis)
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { appeared = true }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localization.string("friends.upcoming.birthdays"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(vm.upcomingBirthdays) { friend in
                        BirthdayMiniCard(friend: friend)
                    }
                }
            }
        }
    }
}

// MARK: - Friend Card
struct FriendCard: View {
    let friend: Friend
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var hovered = false
    @State private var appeared = false
    @State private var showConfetti = false

    var isBirthdayToday: Bool { friend.birthday?.isSameDayOfYear == true }

    var body: some View {
        VStack(spacing: 0) {
            // Header with emoji avatar
            ZStack {
                RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous)
                    .fill(LinearGradient(
                        colors: [.pastelPink.opacity(0.8), .pastelPurple.opacity(0.7)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 80)

                Text(friend.emoji ?? "👤")
                    .font(.system(size: 42))

                // Birthday sparkle
                if isBirthdayToday {
                    HStack { Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundStyle(.yellow)
                            .padding(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 80)

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(friend.name ?? "Unknown")
                    .font(.appBody).fontWeight(.semibold)

                if let loc = friend.location, !loc.isEmpty {
                    Label(loc, systemImage: "location.fill")
                        .font(.appCaption).foregroundStyle(.secondary)
                }

                if let bday = friend.birthday {
                    let days = bday.daysUntilBirthday()
                    Label(days == 0 ? L("friends.birthday.today") : (days == 1 ? L("friends.birthday.in", days) : L("friends.birthday.in.plural", days)),
                          systemImage: "gift")
                        .font(.appCaption)
                        .foregroundStyle(days <= 7 ? Color.accentSecondary : .secondary)
                }

                if let notes = friend.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.appCaption).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cardRadius, style: .continuous))
        .shadow(color: hovered ? AppStyle.shadowColor.opacity(2) : AppStyle.shadowColor,
                radius: hovered ? 14 : AppStyle.shadowRadius, x: 0, y: hovered ? 8 : AppStyle.shadowY)
        .scaleEffect(hovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: hovered)
        .onHover { hovered = $0 }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.08)) { appeared = true }
            if isBirthdayToday { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showConfetti = true } }
        }
        .overlay(alignment: .topTrailing) {
            if hovered {
                Menu {
                    Button(L("friends.card.edit"), action: onEdit)
                    Divider()
                    Button(L("friends.card.delete"), role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                        .background(Color.cardBackground.clipShape(Circle()))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
                .padding(10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay {
            if showConfetti { ConfettiView() }
        }
    }
}

// MARK: - Friend Form Sheet
struct FriendFormSheet: View {
    @ObservedObject var vm: FriendsViewModel
    let friend: Friend?
    let avatarEmojis: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager

    @State private var name = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var emoji = "🌸"
    @State private var birthdayEnabled = true
    @State private var birthday = Date()

    var isEditing: Bool { friend != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isEditing ? localization.string("friends.form.edit.title") : localization.string("friends.form.add.title")).font(.appTitle)

            // Emoji avatar picker
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.string("friends.form.avatar")).font(.appCaption).foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(avatarEmojis, id: \.self) { e in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { emoji = e }
                        } label: {
                            Text(e)
                                .font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(emoji == e ? Color.accentPrimary.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(emoji == e ? Color.accentPrimary : Color.clear, lineWidth: 1.5)
                                )
                                .scaleEffect(emoji == e ? 1.1 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            TextField(localization.string("friends.form.name"), text: $name).textFieldStyle(.roundedBorder)
            TextField(localization.string("friends.form.location"), text: $location).textFieldStyle(.roundedBorder)
            TextField(localization.string("friends.form.notes"), text: $notes).textFieldStyle(.roundedBorder)

            Toggle(localization.string("friends.form.has.birthday"), isOn: $birthdayEnabled)
            if birthdayEnabled {
                DatePicker(localization.string("friends.form.birthday"), selection: $birthday, displayedComponents: .date)
            }

            HStack {
                Button(localization.string("friends.form.cancel")) { dismiss() }.buttonStyle(.plain).foregroundStyle(.secondary)
                Spacer()
                Button(isEditing ? localization.string("friends.form.save.btn") : localization.string("friends.form.add.btn")) { submit() }
                    .keyboardShortcut(.return)
                    .buttonStyle(.borderedProminent).tint(.accentPrimary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(28)
        .frame(width: 400, height: 550)
        .onAppear { loadFriend() }
    }

    private func loadFriend() {
        guard let f = friend else { return }
        name = f.name ?? ""
        location = f.location ?? ""
        notes = f.notes ?? ""
        emoji = f.emoji ?? "🌸"
        if let b = f.birthday { birthday = b; birthdayEnabled = true }
        else { birthdayEnabled = false }
    }

    private func submit() {
        let bday: Date? = birthdayEnabled ? birthday : nil
        if let f = friend {
            vm.updateFriend(f, name: name, birthday: bday, location: location, notes: notes, emoji: emoji)
        } else {
            vm.addFriend(name: name, birthday: bday, location: location, notes: notes, emoji: emoji)
        }
        dismiss()
    }
}

#Preview {
    FriendsView(vm: FriendsViewModel(context: PersistenceController.preview.container.viewContext))
        .frame(width: 900, height: 700)
}
