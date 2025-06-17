//
//  Address.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import Foundation
import CoreLocation

struct Address: Codable, Sendable, Equatable {
	
	enum CodingKeys: String, CodingKey {
		case name, formattedAddress, address, administrative, locality, postalCode, country, countryISO
	}
    
    var name: String?
    var formattedAddress: String?
    var address: String?
    var administrative: String?
    var locality: String?
    var postalCode: String?
    var country: String?
    var countryISO: String?
	
	private(set) var placemark: CLPlacemark?
    
    init(placemark: CLPlacemark) {
        self.placemark = placemark
		map(from: placemark)
    }
    
    //MARK: - mappings
    
	private mutating func map(from placemark: CLPlacemark) {
		name = placemark.name
		address = "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
		locality = "\(placemark.locality ?? "")"
		administrative = "\(placemark.administrativeArea ?? "")"
		postalCode = placemark.postalCode
		country = placemark.country
		countryISO = placemark.isoCountryCode
		
		formattedAddress = [address, locality, administrative, postalCode, country]
			.compactMap { $0 }
			.joined(separator: ", ")
	}
}
