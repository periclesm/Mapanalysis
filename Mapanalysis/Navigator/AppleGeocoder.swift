//
//  AppleGeocoder.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import CoreLocation

enum GeocodingError: LocalizedError {
	case noPlacemarkFound
	case noLocationFound
	
	var errorDescription: String? {
		switch self {
			case .noPlacemarkFound: return "No address could be determined from the coordinates."
			case .noLocationFound:  return "No location could be found for the address string."
		}
	}
}

final class AppleGeocoder: GeocodingProvider {
	
	private let aGeocoder = CLGeocoder()
    
	/**
	 Reverse Geocoder:
	 Give the location coordinates and it will return location information
	 */
    func reverseGeocoder(location: CLLocation) async -> Result<Address, Error> {
        do {
            let placemarks = try await aGeocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                let address = Address(placemark: placemark)
                debugPrint(placemarks.first as Any)
				return .success(address)
            }
            else {
				return .failure(GeocodingError.noPlacemarkFound)
            }
        } catch {
            return .failure(error)
        }
    }
    
	/**
	 Forward Geocoder:
	 Give the address string (ideally, it should be something Maps recognize) and it will return the location coordinates.
	 */
    func forwardGeocoder(addressString: String) async -> Result<CLLocation, Error> {
        do {
            let placemarks = try await aGeocoder.geocodeAddressString(addressString)
			
			if let placemark = placemarks.first?.location {
				return .success(placemark)
			} else {
				return .failure(GeocodingError.noLocationFound)
			}
        } catch {
			return .failure(error)
        }
    }
}
