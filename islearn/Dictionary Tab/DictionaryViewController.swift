//
//  DictionaryViewController.swift
//  islearn
//
//  Created by Aastik Mehta on 25/12/24.
//

import UIKit
import AVKit
import AVFoundation

class DictionaryViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var videoView: UIView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UITextView!
    @IBOutlet weak var label4: UILabel!
    
    var allWords: [Word] = WordDataModel.sharedInstance.fetchAllWords()
    var filteredWords: [Word] = []
    @IBOutlet weak var wordsSearchBar: UISearchBar!
    @IBOutlet weak var wordsTableView: UITableView!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupConstraints()
        
        wordsSearchBar.delegate = self
        wordsTableView.delegate = self
        wordsTableView.dataSource = self
        filteredWords = allWords
        
        loadDailyWord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let selectedIndexPath = wordsTableView.indexPathForSelectedRow {
                wordsTableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            // ScrollView takes full width and height up to tab bar
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View matches ScrollView width
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupConstraints() {
        // Add subviews to content view instead of main view
        contentView.addSubview(wordsSearchBar)
        contentView.addSubview(wordsTableView)
        contentView.addSubview(label4)
        contentView.addSubview(label2)
        contentView.addSubview(label3)
        contentView.addSubview(videoView)
        
        // Ensure views are not using auto-resizing masks
        wordsSearchBar.translatesAutoresizingMaskIntoConstraints = false
        wordsTableView.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        label3.translatesAutoresizingMaskIntoConstraints = false
        label4.translatesAutoresizingMaskIntoConstraints = false
        videoView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Sign of The Day label
        label4.text = "Sign of The Day"
        label4.textColor = .accent
        label4.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        // Configure Word of the Day label
        label2.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        
        NSLayoutConstraint.activate([
            // Search Bar Constraints
            wordsSearchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            wordsSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            wordsSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            wordsSearchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Table View Constraints
            wordsTableView.topAnchor.constraint(equalTo: wordsSearchBar.bottomAnchor, constant: 15),
            wordsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wordsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wordsTableView.heightAnchor.constraint(equalToConstant: 340),
            
            // Label 4 (Sign of The Day) Constraints
            label4.topAnchor.constraint(equalTo: wordsTableView.bottomAnchor, constant: 10),
            label4.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Label 2 (Word Name) Constraints
            label2.topAnchor.constraint(equalTo: label4.bottomAnchor, constant: 15),
            label2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Label 3 (Word Description) Constraints
            label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 2),
            label3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            label3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            label3.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            
            // Video View Constraints
            videoView.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 10),
            videoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoView.widthAnchor.constraint(equalToConstant: 210),
            videoView.heightAnchor.constraint(equalToConstant: 150),
            
            // Ensure the content view's bottom is constrained for scrolling
            videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func loadDailyWord(){
        guard let wordOfTheDay = WordOfTheDay.sharedInstance.getWordOfTheDay() else {return}
        label2.text = wordOfTheDay.wordName
        label3.text = wordOfTheDay.wordDefinition
        let player1 = AVPlayer(url: URL(filePath: Bundle.main.path(forResource: wordOfTheDay.videoURL, ofType: "mp4")!))
        let layer1 = AVPlayerLayer(player: player1)
        layer1.frame = videoView.bounds
        videoView.layer.addSublayer(layer1)
        player1.play()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wordsTableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let word = filteredWords[indexPath.row]
        content.text = word.wordName
        cell.contentConfiguration = content
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWordsDetail" , let indexPath = wordsTableView.indexPathForSelectedRow {
            let wordViewController = segue.destination as! wordsDetailViewController
            let selectedWord = filteredWords[indexPath.row]
            wordViewController.word = selectedWord
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredWords = allWords
        } else {
            filteredWords = allWords.filter { $0.wordName.lowercased().contains(searchText.lowercased()) }
        }
        wordsTableView.reloadData()
    }
    
    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredWords = allWords
        wordsTableView.reloadData()
        searchBar.resignFirstResponder()
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)

    }
}
