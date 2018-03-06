//
//  CustomSuggestionView.swift
//  demoCustomSuggestion
//
//  Created by Atal Bansal on 06/09/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit

class CustomSuggestionView: UIView {
	
	@IBOutlet  weak var userCollectionView:UICollectionView!
	var userListArr:NSArray = NSArray()
	var rangeForReplaceText: NSRange!
	
	override func awakeFromNib() {
		let nibName = UINib(nibName: "suggestionUserCVC", bundle:nil)
        userCollectionView.register(nibName, forCellWithReuseIdentifier: "Cell")
	}
	class func instanceFromNib() -> CustomSuggestionView {
		
        return UINib(nibName: "CustomSuggestionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomSuggestionView
	}

}
extension CustomSuggestionView:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return userListArr.count
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: 130, height: 50)
	}
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath as IndexPath) as! suggestionUserCVC
		cell.nameLbl.text = userListArr[indexPath.row] as? String
		
		return cell
	}
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
		let str=userListArr[indexPath.row] as! String
        let userInfo = ["userText":str,"rangeForReplaceText":rangeForReplaceText] as [String : Any]
       // NotificationCenter.defaultCenter.postNotificationName("UserNameAdded", object: nil, userInfo:userInfo as [NSObject : AnyObject])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserNameAdded"), object: nil, userInfo: userInfo)
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HideCollectionView"), object: nil, userInfo: userInfo)
     //   NotificationCenter.defaultCenter.postNotificationName("HideCollectionView", object: nil, userInfo:userInfo as [NSObject : AnyObject])
		
	}
	

	
}
