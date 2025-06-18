//
//  LocationController.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import UIKit
import CoreLocation

enum LocationAccuracy {
    case reduced, low, medium, high, best, navigation
}

class LocationManager: NSObject, ObservableObject {

    private var manager = CLLocationManager()
	private(set) var isUpdating = false
	private(set) var currentLocation: CLLocation?
	
	var onLocationUpdate: ((CLLocation) -> Void)?
	
	override init() {
        super.init()
		manager.delegate = self
		manager.distanceFilter = kCLDistanceFilterNone
		configureAccuracy(.high)
		enableBackgroundUpdates(false)
	}
	
	//MARK: - Permissions
	
	func requestLocationPermission() {
		switch manager.authorizationStatus {
			case .notDetermined:
				manager.requestWhenInUseAuthorization()
				
			case .restricted, .denied:
				showLocationPermissionAlert()
				
			case .authorizedWhenInUse, .authorizedAlways:
				getCurrentLocation()
				
			@unknown default:
				break
		}
	}
	
	//Track Changes
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
			case .authorizedWhenInUse, .authorizedAlways:
				getCurrentLocation()
				
			case .denied, .restricted:
				showLocationPermissionAlert()
				
			default:
				break
		}
	}
	
	func showLocationPermissionAlert() {
		guard let windowScene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let topVC = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController else {
			return
		}
		
		let alert = UIAlertController(
			title: "Location Permission Needed",
			message: "Please enable location services in Settings.",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		topVC.present(alert, animated: true)
	}
    
    //MARK: - Location Manager Options
    
    func configureAccuracy(_ accuracy: LocationAccuracy ) {
		switch accuracy {
			case .reduced:
				manager.desiredAccuracy = kCLLocationAccuracyReduced
				
			case .low:
				manager.desiredAccuracy = kCLLocationAccuracyKilometer
				
			case .medium:
				manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
				
			case .high :
				manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
				
			case .best:
				manager.desiredAccuracy = kCLLocationAccuracyBest
				
			case.navigation:
				manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		}
    }
    
    func enableBackgroundUpdates(_ enabled: Bool) {
        manager.allowsBackgroundLocationUpdates = enabled
		manager.pausesLocationUpdatesAutomatically = !enabled
    }

	//MARK: - Location Updates
	
	func getCurrentLocation() {
		isUpdating = false
		manager.requestLocation()
	}
	
	func startLocationUpdates() {
		isUpdating = true
		manager.startUpdatingLocation()
	}
	
	func stopLocationUpdates() {
		isUpdating = false
		manager.stopUpdatingLocation()
	}
}

extension LocationManager: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		debugPrint("[Location] Failed Location: \(error.localizedDescription)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		currentLocation = locations.last
		
		if let currentLocation {
			onLocationUpdate?(currentLocation)
		}
	}
	
	func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
		debugPrint("[Location] Paused Location Updates")
	}
	
	func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
		debugPrint("[Location] Resumed Location Updates")
	}
}
