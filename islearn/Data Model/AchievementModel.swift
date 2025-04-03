import UIKit
import Foundation

struct Achievement: Codable {
    var id: UUID
    var achievementId: Int
    var name: String
    var description: String
    var currentLevel: Int
    var currentProgress: Double
    var maxProgress: Double {
        didSet {
            switch self.achievementId {
            case 1:
                self.description = "Learn \(Int(maxProgress)) Signs!"
            case 2:
                self.description = "Score 200+ XP in \(Int(maxProgress)) Tests!"
            case 3:
                self.description = "Complete \(Int(maxProgress)) tests!"
            case 4:
                self.description = "Maintain \(Int(maxProgress)) streak!"
            case 5:
                self.description = "Achieve all achievements!"
            default:
                break
            }
        }
    }
    
    var completionXP: Int
    var isCompleted: Bool {
        return currentLevel == 4
    }
}

class AchievementDataModel {
    static let sharedInstance = AchievementDataModel()
    private var userAchievements: [UUID: [Achievement]] = [:]
    
    private init() {
        loadFromStorage()
    }
    
    private func getCurrentUserID() -> UUID? {
        return ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
    }
    
    func updateProgress(achievementId: Int, increment: Double) {
        guard let userId = getCurrentUserID() else { return }
        ensureUserAchievementsExist(for: userId)
        guard let index = userAchievements[userId]!.firstIndex(where: { $0.achievementId == achievementId }) else { return }
        
        var achievement = userAchievements[userId]![index]
        
        if !achievement.isCompleted {
            if achievement.currentLevel <= 3 {
                achievement.currentProgress += increment
                if achievement.currentProgress >= achievement.maxProgress {
                    achievement.currentLevel += 1
                    sendAchievementNotification(for: achievement)
                    
                    achievement.currentProgress = Double(Int(achievement.currentProgress) % Int(achievement.maxProgress))
                    achievement.maxProgress *= 1.5
                    achievement.completionXP = Int(Double(achievement.completionXP) * 1.5)
                    
                    ProfileDataModel.sharedInstance.updateExperiencePoints(achievement.completionXP)
                }
            }
        } else {
            achievement.name = "Completed!"
            achievement.currentLevel = 4
            achievement.currentProgress = achievement.maxProgress
        }
        
        userAchievements[userId]![index] = achievement
        saveToStorage()
    }
    
    func getAchievementData(_ index: Int) -> Achievement? {
        guard let userId = getCurrentUserID() else {
            print("Error: Could not get current user ID")
            return nil
        }

        ensureUserAchievementsExist(for: userId)

        guard let achievements = userAchievements[userId] else {
            print("Error: No achievements found for user \(userId)")
            return nil
        }

        guard index >= 0, index < achievements.count else {
            print("Error: Index \(index) is out of bounds (Achievements count: \(achievements.count))")
            return nil
        }

        return achievements[index]
    }


    private func ensureUserAchievementsExist(for userId: UUID) {
        if userAchievements[userId] == nil {
            print("Initializing achievements for user: \(userId)")
            userAchievements[userId] = loadDefaultAchievements()
        }
    }
    
    func getAchievementCount() -> Int {
        guard let userId = getCurrentUserID() else { return 0 }
        ensureUserAchievementsExist(for: userId)
        return userAchievements[userId]?.count ?? 0
    }
    
