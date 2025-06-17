//
//  AnnotatorView.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import CoreLocation

struct Annotation: Codable, Sendable {
	
	let latitude: Double
	let longitude: Double
    var title: String?
    var subtitle: String?
    var address: Address?
	
	var coordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	
	var latitudeText: String {
		let latIndication = latitude > 0 ? "North" : "South"
		return String(format: "%.4fº  %@", abs(latitude), latIndication)
	}
	
	var longtitudeText: String {
		let lonIndication = longitude > 0 ? "East" : "West"
		return String(format: "%.4fº  %@", abs(longitude), lonIndication)
	}
	
	init(location: CLLocation) {
		self.latitude = location.coordinate.latitude
		self.longitude = location.coordinate.longitude
	}
}

extension Annotation: Equatable {
	static func == (left: Annotation, right: Annotation) -> Bool {
		abs(left.latitude - right.latitude) < 0.00001 &&
		abs(left.longitude - right.longitude) < 0.00001
	}
}
