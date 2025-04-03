import UIKit

private let reuseIdentifier = "TestListCell"

private var celltapped = 0
private var currentUserId: UUID?

class CircularProgressView: UIView {
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var didConfigureLabel = false
    fileprivate var rounded: Bool
    fileprivate var filled: Bool
    fileprivate let lineWidth: CGFloat?
    
    var timeToFill = 1.1
    
    var progressColor = UIColor.white {
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: Float {
        didSet{
            var pathMoved = progress - oldValue
            if pathMoved < 0 {
                pathMoved = 0 - pathMoved
            }
            setProgress(duration: timeToFill * Double(pathMoved), to: progress)
        }
    }
    
    fileprivate func createProgressView(){
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        }else{
            trackLayer.lineWidth = lineWidth!
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        }else{
            progressLayer.lineWidth = lineWidth!
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }
        
        
        layer.addSublayer(progressLayer)
        
    }
    
    func trackColorToProgressColor() -> Void{
        trackColor = progressColor
        trackColor = UIColor(red: progressColor.cgColor.components![0], green: progressColor.cgColor.components![1], blue: progressColor.cgColor.components![2], alpha: 0.2)
    }
    
    func setProgress(duration: TimeInterval = 3, to newProgress: Float) -> Void{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        
        progressLayer.add(animation, forKey: "animationProgress")
        
    }
    
    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(frame: frame)
        filled = false
        createProgressView()
    }
    
    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(coder: coder)
        createProgressView()
        
    }
    
    init(frame: CGRect, lineWidth: CGFloat?, rounded: Bool) {
        progress = 0
        
        if lineWidth == nil{
            self.filled = true
            self.rounded = false
        }else{
            if rounded{
                self.rounded = true
            }else{
                self.rounded = false
            }
            self.filled = false
        }
        self.lineWidth = lineWidth
        
        super.init(frame: frame)
        createProgressView()
    }
}




class TestListCollectionViewController: UICollectionViewController, TestListCollectionViewCellDelegate {
    var testType : TestType?
    var screenTitle : String?
    
    func testStart(testID : Int, buttonNumber : Int) {
        let alertController = UIAlertController(title: "Start Test ?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
            self.performSegue(withIdentifier: "TestStart", sender: testID)
        }
        
        let no = UIAlertAction(title: "No", style: .destructive) { _ in
        }
    
        celltapped = buttonNumber
        
        alertController.addAction(no)
        alertController.addAction(yes)
        present(alertController, animated: true)
    }
    
    
    @IBSegueAction func TestStart(_ coder: NSCoder, sender: Any?) -> TestStartNavigationViewController? {
        guard let destination = TestStartNavigationViewController(coder: coder),
              let childVC = destination.topViewController as? TestPageViewController
        else {return nil}
        
        guard let sender =  sender as? Int
        else {return nil}
        
        childVC.test = TestDataModel.sharedInstance.giveTest(by: sender,type: testType!)
        return destination
    }
    
    func createCompositionalLayout()->UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            var section : NSCollectionLayoutSection
            switch sectionIndex {
                
            case 0:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(200)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(
                    top : 5,
                    leading: 10,
                    bottom: 0,
                    trailing: 10
                )
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.25))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                
            default :
                return nil
                
            }
            return section
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = screenTitle
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        if currentUserId == nil {
                    print("🚨 currentUserId is nil! Fetching from ProfileDataModel...")
                    currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
                }
                
                if currentUserId == nil {
                    print("❌ Still nil after fetching! Check ProfileDataModel.")
                }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return TestDataModel.sharedInstance.giveTestCount(testType: testType!)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let currentUserId = currentUserId else {
                    print("❌ No current user ID, cannot load test data.")
                    return UICollectionViewCell()
                }
        
        let test = TestDataModel.sharedInstance.giveTest(by: ((testType! == .classic ? 10 : 20)  + indexPath.item + 1), type: (testType!))
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TestListCollectionViewCell
        
        cell.layer.borderColor =  test!.themeColor?.uiColor.cgColor
        
        cell.layer.borderWidth = 3
        
        cell.layer.cornerRadius = 20
        
        if(test!.title == "Coming Soon"){
            cell.newTestLabel.isHidden = true
            cell.testNameLabel.isHidden = true
            cell.progressBarView.isHidden = true
            cell.testDescriptionLabel.isHidden = true
            cell.testButton.isHidden = true
            cell.ComingSoonLabel.isHidden = false
            
            return cell
        }
        
        let progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), lineWidth: 15, rounded: true)
        
        progressView.progressColor = test!.themeColor!.uiColor
        
        if currentUserId == nil {
                    print("🚨 currentUserId is STILL nil! Using default progress (0).")
                    progressView.progress = 0
                } else {
                    let latestScore = TestDataModel.sharedInstance.getLatestScore(for: currentUserId, testID: test!.testID!)
                    progressView.progress = Float(latestScore) / Float(test!.questions.count)
                }
  
        let latestScore = TestDataModel.sharedInstance.getLatestScore(for: currentUserId, testID: test!.testID!)
        
        progressView.progress = Float(latestScore)/Float(test!.questions.count)
        
        progressView.trackColor = .systemGray2
        
        cell.ComingSoonLabel.isHidden = true
        
        cell.testNameLabel.text = test!.title
        
        cell.testDescriptionLabel.text = test!.description
 
        cell.testProgress.text = "\(latestScore)/\(test!.questions.count)"
        
        cell.progressBarView.addSubview(progressView)
        
        cell.testNameLabel.textColor = test!.themeColor?.uiColor
        
        cell.newTestLabel.isHidden = (test!.newTest == true ? false : true)
        
        cell.newTestLabel.backgroundColor = test!.themeColor?.uiColor
        
        cell.newTestLabel.layer.cornerRadius = 30
        
        cell.testButton.tag = indexPath.item
        
        cell.delegate = self
        
        cell.testID = test!.testID!
        
        return cell
    }
    
    @IBAction func unwindToTestList(_ segue: UIStoryboardSegue) {
            collectionView.reloadItems(at: [IndexPath(item:celltapped, section: 0)])
    }
    
    func updateProgressBar(for testID: Int, in cell: TestListCollectionViewCell) {
            // ✅ Ensure `currentUserId` is set
            if currentUserId == nil {
                print("🚨 updateProgressBar: currentUserId is nil! Trying to fetch...")
                currentUserId = ProfileDataModel.sharedInstance.getCurrentUserProfile()?.id
            }

            guard let userId = currentUserId else {
                print("❌ updateProgressBar: Failed to get currentUserId. Cannot update progress.")
                return
            }

            let latestScore = TestDataModel.sharedInstance.getLatestScore(for: userId, testID: testID)

            DispatchQueue.main.async {
                if let progressView = cell.progressBarView.subviews.first as? CircularProgressView {
                    progressView.progress = Float(latestScore) / Float(100)  // ✅ Ensure score updates dynamically
                }
            }
        }
    
}
