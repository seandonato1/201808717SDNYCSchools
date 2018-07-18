//
//  SchoolDetailViewController.swift
//  20180717-SD-NYCSchools
//
//  Created by Sean Donato on 7/17/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class SchoolDetailViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapViewSD: MKMapView!
    @IBOutlet weak var nameLabelSD: UILabel!
    @IBOutlet weak var locationLabelSD: UILabel!
    @IBOutlet weak var mathScoreSD: UILabel!
    @IBOutlet weak var readingScoreSD: UILabel!
    @IBOutlet weak var writingScoreSD: UILabel!
    @IBOutlet weak var overviewSD: UITextView!
    
    let schoolSD: School
    let phoneNumberSD: String
    
    init(schoolData:School) {
        
        //initalize all the properties of MyViewController here, before calling super class designated initalizer
        
        schoolSD = schoolData
        phoneNumberSD = schoolData.phone
        
        super.init(nibName: "SchoolDetailViewController", bundle: nil)//Designated initializer, pass nil, for both params if not using NIB
        //Now you have access to self
        

        
    }
    
    
    
    //This method needs to be implemented as UIViewController conform to NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        mapViewSD.delegate = self
        nameLabelSD.text = schoolSD.name
        locationLabelSD.text = schoolSD.location
        overviewSD.text = schoolSD.overview
        self.getSATScores()
        self.setUpMap()
        
    }
    
    func setUpMap(){
    
        //sets center of map to the schools coordinates
        let centerC = CLLocationCoordinate2D.init(latitude: schoolSD.latitude, longitude: schoolSD.longitude)
        
        //makes viewable region more focused than default
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: centerC, span: span)
        mapViewSD.setRegion(region, animated: true)
        
        //adds annotation at school coordinate
        let annotation = MKPointAnnotation()
        annotation.title = schoolSD.name
        annotation.coordinate = centerC
        mapViewSD.addAnnotation(annotation)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        guard annotation is MKPointAnnotation else { return nil }
    
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    
        if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
    
        return annotationView
        }
    
    @IBAction func callSchool(_ sender: Any) {
    
        //call school
        guard let number = URL(string: "tel://" + phoneNumberSD) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func openInMaps(_ sender: Any) {
    
            //open apple maps with directions to school
            let coordinate = CLLocationCoordinate2DMake(schoolSD.latitude,schoolSD.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Target location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])

        
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        
        let schoolURL = "https://" + schoolSD.website
        UIApplication.shared.open(URL(string : schoolURL)!, options: [:], completionHandler: { (status) in
            
        })


    }
    
    func getSATScores() {
        
        let satsScoresURL = "https://data.cityofnewyork.us/resource/734v-jeq5.json"
        
        //append string for pagination, limit, and order sorting to guarantee the the order of the data is stable, as specified here:https://dev.socrata.com/docs/paging.html
        let schoolsURLSorted = satsScoresURL + "?dbn=" + schoolSD.dbn
        
        //make the HTTP request using Alamofire framework
        Alamofire.request(schoolsURLSorted,method: .get,encoding:URLEncoding.queryString).validate(statusCode:200..<300).responseJSON { response in
            
            switch response.result {
                
            case .success:
                
                guard let data = response.result.value else{return}
                
                if let array = data as?  NSArray
                {
                    if(array.count > 0){
                        
                        guard let dict = array[0] as? Dictionary<String,Any>else {return}
                    
                        self.mathScoreSD.text = dict["sat_math_avg_score"] as? String ?? ""
                        self.readingScoreSD.text = dict["sat_critical_reading_avg_score"] as? String ?? ""
                        self.writingScoreSD.text = dict["sat_writing_avg_score"] as?  String ?? ""

                    }
                    
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
