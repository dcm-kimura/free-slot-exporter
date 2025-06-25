import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var authManager: GoogleAuthManager
    @State private var availableSlots: [AvailableTimeSlot] = []
    @State private var events: [CalendarEvent] = []
    @State private var groupedSchedule: [ScheduleGroup] = []
    @State private var isLoading = false
    @State private var selectedSlots: Set<UUID> = []
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarView
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        if authManager.isAuthenticated {
                            Button(action: {
                                loadMixedSchedule()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14))
                            }
                            .help("スケジュールを更新")
                        } else {
                            EmptyView()
                        }
                    }
                }
        } detail: {
            ExportPreviewView(selectedSlots: availableSlots.filter { selectedSlots.contains($0.id) })
                .navigationTitle("エクスポートプレビュー")
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            // Hide Sidebar機能を無効化
            columnVisibility = .all
        }
        .onChange(of: selectedSlots) { newValue in
        }
        .onChange(of: availableSlots.count) { _ in
            updateGroupedSchedule()
        }
        .onChange(of: events.count) { _ in
            updateGroupedSchedule()
        }
    }
    
    var sidebarView: some View {
        Group {
            if authManager.isAuthenticated {
                VStack(spacing: 0) {
                    if isLoading {
                        ProgressView("Loading schedule...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        mixedScheduleList
                    }
                    
                    // アカウント情報を下部に固定
                    VStack(spacing: 0) {
                        Divider()
                        
                        accountInfoView
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(NSColor.controlBackgroundColor))
                    }
                }
            } else {
                signInView
            }
        }
        .navigationTitle("Schedule")
        .listStyle(.sidebar)
    }
    
    
    var mixedScheduleList: some View {
        List {
            ForEach(groupedSchedule, id: \.id) { group in
                // 日付ヘッダーを通常のリスト項目として表示
                HStack {
                    Text(group.date)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                // グループ内のアイテムを表示
                ForEach(group.items, id: \.id) { item in
                    switch item {
                    case .availableSlot(let slot):
                        AvailableSlotRowView(
                            slot: slot,
                            isMultiSelected: selectedSlots.contains(slot.id)
                        )
                        .id("\(slot.id)-\(selectedSlots.contains(slot.id))")
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .onTapGesture {
                            handleSlotTap(slot)
                        }
                    case .busyEvent(let event):
                        BusyEventRowView(event: event)
                            .id(event.id)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    }
                }
            }
            
            if groupedSchedule.isEmpty {
                HStack {
                    Spacer()
                    Text("No schedule data found")
                        .foregroundColor(.secondary)
                        .font(.body)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 20)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden)
        .onAppear {
            if groupedSchedule.isEmpty {
                loadMixedSchedule()
            }
        }
    }
    
    var accountInfoView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let email = authManager.userEmail {
                    HStack {
                        if let profileImageURL = authManager.userProfileImageURL,
                           let url = URL(string: profileImageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                        
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Button("ログアウト") {
                authManager.signOut()
                availableSlots = []
                events = []
                groupedSchedule = []
                selectedSlots = []
            }
            .font(.caption)
            .foregroundColor(.red)
        }
    }
    
    var signInView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Sign in to view your calendar")
                .font(.title3)
            
            Button("Sign in with Google") {
                authManager.signIn()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func loadMixedSchedule() {
        isLoading = true
        authManager.fetchMixedSchedule { fetchedSlots, fetchedEvents in
            self.availableSlots = fetchedSlots
            self.events = fetchedEvents
            self.updateGroupedSchedule()
            self.isLoading = false
        }
    }
    
    func updateGroupedSchedule() {
        self.groupedSchedule = createGroupedSchedule()
    }
    
    func handleSlotTap(_ slot: AvailableTimeSlot) {
        // チェックボックスの選択状態を切り替え
        toggleSlotSelection(slot)
    }
    
    func toggleSlotSelection(_ slot: AvailableTimeSlot) {
        let wasSelected = selectedSlots.contains(slot.id)
        if wasSelected {
            selectedSlots.remove(slot.id)
        } else {
            selectedSlots.insert(slot.id)
        }
    }
    
    
    
    func createGroupedSchedule() -> [ScheduleGroup] {
        // 空きスロットと予定を合わせてScheduleItemの配列を作成
        var allItems: [ScheduleItem] = []
        
        for slot in availableSlots {
            allItems.append(.availableSlot(slot))
        }
        
        for event in events {
            allItems.append(.busyEvent(event))
        }
        
        // 日付でグループ化
        let grouped = Dictionary(grouping: allItems) { item in
            item.formattedDate
        }
        
        let calendar = Calendar.current
        
        return grouped.compactMap { (dateString, items) in
            // 各日付内で時間順にソート（安定化のためにIDも考慮）
            let sortedItems = items.sorted { item1, item2 in
                guard let time1 = item1.startTime,
                      let time2 = item2.startTime else {
                    return item1.id < item2.id // fallback to ID for stability
                }
                if time1 == time2 {
                    return item1.id < item2.id // 同じ時間の場合はIDでソート
                }
                return time1 < time2
            }
            
            // ソート用のDateオブジェクトを取得（最初のアイテムの日付を使用）
            guard let firstItem = sortedItems.first,
                  let firstStartTime = firstItem.startTime else {
                return nil
            }
            
            let sortDate = calendar.startOfDay(for: firstStartTime)
            
            return ScheduleGroup(date: dateString, sortDate: sortDate, items: sortedItems)
        }
        .sorted { group1, group2 in
            // 実際のDateオブジェクトで正確な時系列ソート
            return group1.sortDate < group2.sortDate
        }
    }
}

enum ScheduleItem {
    case availableSlot(AvailableTimeSlot)
    case busyEvent(CalendarEvent)
    
    var id: String {
        switch self {
        case .availableSlot(let slot):
            return "slot-\(slot.id)"
        case .busyEvent(let event):
            return "event-\(event.id)"
        }
    }
    
    var startTime: Date? {
        switch self {
        case .availableSlot(let slot):
            return slot.startTime
        case .busyEvent(let event):
            return event.startTime
        }
    }
    
    var formattedDate: String {
        switch self {
        case .availableSlot(let slot):
            return slot.formattedDate
        case .busyEvent(let event):
            return event.formattedDate
        }
    }
}

struct ScheduleGroup: Identifiable {
    let id = UUID()
    let date: String
    let sortDate: Date
    let items: [ScheduleItem]
}

struct BusyEventRowView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 選択不可を示すアイコン
            Image(systemName: "minus.circle")
                .foregroundColor(.gray)
                .font(.system(size: 16))
                .frame(width: 20, height: 20)
            
            Rectangle()
                .fill(Color.red)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.summary)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack {
                    Label(event.formattedTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = event.location, !location.isEmpty {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}

struct AvailableSlotRowView: View {
    let slot: AvailableTimeSlot
    let isMultiSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 常にチェックボックスを表示
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isMultiSelected ? Color.green : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isMultiSelected ? Color.green : Color.gray, lineWidth: 2)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isMultiSelected)
                
                if isMultiSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                        .scaleEffect(isMultiSelected ? 1.0 : 0.1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isMultiSelected)
                }
            }
            
            Rectangle()
                .fill(Color.green)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("空き")
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Label(slot.formattedTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(slot.formattedDuration, systemImage: "hourglass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(isMultiSelected ? Color.green.opacity(0.15) : Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isMultiSelected)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isMultiSelected ? Color.green : Color.clear, lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isMultiSelected)
        )
        .contentShape(Rectangle())
    }
}

struct ExportPreviewView: View {
    let selectedSlots: [AvailableTimeSlot]
    
    var exportText: String {
        if selectedSlots.isEmpty {
            return ""
        }
        let exportLines = selectedSlots.map { $0.exportTextJapanese }
        return exportLines.joined(separator: "\n")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー部分
            if !selectedSlots.isEmpty {
                HStack {
                    Label("\(selectedSlots.count)個のスロットを選択中", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("クリップボードにコピー") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(exportText, forType: .string)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                Divider()
            }
            
            // メインコンテンツ
            if selectedSlots.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("スロットを選択してください")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("左側のリストからスロットを選択すると、ここにエクスポート内容のプレビューが表示されます。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(exportText)
                            .textSelection(.enabled)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text("このテキストはクリップボードにコピーして共有できます。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}