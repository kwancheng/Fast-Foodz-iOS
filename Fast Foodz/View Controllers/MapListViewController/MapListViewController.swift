//
//  MapListViewController.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import UIKit
import RealmSwift
import MapKit

class MapListViewController: UIViewController {
    private let initialCoordinates = CLLocationCoordinate2D(latitude: 40.758896, longitude: -73.985130)
    private let searchRadiusMeters = 1000
    private let lastSelectedSegmentKey = "lastSelectedSegment"
    private let cellReuseId = "BusinessTableViewCell"
    private let annotationReuseId = "markerView"
        
    @IBOutlet weak var mapListToggle: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    private var locationManager = CLLocationManager()
    private var authorizationStatus = CLLocationManager.authorizationStatus()
    
    private var notificationToken: NotificationToken? = nil
    private var searchResponse: SearchResponse? = nil
    private var currentLocation: CLLocationCoordinate2D? = nil
                
    private var initializationComplete = false
    
    deinit {
        notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIInitialState()
        
        // This View Controller Monitors the Realm database for changes and acts accordingly
        let realm = try! Realm()
        let query = realm.objects(SearchResponse.self).sorted(byKeyPath: "requestDate", ascending: false)
         
        notificationToken = query.observe({ [weak self](changes: RealmCollectionChange<Results<SearchResponse>>) in
            switch changes {
            case .initial(let initialResults):
                self?.searchResponse = initialResults.isEmpty ? nil : initialResults.first
                
                if (self?.searchResponse) != nil {
                    // we have data from previous session
                    self?.finishInitialization(data: initialResults.first)
                } else {
                    // no cache. load initial. then waiting for update event
                    self?.loadInitialLocation()
                }

             case .update(let results, _, _, _):
                guard let strongSelf = self else { return }

                // Prune the database
                if results.count > 10 {
                    try? realm.write {
                        for i in (5 ..< results.count - 1).reversed() {
                            realm.delete(results[i])
                        }
                    }
                }
                
                if !strongSelf.initializationComplete {
                    self?.finishInitialization(data: results.first)
                } else {
                    // This is a normal update
                    self?.clearData()
                    self?.reloadData(data: results.first)
                }
                
             case .error(_):
                 break
             }
         })
    }
    
    private func finishInitialization(data: SearchResponse?) {
        // center on region's center
        if let regionCenter = data?.regionCenter?.toCLLocationCoordinate2D() {
            self.currentLocation = regionCenter
        }

        reloadData(data: data)
        showUI()
        initializationComplete = true
        startLocationManager()
    }
    
    private func configureUIInitialState() {
        // Various one time adjustments
        self.title = "Fast Food Places"

        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "Back", style: .plain, target: nil, action: nil)
        
        let offset = mapListToggle.frame.height + 24
        tableView.contentInset.top = offset
        
        // Attaching Various Delegates and nib/class registrations
        locationManager.delegate = self
        
