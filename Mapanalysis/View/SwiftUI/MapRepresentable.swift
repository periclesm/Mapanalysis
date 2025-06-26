//
//  MapRepresentable.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 20/6/25.
//

import SwiftUI
import MapKit

struct MapRepresentable: UIViewRepresentable {
	@Binding var annotation: Annotation?
	@Binding var showAnnotation: Bool
	var mapType: MapType
	var mapZoom: Double
	
	let locationManager = LocationManager()
	var onTap: ((CLLocationCoordinate2D) -> Void)? = nil
	
	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		
		// Add a tap
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
		mapView.addGestureRecognizer(tapGesture)
		
		//Set options and map type, ask for Permissions and update location
		mapOptions(mapView)
		
		locationManager.onLocationUpdate = { location in
			showLocation(location, mapView: mapView)
		}

		return mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		setMapType(in: uiView)
		setMapZoom(in: uiView)
		if let annotation {
			showLocation(annotation.location, annotation: annotation, mapView: uiView)
		}
	}
	
	func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
	//nothing so far
}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	//MARK: - Map configuration and functions
	
	func mapOptions(_ mapView: MKMapView) {
		mapView.showsLargeContentViewer = true
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .follow
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
	
	func setMapType(in mapView: MKMapView) {
		switch mapType {
			case .standard:
				mapView.mapType = .standard
			case .satellite:
				mapView.mapType = .satelliteFlyover
			case .hybrid:
				mapView.mapType = .hybridFlyover
		}
	}
	
	func setMapZoom(in mapView: MKMapView) {
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
	
//	func showUserLocation() {
//		if AppPreferences.shared.continuousUpdates {
//			if locationManager.isUpdating {
//				locationManager.stopLocationUpdates()
//			}
//			else {
//				locationManager.startLocationUpdates()
//			}
//		}
//		else {
//			locationManager.stopLocationUpdates()
//			locationManager.getCurrentLocation()
//		}
//	}
	
	func showLocation(_ location: CLLocation, annotation: Annotation? = nil, mapView: MKMapView) {
		mapView.removeAnnotations(mapView.annotations)
		
		let region = MKCoordinateRegion(
			center: location.coordinate,
			latitudinalMeters: AppPreferences.shared.mapZoom,
			longitudinalMeters: AppPreferences.shared.mapZoom
		)
		
		if let annotation {
			centerMap(at: annotation.coordinate, in: mapView)
			createPin(annotation, in: mapView)
		} else {
			mapView.setRegion(region, animated: true)
		}
	}
	
	//Use it to center the map over the Annotation Point
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
//					DispatchQueue.main.async {
						self.parent.annotation = annotation
//					}
				}
			}
		}
	}
}
