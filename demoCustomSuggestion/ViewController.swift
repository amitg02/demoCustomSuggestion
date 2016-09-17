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
		suggestionView.frame = CGRectMake(20, textView.frame.origin.y - 200 , UIScreen.mainScreen().bounds.width - 40, 200)
		suggestionView.hidden = true
		self.view.addSubview(suggestionView)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(userNameAdded), name: "UserNameAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(hideCollectionView), name: "HideCollectionView", object: nil)
		// Do any additional setup after loading the view, typically from a nib.
	}
	func userNameAdded(notification: NSNotification) {
		let str:NSString =  textView.text as NSString
		if notification.name ==  "UserNameAdded" {
			let range:NSRange = notification.userInfo!["rangeForReplaceText"] as! NSRange
			var name:NSString  = notification.userInfo!["userText"] as! NSString
			name = name.stringByAppendingString(" ")
			textView.text = str.stringByReplacingCharactersInRange(range, withString: name as String)
		}
	}
	func hideCollectionView(notification: NSNotification) {
		suggestionCellShow = false
		toggleSuggestionView()
		}
@IBAction func showViewClick(sender: AnyObject) {
	let str = textView.text as NSString
	commentTextView.attributedText = attributedComment(str)
	}
	func attributedComment(comment:NSString)->NSMutableAttributedString{
		let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: comment as String)
		attributedString.addAttributes([NSBaselineOffsetAttributeName:4], range: NSMakeRange(0, comment.length))
		let regex = try!  NSRegularExpression(pattern: "(?<!\\S)@(\\w+)" , options: [.CaseInsensitive])
		
		let matches = regex .matchesInString(comment as String, options: [], range: NSMakeRange(0, comment.length))
			for match in matches {
				let matchRange = match.rangeAtIndex(0)
				attributedString.addAttributes([ NSForegroundColorAttributeName: UIColor.blueColor()], range: matchRange)
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
	func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
		print(URL)
		return false
	}
	func textViewDidChange(textView: UITextView) {
		
		let selectedRange = textView.selectedRange
		let text:NSString = textView.text
		
		if selectedRange.length > 0  {
			let rangeSpace = text.rangeOfString(" ", options: [], range: selectedRange)
			if  rangeSpace.location != NSNotFound {
				suggestionCellShow = false
				toggleSuggestionView()
			return
			}
		}
		
		let stringBeforeCursor:NSString = text.substringWithRange(NSMakeRange(0, selectedRange.location)) as NSString
		let regex = try!  NSRegularExpression(pattern: "(?<!\\S)@[a-z_.0-9]*$" , options: [.CaseInsensitive])
		let tagMatch = regex .firstMatchInString(stringBeforeCursor as String, options: [], range: NSMakeRange(0, stringBeforeCursor.length))
		
		if ((tagMatch == nil)) {
			suggestionCellShow = false
			toggleSuggestionView()
			return;
		}
		
		let tagSignLocation = tagMatch?.range.location
		var spaceAfterTagRange = text.rangeOfString(" ", options: [], range: NSMakeRange(tagSignLocation! + 1, text.length - tagSignLocation! - 1))
		
		if spaceAfterTagRange.location == NSNotFound {
			spaceAfterTagRange.location = text.length
		}
		
		let tagRange = NSMakeRange(tagSignLocation! + 1, spaceAfterTagRange.location - tagSignLocation! - 1)
		let tagText = text.substringWithRange(tagRange)
		var tagTextNS = tagText as NSString
		let regexNew = try!  NSRegularExpression(pattern: "[^a-z0-9]*$", options: [.CaseInsensitive])
		let rangeNew = NSMakeRange(0, tagText.characters.count)
		let rangeRex = regexNew.rangeOfFirstMatchInString(tagText, options: [], range: rangeNew)
		tagTextNS = tagTextNS.stringByReplacingCharactersInRange(rangeRex, withString: "")
		rangeForReplaceText = NSMakeRange(tagRange.location, tagTextNS.length)
		if selectedRange.location >= rangeForReplaceText.location && selectedRange.location <= rangeForReplaceText.location + rangeForReplaceText.length {
			fillterUserList(userListArr, searchText: tagText)
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
			let searchDataSource = userListArr.filter { predicate.evaluateWithObject($0) }
			if searchDataSource .count > 0 {
				suggestionView.userListArr = searchDataSource
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
			suggestionView.frame = CGRectMake(20, textView.frame.origin.y - 70 , UIScreen.mainScreen().bounds.width - 40,0)
		} else if suggestionView.userListArr.count ==  2 || suggestionView.userListArr.count ==  1 {
			suggestionView.frame = CGRectMake(20, textView.frame.origin.y - 70 , UIScreen.mainScreen().bounds.width - 40, 70)
		} else if suggestionView.userListArr.count ==  3 || suggestionView.userListArr.count ==  4 {
			suggestionView.frame = CGRectMake(20, textView.frame.origin.y - 140 , UIScreen.mainScreen().bounds.width - 40, 140)
		} else {
			suggestionView.frame = CGRectMake(20, textView.frame.origin.y - 210 , UIScreen.mainScreen().bounds.width - 40, 210)

		}
		if suggestionCellShow {
			suggestionView.hidden = false
			suggestionCellShow    = false
		} else {
			suggestionView.hidden = true
			suggestionCellShow    = true
		}
		
		suggestionView.userCollectionView.reloadData()
	}
}
extension ViewController :UITableViewDelegate,UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(customTVC.cellIDentifier, forIndexPath: indexPath) as! customTVC
		if indexPath.row == 4{
			cell.btn.hidden = false
		} else{
			cell.btn.hidden = true
		}
			cell.btn.addTarget(self, action: #selector(ViewController.btnPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		return cell
		
	}
	func btnPressed(sender:UIButton) {
		
		let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CustomSuggestionVC") as! CustomSuggestionVC
			self.presentViewController(vc, animated: true, completion: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(didDismissSecondViewController), name: "suggestionViewismissed", object: nil)
		
	
	}
	func didDismissSecondViewController(notification: NSNotification) {
		print(notification.userInfo!["userInfo"] as! String)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}
