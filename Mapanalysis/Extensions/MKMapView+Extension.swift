//
//  MKMapView+Extension.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 30/6/25.
//

import MapKit

extension MKMapView {
	
	///Get the Current Latitudinal Map Zoom (in meters)
	func currentLatitudinalMeters() -> Double {
		return self.region.span.latitudeDelta * 111_000
	}
	
	///Get the Current Longitudinal Map Zoom (in meters)
	func currentLongitudinalMeters() -> Double {
		return self.region.span.longitudeDelta * 111_000 * cos(region.center.latitude * .pi / 180)
	}
}
