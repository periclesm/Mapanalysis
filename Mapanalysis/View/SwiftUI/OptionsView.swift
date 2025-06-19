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
							.padding(.top, 3)
							.padding(.bottom, 3)
							.tint(Color.purple)
							.onChange(of: continiousUpdates) { oldValue, newValue in
								AppPreferences.shared.continuousUpdates = newValue
							}
					}
					
					Section(header: Text("Map Display")) {
						VStack(alignment: .leading) {
							Text("Map zoom distance (in meters)").multilineTextAlignment(.leading)
							HStack {
								Text("100").foregroundColor(.gray).font(.system(size: 12))
								Slider(value: $mapZoom, in: 100...1000).accentColor(.purple)
									.onChange(of: mapZoom) { oldValue, newValue in
										AppPreferences.shared.mapZoom = newValue
									}
								Text("1000").foregroundColor(.gray).font(.system(size: 12))
							}
							.padding(.top, 2)
							.padding(.bottom, 2)
						}
						
						VStack(alignment: .leading) {
							Picker("Map Type", selection: $mapType) {
								Text("Standard").tag(MapType.standard)
								Text("Satellite").tag(MapType.satellite)
								Text("Hybrid").tag(MapType.hybrid)
							}
							.onChange(of: mapType, { oldValue, newValue in
								AppPreferences.shared.mapType = newValue
							})
							.padding(.top, 2)
							.padding(.bottom, 2)
						}
					}
					
					Section(header: Text("Geocoding"),
							footer: Text("Resolving location coordinates from address (geocoding) or the address from coordinates (reverse geocoding) using the selected service.")) {
						Picker("Geocoding Provider\n(forward & reverse)", selection: $geocoder) {
							Text("Apple Maps").tag(GeocoderService.apple)
							Text("Google Maps").tag(GeocoderService.google).disabled(true)
							Text("Bing Maps").tag(GeocoderService.bing).disabled(true)
								.onChange(of: mapType, { oldValue, newValue in
									AppPreferences.shared.mapType = newValue
								})
						}
						.padding(.top, 2)
						.padding(.bottom, 2)
						
						Button(action: {
							showDeclaration = true
						}) {
							HStack {
								Text("Why Google and Bing geocoders are not supported?")
									.font(.system(size: 14))
									.foregroundColor(.primary)
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)
							}
							.contentShape(Rectangle())
							.padding(.top, 2)
							.padding(.bottom, 2)
						}
						.sheet(isPresented: $showDeclaration) {
							// Your modal view
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
