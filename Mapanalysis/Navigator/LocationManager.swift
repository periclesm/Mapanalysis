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
		
		//Deprecated in the latest app version
		//enableBackgroundUpdates(false)
	}
	
	//MARK: - Permissions
	
	func requestLocationPermission() {
		switch manager.authorizationStatus {
			case .notDetermined:
				debugPrint("[Request] Location Permission Not Determined")
				manager.requestWhenInUseAuthorization()
				
			case .restricted, .denied:
				debugPrint("[Request] Location Permission Restricted")
				showLocationPermissionAlert()
				
			case .authorizedWhenInUse, .authorizedAlways:
				debugPrint("[Request] Location Permission Allowed")
				getCurrentLocation()
				
			@unknown default:
				debugPrint("[Request] Location Permission Unknown")
		}
	}
	
	//Track Changes
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
			case .authorizedWhenInUse, .authorizedAlways:
				debugPrint("[Request Change] Location Permission Allowed")
				getCurrentLocation()
				
			case .denied, .restricted:
				debugPrint("[Request Change] Location Permission Restricted")
				showLocationPermissionAlert()
				
			default:
				debugPrint("[Request Change] Location Permission Unknown")
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
    
	@available(*, deprecated, message: "No need for continious updates in the last app version logic.")
    func enableBackgroundUpdates(_ enabled: Bool) {
        manager.allowsBackgroundLocationUpdates = enabled
		manager.pausesLocationUpdatesAutomatically = !enabled
    }

	//MARK: - Location Updates
	
	func getCurrentLocation() {
		isUpdating = false
		manager.requestLocation()
	}
	
	@available(*, deprecated, message: "No need for continious updates in the last app version logic.")
	func startLocationUpdates() {
		isUpdating = true
		manager.startUpdatingLocation()
	}
	
	@available(*, deprecated, message: "No need for continious updates in the last app version logic.")
	func stopLocationUpdates() {
		isUpdating = false
		manager.stopUpdatingLocation()
	}
}

extension LocationManager: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		debugPrint(String.debugInfo() + "Failed getting location: \(error.localizedDescription)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		currentLocation = locations.last
		
		if let currentLocation {
			onLocationUpdate?(currentLocation)
		}
	}
	
	func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
		debugPrint(String.debugInfo() + "Paused Location Updates")
	}
	
	func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
		debugPrint(String.debugInfo() + "Resumed Location Updates")
	}
}
