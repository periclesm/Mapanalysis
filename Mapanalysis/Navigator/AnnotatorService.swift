//
//  AnnotatorService.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import CoreLocation

class AnnotatorService {
	
	private let provider: GeocodingProvider
	
	init(provider: GeocodingProvider = AppleGeocoder()) {
		self.provider = provider
	}
	
	func createAnnotation(_ location: CLLocation?) async -> Annotation? {
        guard let location else {
            debugPrint("no coordinates provided")
            return nil
        }
		
		switch await provider.reverseGeocoder(location: location) {
			case .success(let address):
				var annotation = Annotation(location: location)
				annotation.title = address.name
				annotation.address = address
				return annotation
				
			case .failure(let error):
				debugPrint("Reverse geocoding failed: \(error.localizedDescription)")
		}

        return nil
	}
}
