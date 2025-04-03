import UIKit

class TestResultViewController: UIViewController {
    
    var currentUserId: UUID?
    var testID: Int?
    var testScore: Double?
    var testXP: Int?
    
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultComment1: UILabel!
    @IBOutlet weak var resultComment2: UILabel!
    @IBOutlet weak var resultXPLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 17.5, *) {
            let haptic = UIImpactFeedbackGenerator(style: .light, view: view)
            haptic.impactOccurred(intensity: 1)
        }
        
        if currentUserId == nil {
            print("🚨 currentUserId is nil! Fetching from ProfileDataModel...")
            currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
        }
        
        updateResultScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateResultScreen()
    }
    
    func updateResultScreen() {
        guard let testID, let testScore, let currentUserId,
              let temp = TestDataModel.sharedInstance.giveTest(by: testID) else { return }
        
        // Hide all stars initially
        [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView].forEach { $0?.isHidden = true }
        
        let previousScore = TestDataModel.sharedInstance.getScore(for: currentUserId, testId: temp.id)
        
        let xpEarned = (previousScore >= Int(testScore * 5)) ? Int(Double(testXP!) * 0.1) : testXP!
        resultXPLabel.text = "+ \(xpEarned) XP"
        
        let scoreRanges: [(Double, Int, String, String)] = [
            (0.0, 0, "You need to work on your skills!", "Poor performance"),
            (0.2, 1, "Focus more", "Work More"),
            (0.4, 2, "More work can be done", "Practice More"),
            (0.6, 3, "Keep it up!", "Exceeded Expectations"),
            (0.8, 4, "Good Job!", "Good Performance"),
            (1.0, 5, "Awesome Work!", "Awesome Performance")
        ]
        
        for (threshold, stars, comment1, comment2) in scoreRanges {
            if testScore <= threshold {
                for i in 0..<stars {
                    [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView][i]?.isHidden = false
                }
                resultComment1.text = comment1
                resultComment2.text = comment2
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("✅ prepare(for: segue) called!")
        
        guard let destinationVC = segue.destination as? TestListCollectionViewController else {
            print("🚨 Destination view controller is not TestListCollectionViewController")
            return
        }
        
        guard let testID, let testScore, let testXP, let currentUserId else {
            print("🚨 Missing parameters: testID: \(testID ?? 0), testScore: \(testScore ?? 0), testXP: \(testXP ?? 0), currentUserId: \(currentUserId?.uuidString ?? "nil")")
            return
        }
        
        guard let temp = TestDataModel.sharedInstance.giveTest(by: testID) else {
            print("🚨 Test data not found for ID: \(testID)")
            return
        }
        
        let newScore = Int(testScore * 5)
        let maxScore = temp.questions.count
        let previousScore = TestDataModel.sharedInstance.getScore(for: currentUserId, testId: temp.id)
        
        print("📊 New Score: \(newScore), Previous Score: \(previousScore), Max Score: \(maxScore)")
        
        let finalScore = min(newScore, maxScore)
        
        // ✅ Always update the latest test score
        TestDataModel.sharedInstance.updateLatestScore(for: currentUserId, testID: testID, newScore: finalScore)
        
        if newScore > previousScore {
            print("🏆 New High Score! Updating XP...")
//            TestDataModel.sharedInstance.updateScore(for: currentUserId, testID: testID, newScore: finalScore)
            
            print("🔹 Calling updateExperiencePoints(\(testXP))")
            ProfileDataModel.sharedInstance.updateExperiencePoints(testXP)
            
            AchievementDataModel.sharedInstance.updateProgress(achievementId: 3, increment: 1)
            AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: Double(finalScore))
            BadgesDataModel.sharedInstance.updateStreak(for: currentUserId, increment: 1)
            print("🔄 Called updateStreak for user \(currentUserId)")
            if newScore == maxScore {
                print("🎉 Perfect score! Unlocking achievement...")
                AchievementDataModel.sharedInstance.updateProgress(achievementId: 2, increment: 1)
            }
        } else {
            let reducedXP = Int(Double(testXP) * 0.1)
            print("😕 Not a high score. Awarding reduced XP: \(reducedXP)")
            ProfileDataModel.sharedInstance.updateExperiencePoints(reducedXP)
        }
        
        print("✅ Finished prepare(for: segue)")
    }
    
}
