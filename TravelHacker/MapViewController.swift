//
//  MapViewController.swift
//  TravelHacker
//
//  Created by Emin Israfil on 2/24/24.
//

import Foundation
import MapKit

class TravelMapViewController: UIViewController {
    var mapView: MKMapView!
    var searchResults: [SearchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupAnnotations()
        configureNavigationBar()
    }
    
    private func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
    }
    
    private func setupAnnotations() {
        for result in searchResults {
            let annotation = MKPointAnnotation()
            annotation.title = result.description
            annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            mapView.addAnnotation(annotation)
        }
        if let firstResult = searchResults.first {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstResult.latitude, longitude: firstResult.longitude), latitudinalMeters: 100000, longitudinalMeters: 100000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Search Results Map"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // Method to update search results and refresh map annotations
    func updateSearchResults(_ results: [SearchResult]) {
        searchResults = results
        mapView.removeAnnotations(mapView.annotations) // Remove existing annotations
        setupAnnotations()
    }
}


