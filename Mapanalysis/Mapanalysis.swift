//
//  Mapanalysis.swift
//  Mapanalysis
//
//  Created by Pericles Maravelakis on 18/6/25.
//

import SwiftUI

@main
struct maplysis: App {
	init() {
		let permissionManager = LocationManager()
		permissionManager.requestLocationPermission()
		
		AppPreferences.shared.loadFavoriteLocations()
	}
	var body: some Scene {
		WindowGroup {
			MapView()
		}
	}
}
