import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pushNotification: UISwitch!
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var newNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        loadUserProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editProfileImage.layer.cornerRadius = editProfileImage.frame.size.width / 2.1
        editProfileImage.clipsToBounds = true
    }
    
    private func loadUserProfile() {
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else {
            print("No user profile found.")
            return
        }
        
        editProfileImage.image = UIImage(data: currentUser.image.photo) 
        pushNotification.isOn = currentUser.notifications
        newNameTextField.text = currentUser.name
    }
    
    @IBAction func tapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
            })
        }
        
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            editProfileImage.image = selectedImage
        }
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else {
            print("No user profile found.")
            return
        }
        guard let updatedName = newNameTextField.text, !updatedName.isEmpty else { return }
        guard let updatedImage = editProfileImage.image else { return }
        
        ProfileDataModel.sharedInstance.updateProfileData(updatedName, updatedImage, pushNotification.isOn)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else {
            print("No user profile found.")
            return
        }
        
        let alertController = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete this account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            let userId = currentUser.id
            
            // Delete user-specific data
            TestDataModel.sharedInstance.deleteData(for: userId)
            AchievementDataModel.sharedInstance.deleteData(for: userId)
            BadgesDataModel.sharedInstance.deleteData(for: userId)
            JourneyDataModel.shared.deleteData(for: userId)
            BookMarkedWords.sharedInstance.deleteData(for: userId)
            BadgesDataModel.sharedInstance.resetToDefault(for: userId)
            AchievementDataModel.sharedInstance.resetToDefault(for: userId)
            ProfileDataModel.sharedInstance.deleteProfile(userId)
            self.navigateToMainPage()
        })
        
        present(alertController, animated: true)
    }
    
    func navigateToMainPage() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateInitialViewController()
        sceneDelegate.window?.rootViewController = mainViewController
        sceneDelegate.window?.makeKeyAndVisible()
    }
}

