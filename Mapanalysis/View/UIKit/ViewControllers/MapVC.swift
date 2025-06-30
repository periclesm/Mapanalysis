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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setMapZoom()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//Ask for permissions and show location
		locationManager.requestLocationPermission()
		locationButtonBackgroundAppearance()
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
		
		dvc.continuousUpdates = { enabled in
			if enabled {
				self.locationManager.startLocationUpdates()
				self.locationButtonBackgroundAppearance()
			} else {
				self.locationManager.stopLocationUpdates()
			}
			
			self.locationButtonRingAppearance(continuousEnabled: AppPreferences.shared.continuousUpdates)
			self.locationButtonBackgroundAppearance()
		}
		
		dvc.backgroundUpdates = { enabled in
			self.locationManager.enableBackgroundUpdates(enabled)
		}
	}
	
	private func bindFavorites(_ dvc: FavoritesVC) {
		dvc.presentAnnotation = { [weak self] annotation in
			let location = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
			self?.showLocation(on: location, userInitiated: true)
		}
	}
	
	//MARK: - Display
	
	private func setupUI() {
		//Set options and map type
		mapOptions()
		setMapType(type: AppPreferences.shared.mapType)
		locationButtonRingAppearance(continuousEnabled: AppPreferences.shared.continuousUpdates)
	}
	
	private func locationButtonRingAppearance(continuousEnabled: Bool) {
		var config = locationButton.configuration
		
		if continuousEnabled {
			config?.background.strokeColor = .systemMint
		} else {
			config?.background.strokeColor = .systemOrange
		}
		
		locationButton.configuration = config
	}
	
	private func locationButtonBackgroundAppearance() {
		var config = locationButton.configuration
		
		if locationManager.isUpdating {
			config?.background.backgroundColor = .systemTeal
		} else {
			config?.background.backgroundColor = .systemPurple
		}
		
		locationButton.configuration = config
	}
	
	///Using this function at app start to set the Map Zoom based on AppPreferences.shared.mapZoom
	private func setMapZoom() {
		let region = MKCoordinateRegion(
			center: mapView.centerCoordinate,
			latitudinalMeters: AppPreferences.shared.mapZoom,
			longitudinalMeters: AppPreferences.shared.mapZoom
		)
		
		mapView.setRegion(region, animated: true)
	}
	
	//The heck! I used AI to get this... There is no API function for that and I had no clue.
	///Get the Current Latitudinal Map Zoom (aka, either the default or the one the user set by pinching)
	private func getCurrentLatitudinalMeters() -> Double {
		let region = mapView.region
		return region.span.latitudeDelta * 111_000
	}
	
	///Get the Current Longitudinal Map Zoom (aka, either the default or the one the user set by pinching)
	private func getCurrentLongitudinalMeters() -> Double {
		let region = mapView.region
		return region.span.longitudeDelta * 111_000 * cos(region.center.latitude * .pi / 180)
	}
	
	//MARK: - Map configuration and functions
	
	private func mapOptions() {
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
	
	private func setMapType(type: MapType) {
		switch type {
			case .standard:
				mapView.mapType = .standard
			case .satellite:
				mapView.mapType = .satelliteFlyover
			case .hybrid:
				mapView.mapType = .hybridFlyover
		}
	}
	
	/**
	 Shows the location on the map.
	 Used for 2 cases: Either when Location managers updates current location or when the user requests a location (by tapping on the map or selecting a favorite).
	 In the latter case `userInitiated` is true, otherwise false (Location Manager initiated).
	 In both User Initiated cases, Annotation View appears and needs to have the pin and map re-centered to the top half of the screen (bottom half is the Annotation View)
	 In Location Manager case, just a `setRegion` will do.
	 */
	private func showLocation(on location: CLLocation, userInitiated: Bool) {
		debugPrint(String.debugInfo() + "Show location")
		debugPrint("lat: \(location.coordinate.latitude), lon: \(location.coordinate.longitude)")
		debugPrint("mapzoom: \(AppPreferences.shared.mapZoom)")
		mapView.removeAnnotations(mapView.annotations)
		
		let region = MKCoordinateRegion(
			center: location.coordinate,
			latitudinalMeters: userInitiated ? getCurrentLatitudinalMeters() : AppPreferences.shared.mapZoom,
			longitudinalMeters: userInitiated ? getCurrentLongitudinalMeters() : AppPreferences.shared.mapZoom
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
	
	///Used in the callback when user sets the default Map Zoom in settings. It simply zooms the map on the Map Center
	private func zoomCurrentLocation() {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		showLocation(on: location, userInitiated: false)
	}
	
	///Use it to center the map over the Annotation Point
	private func centerMap(at coordinate: CLLocationCoordinate2D) {
		//Get the screen point from coordinate
		let point = mapView.convert(coordinate, toPointTo: mapView)

		let newCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.height * 0.3)
		let translationX = newCenter.x - point.x
		let translationY = newCenter.y - point.y
		let offset = CGPoint(x: translationX, y: translationY)
		
		mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x), animated: true)
	}
	
	///Adds the Pin on the map on a user selected location or when a favorite is selected.
	private func createPin(_ annotation: Annotation) {
		let pin = MKPointAnnotation()
		pin.coordinate = annotation.coordinate
		pin.title = annotation.title
		mapView.addAnnotation(pin)
	}
	
	//MARK: - IBActions
	
	/**
	 Tap the location button:
	 If not in continuous mode, it will get the current location once
	 If in continuous mode, it will start/stop getting location updates (but continuous updates setting will remain.
	 */
	@IBAction func requestLocationAction() {
		if AppPreferences.shared.continuousUpdates {
			if locationManager.isUpdating {
				locationManager.stopLocationUpdates()
			} else {
				locationManager.startLocationUpdates()
			}
			
			locationButtonBackgroundAppearance()
		} else {
			locationManager.getCurrentLocation()
		}
	}
	
	///Long Tap on location button to toggle map continuous updates. This is a shortcut instead of opening Options.
	@IBAction func continuousUpdatesAction(_ gesture: UILongPressGestureRecognizer) {
		switch gesture.state {
			case .began:
				if AppPreferences.shared.continuousUpdates {
					AppPreferences.shared.continuousUpdates = false
					locationManager.stopLocationUpdates()
				} else {
					AppPreferences.shared.continuousUpdates = true
					locationManager.startLocationUpdates()
				}
				
				locationManager.enableBackgroundUpdates(AppPreferences.shared.backgroundUpdates)
				locationButtonRingAppearance(continuousEnabled: AppPreferences.shared.continuousUpdates)
				locationButtonBackgroundAppearance()
				
			default:
				break // do nothing
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
