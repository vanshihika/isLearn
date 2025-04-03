//
//  TestPageViewController.swift
//  islearn
//
//  Created by student-2 on 18/12/24.
//

import UIKit
import AVKit
import AVFoundation

class TestPageViewController: UIViewController {
    
    var test : Test?
    
    @IBOutlet weak var TestQuestionLabel: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var optionAButton: UIButton!
    
    @IBOutlet weak var optionBButton: UIButton!
    
    @IBOutlet weak var optionCButton: UIButton!
    
    @IBOutlet weak var optionDButton: UIButton!
    
    @IBOutlet weak var videoOptionA: UIView!
    
    @IBOutlet weak var videoOptionB: UIView!
    
    @IBOutlet weak var videoOptionC: UIView!
    
    @IBOutlet weak var mcqAStack: UIStackView!
    
    @IBOutlet weak var mcqBStack: UIStackView!
    
    @IBOutlet weak var GestureAStack: UIStackView!
    
    @IBOutlet weak var GestureAWordLabel: UILabel!
    
    @IBOutlet weak var GestureACameraView: UIView!
    
    let videoCapture = VideoCapture()
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var pointsLayer = CAShapeLayer()
    
    var actionDetected = false
    
    var questionNumber = 0
    
    var currentScore : Double = 0
    
    var testXP : Double = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(test?.title ?? "")"
        loadQuestion()
        
        optionAButton.layer.cornerRadius = 20
        optionBButton.layer.cornerRadius = 20
        optionCButton.layer.cornerRadius = 20
        optionDButton.layer.cornerRadius = 20
        
        
//        setupVideoPreview()
        
