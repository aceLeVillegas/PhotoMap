//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let vc = UIImagePickerController()
    var photoPick: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
        
        vc.delegate = self
        vc.allowsEditing = true
        self.navigationController?.popToViewController(self, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        self.present(vc, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        photoPick = originalImage
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "tagSegue", sender: nil)
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: Double, longitude: Double, image: UIImage){
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.photo = image
        mapView.addAnnotation(annotation)
        
        self.navigationController?.popToViewController(self, animated: true)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Segue For Locations
        if segue.identifier == "tagSegue"{
            
            let destinationViewController = segue.destination as! LocationsViewController
            
            destinationViewController.photoPick = self.photoPick
            destinationViewController.delegate = self
            
        }
        // Segue For FullImage 
        if segue.identifier == "fullImageSegue"{
            
            let destinationViewController = segue.destination as! FullImageViewController

            destinationViewController.pinImage = self.photoPick
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            
        }
        // Resize Image
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        imageView.image = thumbnail
        UIGraphicsEndImageContext()
        
        // Info Button
        let button = UIButton(type: UIButtonType.detailDisclosure) as UIButton
        annotationView?.rightCalloutAccessoryView = button

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView{
            
            // On tapping the disclosure button you will get here
            if let anno =  view.annotation as? PhotoAnnotation{
                
                self.photoPick = anno.photo
                self.performSegue(withIdentifier: "fullImageSegue", sender: nil)
            }
            
        }
    }
}
