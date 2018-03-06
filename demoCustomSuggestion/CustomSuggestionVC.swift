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
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
		
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
        self.dismiss(animated: false, completion: nil)
        let str:String = (dic.object(forKey: "name") as? String)!
		let userInfo = ["userInfo" : str]
     //   NotificationCenter.defaultCenter.postNotificationName("suggestionViewismissed", object: nil,userInfo:userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "suggestionViewismissed"), object: nil, userInfo: userInfo)

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.isSearching == true {
			return dataArrSearch.count
		}else {
			return dataArr.count
		}
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var dic:NSDictionary  = NSDictionary()
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
		if self.isSearching == true {
			dic =  dataArrSearch[indexPath.row] as! NSDictionary
		}else {
				dic =  dataArr[indexPath.row] as! NSDictionary
		}
        cell.textLabel?.text = dic.object(forKey: "name") as? String
        cell.detailTextLabel?.text = dic.object(forKey: "vicinity") as? String
		return cell
		
	}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
		btn.tag = indexPath.row
        self.cloaseClick(sender: btn)
	}
	
	
}
extension CustomSuggestionVC : UISearchBarDelegate {
	
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
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
                let listItem:String = (dic.object(forKey: "name") as? String)!
//                if listItem.lowercaseString.rangeOfString(self.mySearchBar.text!.lowercaseString) != nil {
//                    dataArrSearch.add(dic)
//                }
                if (listItem.lowercased().range(of: self.mySearchBar.text!.lowercased()) != nil) {
                    dataArrSearch.add(dic)
                }
			}
			
			tableviewSchool.reloadData()
		}
		
	}
	
	// hide kwyboard when search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		self.mySearchBar.resignFirstResponder()
	}
	
	// hide keyboard when cancel button clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.mySearchBar.text = ""
		self.mySearchBar.resignFirstResponder()
		
		tableviewSchool.reloadData()
	}

}