        mapView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellReuseId, bundle: nil), forCellReuseIdentifier: cellReuseId)
                        
        mapListToggle.backgroundColor = UIColor.londonSky
        mapListToggle.selectedSegmentTintColor = UIColor.competitionPurple
        mapListToggle.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        mapListToggle.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.deepIndigo], for: .normal)
        
        mapListToggle.addTarget(self, action: #selector(mapListToggleChanged(_:)), for: .valueChanged)
        
        mapListToggle.selectedSegmentIndex = 0
        mapListToggle.isHidden = true
        mapView.isHidden = true
        tableView.isHidden = true
        loadIndicator.startAnimating()
    }
    
    private func showUI() {
        let defaults = UserDefaults.standard
        
        var segment: Segment = .map
        if let lastSelectedSegment = defaults.object(forKey: lastSelectedSegmentKey) as? Int {
            segment = Segment(rawValue: lastSelectedSegment) ?? .map
        }
        showSegment(segment)
    }
    
    private func showSegment(_ segmentToShow: Segment) {
        if mapListToggle.selectedSegmentIndex != segmentToShow.rawValue {
            mapListToggle.selectedSegmentIndex = segmentToShow.rawValue
        }
        
        UserDefaults.standard.set(segmentToShow.rawValue, forKey: lastSelectedSegmentKey)
        
        mapListToggle.isHidden = false
        loadIndicator.stopAnimating()

        var viewToHide: UIView?
        var viewToShow: UIView?
        
        switch segmentToShow {
        case .map:
            guard mapView.isHidden else { return } // nothing to show, map is already shown
            viewToShow = mapView
            viewToHide = tableView.isHidden ? nil : tableView
            
        case .list:
            guard tableView.isHidden else { return } // nothing to show, list is already shown
            viewToShow = tableView
            viewToHide = mapView.isHidden ? nil : mapView
        }

        // Make sure they are properly prepped
        viewToShow?.alpha = 0
        viewToShow?.isHidden = false
        viewToHide?.alpha = 1
        viewToHide?.isHidden = false
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                viewToShow?.alpha = 1
                viewToHide?.alpha = 0
            },
            completion: { (done) in
                viewToHide?.isHidden = true
            })
    }
    
    private func showBusinessDetails(business: Business) {
        self.performSegue(withIdentifier: "showDetails", sender: business)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let business = sender as? Business else { return }
        guard let vc = segue.destination as? BusinessDetailViewController else { return }
        vc.business = business
        vc.userLocation = currentLocation
    }
        
    private func startLocationManager() {
        // Startup Location Manager
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
        
    private func clearData() {
        self.searchResponse = nil
        tableView.reloadData() // removes all the realm objects
        mapView.removeAnnotations(mapView.annotations.filter({$0 is BusinessAnnotation}))
    }
    
    private func reloadData(data: SearchResponse?) {
        guard let data = data else { return }
        
        self.searchResponse = data
        
        tableView.reloadData()

        let annotations = try? self.searchResponse?.businesses.compactMap({ (business) throws -> BusinessAnnotation? in
            return BusinessAnnotation(business: business)
        })
        
        if let annotations = annotations {
            // remove previous annotations
            mapView.removeAnnotations(mapView.annotations.filter({$0 is BusinessAnnotation}))
            // add the new ones
            mapView.addAnnotations(annotations)
            centerMapOnCurrentLocation()
        }
    }
    
    private func loadInitialLocation() {
        self.currentLocation = initialCoordinates
        
        Database.shared.refreshBusinesses(
            latitude: initialCoordinates.latitude,
            longitude: initialCoordinates.longitude,
            radiusMeters: searchRadiusMeters,
            completion: nil)
    }
    
    @objc
    private func mapListToggleChanged(_ sender: UISegmentedControl) {
        let segment: Segment = sender.selectedSegmentIndex == 0 ? .map : .list
        self.showSegment(segment)
    }
    
    func centerMapOnCurrentLocation() {
        guard let currentLocation = self.currentLocation else { return } // failed ... just ignore
        
        let region = MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: CLLocationDistance(searchRadiusMeters),
            longitudinalMeters: CLLocationDistance(searchRadiusMeters))
        
        mapView.setRegion(region, animated: true)
    }
}

// MARK: Private Classes
fileprivate extension MapListViewController {
    enum Segment: Int {
        case map, list
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension MapListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResponse?.businesses.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as? BusinessTableViewCell else {
            fatalError("Nib not registered")
        }

        if let business = searchResponse?.businesses[indexPath.row] {
            cell.populateCell(business: business)
        }
        
        let sv = UIView()
        sv.backgroundColor = UIColor.powderBlue
        cell.selectedBackgroundView = sv
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let business = self.searchResponse?.businesses[indexPath.row] else { return }
        showBusinessDetails(business: business)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let bc = cell as? BusinessTableViewCell else { return }
        updateCategoryTint(cell: bc, indexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPaths = self.tableView.indexPathsForVisibleRows else { return }
        for indexPath in indexPaths {
            guard let bc = self.tableView.cellForRow(at: indexPath) as? BusinessTableViewCell else { continue }
            updateCategoryTint(cell: bc, indexPath: indexPath)
        }
    }
    
    private func updateCategoryTint(cell: BusinessTableViewCell, indexPath: IndexPath) {
        let rectOfCellInTableView = tableView.rectForRow(at: indexPath)
        let rectOfCellInSuperview = tableView.convert(rectOfCellInTableView, to: tableView.superview)
        let midY = rectOfCellInSuperview.midY

        let tableHeight = tableView.frame.height
        guard midY >= 0 && midY < tableHeight else {
            cell.categoryImage.tintColor = UIColor.deepIndigo
            return
        }
        
        let colorCount = CGFloat(UIColor.gradientColors.count)
        let brackets = tableHeight / colorCount

        let colorPos = Int(rectOfCellInSuperview.midY / brackets)        
        cell.categoryImage.tintColor = UIColor.gradientColors[colorPos]
    }
}

// MARK: MKMapViewDelegate
extension MapListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is BusinessAnnotation else { return nil }
        
        let view: MKAnnotationView = {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseId) {
                return view
            } else {
                return MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
            }
        }()

        view.image = UIImage(named: "pin")
        view.annotation = annotation
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let businessAnnotation = view.annotation as? BusinessAnnotation else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        showBusinessDetails(business: businessAnnotation.business)
    }
}

// Mark: CLLocationManagerDelegate
extension MapListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.authorizationStatus = status
                locationManager.startUpdatingLocation()
                       
            default:
                self.authorizationStatus = status
                loadInitialLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locationManager.location?.coordinate else { return }
        
        self.currentLocation = coord
        // kick off a new load
        Database.shared.refreshBusinesses(
            latitude: coord.latitude,
            longitude: coord.longitude,
            radiusMeters: searchRadiusMeters,
            completion: nil)
    }
    
}