        videoCapture.predictor.delegate = self
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCapture.endCaptureSession()
    }
    
    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        
        guard let previewLayer = previewLayer else { return }
        
        
        GestureACameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = GestureACameraView.frame
        
        GestureACameraView.layer.addSublayer(pointsLayer)
        pointsLayer.frame = GestureACameraView.frame
        
    }
    
    
    @IBAction func optionSelectedMCQB(_ sender : UIButton){
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactMedium.impactOccurred()
        if let test {
            if (sender.tag == test.questions[questionNumber].answer) {
                currentScore += 0.3
                testXP += Double(test.questions[questionNumber].questionXP)
            }
            
            questionNumber+=1
            
            if(questionNumber < test.questions.count){
                loadQuestion()
                
            }else{
                performSegue(withIdentifier: "Results", sender: [currentScore,testXP])
            }
            
        }
    }
    
    
    @IBAction func GestureASkipButtonPressed(_ sender: UIButton) {
        if let test{
            questionNumber+=1
            if(questionNumber < test.questions.count){
                loadQuestion()
                
            }else{
                performSegue(withIdentifier: "Results", sender: [currentScore,testXP])
            }
        }
    }
    
    @IBAction func optionSelectedMCQA(_ sender: UIButton) {
        
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
            impactMedium.impactOccurred()

            guard let test else { return }

            if sender.tag == test.questions[questionNumber].answer {
                currentScore += 0.2
                testXP += Double(test.questions[questionNumber].questionXP)
                sender.backgroundColor = .systemGreen // Correct answer
            } else {
                sender.backgroundColor = .systemRed // Incorrect answer
                highlightCorrectAnswer(test.questions[questionNumber].answer!) // Show correct answer
            }

            questionNumber += 1

        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if self.questionNumber < self.test!.questions.count {
                    self.loadQuestion()
                } else {
                    self.performSegue(withIdentifier: "Results", sender: [self.currentScore, self.testXP])
                }
            }
    }
    private func highlightCorrectAnswer(_ correctAnswer: Int) {
        switch correctAnswer {
        case 1: optionAButton.backgroundColor = .systemGreen
        case 2: optionBButton.backgroundColor = .systemGreen
        case 3: optionCButton.backgroundColor = .systemGreen
        case 4: optionDButton.backgroundColor = .systemGreen
        default: break
        }
    }
    
    //    @IBSegueAction func showResults(_ coder: NSCoder, sender : Any?) -> TestResultViewController? {
    //        
    //        let destination = TestResultViewController(coder: coder)
    //        destination?.testScore = sender as? Double ?? 0
    //        return destination
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TestResultViewController{
            if(sender as? [Double] == nil){
                return
            }
            let temp = sender as! [Double]
            destination.testScore = temp[0]
            destination.testID = test?.testID ?? 0
            destination.testXP = Int(temp[1])
        }
    }
    
    
    func loadQuestion(){
        
        TestQuestionLabel.text = "Q\(questionNumber + 1): " + (test?.questions[questionNumber].questionStatement ?? "")
        
        let givenTestType = test?.testType
        let givenQuestionType = test?.questions[questionNumber].questionType
        
        mcqAStack.isHidden = true
        mcqBStack.isHidden = true
        GestureAStack.isHidden = true
        videoCapture.endCaptureSession()
        
        
        if givenTestType == .classic {
            if givenQuestionType == .mcqA {
                
                mcqAStack.isHidden = false
                mcqBStack.isHidden = true
                
                optionAButton.setTitle(test?.questions[questionNumber].options![0], for: .normal)
                optionAButton.tag = 1
                optionAButton.backgroundColor = .accent
                
                
                optionBButton.setTitle(test?.questions[questionNumber].options![1], for: .normal)
                optionBButton.tag = 2
                optionBButton.backgroundColor = .accent
                
                optionCButton.setTitle(test?.questions[questionNumber].options![2], for: .normal)
                optionCButton.tag = 3
                optionCButton.backgroundColor = .accent
                
                optionDButton.setTitle(test?.questions[questionNumber].options![3], for: .normal)
                optionDButton.tag = 4
                optionDButton.backgroundColor = .accent
                
                let player = AVPlayer(url: URL(filePath: Bundle.main.path(forResource: "holi", ofType: "mp4")!))
                
                let layer = AVPlayerLayer(player: player)
                layer.frame = videoView.frame
                
                videoView.layer.addSublayer(layer)
                player.play()
                
            }else if (givenQuestionType == .mcqB){
                
                mcqAStack.isHidden = true
                mcqBStack.isHidden = false
                
                var player1 = AVPlayer(url: URL(filePath: Bundle.main.path(forResource: test?.questions[questionNumber].options![0], ofType: "mp4")!))
                
                let layer1 = AVPlayerLayer(player: player1)
                
                layer1.frame = videoOptionA.bounds
                
                videoOptionA.layer.addSublayer(layer1)
                videoOptionA.tag = 1
                
                player1.play()
                let dupe = AVPlayerItem(asset: player1.currentItem!.asset)
                player1 = AVPlayer(playerItem: dupe)
                
                let layer2 = AVPlayerLayer(player: player1)
                
                layer2.frame = videoOptionB.bounds
                
                videoOptionB.layer.addSublayer(layer2)
                videoOptionB.tag = 1
                
                
                player1.play()
                
                //                
                let dupe1 = AVPlayerItem(asset: player1.currentItem!.asset)
                player1 = AVPlayer(playerItem: dupe1)
                
                let layer3 = AVPlayerLayer(player: player1)
                
                layer3.frame = videoOptionB.bounds
                
                videoOptionC.layer.addSublayer(layer3)
                videoOptionC.tag = 2
                
                player1.play()
            }
        }
        else{
            if(givenQuestionType == .wordGesture){
                setupVideoPreview()
                GestureAStack.isHidden = false
                GestureAWordLabel.text = test?.questions[questionNumber].gestureWord
                
                videoCapture.startCaptureSession()
            }
        }
        
        
    }
    
    @IBSegueAction func TestCancel(_ coder: NSCoder) -> TestResultViewController? {
        
        
        let result : TestResultViewController? = TestResultViewController(coder: coder)
        
        result?.testScore = 0
        
        let alertController = UIAlertController(title: "Quit Test ?", message: nil, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { ( _ ) in
            
            if let result {
                result.testID = self.test?.testID
                self.videoCapture.endCaptureSession()
                self.performSegue(withIdentifier: "Results", sender : [0,0])
            }
        }
        
        let no = UIAlertAction(title: "No", style: .destructive)
        
        alertController.addAction(yes)
        
        alertController.addAction(no)
        
        present(alertController, animated: true)
        
        return result
    }
    
    
}


extension TestPageViewController : PredictorDelegate {
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double) {
        if confidence >= 0.9 && actionDetected == false {
            actionDetected = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.actionDetected = false
                
                if(action == self.test!.questions[self.questionNumber].gestureWord ?? ""){
                    self.performSegue(withIdentifier: "Results", sender: [1,100])
                }
                
            }
            
            
        }
        
        
    }
    
    func predictor(_ predictor: Predictor, didFindRecoganisedPoints points: [CGPoint]) {
        guard let previewLayer else {return}
        
        let convertedPoints = points.map {
            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        let combinedPath = CGMutablePath()
        
        for point in convertedPoints {
            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 10, height: 10))
            combinedPath.addPath(dotPath.cgPath)
        }
        
        pointsLayer.path = combinedPath
        
        DispatchQueue.main.async {
            self.pointsLayer.didChangeValue(for: \.path)
        }
    }
}

