//
//  MapRepresentable.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 20/6/25.
//

import SwiftUI
import MapKit

/*
 Important Note:
 There is no need to have both MapRepresentable and MapVC leading to duplicate code that is hard to maintain (once change here needs to change there and vice-versa).
 I will combine these two so that one class for both will to the trick.
 Will do... soon... ish!
 */

struct MapRepresentable: UIViewRepresentable {
	@Binding var annotation: Annotation?
	@Binding var showAnnotation: Bool
	var continuousUpdates: Bool
	var backgroundUpdates: Bool
	var mapType: MapType
	var mapZoom: Double
	
	let locationManager: LocationManager //DO NOT re-initialize location manager. It needs only one instance to run. Pass it from MapView.
	
	var onTap: ((CLLocationCoordinate2D) -> Void)? = nil
	
	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		
		// Add a tap
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
		mapView.addGestureRecognizer(tapGesture)
		
		//Set options and map type, ask for Permissions and update location
		mapOptions(mapView)
		setMapType(in: mapView)
		setMapZoom(in: mapView)
		
		//This is a hack! See coordinator
		context.coordinator.originalMapType = mapType
		context.coordinator.originalMapZoom = mapZoom
		
		locationManager.onLocationUpdate = { location in
			DispatchQueue.main.async {
				showLocation(on: location, mapView: mapView)
			}
		}

		return mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		//Using the hack in order to control when mapType will run (when changed from Options)
		//Setting the MapType should not run each and every time the map needs an update (ex. Continuous updates)
		if mapType != context.coordinator.originalMapType {
			setMapType(in: uiView)
			context.coordinator.originalMapType = mapType
		}
		
		//Using the hack in the same concept as above.
		if mapZoom != context.coordinator.originalMapZoom {
			setMapZoom(in: uiView)
			context.coordinator.originalMapZoom = mapZoom
		}
		
		if let annotation {
			showLocation(on: annotation.location, annotation: annotation, mapView: uiView)
		}
		
		if continuousUpdates {
			locationManager.startLocationUpdates()
		} else {
			locationManager.stopLocationUpdates()
		}
		
		locationManager.enableBackgroundUpdates(backgroundUpdates)
	}
	
	func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
	//nothing so far
}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	//MARK: - Map configuration and functions
	
	private func mapOptions(_ mapView: MKMapView) {
		mapView.showsLargeContentViewer = true
		//showsUserLocation is actually an app hack. User Location in MapKit is not the same as in Core Location. The app uses mostly Core Location to track the user but when it is disabled, the map keeps showing the blue dot that comes from the MapKit and not Core Location (to have constant location updates, enable Continuous Location updates). This is mostly a UX feature to keep the user with a sense of locality even when location updates are turned off.
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
	
	private func setMapType(in mapView: MKMapView) {
		switch mapType {
			case .standard:
				mapView.mapType = .standard
			case .satellite:
				mapView.mapType = .satelliteFlyover
			case .hybrid:
				mapView.mapType = .hybridFlyover
		}
	}
	
	private func showLocation(on location: CLLocation, annotation: Annotation? = nil, mapView: MKMapView) {
		mapView.removeAnnotations(mapView.annotations)
		
		if let annotation {
			centerMap(at: annotation.coordinate, in: mapView)
			createPin(annotation, in: mapView)
		} else {
			let region = MKCoordinateRegion(
				center: location.coordinate,
				latitudinalMeters: mapView.currentLatitudinalMeters(),
				longitudinalMeters: mapView.currentLongitudinalMeters()
			)
			
			mapView.setRegion(region, animated: true)
		}
	}
	
	private func centerMap(in mapView: MKMapView) {
		if continuousUpdates {
			if backgroundUpdates {
				mapView.userTrackingMode = .followWithHeading
			} else {
				mapView.userTrackingMode = .follow
			}
		} else {
			mapView.userTrackingMode = .none
		}
	}
	
	private func setMapZoom(in mapView: MKMapView) {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		
		mapView.setRegion(
			MKCoordinateRegion(
				center: location.coordinate,
				latitudinalMeters: mapZoom,
				longitudinalMeters: mapZoom
			),
			animated: true
		)
	}
	
	private func centerMap(at coordinate: CLLocationCoordinate2D, in mapView: MKMapView) {
		//Get the screen point from coordinate
		let point = mapView.convert(coordinate, toPointTo: mapView)
		
		let newCenter = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.height * 0.3)
		let translationX = newCenter.x - point.x
		let translationY = newCenter.y - point.y
		let offset = CGPoint(x: translationX, y: translationY)
		
		mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: offset.y, left: offset.x, bottom: -offset.y, right: -offset.x), animated: true)
	}
	
	private func createPin(_ annotation: Annotation, in mapView: MKMapView) {
		let pin = MKPointAnnotation()
		pin.coordinate = annotation.coordinate
		pin.title = annotation.title
		mapView.addAnnotation(pin)
	}
	
	// MARK: - Coordinator
	class Coordinator: NSObject, MKMapViewDelegate {
		var parent: MapRepresentable
		
		/*
		 Adding these two variables to keep track of the changes in map zoom and type.
		 These variables need mutable state that UIViewRepresentable (SUI declarative) dislikes so the coordinator (UIK imperative) is the best place to put them.
		 */
		var originalMapType: MapType = .standard
		var originalMapZoom: Double = 0
		
		init(_ parent: MapRepresentable) {
			self.parent = parent
		}
		
		@objc func mapTapped(_ sender: UITapGestureRecognizer) {
			guard let mapView = sender.view as? MKMapView else { return }
			
			let point = sender.location(in: mapView)
			let coord = mapView.convert(point, toCoordinateFrom: mapView)
			
			let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
			Task(priority: .userInitiated) {
				/*
				 Get the annotator here.
				 Works by default with Apple Geocoder. If another Geocoder is present, the geocoder should conform to the GeocodingProvider protocol
				 and annotator should be initialied as annotator = AnnotatorService(provider: ).
				 */
				if let annotation = await AnnotatorService().createAnnotation(location) {
						self.parent.annotation = annotation
				}
			}
		}
	}
}
