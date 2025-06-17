//
//  GeocodingProvider.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 16/6/25.
//

import CoreLocation

protocol GeocodingProvider {
	func reverseGeocoder(location: CLLocation) async -> Result<Address, Error>
	func forwardGeocoder(addressString: String) async -> Result<CLLocation, Error>
}
