//
//  CustomSuggestionVC.swift
//  demoCustomSuggestion
//
//  Created by Atal Bansal on 06/09/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit

class CustomSuggestionVC: UIViewController {
	@IBOutlet  weak var tableviewSchool:UITableView!
	@IBOutlet var mySearchBar: UISearchBar!
	
	var isSearching : Bool = false
	var dataArr:NSMutableArray = NSMutableArray()
	var dataArrSearch:NSMutableArray = NSMutableArray()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		relodData1()
        // Do any additional setup after loading the view.
    }
	func relodData1(){
		//let baseUrl = "https://maps.googleapis.com/maps/api/place/search/json?location=28.5355,77.3910&radius=1000&types=school&sensor=true&key=AIzaSyCskP0bQxjH4AE5rAAtHIiwpaa3Zih8yoE"
		//let apikey = "AIzaSyCskP0bQxjH4AE5rAAtHIiwpaa3Zih8yoE"
		//let url = NSURL(string: "\(baseUrl)latlng=\(lat),\(long)&key=\(apikey)")
		let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/search/json?location=28.621460,77.1957362&radius=5000&types=school&sensor=true&key=AIzaSyCskP0bQxjH4AE5rAAtHIiwpaa3Zih8yoE")
		let data = NSData(contentsOfURL: url!)
		let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
		
		if let result = json["results"] as? NSMutableArray {
			print(result)
			dataArr=result
			tableviewSchool.reloadData()

		}
		
		
	}
	@IBAction func cloaseClick(sender: AnyObject) {
		var dic:NSDictionary  = NSDictionary()
		if self.isSearching == true {
			dic =  dataArrSearch[sender.tag] as! NSDictionary
		}else {
			dic =  dataArr[sender.tag] as! NSDictionary
		}
		self.dismissViewControllerAnimated(false, completion: nil)
		let str:String = (dic.objectForKey("name") as? String)!
		let userInfo = ["userInfo" : str]
		NSNotificationCenter.defaultCenter().postNotificationName("suggestionViewismissed", object: nil,userInfo:userInfo)

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CustomSuggestionVC :UITableViewDelegate,UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.isSearching == true {
			return dataArrSearch.count
		}else {
			return dataArr.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var dic:NSDictionary  = NSDictionary()
		let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
		if self.isSearching == true {
			dic =  dataArrSearch[indexPath.row] as! NSDictionary
		}else {
				dic =  dataArr[indexPath.row] as! NSDictionary
		}
		cell.textLabel?.text = dic.objectForKey("name") as? String
		cell.detailTextLabel?.text = dic.objectForKey("vicinity") as? String
		return cell
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let btn = UIButton(type: UIButtonType.Custom)
		btn.tag = indexPath.row
		self.cloaseClick(btn)
	}
	
	
}
extension CustomSuggestionVC : UISearchBarDelegate {
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		
		if self.mySearchBar.text!.isEmpty {
			
			// set searching false
			self.isSearching = false
			
			// reload table view
			tableviewSchool.reloadData()
			
		}else{
			
			// set searghing true
			self.isSearching = true
			
			// empty searching array
			dataArrSearch.removeAllObjects()
			
			// find matching item and add it to the searcing array
			for i in 0..<self.dataArr.count {
				
				let dic:NSDictionary =  dataArr[i] as! NSDictionary
				let listItem:String = (dic.objectForKey("name") as? String)!
				if listItem.lowercaseString.rangeOfString(self.mySearchBar.text!.lowercaseString) != nil {
					dataArrSearch.addObject(dic)
				}
			}
			
			tableviewSchool.reloadData()
		}
		
	}
	
	// hide kwyboard when search button clicked
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.mySearchBar.resignFirstResponder()
	}
	
	// hide keyboard when cancel button clicked
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		self.mySearchBar.text = ""
		self.mySearchBar.resignFirstResponder()
		
		tableviewSchool.reloadData()
	}

}
