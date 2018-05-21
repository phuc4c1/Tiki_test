//
//  ViewController.swift
//  Tiki Test
//
//  Created by Nguyễn Tấn Phúc on 5/21/18.
//  Copyright © 2018 Nguyễn Tấn Phúc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var contentList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupLayout()
        self.initTableView()
    }
    
    func initTableView() {
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TweetCell")
    }
    
    func setupLayout() {
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func updateSendButtonEnable() {
        self.sendButton.isEnabled = (textView.text.count != 0)
    }
}

// MARK: - Outlet function
extension ViewController {
    func checkValidateTweet(tweetContentList: [String]) -> Bool {
        for tweetContent in tweetContentList {
            if tweetContent.count > 50 {
                // Show alert
                let alertController = UIAlertController(title: "Erorr", message: "Tweet span of nonwhite space character > 50", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return false
            }
        }
        
        return true
    }
    
    func getTotalCharacter(stringList: [String]) -> Int {
        var numberCharacter = stringList.count - 1 // number space
        
        for string in stringList {
            numberCharacter = numberCharacter + string.count
        }
        
        return numberCharacter > 0 ? numberCharacter : 0
    }
    
    
    func validateTweetContent(tweetContent: String) -> [String] {
        if tweetContent.count < 50 {
            return [tweetContent]
        } else {
            var tweetList = tweetContent.components(separatedBy: " ")
            
            // Get toal sub tweet: this formula is not correct.
            // TODO: update formula later
            let totalSubTweet = (tweetContent.count / 50) + 1
            var subTweetIndex = 1
            
            var newSubTweetList: [String] = []
            var tempSubTweetList: [String] = []
            tempSubTweetList.append("\(subTweetIndex)/\(totalSubTweet)")
            
            while tweetList.count > 0 {
                let subTweet = tweetList.removeFirst()
                tempSubTweetList.append(subTweet)
                
                // for case: Last subTweet
                if tweetList.count == 0 {
                    let newSubTweet = tempSubTweetList.joined(separator: " ")
                    newSubTweetList.append(newSubTweet)
                    
                    break
                }
                
                let totalCharacterSubTweet = self.getTotalCharacter(stringList: tempSubTweetList)
                
                // If append new subTweet > 50 character -> re-insert last subtweet,
                if totalCharacterSubTweet > 50 {
                    let lastSubTweet = tempSubTweetList.removeLast()
                    tweetList.insert(lastSubTweet, at: 0)
                    
                    // Add new sub tweet
                    let newSubTweet = tempSubTweetList.joined(separator: " ")
                    newSubTweetList.append(newSubTweet)
                    
                    // Reset temp sub tweet
                    tempSubTweetList.removeAll()
                    subTweetIndex = subTweetIndex + 1
                    tempSubTweetList.append("\(subTweetIndex)/\(totalSubTweet)")
                    
                }
                
            }
            
            return newSubTweetList
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        let text = textView.text!
        
        if text.count > 0 {
            let tweetContentList = validateTweetContent(tweetContent: text)
            
            let checkValidate = checkValidateTweet(tweetContentList: tweetContentList)
            if checkValidate == true {
                for tweetContent in tweetContentList {
                    contentList.append(tweetContent)
                }
                
                // Reset input
                textView.text = ""
                textView.resignFirstResponder()
            }
            
            tableView.reloadData()
        }
        
        self.updateSendButtonEnable()
        
        // Reset layout
        self.textViewHeightConstraint.constant = 30
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        cell.selectionStyle = .none
        
        let content = contentList[indexPath.row]
        cell.setupContent(content: content)
        
        return cell
    }
}

// MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.updateSendButtonEnable()
        
        self.textViewHeightConstraint.constant = textView.getHeightWithWidthFixed()
    }
}

extension UITextView {
    func getHeightWithWidthFixed() -> CGFloat {
        let constraintRect = CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedStringKey: self.font ?? UIFont.systemFont(ofSize: 13)], context: nil)
        
        let height = boundingBox.height + self.layoutMargins.top + self.layoutMargins.bottom
        
        return height
    }
}
