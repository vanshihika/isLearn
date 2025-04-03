import UIKit

class JourneyViewController: UIViewController, UIScrollViewDelegate {
    var currentUserId: UUID!
    
    var alphabetRectangularButton = RectangularButton(color: Color(uiColor: .themeColor), title: "Alphabets", description: "Learn your alphabets in a fun and interactive way!")
    var numberRectangularButton = RectangularButton(color: Color(uiColor: .red), title: "Numbers", description: "Get your numbers right!")
    
    let buttonSize: CGFloat = 100
    let padding: CGFloat = 30
    var scrollView: UIScrollView!
    
    var alphabetButtons: [UIButton] = []
    var numberButtons: [UIButton] = []
    
    var currentYPosition: CGFloat = 0
    var numberSectionY: CGFloat = 0
    var lineLayers: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUserId == nil {
            if let existingUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() {
                currentUserId = existingUser.id
            } else {
                currentUserId = ProfileDataModel.sharedInstance.createDummyUser()
            }
        }

        
        setupScrollView()
        view.backgroundColor = .black

        let userJourney = JourneyDataModel.shared.getJourney(for: currentUserId)
        
        setupRectangularButtons(buttonInfo: alphabetRectangularButton, startY: padding)
        if userJourney.section.count > 0 {
            alphabetButtons = setupCircularButtons(for: userJourney.section[0].exercises, sectionTitle: "Alphabets", color: .themeColor, offsetY: currentYPosition)
        }
        currentYPosition += padding
        
        setupRectangularButtons(buttonInfo: numberRectangularButton, startY: currentYPosition)
        if userJourney.section.count > 1 {
            numberButtons = setupCircularButtons(for: userJourney.section[1].exercises, sectionTitle: "Numbers", color: .red, offsetY: currentYPosition)
        }
        
        drawLinesBetweenButtons(from: alphabetButtons)
        drawLinesBetweenButtons(from: numberButtons)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        
        let userJourney = JourneyDataModel.shared.getJourney(for: currentUserId)
        
        for (sectionIndex, section) in userJourney.section.enumerated() {
            let sectionTitle = section.title

            updateExerciseButtons(forSectionTitle: sectionTitle)
            
            if let firstExercise = section.exercises.first, !JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: firstExercise.name) {
                let firstButton = sectionTitle == "Alphabets" ? alphabetButtons.first : numberButtons.first
                firstButton?.isEnabled = true
                firstButton?.backgroundColor = sectionTitle == "Alphabets" ? .themeColor : .red
            }
        
