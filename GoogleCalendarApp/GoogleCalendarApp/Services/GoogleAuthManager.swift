import Foundation
import AppKit
import AppAuth

class GoogleAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var userProfileImageURL: String?
    
    private var authState: OIDAuthState?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // OAuth設定 - Config.plistから読み込む
    private let clientID: String
    private let clientSecret: String
    private let redirectURI: String
    
    init() {
        // Config.plistから設定を読み込む
        let bundle = Bundle.module
        guard let configURL = bundle.url(forResource: "Config", withExtension: "plist"),
              let config = NSDictionary(contentsOf: configURL),
              let id = config["ClientID"] as? String,
              let secret = config["ClientSecret"] as? String else {
            fatalError("Config.plist not found or missing required keys. Please create Config.plist with ClientID and ClientSecret.")
        }
        
        self.clientID = id
        self.clientSecret = secret
        // Client IDの".apps.googleusercontent.com"を除いた部分を使用
        let clientIDWithoutDomain = id.replacingOccurrences(of: ".apps.googleusercontent.com", with: "")
        self.redirectURI = "com.googleusercontent.apps.\(clientIDWithoutDomain):/oauthredirect"
        
        // デバッグ情報を出力
        print("🔧 OAuth Configuration:")
        print("   Client ID: \(self.clientID)")
        print("   Redirect URI: \(self.redirectURI)")
        print("   Client Secret: \(secret.prefix(10))...")  // セキュリティのため一部のみ表示
        print("   URI Length: \(self.redirectURI.count) characters")
        print("   URI Components: \(self.redirectURI.components(separatedBy: ":"))")
        
        loadAuthState()
    }
    
    func signIn() {
        let issuer = URL(string: "https://accounts.google.com")!
        let redirectURI = URL(string: self.redirectURI)!
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            guard let config = configuration else {
                print("Error retrieving discovery document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let request = OIDAuthorizationRequest(
                configuration: config,
                clientId: self.clientID,
                clientSecret: self.clientSecret,
                scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, "https://www.googleapis.com/auth/calendar.readonly"],
                redirectURL: redirectURI,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil
            )
            
            // macOS用のExternal User Agentを作成
            guard let window = NSApp.keyWindow else {
                print("No key window available")
                return
            }
            
            let externalUserAgent = OIDExternalUserAgentMac(presenting: window)
            
            self.currentAuthorizationFlow = OIDAuthState.authState(
                byPresenting: request,
                externalUserAgent: externalUserAgent,
                callback: { authState, error in
                    if let authState = authState {
                        print("✅ OAuth認証成功")
                        self.authState = authState
                        self.saveAuthState()
                        self.isAuthenticated = true
                        self.fetchUserEmail()
                    } else {
                        print("❌ OAuth認証エラー:")
                        print("   エラー: \(error?.localizedDescription ?? "Unknown error")")
                        if let error = error as NSError? {
                            print("   ドメイン: \(error.domain)")
                            print("   コード: \(error.code)")
                            print("   詳細: \(error.userInfo)")
                        }
                        
                        DispatchQueue.main.async {
                            // エラーを視覚的に表示
                            let alert = NSAlert()
                            alert.messageText = "Google認証エラー"
                            alert.informativeText = """
                            認証に失敗しました。
                            
                            考えられる原因:
                            • Google Cloud ConsoleでリダイレクトURIが正しく設定されていない
                            • OAuth同意画面の設定が不完全
                            • Calendar APIが有効になっていない
                            
                            エラー詳細: \(error?.localizedDescription ?? "不明")
                            """
                            alert.alertStyle = .warning
                            alert.addButton(withTitle: "OK")
                            alert.runModal()
                        }
                    }
                }
            )
        }
    }
    
    func signOut() {
        authState = nil
        isAuthenticated = false
        userEmail = nil
        userProfileImageURL = nil
        clearAuthState()
    }
    
    func fetchEvents(completion: @escaping ([CalendarEvent]) -> Void) {
        guard let authState = authState else {
            completion([])
            return
        }
        
        authState.performAction { accessToken, _, error in
            guard let accessToken = accessToken else {
                print("Error getting access token: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now)!
            
            let dateFormatter = ISO8601DateFormatter()
            let timeMin = dateFormatter.string(from: now)
            let timeMax = dateFormatter.string(from: weekFromNow)
            
            var components = URLComponents(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!
            components.queryItems = [
                URLQueryItem(name: "timeMin", value: timeMin),
                URLQueryItem(name: "timeMax", value: timeMax),
                URLQueryItem(name: "singleEvents", value: "true"),
                URLQueryItem(name: "orderBy", value: "startTime"),
                URLQueryItem(name: "maxResults", value: "50")
            ]
            
            var request = URLRequest(url: components.url!)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("Error fetching events: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let items = json?["items"] as? [[String: Any]] ?? []
                    
                    let events = items.compactMap { item -> CalendarEvent? in
                        guard let id = item["id"] as? String,
                              let summary = item["summary"] as? String else {
                            return nil
                        }
                        
                        let start = item["start"] as? [String: Any]
                        let end = item["end"] as? [String: Any]
                        
                        let dateFormatter = ISO8601DateFormatter()
                        let startDate = start?["dateTime"] as? String ?? start?["date"] as? String
                        let endDate = end?["dateTime"] as? String ?? end?["date"] as? String
                        
                        let startTime = startDate.flatMap { dateFormatter.date(from: $0) }
                        let endTime = endDate.flatMap { dateFormatter.date(from: $0) }
                        let isAllDay = start?["date"] != nil
                        
                        return CalendarEvent(
                            id: id,
                            summary: summary,
                            startTime: startTime,
                            endTime: endTime,
                            location: item["location"] as? String,
                            description: item["description"] as? String,
                            isAllDay: isAllDay
                        )
                    }
                    
                    DispatchQueue.main.async {
                        completion(events)
                    }
                } catch {
                    print("Error parsing events: \(error)")
                    completion([])
                }
            }.resume()
        }
    }
    
    func fetchAvailableTimeSlots(completion: @escaping ([AvailableTimeSlot]) -> Void) {
        fetchEvents { events in
            let availableSlots = self.calculateAvailableTimeSlots(from: events)
            completion(availableSlots)
        }
    }
    
    func fetchMixedSchedule(completion: @escaping ([AvailableTimeSlot], [CalendarEvent]) -> Void) {
        fetchEvents { events in
            let availableSlots = self.calculateAvailableTimeSlots(from: events)
            completion(availableSlots, events)
        }
    }
    
    private func calculateAvailableTimeSlots(from events: [CalendarEvent]) -> [AvailableTimeSlot] {
        let calendar = Calendar.current
        let now = Date()
        
        // 営業時間を9:00-18:00と仮定
        let workStartHour = 9
        let workEndHour = 18
        let minimumSlotDuration: TimeInterval = 30 * 60 // 30分
        
        var availableSlots: [AvailableTimeSlot] = []
        
        
        // 今日から7日間をチェック
        for dayOffset in 0..<7 {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now)) else { continue }
            
            // 週末をスキップ
            let weekday = calendar.component(.weekday, from: currentDay)
            if weekday == 1 || weekday == 7 { 
                continue 
            }
            
            guard let workStart = calendar.date(bySettingHour: workStartHour, minute: 0, second: 0, of: currentDay),
                  let workEnd = calendar.date(bySettingHour: workEndHour, minute: 0, second: 0, of: currentDay) else { continue }
            
            // その日のイベントを取得してソート
            let dayEvents = events.filter { event in
                guard let eventStart = event.startTime else { return false }
                return calendar.isDate(eventStart, inSameDayAs: currentDay) && !event.isAllDay
            }.sorted { $0.startTime! < $1.startTime! }
            
            var currentTime = max(workStart, now)
            
            for event in dayEvents {
                guard let eventStart = event.startTime,
                      let eventEnd = event.endTime else { continue }
                
                // イベント開始前に空き時間があるかチェック
                if currentTime < eventStart {
                    let duration = eventStart.timeIntervalSince(currentTime)
                    if duration >= minimumSlotDuration {
                        availableSlots.append(AvailableTimeSlot(
                            startTime: currentTime,
                            endTime: eventStart,
                            duration: duration
                        ))
                    }
                }
                
                // 次の開始時間をイベント終了時間に更新
                currentTime = max(currentTime, eventEnd)
            }
            
            // 最後のイベント後から営業時間終了まで
            if currentTime < workEnd {
                let duration = workEnd.timeIntervalSince(currentTime)
                if duration >= minimumSlotDuration {
                    availableSlots.append(AvailableTimeSlot(
                        startTime: currentTime,
                        endTime: workEnd,
                        duration: duration
                    ))
                }
            }
        }
        
        
        return availableSlots.sorted { $0.startTime < $1.startTime }
    }
    
    private func fetchUserEmail() {
        guard let authState = authState else { return }
        
        authState.performAction { accessToken, _, error in
            guard let accessToken = accessToken else { return }
            
            var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let email = json["email"] as? String else { return }
                
                let profileImageURL = json["picture"] as? String
                
                DispatchQueue.main.async {
                    self.userEmail = email
                    self.userProfileImageURL = profileImageURL
                }
            }.resume()
        }
    }
    
    private func saveAuthState() {
        guard let authState = authState else { return }
        
        let keychainItemName = "GoogleCalendarApp"
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: keychainItemName,
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        } catch {
            print("Error saving auth state: \(error)")
        }
    }
    
    private func loadAuthState() {
        let keychainItemName = "GoogleCalendarApp"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainItemName,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let authState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) else {
            return
        }
        
        self.authState = authState
        self.isAuthenticated = authState.isAuthorized
        if isAuthenticated {
            fetchUserEmail()
        }
    }
    
    private func clearAuthState() {
        let keychainItemName = "GoogleCalendarApp"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainItemName
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
