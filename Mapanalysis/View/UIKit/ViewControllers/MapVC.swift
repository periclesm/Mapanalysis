//
//  MapVC.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit
import MapKit

class MapVC: UIViewController {
	
	@IBOutlet weak var locationButton: UIButton!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapTap: UIGestureRecognizer!
	
	private let locationManager = LocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.onLocationUpdate = { [weak self] location in
			self?.showLocation(on: location, userInitiated: false)
		}
		
		setupUI()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//Ask for permissions and show location
		locationManager.requestLocationPermission()
		//Granting permission automatically requests for location in Location Manager
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
		dvc.setMapType = {
			self.setMapType(type: AppPreferences.shared.mapType)
		}
		
		dvc.setMapZoomLevel = {
			debugPrint("Location update requested")
			self.zoomCurrentLocation()
		}
		
		dvc.centerMap = { enabled in
			if enabled {
				if AppPreferences.shared.headingOnMap {
					self.mapView.userTrackingMode = .followWithHeading
					self.locationButtonAppearance(trackingEnabled: true)
				} else {
					self.mapView.userTrackingMode = .follow
					self.locationButtonAppearance(trackingEnabled: true)
				}
			} else {
				self.mapView.userTrackingMode = .none
				self.locationButtonAppearance(trackingEnabled: false)
			}
			
			self.locationManager.getCurrentLocation()
		}
		
		dvc.headingOnMap = { enabled in
			if AppPreferences.shared.centerMap {
				self.mapView.userTrackingMode = .followWithHeading
			} else {
				self.mapView.userTrackingMode = .none
			}
			
			self.locationManager.getCurrentLocation()
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
		//Set options and map type
		mapOptions()
		setMapType(type: AppPreferences.shared.mapType)
		
		locationButtonAppearance(trackingEnabled: AppPreferences.shared.centerMap)
	}
	
	private func locationButtonAppearance(trackingEnabled: Bool) {
		var config = locationButton.configuration
		
		if trackingEnabled {
			config?.background.strokeColor = .systemMint
		} else {
			config?.background.strokeColor = .systemOrange
		}
		
		locationButton.configuration = config
	}
	
	//MARK: - Map configuration and functions
	
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
		
		if AppPreferences.shared.centerMap {
			mapView.userTrackingMode = .follow
			
			if AppPreferences.shared.headingOnMap {
				mapView.userTrackingMode = .followWithHeading
			}
		}
	}
	
	func setMapType(type: MapType) {
		switch type {
			case .standard:
				mapView.mapType = .standard
			case .satellite:
				mapView.mapType = .satelliteFlyover
			case .hybrid:
				mapView.mapType = .hybridFlyover
		}
	}
	
	func showLocation(on location: CLLocation, userInitiated: Bool) {
		debugPrint(String.debugInfo() + "Show location")
		debugPrint("lat: \(location.coordinate.latitude), lon: \(location.coordinate.longitude)")
		debugPrint("mapzoom: \(AppPreferences.shared.mapZoom)")
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
	
	func zoomCurrentLocation() {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		showLocation(on: location, userInitiated: false)
		
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
	
	//MARK: - IBActions
	
	@IBAction func centerToUserLocation() {
		/*
		 Important Note Here:
		 When the user pans, zooms or simply moves away from the current location, tracking stops.
		 When tracking is enabled again, it's a MKMap functionality not a CoreLocation functionality and the
		 Location Manager does not trigger.
		 Even when I manually trigger the location update, some zoom gimmicks are happenning because MKMap and
		 Location manager have different opinions on who's the boss for this.
		 I have not added a fix for this issue. Perhaps in a future code revisit...
		 */
		
		//if the user pans or zooms the map and center is on, it will be set to off.
		//Requesting location update each time the button is pressed to give an update when center is lost.
		debugPrint(String.debugInfo() + "Center map")
		
		followUserLocation()
		locationManager.getCurrentLocation()
	}
	
	private func followUserLocation() {
		switch mapView.userTrackingMode {
			case .none:
				debugPrint("Location does not follow User -- Enabling again")
				if AppPreferences.shared.centerMap {
					if AppPreferences.shared.headingOnMap {
						self.mapView.userTrackingMode = .followWithHeading
					} else {
						self.mapView.userTrackingMode = .follow
					}
				}
				
			case .follow:
				debugPrint("Location follows User")
				
			case .followWithHeading:
				debugPrint("Location follows User with Heading")
				
			@unknown default:
				debugPrint("Unknown follow user mode")
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
