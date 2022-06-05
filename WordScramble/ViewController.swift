//
//  ViewController.swift
//  WordScramble
//
//  Created by Huy Bui on 2021-09-13.
//  Copyright © 2021 Huy Bui. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords: [String] = []
    var usedWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n");
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] _ in // _ is inferred to be of type UIAlertAction; a more descriptive alternative would be to write (_: UIAlertAction)
            // self and alertController must be unwrapped since they are weakly referenced and could be nil
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowercaseAnswer = answer.lowercased()
        
        if isNotStartWord(word: lowercaseAnswer) {
            if isNotBlank(word: lowercaseAnswer) {
                if hasMoreThan3Letters(word: lowercaseAnswer) {
                    if isPossible(word: lowercaseAnswer) {
                        if (isOriginal(word: lowercaseAnswer)){
                            if (isReal(word: lowercaseAnswer)) {
                                usedWords.insert(lowercaseAnswer, at: 0)
                                
                                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                
                                return
                            } else { // Word is not real
                                showErrorMessge("Word not recognized")
                            }
                        } else { // Word has already been used
                            showErrorMessge("This word has already been used")
                        }
                    } else { // Word is not possible
                        guard let title = title?.lowercased() else { return }
                        showErrorMessge("You can't spell \(lowercaseAnswer) from \(title)")
                    }
                } else { // Word has less than 3 letters
                    showErrorMessge("Word must contain three or more letters")
                }
            } else { // Word is blank
                showErrorMessge("No answer provided")
            }
        } else { // Word is starting word
            showErrorMessge("Word must not be starting word")
        }
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var givenWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = givenWord.firstIndex(of: letter) {
                givenWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count) // utf16 ensures that the string evaluated properly by UIKit methods (written in Objective-C)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isNotBlank(word: String) -> Bool {
        if (word.lowercased() == "" || word.contains(" ")) {
            return false
        }
        
        return true
    }
    
    func hasMoreThan3Letters(word: String) -> Bool {
        return word.utf16.count >= 3
    }
    
    func isNotStartWord(word: String) -> Bool {
        return !(word.lowercased() == title?.lowercased())
    }
    
    func showErrorMessge(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Invalid answer", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(alertController, animated: true)
    }
    
}

