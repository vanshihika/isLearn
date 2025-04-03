import UIKit
import Foundation

struct Word: Hashable, Codable {
    var id: UUID
    var wordName: String
    var wordDefinition: String
    var videoURL: String
    
    init(id: UUID = UUID(), wordName: String, wordDefinition: String, videoURL: String) {
        self.id = id
        self.wordName = wordName
        self.wordDefinition = wordDefinition
        self.videoURL = videoURL
    }
}

class WordDataModel {
    private var words: [Word] = [
        Word(wordName: "Experience", wordDefinition: "Experience is the knowledge or skill gained through involvement in or exposure to a particular activity or field over time.", videoURL: "holi"),
        Word(wordName: "Particular", wordDefinition: "You use 'particular' to emphasize that something is specific or distinctive within a larger group or category.", videoURL: "holi"),
        Word(wordName: "Assess", wordDefinition: "When you assess a person, thing, or situation, you evaluate or judge its quality, importance, or effectiveness.", videoURL: "holi"),
        Word(wordName: "Anxiety", wordDefinition: "A feeling of nervousness or worry.", videoURL: "holi"),
        Word(wordName: "Depression", wordDefinition: "Depression is a mental state in which an individual experiences persistent feelings of sadness", videoURL: "holi"),
        Word(wordName: "Mariachi", wordDefinition: "A small group of musicians playing Mexican music...", videoURL: "holi"),
        Word(wordName: "Resilience", wordDefinition: "The ability to recover from setbacks, adapt well to change, and keep going in the face of adversity.", videoURL: "holi"),
        Word(wordName: "Cognition", wordDefinition: "The mental action or process of acquiring knowledge and understanding through thought, experience, and the senses.", videoURL: "holi"),
        Word(wordName: "Perspective", wordDefinition: "A particular attitude toward or way of regarding something; a point of view.", videoURL: "holi"),
        Word(wordName: "Empathy", wordDefinition: "The ability to understand and share the feelings of another.", videoURL: "holi"),
        Word(wordName: "Innovation", wordDefinition: "The action or process of innovating, introducing new ideas or methods.", videoURL: "holi"),
        Word(wordName: "Collaboration", wordDefinition: "The action of working with someone to produce or create something.", videoURL: "holi"),
        Word(wordName: "Diversity", wordDefinition: "The state of being diverse; a range of different things or qualities.", videoURL: "holi"),
        Word(wordName: "Sustainability", wordDefinition: "The ability to be maintained at a certain rate or level without depleting resources.", videoURL: "holi"),
        Word(wordName: "Persuasion", wordDefinition: "The act of convincing someone to do or believe something through reasoning or argument.", videoURL: "holi"),
        Word(wordName: "Altruism", wordDefinition: "The belief in or practice of selfless concern for the well-being of others.", videoURL: "holi")
    ]
    
    static let sharedInstance: WordDataModel = WordDataModel()
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("words_list").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedWords = try? propertyDecoder.decode([Word].self, from: retrievedData) {
            words = decodedWords
        }
    }
    
    func fetchAllWords() -> [Word] {
        return words
    }
    
    func giveWord(_ byName: String) -> Word? {
        words.first { $0.wordName == byName }
    }
    
    func giveMatching(_ compareString: String) -> [Word] {
        words.filter { $0.wordName.contains(compareString) }
    }
    
    func saveToDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("words_list").appendingPathExtension("plist")
        
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(words) {
            try? encodedValue.write(to: archiveURl, options: .noFileProtection)
        }
    }
    
    func deleteData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("words_list").appendingPathExtension("plist")
        
        try? FileManager.default.removeItem(at: archiveURl)
    }
    
    func fetchAllWords() async throws -> [Word] {
        let response = try await SupabaseManager.shared.client
            .from("words")
            .select()
            .execute()
        return try JSONDecoder().decode([Word].self, from: response.data)
    }
}

class WordOfTheDay {
    private var words: [Word: Date] = [
        Word(
            wordName: "Independence",
            wordDefinition: "Freedom from being governed or ruled by another country",
            videoURL: "holi"
        ): Date()
    ]
    
    static let sharedInstance = WordOfTheDay()
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("wotd_list").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedWOTD = try? propertyDecoder.decode([Word: Date].self, from: retrievedData) {
            words = decodedWOTD
        }
    }
    
    func getWordOfTheDay() -> Word? {
        let today = Calendar.current.startOfDay(for: Date())
        return words.first { Calendar.current.startOfDay(for: $0.value) == today }?.key
    }
    
    func saveToDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("wotd_list").appendingPathExtension("plist")
        
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(words) {
            try? encodedValue.write(to: archiveURl, options: .noFileProtection)
        }
    }
    
    func deleteData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("wotd_list").appendingPathExtension("plist")
        
        try? FileManager.default.removeItem(at: archiveURl)
    }
}

class BookMarkedWords {
    // Map user UUIDs to their bookmarked words
    private var userBookmarkedWords: [UUID: [Word]] = [:]
    
    static let sharedInstance = BookMarkedWords()
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_bookmarks").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedUserBookmarks = try? propertyDecoder.decode([String: [Word]].self, from: retrievedData) {
            // Convert string keys back to UUIDs
            for (key, value) in decodedUserBookmarks {
                if let uuid = UUID(uuidString: key) {
                    userBookmarkedWords[uuid] = value
                }
            }
        }
    }
    
    func toggleBookmarkedWords(_ word: Word, for userId: UUID) {
        // Initialize empty array if user doesn't have bookmarks yet
        if userBookmarkedWords[userId] == nil {
            userBookmarkedWords[userId] = []
        }
        
        if userBookmarkedWords[userId]!.contains(where: { $0.id == word.id }) {
            userBookmarkedWords[userId]!.removeAll { $0.id == word.id }
        } else {
            userBookmarkedWords[userId]!.append(word)
        }
        saveToDirectory()
    }
    
    func getBookmarkedWords(for userId: UUID) -> [Word] {
        return userBookmarkedWords[userId] ?? []
    }

    func saveToDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_bookmarks").appendingPathExtension("plist")
        
        // Convert UUID keys to strings for storage
        var stringKeyedDict: [String: [Word]] = [:]
        for (key, value) in userBookmarkedWords {
            stringKeyedDict[key.uuidString] = value
        }
        
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(stringKeyedDict) {
            try? encodedValue.write(to: archiveURl, options: .noFileProtection)
        }
    }
    
    func deleteData(for userId: UUID) {
        userBookmarkedWords[userId] = nil
        saveToDirectory()
    }
    
    func deleteAllData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("user_bookmarks").appendingPathExtension("plist")
        
        try? FileManager.default.removeItem(at: archiveURl)
        userBookmarkedWords = [:]
    }
}






