import Foundation
import UIKit

extension UIColor {
    static let themeColor = UIColor(red: 0/255, green: 161/255, blue: 255/255, alpha: 1.0)
}

struct RectangularButton: Codable {
    var id: UUID
    var color: Color
    var title: String
    var description: String
    
    init(id: UUID = UUID(), color: Color, title: String, description: String) {
        self.id = id
        self.color = color
        self.title = title
        self.description = description
    }
}

struct Exercise: Codable {
    var id: UUID
    var name: String
    var completed: Bool
    var isLocked: Bool
    
    init(id: UUID = UUID(), name: String, completed: Bool, isLocked: Bool) {
        self.id = id
        self.name = name
        self.completed = completed
        self.isLocked = isLocked
    }
}

struct Section: Codable {
    var id: UUID
    var title: String
    var exercises: [Exercise]
    
    init(id: UUID = UUID(), title: String, exercises: [Exercise]) {
        self.id = id
        self.title = title
        self.exercises = exercises
    }
}

struct Journey: Codable {
    var id: UUID
    var section: [Section]
    
    init(id: UUID = UUID(), section: [Section]) {
        self.id = id
        self.section = section
    }
}

class JourneyDataModel {
    static var shared = JourneyDataModel()
    private var userJourneys: [UUID: Journey] = [:]
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedUserJourneys = try? propertyDecoder.decode([String: Journey].self, from: retrievedData) {
            // Convert string keys back to UUIDs
            for (key, value) in decodedUserJourneys {
                if let uuid = UUID(uuidString: key) {
                    userJourneys[uuid] = value
                }
            }
        }
    }
    
    func getJourney(for userId: UUID) -> Journey {
        if userJourneys[userId] == nil {
            userJourneys[userId] = createDefaultJourney()
        }
        return userJourneys[userId]!
    }
    
    func createDefaultJourney() -> Journey {
        return Journey(section: [
            Section(title: "Alphabets", exercises: [
                Exercise(name: "A", completed: false, isLocked: false),
                Exercise(name: "B", completed: false, isLocked: true),
                Exercise(name: "C", completed: false, isLocked: true),
                Exercise(name: "D", completed: false, isLocked: true),
                Exercise(name: "E", completed: false, isLocked: true),
                Exercise(name: "F", completed: false, isLocked: true),
                Exercise(name: "G", completed: false, isLocked: true),
                Exercise(name: "H", completed: false, isLocked: true),
                Exercise(name: "I", completed: false, isLocked: true),
                Exercise(name: "J", completed: false, isLocked: true),
                Exercise(name: "K", completed: false, isLocked: true),
                Exercise(name: "L", completed: false, isLocked: true),
                Exercise(name: "M", completed: false, isLocked: true),
                Exercise(name: "N", completed: false, isLocked: true),
                Exercise(name: "O", completed: false, isLocked: true),
                Exercise(name: "P", completed: false, isLocked: true),
                Exercise(name: "Q", completed: false, isLocked: true),
                Exercise(name: "R", completed: false, isLocked: true),
                Exercise(name: "S", completed: false, isLocked: true),
                Exercise(name: "T", completed: false, isLocked: true),
                Exercise(name: "U", completed: false, isLocked: true),
                Exercise(name: "V", completed: false, isLocked: true),
                Exercise(name: "W", completed: false, isLocked: true),
                Exercise(name: "X", completed: false, isLocked: true),
                Exercise(name: "Y", completed: false, isLocked: true),
                Exercise(name: "Z", completed: false, isLocked: true)
            ]),
            Section(title: "Numbers", exercises: [
                Exercise(name: "1", completed: false, isLocked: true),
                Exercise(name: "2", completed: false, isLocked: true),
                Exercise(name: "3", completed: false, isLocked: true),
                Exercise(name: "4", completed: false, isLocked: true),
                Exercise(name: "5", completed: false, isLocked: true),
                Exercise(name: "6", completed: false, isLocked: true),
                Exercise(name: "7", completed: false, isLocked: true),
                Exercise(name: "8", completed: false, isLocked: true),
                Exercise(name: "9", completed: false, isLocked: true),
            ]),
        ])
    }
    
    func completeExercise(for userId: UUID, sectionTitle: String, exerciseName: String) {
        if userJourneys[userId] == nil {
            userJourneys[userId] = createDefaultJourney()
        }
        
        var journey = userJourneys[userId]!
        
        guard let sectionIndex = journey.section.firstIndex(where: { $0.title == sectionTitle }),
              let exerciseIndex = journey.section[sectionIndex].exercises.firstIndex(where: { $0.name == exerciseName }) else {
            return
        }
        
        journey.section[sectionIndex].exercises[exerciseIndex].completed = true
        userJourneys[userId] = journey
        
        unlockNextExercise(for: userId, in: sectionTitle, after: exerciseName)
        
        if exerciseIndex == journey.section[sectionIndex].exercises.count - 1 {
            unlockFirstExerciseOfNextSection(for: userId, from: sectionIndex)
        }
        
        saveToDirectory()
    }
   
    func unlockNextExercise(for userId: UUID, in sectionTitle: String, after exerciseName: String) {
            if userJourneys[userId] == nil {
                userJourneys[userId] = createDefaultJourney()
            }
            
            var journey = userJourneys[userId]!
            
            guard let sectionIndex = journey.section.firstIndex(where: { $0.title == sectionTitle }),
                  let exerciseIndex = journey.section[sectionIndex].exercises.firstIndex(where: { $0.name == exerciseName }),
                  exerciseIndex + 1 < journey.section[sectionIndex].exercises.count else {
                return
            }
            
            journey.section[sectionIndex].exercises[exerciseIndex + 1].isLocked = false
            userJourneys[userId] = journey
            
            saveToDirectory()
        }
        
        func unlockFirstExerciseOfNextSection(for userId: UUID, from sectionIndex: Int) {
            if userJourneys[userId] == nil {
                userJourneys[userId] = createDefaultJourney()
            }
            
            var journey = userJourneys[userId]!
            
            if sectionIndex + 1 < journey.section.count && !journey.section[sectionIndex + 1].exercises.isEmpty {
                journey.section[sectionIndex + 1].exercises[0].isLocked = false
                userJourneys[userId] = journey
            }
            
            saveToDirectory()
        }
        
        func isExerciseCompleted(for userId: UUID, sectionTitle: String, exerciseName: String) -> Bool {
            if userJourneys[userId] == nil {
                userJourneys[userId] = createDefaultJourney()
            }
            
            let journey = userJourneys[userId]!
            
            if let section = journey.section.first(where: { $0.title == sectionTitle }),
               let exercise = section.exercises.first(where: { $0.name == exerciseName }) {
                return exercise.completed
            }
            return false
        }
       
        func isExerciseLocked(for userId: UUID, sectionTitle: String, exerciseName: String) -> Bool {
            if userJourneys[userId] == nil {
                userJourneys[userId] = createDefaultJourney()
            }
            
            let journey = userJourneys[userId]!
            
            if let section = journey.section.first(where: { $0.title == sectionTitle }),
               let exercise = section.exercises.first(where: { $0.name == exerciseName }) {
                return exercise.isLocked
            }
            return true
        }
        
        func saveToDirectory() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
            
            // Convert UUID keys to strings for storage
            var stringKeyedDict: [String: Journey] = [:]
            for (key, value) in userJourneys {
                stringKeyedDict[key.uuidString] = value
            }
            
            let propertyEncoder = PropertyListEncoder()
            if let encodedValue = try? propertyEncoder.encode(stringKeyedDict) {
                try? encodedValue.write(to: archiveURl, options: .noFileProtection)
            }
        }
        
        func deleteData(for userId: UUID) {
            userJourneys[userId] = nil
            saveToDirectory()
        }
        
        func deleteAllData() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let archiveURl = documentsDirectory.appendingPathComponent("user_journeys").appendingPathExtension("plist")
            
            try? FileManager.default.removeItem(at: archiveURl)
            userJourneys = [:]
        }
    }