    private func loadDefaultAchievements() -> [Achievement] {
        return [
            Achievement(id: UUID(), achievementId: 1, name: "Sign Learner", description: "Learn 5 Signs!", currentLevel: 1, currentProgress: 0, maxProgress: 10, completionXP: 100),
            Achievement(id: UUID(), achievementId: 2, name: "Test Master", description: "Complete 5 tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 150),
            Achievement(id: UUID(), achievementId: 3, name: "Test Finisher", description: "Score Perfectly in 5 Tests!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 200),
            Achievement(id: UUID(), achievementId: 4, name: "Streak Keeper", description: "Maintain 100 streak!", currentLevel: 1, currentProgress: 0, maxProgress: 7, completionXP: 250),
            Achievement(id: UUID(), achievementId: 5, name: "Completionist", description: "Achieve All Achievements!", currentLevel: 1, currentProgress: 0, maxProgress: 5, completionXP: 300)
        ]
    }

    private func sendAchievementNotification(for achievement: Achievement) {
        let notification = UNMutableNotificationContent()
        notification.body = "Achievement Unlocked!"
        notification.title = "\(achievement.name)"
        notification.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "AchievementNotification", content: notification, trigger: trigger)
        
        if ProfileDataModel.sharedInstance.getNotificationSettings() {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    private func saveToStorage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_achievements").appendingPathExtension("plist")
        
        var stringKeyedDict: [String: [Achievement]] = [:]
        for (key, value) in userAchievements {
            stringKeyedDict[key.uuidString] = value
        }
        
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(stringKeyedDict) {
            try? encodedValue.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    private func loadFromStorage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_achievements").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURL),
           let decodedUserAchievements = try? propertyDecoder.decode([String: [Achievement]].self, from: retrievedData) {
            for (key, value) in decodedUserAchievements {
                if let uuid = UUID(uuidString: key) {
                    userAchievements[uuid] = value
                }
            }
        }
    }
    
    func resetToDefault(for userId: UUID) {
        userAchievements[userId] = loadDefaultAchievements()
        saveToStorage()
    }
    
    func deleteData(for userId: UUID) {
        userAchievements.removeValue(forKey: userId)
        saveToStorage()
    }
}


struct Badge: Codable {
    var id: UUID
    var badgeId: Int
    var name: String
    var description: String
    var isCompleted: Bool
    
    var displayColor: UIColor {
            return isCompleted ? .systemOrange : .systemGray4
        }
    
    init(id: UUID = UUID(), badgeId: Int, name: String, description: String, isCompleted: Bool) {
        self.id = id
        self.badgeId = badgeId
        self.name = name
        self.description = description
        self.isCompleted = isCompleted
    }
}

class BadgesDataModel {
    static let sharedInstance = BadgesDataModel()
    private var userBadges: [UUID: [Badge]] = [:]
    
    // 🔹 Predefined list of badges
    private let predefinedBadges: [Badge] = [
        Badge(badgeId: 1, name: "1", description: "Complete lessons for 10 days straight!", isCompleted: false),
        Badge(badgeId: 2, name: "25", description: "Complete lessons for 25 days straight!", isCompleted: false),
        Badge(badgeId: 3, name: "50", description: "Complete lessons for 50 days straight!", isCompleted: false),
        Badge(badgeId: 4, name: "100", description: "Complete lessons for 100 days straight!", isCompleted: false)
    ]

    private init() {
        loadFromStorage()
    }

    private func getCurrentUserID() -> UUID? {
        return ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
    }

    func getBadgesData(_ id: Int) -> Badge? {
        guard let userId = getCurrentUserID(),
              let badges = userBadges[userId] else { return nil }
        
        return badges.first { $0.badgeId == id }
    }

    func updateBadgeStatus(badgeId: Int) {
        guard let userId = getCurrentUserID() else { return }
        ensureUserBadgesExist(for: userId)
        guard let index = userBadges[userId]?.firstIndex(where: { $0.badgeId == badgeId }) else { return }
        
        userBadges[userId]![index].isCompleted = true
        saveToStorage()
    }

    private func ensureUserBadgesExist(for userId: UUID) {
        if userBadges[userId] == nil {
            userBadges[userId] = createUserBadgesFromPredefined()
        }
    }

    private func createUserBadgesFromPredefined() -> [Badge] {
        return predefinedBadges.map { Badge(id: UUID(), badgeId: $0.badgeId, name: $0.name, description: $0.description, isCompleted: false) }
    }

    private func saveToStorage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_badges").appendingPathExtension("plist")
        
        var stringKeyedDict: [String: [Badge]] = [:]
        for (key, value) in userBadges {
            stringKeyedDict[key.uuidString] = value
        }
        
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(stringKeyedDict) {
            try? encodedValue.write(to: archiveURL, options: .noFileProtection)
        }
    }

    private func loadFromStorage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("user_badges").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURL),
           let decodedUserBadges = try? propertyDecoder.decode([String: [Badge]].self, from: retrievedData) {
            for (key, value) in decodedUserBadges {
                if let uuid = UUID(uuidString: key) {
                    userBadges[uuid] = value
                }
            }
        }
    }

    func getBadgesCount() -> Int {
        guard let userId = getCurrentUserID() else {
            print("Error: No user ID found for badges")
            return 0
        }
        ensureUserBadgesExist(for: userId)
        let count = userBadges[userId]?.count ?? 0
        print("Badge count for user \(userId): \(count)")
        
        return count
    }

    func resetToDefault(for userId: UUID) {
        userBadges[userId] = createUserBadgesFromPredefined()
        saveToStorage()
    }

    func updateStreak(for userId: UUID, increment: Int) {
        guard let currentUserId = getCurrentUserID(), currentUserId == userId else {
            print("🚨 Error: Invalid user ID or user not logged in.")
            return
        }

        ensureUserBadgesExist(for: userId)

        let oldStreak = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.currentStreak ?? 0
        print("🔥 Before Update: Streak = \(oldStreak)")

        ProfileDataModel.sharedInstance.updateCurrentStreak()

        let newStreak = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.currentStreak ?? 0
        print("🔥 After Update: Streak = \(newStreak)")

        var badgeUnlocked = false

        if var badges = userBadges[userId] { // ✅ Safe optional binding
            var updatedBadges = false
            
            for index in badges.indices where !badges[index].isCompleted {
                switch badges[index].badgeId {
                    case 1 where newStreak >= 1,
                         2 where newStreak >= 25,
                         3 where newStreak >= 50,
                         4 where newStreak >= 100:

                        print("🎉 Unlocking badge: \(badges[index].name)")
                        badges[index].isCompleted = true
                        updatedBadges = true // Track if any badge was updated

                    default:
                        break
                }
            }

            if updatedBadges {
                userBadges[userId] = badges // ✅ Save updated array back
                badgeUnlocked = true
            }
        }

    }


    func checkAndUnlockBadges(for userId: UUID) {
        ensureUserBadgesExist(for: userId)
        let currentStreak = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.currentStreak ?? 0
        var badgeUnlocked = false

        for badge in userBadges[userId]! {
            if !badge.isCompleted {
                switch badge.badgeId {
                    case 1 where currentStreak >= 10,
                         2 where currentStreak >= 25,
                         3 where currentStreak >= 50,
                         4 where currentStreak >= 100:
                        updateBadgeStatus(badgeId: badge.badgeId)
                        badgeUnlocked = true
                    default:
                        break
                }
            }
        }

        // ✅ Notify UI to update when a badge is unlocked
        if badgeUnlocked {
            NotificationCenter.default.post(name: NSNotification.Name("BadgeUpdated"), object: nil)
        }
    }


    func deleteData(for userId: UUID) {
        userBadges.removeValue(forKey: userId)
        saveToStorage()
    }
}


