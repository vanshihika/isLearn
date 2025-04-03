//
//  BookmarksTableViewController.swift
//  islearn
//
//  Created by Aastik Mehta on 25/12/24.
//

import UIKit

class BookmarksTableViewController: UITableViewController {

    private var emptyStateView: UIView!
    var currentUserId: UUID?
    private var bookmarkedWords: [Word] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUserId()  // Ensure user ID is set before using it
        setupEmptyStateView()
        updateBookmarks()
        
        if let navigationController = navigationController {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance  
            }
    }

    private func fetchCurrentUserId() {
        if let userProfile = ProfileDataModel.sharedInstance.getCurrentUserProfile() {
            currentUserId = userProfile.id
            print("✅ Using logged-in user ID: \(currentUserId!)")
        } else {
            currentUserId = UUID()
            print("⚠️ No user logged in! Using dummy ID: \(currentUserId!)")
        }
    }

    @objc func updateBookmarks() {
        guard let currentUserId = currentUserId else {
            print("🚨 ERROR: `currentUserId` is nil while fetching bookmarks.")
            return
        }

        bookmarkedWords = BookMarkedWords.sharedInstance.getBookmarkedWords(for: currentUserId)
        updateUI()
    }

    func updateUI() {
        let hasBookmarks = !bookmarkedWords.isEmpty
        emptyStateView.isHidden = hasBookmarks

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBookmarks()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmark", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let word = bookmarkedWords[indexPath.row]
        content.text = word.wordName
        content.secondaryText = word.wordDefinition
        cell.contentConfiguration = content
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookmarkDetail",
           let indexPath = tableView.indexPathForSelectedRow {
            let wordViewController = segue.destination as! DictionaryWordsViewController
            let selectedWord = bookmarkedWords[indexPath.row]
            wordViewController.word = selectedWord
        }
    }

    // MARK: - Programmatic Empty State View
    private func setupEmptyStateView() {
        emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        // Constraints
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])

        // Image
        let imageView = UIImageView(image: UIImage(systemName: "bookmark.slash"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)

        // Label
        let messageLabel = UILabel()
        messageLabel.text = "No bookmarks yet!\nStart saving your favorite words."
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(messageLabel)

        // Constraints for imageView
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Constraints for label
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
}
