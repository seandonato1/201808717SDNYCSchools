//
//  ViewController.swift
//  20180717-SD-NYCSchools
//
//  Created by Sean Donato on 7/17/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

import UIKit
import Alamofire


//variable to store school structs parsed from received data
private var schoolArray = [School]()

//offset for pagination of results
var offset = 0

//this is a helper variable that is changed to 1 once the received data array has a length of zero, so we know not to make any more calls. While it's value is zero, getBooks will be called when the user scrolls to the bottom of the table view
var moreSchools = 0

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate {
    @IBOutlet weak var schoolTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return schoolArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolcell", for: indexPath) as! SchoolTableViewCell
        
        let school = schoolArray[indexPath.row]

        
        cell.schoolName.text = school.name
        
        if indexPath.row == schoolArray.count - 1 { // last cell
            
            if(moreSchools == 0){
                
                self.getBooks() // increment `fromIndex` by 20 before server call

            }
            
        }

        return cell


    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //corresponding school object for row
        let school = schoolArray[indexPath.row]
        
        //initialize school detail view controller
        let schoolDVC = SchoolDetailViewController(schoolData: school)
       
        //push detail view controller onto the navigation controller
        self.navigationController?.pushViewController(schoolDVC, animated: true)
        
        
    }
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        schoolTable.delegate = self
        schoolTable.dataSource = self
        schoolTable.rowHeight = 64
        
        //this method makes a GET call to the pre set URL to retrieve school data
        self.getBooks()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getBooks() {
        
        let schoolsURL = "https://data.cityofnewyork.us/resource/97mf-9njv.json"
        
        //append string for pagination, limit, and order sorting to guarantee the the order of the data is stable, as specified here:https://dev.socrata.com/docs/paging.html
        let schoolsURLSorted = schoolsURL + "?$limit=50&$order=:id&$offset=" + String(offset)
        
       //make the HTTP request using Alamofire framework
    Alamofire.request(schoolsURLSorted,method: .get,encoding:URLEncoding.queryString).validate(statusCode:200..<300).responseJSON { response in
            
            switch response.result {
                
            case .success:
                
                guard let data = response.result.value else{return}
                
                    if let array = data as?  [Dictionary<String, Any>]
                    {
                        
                        var i = 0

                        while i < array.count{
                            
                            let dict = array[i]
                            
                            let school = School(dictionary: dict)
                            
                            schoolArray.append(school)
                            
                            i += 1
                        }
                        if(array.count>0){
                            offset += 50

                        }else{
                            moreSchools = 1
                        }
                        self.schoolTable.reloadData()
                    }
                
                print("Validation Successful")
                
            case .failure(let error):
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                //
                let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                    print("");
                }
                
                alertController.addAction(action1)
                self.present(alertController, animated: true, completion: nil)
                print(error.localizedDescription)
            }
        }
    }

}

