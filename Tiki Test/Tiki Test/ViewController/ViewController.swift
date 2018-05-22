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
            
            // Add prefix for all separate subtweet
            let totalSubTweet = tweetList.count
            var subTweetIndex = 0
            
            var newSubTweetList: [[String]] = []
            while subTweetIndex < tweetList.count {
                var tempSubTweet: [String] = []
                tempSubTweet.append("\(subTweetIndex + 1)/\(totalSubTweet)")
                tempSubTweet.append(tweetList[subTweetIndex])
                
                newSubTweetList.append(tempSubTweet)
                
                subTweetIndex = subTweetIndex + 1
            }
            
            // Get first item of next subtweet & check can insert into current sub tweet
            var needRecheck = true
            while needRecheck {
                needRecheck = false
                
                subTweetIndex = 0
                while subTweetIndex < newSubTweetList.count - 1 {
                    // Reset prefix of current subTweet
                    newSubTweetList[subTweetIndex][0] = "\(subTweetIndex + 1)/\(newSubTweetList.count)"
                    // Reset prefix next sub tweet
                    newSubTweetList[subTweetIndex + 1][0] = "\(subTweetIndex + 2)/\(newSubTweetList.count)"
                    
                    let firstItemNextSubTweet = newSubTweetList[subTweetIndex + 1][1]
                    // Check can insert into current subtweet
                    newSubTweetList[subTweetIndex].append(firstItemNextSubTweet)
                    let totalCharacterSubTweet = self.getTotalCharacter(stringList: newSubTweetList[subTweetIndex])
                    if totalCharacterSubTweet > 50 {
                        let _ = newSubTweetList[subTweetIndex].removeLast()
                        
                        subTweetIndex = subTweetIndex + 1
                    } else {
                        // Check next subtweet can exist
                        if newSubTweetList[subTweetIndex + 1].count <= 2 {
                            newSubTweetList.remove(at: subTweetIndex + 1)
                            
                            needRecheck = true
                        } else {
                            newSubTweetList[subTweetIndex + 1].remove(at: 1)
                        }
                    }
                }
            }
            
            print(newSubTweetList)
            // Create output
            var resultSubTweet: [String] = []
            for subTweet in newSubTweetList {
                resultSubTweet.append(subTweet.joined(separator: " "))
            }
            
            return resultSubTweet
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
