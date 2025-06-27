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
		AppPreferences.shared.loadFavoriteLocations()
	}
	var body: some Scene {
		WindowGroup {
			MapView()
		}
	}
}
