import UIKit
import AVKit
import AVFoundation

class UnitViewController: UIViewController {
    
    @IBOutlet weak var buttonTitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var completedButton: UIButton!
    
    var exercise: Exercise?
    var sectionTitle: String?
    var userId: UUID?
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let userId = userId, let exercise = exercise, let sectionTitle = sectionTitle else {
            print("Error: Missing required properties")
            return
        }
        
        buttonTitle.text = exercise.name
        navigationItem.title = sectionTitle
        
        let isCompleted = JourneyDataModel.shared.isExerciseCompleted(for: userId, sectionTitle: sectionTitle, exerciseName: exercise.name)
        let isLocked = JourneyDataModel.shared.isExerciseLocked(for: userId, sectionTitle: sectionTitle, exerciseName: exercise.name)
        
        completedButton.isEnabled = !isCompleted && !isLocked
        completedButton.setTitle(isCompleted ? "Completed" : "Mark as Completed", for: .normal)
        setupVideoPlayer()
    }
    
    func setupVideoPlayer() {
        guard videoPlayer == nil else { return }
        
        let videoPlayer = AVPlayer()
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        
        videoPlayerLayer.videoGravity = .resizeAspectFill
        videoPlayerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(videoPlayerLayer)
        
        self.videoPlayer = videoPlayer
        self.videoPlayerLayer = videoPlayerLayer
        
        if let videoPath = Bundle.main.path(forResource: "holi", ofType: "mp4") {
            let videoURL = URL(fileURLWithPath: videoPath)
            self.videoPlayer?.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            self.videoPlayer?.play()
        }
    }
    
    @IBAction func markAsCompletedTapped(_ sender: UIButton) {
        guard let userId = userId, let exercise = exercise, let sectionTitle = sectionTitle else {
            return
        }
        
        // Check if already completed
        if JourneyDataModel.shared.isExerciseCompleted(for: userId, sectionTitle: sectionTitle, exerciseName: exercise.name) {
            return
        }
        
        JourneyDataModel.shared.completeExercise(for: userId, sectionTitle: sectionTitle, exerciseName: exercise.name)
        
        AchievementDataModel.sharedInstance.updateProgress(achievementId: 1, increment: 1)
        
        ProfileDataModel.sharedInstance.addLearnedSign(for: userId, with: exercise.name)
        
        BadgesDataModel.sharedInstance.updateStreak(for: userId, increment: 1)
        
        // Update UI
        sender.setTitle("Completed", for: .normal)
        sender.isEnabled = false
        
        // Unlock next exercise
        if let section = JourneyDataModel.shared.getJourney(for: userId).section.first(where: { $0.title == sectionTitle }),
           let exerciseIndex = section.exercises.firstIndex(where: { $0.name == exercise.name }) {
            
            if exerciseIndex + 1 < section.exercises.count {
                let nextExercise = section.exercises[exerciseIndex + 1]
                if !nextExercise.completed {
                    JourneyDataModel.shared.unlockNextExercise(for: userId, in: sectionTitle, after: exercise.name)
                }
            }
        }
        
        // Show completion alert
        let alert = UIAlertController(title: "Completed", message: "Great job!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}

