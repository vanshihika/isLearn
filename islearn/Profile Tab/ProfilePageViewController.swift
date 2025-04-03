import UIKit

class ProfilePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var achievementsCollection: UICollectionView!
    @IBOutlet weak var badgesCollection: UICollectionView!
    @IBOutlet weak var longestStreakLabel: UILabel!
    @IBOutlet weak var learnedWordsLabel: UILabel!
    @IBOutlet weak var totalExperienceLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileLoad()
        
        badgesCollection.delegate = self
        badgesCollection.dataSource = self
        
        achievementsCollection.delegate = self
        achievementsCollection.dataSource = self
        
        
        setupStreakLabel()
        setupTotalExperienceLabel()
        setupLearnedWordsLabel()
        badgesCollection.reloadData()
        achievementsCollection.reloadData()
        setCollectionViewContentHeight()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBadgesCollectionView), name: NSNotification.Name("BadgeUpdated"), object: nil)
    }
    @objc func reloadBadgesCollectionView() {
        badgesCollection.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        achievementsCollection.reloadData()
        badgesCollection.reloadData()
        setupStreakLabel()
        setupTotalExperienceLabel()
        setupLearnedWordsLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        achievementsCollection.heightAnchor.constraint(equalToConstant: achievementsCollection.contentSize.height).isActive = true
    }

    func setupStreakLabel() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        let streak = profile.currentStreak
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "flame.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        let attributedString = NSMutableAttributedString(string: "\(streak) ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))
        
        longestStreakLabel.textColor = .systemOrange
        longestStreakLabel.attributedText = attributedString
        
        BadgesDataModel.sharedInstance.checkAndUnlockBadges(for: profile.id)
        
        badgesCollection.reloadData()
    }
    
    func setupTotalExperienceLabel() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        let totalExperiencePoints = profile.totalExperiencePoints
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "bolt.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        let attributedString = NSMutableAttributedString(string: "\(totalExperiencePoints) ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))
        
        totalExperienceLabel.textColor = .systemYellow
        totalExperienceLabel.attributedText = attributedString
    }
    
    func setupLearnedWordsLabel() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        let learnedSignsCount = profile.learnedSigns.count  // Get the number of learned signs
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        
        let attributedString = NSMutableAttributedString(string: "\(learnedSignsCount) ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length - 1))
        
        learnedWordsLabel.textColor = .systemPurple
        learnedWordsLabel.attributedText = attributedString
    }
    
    func profileLoad() {
        guard let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile() else { return }
        
        profileImage.image = UIImage(data: profile.image.photo)
        userName.text = profile.name
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesCollection {
            return BadgesDataModel.sharedInstance.getBadgesCount()
        } else{
            print(AchievementDataModel.sharedInstance.getAchievementCount())
            return AchievementDataModel.sharedInstance.getAchievementCount()
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == badgesCollection{
            return CGSize(width: 110, height: 115)}
        else {
            return CGSize(width: 420, height: 125)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == badgesCollection {
            return 10
        }else {
            return 30
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badge", for: indexPath) as? BadgeCollectionViewCell else {
                fatalError("Could not dequeue BadgeCollectionViewCell")
            }
            
            let badge = BadgesDataModel.sharedInstance.getBadgesData(indexPath.item+1)
            
            print(badge?.isCompleted)
            cell.badgeImage.image = UIImage(systemName: "hexagon")
            cell.badgeImage.center = cell.contentView.center
            cell.badgeLabel.text = badge?.name
            cell.badgeImage.contentMode = .scaleToFill
            if((badge?.isCompleted) == true){
                cell.badgeImage.tintColor = .systemOrange
            } else {
                cell.badgeImage.tintColor = .gray
            }
            collectionView.showsHorizontalScrollIndicator = false
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "achievement", for: indexPath) as? AchievementsCollectionViewCell else {
                print("Error: Failed to dequeue AchievementsCollectionViewCell for index \(indexPath.item)")
                return UICollectionViewCell()
            }
            
            guard let achievement = AchievementDataModel.sharedInstance.getAchievementData(indexPath.item) else {
                print("Error: Achievement at index \(indexPath.item) is nil")
                return cell
            }
            
            let trophyImage = UIImage(systemName: "trophy.fill")
            let emptyTrophy = UIImage(systemName: "trophy")
            cell.MainTrophy.image = emptyTrophy
            cell.bronzeTrophy.image = trophyImage
            cell.silverTrophy.image = trophyImage
            cell.goldTrophy.image = trophyImage

            switch achievement.currentLevel {
            case 1:
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .darkGray
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            case 2:
                cell.MainTrophy.tintColor = .white
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            case 3:
                cell.MainTrophy.tintColor = .white
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .silver
                cell.goldTrophy.tintColor = .darkGray
            case 4:
                cell.MainTrophy.tintColor = .accent
                cell.bronzeTrophy.tintColor = .maroon
                cell.silverTrophy.tintColor = .silver
                cell.goldTrophy.tintColor = .golden
            default:
                cell.MainTrophy.tintColor = .darkGray
                cell.bronzeTrophy.tintColor = .darkGray
                cell.silverTrophy.tintColor = .darkGray
                cell.goldTrophy.tintColor = .darkGray
            }

            let progressValue = Float(achievement.currentProgress / achievement.maxProgress)
            cell.achievementProgress.progress = progressValue
            print("Achievement Progress for \(achievement.name): \(progressValue)")

            cell.achievementTitle.text = achievement.name
            cell.achievementDetail.text = achievement.description

            achievementsCollection.showsVerticalScrollIndicator = false

            return cell
        }

    }
    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
        guard let sourceVC = segue.source as? ProfileEditViewController,
              let profile = ProfileDataModel.sharedInstance.getCurrentUserProfile(),
              let imageData = sourceVC.editProfileImage.image?.pngData() else { return }
        
        ProfileDataModel.sharedInstance.updateProfileData(
            sourceVC.newNameTextField.text!,
            sourceVC.editProfileImage.image!,
            sourceVC.pushNotification.isOn
        )
        
        profileImage.image = sourceVC.editProfileImage.image
        userName.text = sourceVC.newNameTextField.text
    }
    
    func setCollectionViewContentHeight() {
        let contentHeight = achievementsCollection.collectionViewLayout.collectionViewContentSize.height
        achievementsCollection.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
    }
}
