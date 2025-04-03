import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let currentUser = ProfileDataModel.sharedInstance.getCurrentUserProfile() else {
            print("No current user profile found.")
            return
        }
        
        if currentUser.showOnboarding {
            print("Presenting Onboarding...")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController {
                onboardingVC.modalPresentationStyle = .overFullScreen
                present(onboardingVC, animated: true, completion: nil)
            } else {
                print("⚠️ Error: Could not instantiate OnboardingViewController from storyboard")
            }
        }
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        ProfileDataModel.sharedInstance.setOnboardingCompleted()
    }
}

