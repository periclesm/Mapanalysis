//
//  OptionsView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 18/6/25.
//

import SwiftUI

struct OptionsView: View {
	@State var continiousUpdates = AppPreferences.shared.continuousUpdates
	@State var mapType: MapType = AppPreferences.shared.mapType
	@State var mapZoom = AppPreferences.shared.mapZoom
	@State var geocoder: GeocoderService = AppPreferences.shared.geocoder
	@State private var showDeclaration = false
	
	var body: some View {
		ZStack {
			VStack {
				Spacer()
				
				Text("Options")
					.foregroundColor(.white)
					.font(.system(size: 28, weight: .bold))
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 20)
					.padding(.top, 20)
				
				List {
					Section(header: Text("Location Update"),
							footer: Text("When the setting is off, the device will ask once for the current location. Otherwise, it will request location updates at timed intervals and will stop by pressing the location button again.")) {
						Toggle("Continious Location Updates", isOn: $continiousUpdates)
							.font(.system(size: 15))
							.tint(Color.purple)
							.onChange(of: continiousUpdates) { oldValue, newValue in
								AppPreferences.shared.continuousUpdates = newValue
							}
					}
					
					Section(header: Text("Map Display")) {
						VStack(alignment: .leading) {
							Text("Map zoom distance (in meters)").multilineTextAlignment(.leading)
								.font(.system(size: 15))
							HStack {
								Text("100").foregroundColor(.gray).font(.system(size: 12))
								Slider(value: $mapZoom, in: 100...1000).accentColor(.purple)
									.onChange(of: mapZoom) { oldValue, newValue in
										AppPreferences.shared.mapZoom = newValue
									}
								Text("1000").foregroundColor(.gray).font(.system(size: 12))
							}.padding(.vertical, 10)
						}
						
						VStack(alignment: .leading) {
							Picker("Map Type", selection: $mapType) {
								Text("Standard").tag(MapType.standard)
								Text("Satellite").tag(MapType.satellite)
								Text("Hybrid").tag(MapType.hybrid)
							}
							.font(.system(size: 15))
							.onChange(of: mapType, { oldValue, newValue in
								AppPreferences.shared.mapType = newValue
							})
						}
					}
					
					Section(header: Text("Geocoding"),
							footer: Text("Resolving location coordinates from address (geocoding) or the address from coordinates (reverse geocoding) using the selected service.")) {
						Picker("Geocoding Provider", selection: $geocoder) {
							Text("Apple Maps").tag(GeocoderService.apple)
							Text("Google Maps").disabled(true)
								//.tag(GeocoderService.google)
							Text("Bing Maps").disabled(true)
								//.tag(GeocoderService.bing)
								.onChange(of: mapType, { oldValue, newValue in
									AppPreferences.shared.mapType = newValue
								})
						}
						.font(.system(size: 15))
						
						Button(action: {
							showDeclaration = true
						}) {
							HStack {
								Text("Why Google and Bing geocoding are disabled?")
									.foregroundColor(.primary)
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)
							}
							.font(.system(size: 13))
							.contentShape(Rectangle())
						}
						.sheet(isPresented: $showDeclaration) {
							DeclarationView()
						}
					}
				}
			}
		}
		.background(.purple)
	}
}

#Preview {
	OptionsView()
}
