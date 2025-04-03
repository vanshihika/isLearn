import UIKit
import Foundation

struct Profile: Codable {
    var id: UUID
    var name: String
    var image: Image
    var totalExperiencePoints: Int
    var currentStreak: Int
    var userLongestStreak: Int
    var userStreakBadges: [Badge] = []
    var userAchievements: [Achievement] = []
    var notifications: Bool = false
    var wordsLearned: Int
    var lastActiveDate: Date?
    var showOnboarding: Bool = true
    var learnedSigns: [String] = []
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastActiveDay = lastActiveDate else {
            currentStreak = 1
            lastActiveDate = today
            userLongestStreak = max(userLongestStreak, currentStreak)
            return
        }
        
        let dayDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActiveDay), to: today).day ?? 0
        
        if dayDifference == 1 {
            currentStreak += 1
        } else if dayDifference > 1 {
            currentStreak = 1
        }
        
        lastActiveDate = today
        userLongestStreak = max(userLongestStreak, currentStreak)
    }
}

public struct Image: Codable {
    public var photo: Data
    
    public init?(photo: UIImage) {
        guard let imageData = photo.pngData() else { return nil }
        self.photo = imageData
    }
}

class ProfileDataModel {
    static let sharedInstance = ProfileDataModel()
    private var profiles: [Profile] = []
    private var currentUserID: UUID?
    
    private let storageURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("profiles_list").appendingPathExtension("plist")
    }()
    
    private init() {
        loadProfiles()
        if profiles.isEmpty {
            let newUserID = createDummyUser()
            currentUserID = newUserID
        }
    }
    
    private func loadProfiles() {
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: storageURL),
           let decodedProfiles = try? decoder.decode([Profile].self, from: data) {
            profiles = decodedProfiles
        }
    }
    
    private func saveProfiles() {
            let encoder = PropertyListEncoder()
            if let encodedData = try? encoder.encode(profiles) {
                do {
                    try encodedData.write(to: storageURL, options: .atomic)
                    print("Profiles saved successfully.")
                } catch {
                    print("Error saving profiles: \(error)")
                }
            }
        }
    
    func setCurrentUser(_ id: UUID) {
        if profiles.contains(where: { $0.id == id }) {
            currentUserID = id
        }
    }
    
    func getCurrentUserProfile() -> Profile? {
            guard let userID = currentUserID, let index = profiles.firstIndex(where: { $0.id == userID }) else {
                print("No current user profile found. Creating a dummy user.")
                let newUserID = createDummyUser()
                currentUserID = newUserID
                return profiles.first { $0.id == newUserID }
            }
            return profiles[index]
        }

    func createDummyUser() -> UUID {
        let newUserID = UUID()
        
        let defaultImage = UIImage(named: "defaultUser") ?? UIImage(systemName: "person.fill")!

        let dummyUser = Profile(
            id: newUserID,
            name: "Guest User",
            image: (Image(photo: defaultImage) ?? Image(photo: UIImage(systemName: "person.fill")!))!,
            totalExperiencePoints: 0,
            currentStreak: 0,
            userLongestStreak: 0,
            wordsLearned: 0
        )

        profiles.append(dummyUser)
        saveProfiles()
        currentUserID = newUserID

        print("Dummy user created successfully: \(dummyUser)")
        return newUserID
    }

    func updateProfileData(_ username: String, _ userProfile: UIImage, _ userNotif: Bool) {
        guard let id = currentUserID, let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        
        profiles[index].name = username
        profiles[index].image.photo = userProfile.pngData()!
        profiles[index].notifications = userNotif
        saveProfiles()
    }
    
    func updateExperiencePoints(_ points: Int) {
            guard let id = currentUserID else {
                print("🚨 Error: currentUserID is nil")
                return
            }
            
            guard let index = profiles.firstIndex(where: { $0.id == id }) else {
                print("🚨 Error: No profile found for user \(id.uuidString)")
                return
            }

            print("🟢 Before XP Update: \(profiles[index].totalExperiencePoints)")

            profiles[index].totalExperiencePoints += points

            print("🟢 After XP Update: \(profiles[index].totalExperiencePoints)")

            saveProfiles()
            print("✅ XP Updated and Profiles Saved")
        }


    func updateCurrentStreak() {
        guard let id = currentUserID,
              let index = profiles.firstIndex(where: { $0.id == id }) else {
            print("🚨 Error: No user profile found.")
            return
        }

        print("🔄 Before increment: \(profiles[index].currentStreak)")

        profiles[index].updateStreak() // ✅ Directly call the mutating method on the struct

        print("✅ After increment: \(profiles[index].currentStreak)")

        saveProfiles() // ✅ Save the updated profile list
    }



//    func saveToStorage(_ userProfile: UserProfile) {
//        print("💾 Saving Streak: \(userProfile.currentStreak)")
//        
//        do {
//            let data = try JSONEncoder().encode(userProfile)
//            UserDefaults.standard.set(data, forKey: "UserProfile")
//            print("✅ Streak saved successfully!")
//        } catch {
//            print("❌ Error saving profile: \(error)")
//        }
//    }

    
    func addLearnedSign(for userId: UUID, with sign: String) {
        guard let index = profiles.firstIndex(where: { $0.id == userId }) else {
            print("🚨 User not found for ID: \(userId)")
            return
        }
        print("✅ Before Adding: \(profiles[index].learnedSigns)")

        if !profiles[index].learnedSigns.contains(sign) {
            profiles[index].learnedSigns.append(sign)

            print("✅ Before Saving:", profiles[index].learnedSigns)

            saveProfiles()
            print("✅ After Saving:", profiles[index].learnedSigns)

        } else {
            print("⚠️ Sign already learned: \(sign)")
        }
    }


        
        func getLearnedSigns() -> [String] {
            guard let id = currentUserID, let profile = profiles.first(where: { $0.id == id }) else { return [] }
            return profile.learnedSigns
        }
    
    func getNotificationSettings() -> Bool {
        guard let id = currentUserID else { return true }
        return profiles.first { $0.id == id }?.notifications ?? true
    }
    
    func setOnboardingCompleted() {
        guard let id = currentUserID, let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[index].showOnboarding = false
        saveProfiles()
    }
    
    func deleteProfile(_ id: UUID) {
        profiles.removeAll { $0.id == id }
        if id == currentUserID {
            currentUserID = profiles.first?.id ?? createDummyUser()
        }
        saveProfiles()
    }
}

