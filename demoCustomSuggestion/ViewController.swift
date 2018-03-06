//
//  ViewController.swift
//  demoCustomSuggestion
//
//  Created by Atal Bansal on 06/09/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet  weak var tableview:UITableView!
	@IBOutlet  weak var textView:UITextView!
	@IBOutlet  weak var commentTextView:UITextView!
	
	var userListArr:NSArray = NSArray()
	var suggestionView:CustomSuggestionView!
	var rangeForReplaceText:NSRange!
	var suggestionCellShow:Bool = false
	//tets
	override func viewDidLoad() {
		super.viewDidLoad()
		userListArr = NSArray(array: ["amit","ankit","nikhil","ajay","abhay","vijay","vicky","rohan","vinay","nitin","vibhi","vicky"])
		suggestionView = CustomSuggestionView.instanceFromNib()
		suggestionView.userListArr = userListArr
        suggestionView.frame = CGRect(x: 20, y: textView.frame.origin.y - 200, width: UIScreen.main.bounds.width - 40, height: 200)//CGRectMake(20, textView.frame.origin.y - 200 , UIScreen.main.bounds.width - 40, 200)
        suggestionView.isHidden = true
		self.view.addSubview(suggestionView)
        NotificationCenter.default.addObserver(self, selector:#selector(userNameAdded), name: NSNotification.Name(rawValue: "UserNameAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(hideCollectionView), name: NSNotification.Name(rawValue: "HideCollectionView"), object: nil)
		// Do any additional setup after loading the view, typically from a nib.
	}
	func userNameAdded(notification: NSNotification) {
		let str:NSString =  textView.text as NSString
        if notification.name.rawValue ==  "UserNameAdded" {
			let range:NSRange = notification.userInfo!["rangeForReplaceText"] as! NSRange
			var name:NSString  = notification.userInfo!["userText"] as! NSString
            name = name.appending(" ") as NSString
            textView.text = str.replacingCharacters(in: range, with: name as String)
		}
	}
	func hideCollectionView(notification: NSNotification) {
		suggestionCellShow = false
		toggleSuggestionView()
		}
@IBAction func showViewClick(sender: AnyObject) {
	let str = textView.text as NSString
    commentTextView.attributedText = attributedComment(comment: str)
	}
	func attributedComment(comment:NSString)->NSMutableAttributedString{
		let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: comment as String)
		attributedString.addAttributes([NSBaselineOffsetAttributeName:4], range: NSMakeRange(0, comment.length))
        let regex = try!  NSRegularExpression(pattern: "(?<!\\S)@(\\w+)" , options: [.caseInsensitive])
		
        let matches = regex .matches(in: comment as String, options: [], range: NSMakeRange(0, comment.length))
			for match in matches {
                let matchRange = match.rangeAt(0)
                attributedString.addAttributes([ NSForegroundColorAttributeName: UIColor.blue], range: matchRange)
			}
		
		return attributedString
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
//	override func viewWillDisappear(animated: Bool) {
//		NSNotificationCenter.defaultCenter().removeObserver(self)
//	}

}

