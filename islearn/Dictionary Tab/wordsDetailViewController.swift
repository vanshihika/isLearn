import UIKit
import AVKit
import AVFoundation

class wordsDetailViewController: UIViewController {
    
    var word: Word?
    var currentUserId: UUID? 

    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDescriptionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!

    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if word == nil {
                    print("🚨 ERROR: word is nil. It must be passed before this view loads.")
                    return
                }
                
                // Handle currentUserId if it's nil
                if currentUserId == nil {
                    print("⚠️ currentUserId is nil! Attempting to fetch from ProfileDataModel...")
                    currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
                }
                
                guard let word = word, let currentUserId = currentUserId else {
                    print("❌ ERROR: Either word or currentUserId is still nil.")
                    return
                }

//        wordNameLabel.text = word.wordName
        wordDescriptionLabel.text = word.wordDefinition
        self.title = word.wordName

        setupVideoPreview()
        loadVideo(for: word)
        updateBookmarkButton()
    }
    
    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        guard let previewLayer = previewLayer else { return }

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = gestureView.bounds
        gestureView.layer.addSublayer(previewLayer)
    }

    private func loadVideo(for word: Word) {
        guard let videoPath = Bundle.main.path(forResource: word.videoURL, ofType: "mp4") else { return }
        let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Remove previous layers
        videoView.layer.addSublayer(playerLayer)

        player.play()
    }

    private func updateBookmarkButton() {
        guard let word = word, let currentUserId = currentUserId else { return }
        let isBookmarked = BookMarkedWords.sharedInstance.getBookmarkedWords(for: currentUserId).contains { $0.id == word.id }
        bookmarkButton.image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
    }

    @IBAction func bookmarkBtnTapped(_ sender: UIBarButtonItem) {
        guard let word = word, let currentUserId = currentUserId else { return }

                // Toggle bookmark status
                BookMarkedWords.sharedInstance.toggleBookmarkedWords(word, for: currentUserId)
                
                // Update the bookmark button UI immediately
                updateBookmarkButton()
                
                // Notify other screens to update their bookmarks
                NotificationCenter.default.post(name: NSNotification.Name("BookmarksUpdated"), object: nil)
            }
}