            if let lastExercise = section.exercises.last,
               JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: lastExercise.name),
               sectionIndex + 1 < userJourney.section.count {
                
                let nextSection = userJourney.section[sectionIndex + 1]
                if !nextSection.exercises.isEmpty {
                    let nextSectionButton = nextSection.title == "Alphabets" ? alphabetButtons.first : numberButtons.first
                    
                    nextSectionButton?.isEnabled = true
                    nextSectionButton?.backgroundColor = nextSection.title == "Alphabets" ? .themeColor : .red
                }
            }
        }
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.delegate = self
     
        view.addSubview(scrollView)
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        let userJourney = JourneyDataModel.shared.getJourney(for: currentUserId)
        
        let totalHeight = CGFloat(userJourney.section.reduce(0) { $0 + $1.exercises.count }) * (buttonSize + padding) + padding + 400
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: totalHeight)
        scrollView.contentSize = CGSize(width: view.frame.width, height: totalHeight)
    }
    
    func setupRectangularButtons(buttonInfo: RectangularButton, startY: CGFloat) {
        guard let contentView = scrollView.subviews.first else { return }
        
        let rectangularButton = UIButton()
        rectangularButton.backgroundColor = buttonInfo.color.uiColor
        rectangularButton.layer.cornerRadius = 8
        rectangularButton.frame = CGRect(x: padding, y: startY, width: scrollView.frame.width - 2 * padding, height: 100)
        contentView.addSubview(rectangularButton)
        
        let titleLabel = UILabel()
        titleLabel.text = buttonInfo.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.frame = CGRect(x: 20, y: 10, width: rectangularButton.frame.width - 40, height: 30)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = buttonInfo.description
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.frame = CGRect(x: 20, y: 40, width: rectangularButton.frame.width - 40, height: 50)
        
        rectangularButton.addSubview(titleLabel)
        rectangularButton.addSubview(descriptionLabel)
        currentYPosition = startY + rectangularButton.frame.height + padding
    }
    
    func setupCircularButtons(for exercises: [Exercise], sectionTitle: String, color: UIColor, offsetY: CGFloat) -> [UIButton] {
        guard let contentView = scrollView.subviews.first else { return [] }
        var buttons: [UIButton] = []
        var currentYPosition = offsetY
        
        for (index, exercise) in exercises.enumerated() {
            let button = UIButton()
            let completed = JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let isLocked = JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            button.setTitle("\(exercise.name)\(completed ? " ✓" : (isLocked ? " 🔐" : ""))", for: .normal)
            button.backgroundColor = isLocked ? .gray : color
            button.isEnabled = !isLocked
            button.layer.cornerRadius = buttonSize / 2
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            let x: CGFloat = index % 2 == 0 ? padding : view.frame.width - padding - buttonSize
            button.frame = CGRect(x: x, y: currentYPosition, width: buttonSize, height: buttonSize)
            
            contentView.addSubview(button)
            buttons.append(button)
            
            currentYPosition += buttonSize + padding
        }
        
        self.currentYPosition = currentYPosition
        return buttons
    }
    
    func updateExerciseButtons(forSectionTitle sectionTitle: String) {
        let userJourney = JourneyDataModel.shared.getJourney(for: currentUserId)
        
        guard let section = userJourney.section.first(where: { $0.title == sectionTitle }) else { return }
        var buttonArray: [UIButton] = []
        
        if sectionTitle == "Alphabets" {
            buttonArray = alphabetButtons
        } else if sectionTitle == "Numbers" {
            buttonArray = numberButtons
        }
        
        for (index, exercise) in section.exercises.enumerated() {
            guard index < buttonArray.count else { continue }
            
            let completed = JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let isLocked = JourneyDataModel.shared.isExerciseLocked(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
            let button = buttonArray[index]
            let newTitle = completed ? "\(exercise.name) ✓" : exercise.name
            let attributedTitle = NSMutableAttributedString(string: newTitle)

            if isLocked, let lockImage = UIImage(systemName: "lock.fill") {
                let lockAttachment = NSTextAttachment()
                lockAttachment.image = lockImage.withTintColor(.white, renderingMode: .alwaysOriginal) // Ensure correct color
                lockAttachment.bounds = CGRect(x: 0, y: -3, width: 25, height: 27) // Adjust size & position
                
                let lockString = NSAttributedString(attachment: lockAttachment)
                attributedTitle.append(NSAttributedString(string: " ")) // Space before icon
                attributedTitle.append(lockString)
            }

            button.setAttributedTitle(attributedTitle, for: .normal)

            if completed && index + 1 < buttonArray.count {
                let nextButton = buttonArray[index + 1]
                nextButton.isEnabled = true
                nextButton.backgroundColor = sectionTitle == "Alphabets" ? .themeColor : .red
            }
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let sectionTitle = alphabetButtons.contains(sender) ? "Alphabets" : "Numbers"
        let exerciseIndex = sender.tag

        let userJourney = JourneyDataModel.shared.getJourney(for: currentUserId)
        
        let exercises = userJourney.section.first(where: { $0.title == sectionTitle })?.exercises ?? []
        
        guard exerciseIndex < exercises.count else { return }
        let exercise = exercises[exerciseIndex]
        
        let completed = JourneyDataModel.shared.isExerciseCompleted(for: currentUserId, sectionTitle: sectionTitle, exerciseName: exercise.name)
        
        if completed {
            if exerciseIndex + 1 < exercises.count {
                let nextButton = alphabetButtons.contains(sender) ?
                    (exerciseIndex + 1 < alphabetButtons.count ? alphabetButtons[exerciseIndex + 1] : nil) :
                    (exerciseIndex + 1 < numberButtons.count ? numberButtons[exerciseIndex + 1] : nil)
                
                nextButton?.isEnabled = true
                nextButton?.backgroundColor = alphabetButtons.contains(sender) ? .themeColor : .red
            }
        }

        performSegue(withIdentifier: "toUnitViewController", sender: [exercise, sectionTitle, currentUserId])
    }
    
    @IBSegueAction func toNextUnit(_ coder: NSCoder, sender: Any?) -> UnitViewController? {
        let nextVC = UnitViewController(coder: coder)
        nextVC!.sectionTitle = (sender as! [Any])[1] as! String
        nextVC!.exercise = (sender as! [Any])[0] as! Exercise
        nextVC!.userId = (sender as! [Any])[2] as! UUID
        return nextVC
    }
    
    func drawLinesBetweenButtons(from buttons: [UIButton]) {
        guard let contentView = scrollView.subviews.first else { return }
        var previousButton: UIButton? = nil
        
        for i in 0..<buttons.count {
            let currentButton = buttons[i]
            if let previousButton = previousButton {
                let startPoint = CGPoint(x: previousButton.center.x, y: previousButton.center.y)
                let endPoint = CGPoint(x: currentButton.center.x, y: currentButton.center.y)
                let lineLayer = drawLine(from: startPoint, to: endPoint, in: contentView)
                lineLayers.append(lineLayer)
            }
            previousButton = currentButton
        }
        for button in buttons {
            button.superview?.bringSubviewToFront(button)
        }
    }
    
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint, in view: UIView) -> CAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    func fetchJourney(forUserID userID: UUID) async throws -> Journey {
        let response = try await SupabaseManager.shared.client
            .from("journey")
            .select()
            .eq("user_id", value: userID)
            .execute()
        let rows = try JSONDecoder().decode([JourneyRow].self, from: response.data)
        let sections = Dictionary(grouping: rows, by: { $0.section_title })
            .map { Section(
                title: $0.key,
                exercises: $0.value.map {
                    Exercise(
                        name: $0.exercise_name,
                        completed: $0.completed,
                        isLocked: $0.is_locked
                    )
                }
            )}
        return Journey(section: sections)
    }

    struct JourneyRow: Codable {
        let section_title: String
        let exercise_name: String
        let completed: Bool
        let is_locked: Bool
    }
}
