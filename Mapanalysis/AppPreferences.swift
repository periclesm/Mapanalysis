//
//  AppPreferences.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 12/6/25.
//

import Foundation

enum GeocoderService: Int {
	case apple = 0, google, bing
}

enum MapType: Int {
	case standard = 0, satellite, hybrid
}

class AppPreferences: NSObject {
	
	static var shared = AppPreferences()
	var defaults = UserDefaults.standard
	
	var geocoder: GeocoderService {
		set {
			defaults.set(newValue.rawValue, forKey: "Geocoder")
		}
		
		get {
			return GeocoderService(rawValue: defaults.object(forKey: "Geocoder") as? Int ?? 0) ?? .apple
		}
	}
	
	var continuousUpdates: Bool {
		set {
			defaults.set(newValue, forKey: "ContinuousUpdates")
		}
		
		get {
			return defaults.object(forKey: "ContinuousUpdates") as? Bool ?? false
		}
	}
	
	var mapZoom: Double {
		set {
			defaults.set(newValue, forKey: "MapZoomDistance")
		}
		
		get {
			return defaults.object(forKey: "MapZoomDistance") as? Double ?? 500.0
		}
	}
	
	var mapType: MapType {
		set {
			defaults.set(newValue.rawValue, forKey: "MapType")
		}
		
		get {
			return MapType(rawValue: defaults.object(forKey: "MapType") as? Int ?? 0) ?? .standard
		}
	}
	
	var favorites: Array<Annotation> = [] {
		didSet {
			if favorites.isNotEmpty {
				saveFavoriteLocations()
			}
		}
	}
	
	func saveFavoriteLocations() {
		if let data = try? JSONEncoder().encode(favorites) {
			defaults.set(data, forKey: "Favorites")
		}
	}
	
	func loadFavoriteLocations() {
		if let data = defaults.data(forKey: "Favorites") {
			if let savedFavorites = try? JSONDecoder().decode([Annotation].self, from: data) {
				favorites = savedFavorites
			}
		}
	}
}

extension Collection {
	var isNotEmpty: Bool { !isEmpty }
}
