import UIKit
import Foundation

struct Test: Codable {
    var id: UUID
    var title: String
    var description: String
    var questions: [Question]
    var themeColor: Color?
    var previousScore: Int
    var newTest: Bool?
    var testID: Int?
    var testType: TestType?
    
    init(id: UUID = UUID(), title: String, description: String, questions: [Question], themeColor: Color? = nil, previousScore: Int = 0, newTest: Bool? = nil, testID: Int? = nil, testType: TestType? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
        self.themeColor = themeColor
        self.previousScore = previousScore
        self.newTest = newTest
        self.testID = testID
        self.testType = testType
    }
}

struct Color: Codable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor: UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

enum TestType: String, Equatable, Codable {
    case classic, gesture
    
    var description: String {
        switch self {
        case .classic:
            return "Classic"
        case .gesture:
            return "Gesture"
        }
    }
    
    static func == (lhs: TestType, rhs: TestType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

class TestDataModel {
    private var userTestScores: [UUID: [UUID: Int]] = [:]
    
    private var tests: [Test] = [
        Test(
            title: "Alphabets",
            description: "Learn The Alphabets",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign A?", answer: 2, options: ["holi", "holi", "holi"], questionType: .mcqB, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["A", "B","C","D"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["G", "H","K","I"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["A", "L","S","D"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["B", "R","U","H"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemBlue),
            previousScore: 0,
            testID: 11,
            testType: .classic
        ),
        Test(
            title: "Alphabets",
            description: "Practice The Alphabets",
            questions: [
                Question(questionTitle: .test, questionStatement: "Perform The Sign", gestureWord: "A", questionType: .wordGesture, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemBlue),
            previousScore: 0,
            testID: 21,
            testType: .gesture
        ),
        Test(
            title: "Numbers",
            description: "Practice The Numbers",
            questions: [
                Question(questionTitle: .test, questionStatement: "Perform The Sign", gestureWord: "5", questionType: .wordGesture, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemRed),
            previousScore: 0,
            testID: 22,
            testType: .gesture
        ),
        Test(
            title: "Numbers",
            description: "Learn The Digits",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["1", "9","8","4"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["2", "0","1","6"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["6", "9","0","1"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["1", "2","3","6"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["1", "7","2","9"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemRed),
            previousScore: 0,
            testID: 12,
            testType: .classic
        ),
        Test(
            title: "Greeting People",
            description: "Learn how to meet and greet people",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Hello", "Good Morining","Good Evening","Rice"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Greetings", "Hello", "Good Evening", "Bonjour"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Greetings", "Hello", "Good Evening", "Bonjour"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Greetings", "Hello", "Good Evening", "Bonjour"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Greetings", "Hello", "Good Evening", "Bonjour"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemYellow),
            previousScore: 0,
            testID: 13,
            testType: .classic
        ),
        Test(
            title: "Friends & Family I",
            description: "Learn signs for friends and family",
            questions: [
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Father", "Mother","Sister","Brother"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Dog", "Father","Sister","Mother"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Hello", "Mother","Father","Good Evening"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["A", "Father","Good Evening","Brother"], questionType: .mcqA, questionXP: 50),
                Question(questionTitle: .test, questionStatement: "Identify the Sign", answer: 2, options: ["Sister", "Mother","Cat","Brother"], questionType: .mcqA, questionXP: 50),
            ],
            themeColor: Color(uiColor: .systemPink),
            previousScore: 0,
            newTest: true,
            testID: 14,
            testType: .classic
        ),
        Test(
            title: "Coming Soon",
            description: "More content will be added in the future",
            questions: [],
            themeColor: Color(uiColor: .systemGray),
            testID: 0,
            testType: nil
        )
    ]
    
    static var sharedInstance: TestDataModel = TestDataModel()
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURl = documentsDirectory.appendingPathComponent("tests_list").appendingPathExtension("plist")
        
        let propertyDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURl),
           let decodedTests = try? propertyDecoder.decode([Test].self, from: retrievedData) {
            tests = decodedTests
        }
        
        // Load user test scores
        let scoresURl = documentsDirectory.appendingPathComponent("user_test_scores").appendingPathExtension("plist")
        if let retrievedData = try? Data(contentsOf: scoresURl),
           let decodedScores = try? propertyDecoder.decode([String: [String: Int]].self, from: retrievedData) {
            // Convert string keys back to UUIDs
            for (userKey, testScores) in decodedScores {
                if let userUUID = UUID(uuidString: userKey) {
                    var testUUIDScores: [UUID: Int] = [:]
                    for (testKey, score) in testScores {
                        if let testUUID = UUID(uuidString: testKey) {
                            testUUIDScores[testUUID] = score
                        }
                    }
                    userTestScores[userUUID] = testUUIDScores
                }
            }
        }
    }
    
    func giveTest(by id: UUID) -> Test? {
        return tests.first { $0.id == id }
    }
    
    func giveTest(by testID: Int) -> Test? {
        return tests.first { $0.testID == testID }
    }
    
    func giveTest(by testID: Int, type: TestType) -> Test? {
        return tests.first { ($0.testType == type && $0.testID == testID) || ($0.testType == nil) }
    }
    
    func updateScore(for userId: UUID, testId: UUID, newScore: Int) {
        if userTestScores[userId] == nil {
            userTestScores[userId] = [:]
        }
        
        userTestScores[userId]![testId] = newScore
        saveToDirectory()
    }
    
    func updateScore(for userId: UUID, testID: Int, newScore: Int) {
        if let test = giveTest(by: testID) {
            updateScore(for: userId, testId: test.id, newScore: newScore)
        }
    }
    
    func getScore(for userId: UUID, testId: UUID) -> Int {
        return userTestScores[userId]?[testId] ?? 0
    }
    
    func getAllTests() -> [Test] {
        return tests
    }
    
    func getTestsByType(type: TestType) -> [Test] {
        return tests.filter { $0.testType == type }
    }
    
    func giveTestCount(testType: TestType) -> Int {
        return (tests.filter { $0.testType == testType }.count) + 1
    }
    
    func updateLatestScore(for userId: UUID, testID: Int, newScore: Int) {
        if let test = giveTest(by: testID) {
            updateScore(for: userId, testId: test.id, newScore: newScore)
            
            if let testIndex = tests.firstIndex(where: { $0.id == test.id }) {
                tests[testIndex].previousScore = newScore
                saveToDirectory()
            }
        }
    }

    func getLatestScore(for userId: UUID, testID: Int) -> Int {
        if let test = giveTest(by: testID) {
            return getScore(for: userId, testId: test.id)
        }
        return 0
    }
    
    private func saveToDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Save tests
        let archiveURl = documentsDirectory.appendingPathComponent("tests_list").appendingPathExtension("plist")
        let propertyEncoder = PropertyListEncoder()
        if let encodedValue = try? propertyEncoder.encode(tests) {
            try? encodedValue.write(to: archiveURl, options: .noFileProtection)
        }
        
        // Save user test scores
        let scoresURl = documentsDirectory.appendingPathComponent("user_test_scores").appendingPathExtension("plist")
        
        // Convert UUID keys to strings for storage
        var stringKeyedDict: [String: [String: Int]] = [:]
        for (userKey, testScores) in userTestScores {
            var stringKeyedScores: [String: Int] = [:]
            for (testKey, score) in testScores {
                stringKeyedScores[testKey.uuidString] = score
            }
            stringKeyedDict[userKey.uuidString] = stringKeyedScores
        }
        
        if let encodedValue = try? propertyEncoder.encode(stringKeyedDict) {
            try? encodedValue.write(to: scoresURl, options: .noFileProtection)
        }
    }
    
    func deleteData(for userId: UUID) {
        userTestScores[userId] = nil
        saveToDirectory()
    }
    
    func deleteAllData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Delete tests list
        let archiveURl = documentsDirectory.appendingPathComponent("tests_list").appendingPathExtension("plist")
        try? FileManager.default.removeItem(at: archiveURl)
        
        // Delete user test scores
        let scoresURl = documentsDirectory.appendingPathComponent("user_test_scores").appendingPathExtension("plist")
        try? FileManager.default.removeItem(at: scoresURl)
        
        userTestScores = [:]
    }
}
