//
//  DictionaryWordsViewController.swift
//  islearn
//
//  Created by Aastik Mehta on 25/12/24.
//

import UIKit
import AVKit
import AVFoundation

class DictionaryWordsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordDescriptionLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var gestureCameraView: UIView!

    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var word: Word?
    var userId: UUID = UUID()
    var currentUserId: UUID? 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let word = word else { return }
        
        if let userProfile = ProfileDataModel.sharedInstance.getCurrentUserProfile() {
                    currentUserId = userProfile.id
                    print("✅ Using current user ID: \(currentUserId!)")
                } else {
                    currentUserId = UUID() // Assign a dummy user ID if no user is logged in
                    print("⚠️ No user logged in! Using dummy ID: \(currentUserId!)")
                }
        
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
        previewLayer.frame = gestureCameraView.bounds
        gestureCameraView.layer.addSublayer(previewLayer)
    }
   
    private func loadVideo(for word: Word) {
        guard let videoPath = Bundle.main.path(forResource: word.videoURL, ofType: "mp4") else { return }
        let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear previous layers
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
