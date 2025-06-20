//
//  MapVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit
import MapKit

class MapVC: UIViewController {
	
	@IBOutlet weak var locationButton: MALocationButton!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapTap: UIGestureRecognizer!
	
	private let locationManager = LocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.destination {
			case let dvc as OptionsVC:
				bindOptions(dvc)
				
			case let dvc as AnnotationVC:
				dvc.annotation = sender as? Annotation
				
			case let dvc as FavoritesVC:
				bindFavorites(dvc)
				
			default:
				assert(true, "Unhandled segue destination")
		}
	}
	
	private func bindOptions(_ dvc: OptionsVC) {
		dvc.mapUpdate = {
			self.setmapType(type: AppPreferences.shared.mapType)
		}
		
		dvc.locationUpdate = {
			debugPrint("Location update requested")
			//self.displayLocation()
		}
		
		dvc.continuousUpdates = { enabled in
			self.updateLocation()
		}
	}
	
	private func bindFavorites(_ dvc: FavoritesVC) {
		dvc.presentAnnotation = { [weak self] annotation in
			let location = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
			self?.showLocation(on: location, userInitiated: true)
		}
	}
	
	//MARK: - Map Display
	
	private func setupUI() {
		locationButton.setState(state: .standard)
		mapOptions()
		setmapType(type: AppPreferences.shared.mapType)
		
		locationManager.requestLocationPermission()
		updateLocation()
		
		locationManager.onLocationUpdate = { [weak self] location in
			self?.showLocation(on: location, userInitiated: false)
		}
	}
	
	func mapOptions() {
		mapView.showsLargeContentViewer = true
		mapView.showsUserLocation = true
		mapView.showsScale = true
		mapView.showsCompass = true
		mapView.showsBuildings = true
		mapView.showsTraffic = {
			switch mapView.mapType {
				case .standard, .hybrid, .hybridFlyover:
					true
				default:
					false
			}
		}()
	}
	
	func setmapType(type: MapType) {
		switch type {
			case .standard:
				mapView.mapType = .standard
			case .satellite:
				mapView.mapType = .satelliteFlyover
			case .hybrid:
				mapView.mapType = .hybridFlyover
		}
	}
	
	//MARK: - Map functionality
	
	func showLocation(on location: CLLocation, userInitiated: Bool) {
		mapView.removeAnnotations(mapView.annotations)
		
		let region = MKCoordinateRegion(
			center: location.coordinate,
			latitudinalMeters: AppPreferences.shared.mapZoom,
			longitudinalMeters: AppPreferences.shared.mapZoom
		)
		
		if userInitiated {
			Task(priority: .userInitiated) { [weak self] in
				guard let self else { return }
				
				/*
				 Get the annotator here.
				 Works by default with Apple Geocoder. If another Geocoder is present, the geocoder should conform to the GeocodingProvider protocol
				 and annotator should be initialied as annotator = AnnotatorService(provider: ).
				 */
				let annotator = AnnotatorService()
				
				if let annotation = await annotator.createAnnotation(location) {
					centerMap(at: annotation.coordinate)
					createPin(annotation)
					performSegue(withIdentifier: "AnnotationSegue", sender: annotation)
				}
			}
		} else {
			mapView.setRegion(region, animated: true)
		}
	}
	
	//Use it to center the map over the Annotation Point
	func centerMap(at coordinate: CLLocationCoordinate2D) {
		//Get the screen point from coordinate
		let point = mapView.convert(coordinate, toPointTo: mapView)

		let newCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.height * 0.3)
		let translationX = newCenter.x - point.x
		let translationY = newCenter.y - point.y
		let offset = CGPoint(x: translationX, y: translationY)
		
		mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x), animated: true)
	}
	
	func createPin(_ annotation: Annotation) {
		let pin = MKPointAnnotation()
		pin.coordinate = annotation.coordinate
		pin.title = annotation.title
		mapView.addAnnotation(pin)
	}
	
	@IBAction func updateLocation() {
		if AppPreferences.shared.continuousUpdates {
			if locationManager.isUpdating {
				locationManager.stopLocationUpdates()
				locationButton.setState(state: .continuousOFF)
			}
			else {
				locationManager.startLocationUpdates()
				locationButton.setState(state: .continuousON)
			}
		}
		else {
			locationManager.stopLocationUpdates()
			locationManager.getCurrentLocation()
			locationButton.setState(state: .standard)
		}
	}
	
	@IBAction func handleMapTap(_ gesture: UITapGestureRecognizer) {
		let location = mapTap.location(in: mapView)
		let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
		
		//Recenter Map
		let tappedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		showLocation(on: tappedLocation, userInitiated: true)
	}
}