extension ViewController :UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		print(URL)
		return false
	}
    func textViewDidChange(_ textView: UITextView) {
		
		let selectedRange = textView.selectedRange
        let text:NSString = textView.text! as NSString
		
		if selectedRange.length > 0  {
            let rangeSpace = text.range(of: " ", options: [], range: selectedRange)
			if  rangeSpace.location != NSNotFound {
				suggestionCellShow = false
				toggleSuggestionView()
			return
			}
		}
		
        let stringBeforeCursor:NSString = text.substring(with: NSMakeRange(0, selectedRange.location)) as NSString
        let regex = try!  NSRegularExpression(pattern: "(?<!\\S)@[a-z_.0-9]*$" , options: [.caseInsensitive])
        let tagMatch = regex .firstMatch(in: stringBeforeCursor as String, options: [], range: NSMakeRange(0, stringBeforeCursor.length))
		
		if ((tagMatch == nil)) {
			suggestionCellShow = false
			toggleSuggestionView()
			return;
		}
		
		let tagSignLocation = tagMatch?.range.location
        var spaceAfterTagRange = text.range(of: " ", options: [], range: NSMakeRange(tagSignLocation! + 1, text.length - tagSignLocation! - 1))
		
		if spaceAfterTagRange.location == NSNotFound {
			spaceAfterTagRange.location = text.length
		}
		
		let tagRange = NSMakeRange(tagSignLocation! + 1, spaceAfterTagRange.location - tagSignLocation! - 1)
        let tagText = text.substring(with: tagRange)
		var tagTextNS = tagText as NSString
        let regexNew = try!  NSRegularExpression(pattern: "[^a-z0-9]*$", options: [.caseInsensitive])
		let rangeNew = NSMakeRange(0, tagText.characters.count)
        let rangeRex = regexNew.rangeOfFirstMatch(in: tagText, options: [], range: rangeNew)
        tagTextNS = tagTextNS.replacingCharacters(in: rangeRex, with: "") as NSString
		rangeForReplaceText = NSMakeRange(tagRange.location, tagTextNS.length)
		if selectedRange.location >= rangeForReplaceText.location && selectedRange.location <= rangeForReplaceText.location + rangeForReplaceText.length {
            fillterUserList(userListArr1: userListArr, searchText: tagText)
		} else{
			suggestionCellShow = false
			toggleSuggestionView()
		}


	}

	func fillterUserList(userListArr1:NSArray,searchText:String) {
		suggestionView.rangeForReplaceText = rangeForReplaceText
		if searchText.isEmpty {
			suggestionView.userListArr = userListArr1
			suggestionCellShow = true
			toggleSuggestionView()
		} else {
			let predicate = NSPredicate(format: "SELF beginswith %@", searchText)
            let searchDataSource = userListArr.filter { predicate.evaluate(with: $0) }
			if searchDataSource .count > 0 {
                suggestionView.userListArr = searchDataSource as NSArray
				suggestionCellShow = true
				toggleSuggestionView()
			} else{
				suggestionCellShow = false
				toggleSuggestionView()
			}
			
		}
		
		
	}
	func toggleSuggestionView(){
		if suggestionView.userListArr.count ==  0 {
            suggestionView.frame = CGRect(x: 20, y: textView.frame.origin.y - 70, width: UIScreen.main.bounds.width - 40, height: 0)//CGRectMake(20, textView.frame.origin.y - 70 , UIScreen.main.bounds.width - 40,0)
		} else if suggestionView.userListArr.count ==  2 || suggestionView.userListArr.count ==  1 {
            suggestionView.frame = CGRect(x: 20, y: textView.frame.origin.y - 70, width: UIScreen.main.bounds.width - 40, height: 70)//CGRectMake(20, textView.frame.origin.y - 70 , UIScreen.main.bounds.width - 40, 70)
		} else if suggestionView.userListArr.count ==  3 || suggestionView.userListArr.count ==  4 {
            suggestionView.frame = CGRect(x: 20, y: textView.frame.origin.y - 140, width: UIScreen.main.bounds.width - 40, height: 140)//CGRectMake(20, textView.frame.origin.y - 140 , UIScreen.main.bounds.width - 40, 140)
		} else {
            suggestionView.frame = CGRect(x: 20, y: textView.frame.origin.y - 70, width: UIScreen.main.bounds.width - 40, height: 210)//CGRectMake(20, textView.frame.origin.y - 210 , UIScreen.main.bounds.width - 40, 210)

		}
		if suggestionCellShow {
            suggestionView.isHidden = false
			suggestionCellShow    = false
		} else {
            suggestionView.isHidden = true
			suggestionCellShow    = true
		}
		
		suggestionView.userCollectionView.reloadData()
	}
}
extension ViewController :UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customTVC.cellIDentifier, for: indexPath as IndexPath) as! customTVC
		if indexPath.row == 4{
            cell.btn.isHidden = false
		} else{
            cell.btn.isHidden = true
		}
        cell.btn.addTarget(self, action: #selector(ViewController.btnPressed(sender:)), for: UIControlEvents.touchUpInside)
		return cell
		
	}
	@objc func btnPressed(sender:UIButton) {
		
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomSuggestionVC") as! CustomSuggestionVC
        self.present(vc, animated: true, completion: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didDismissSecondViewController), name: NSNotification.Name(rawValue: "suggestionViewismissed"), object: nil)
		
	
	}
	func didDismissSecondViewController(notification: NSNotification) {
		print(notification.userInfo!["userInfo"] as! String)
        NotificationCenter.default.removeObserver(self)
	}
}
