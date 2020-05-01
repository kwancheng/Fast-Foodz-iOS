//
//  BusinessDetailViewController.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import UIKit
import MapKit
import SDWebImage

class BusinessDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callButton: UIButton!
    
    var business: Business?
    var userLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIInitialState()
        
        // Retrieve Directions
        if let userLocation = self.userLocation,
            let businessLocation = self.business?.coordinates?.toCLLocationCoordinate2D()
        {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: businessLocation, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    private func configureUIInitialState() {
        self.title = "Details"
        
        mapView.delegate = self
                
        callButton.backgroundColor = UIColor.competitionPurple
        callButton.setTitleColor(UIColor.white, for: .normal)
        
        imageView.backgroundColor = UIColor.londonSky
        
        if let imageUrl = business?.imageUrl,
            let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        
        nameLabel.text = business?.name
    }
    
    @IBAction func onSharePressed(_ sender: Any) {
        var shareItems = [Any]()
        if let urlStr = business?.url,
            let url = URL(string: urlStr) {
            shareItems.append(url)
        }
        
        let vc = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onCallBusinessPressed(_ sender: Any) {
        if let phone = business?.phone,
            let phoneUrl = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK: MKMapViewDelegate
extension BusinessDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.bluCepheus
        renderer.lineWidth = 4
        return renderer
    }
}
