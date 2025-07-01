//
//  OptionsView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 18/6/25.
//

import SwiftUI

struct OptionsView: View {
	@Binding var continuousUpdates: Bool
	@Binding var backgroundUpdates: Bool
	@Binding var mapType: MapType
	@Binding var mapZoom: Double
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
							footer: Text("Continuous asks for location updates at intervals and updates the user location on the map.\nBackground updates gets the current location when the app is in the background.\nLong press on location button in map screen enables this option while a simple tap only updates the location once.")) {
						Toggle("Continuous location updates", isOn: $continuousUpdates)
							.font(.system(size: 15))
							.tint(Color.purple)
							.onChange(of: continuousUpdates) { oldValue, newValue in
								AppPreferences.shared.continuousUpdates = newValue
							}
						
						Toggle("Background location updates", isOn: $backgroundUpdates)
							.font(.system(size: 15))
							.tint(Color.purple)
							.onChange(of: backgroundUpdates) { oldValue, newValue in
								AppPreferences.shared.backgroundUpdates = newValue
							}
							.disabled(!continuousUpdates)
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
							footer: Text("Forward (from address) and reverse (from coordinates) geocoding setup.")) {
						Picker("Geocoding Provider", selection: $geocoder) {
							Text("Apple Maps").tag(GeocoderService.apple)
							Text("Google Maps").disabled(true)
								//.tag(GeocoderService.google)
							Text("Bing Maps").disabled(true)
								//.tag(GeocoderService.bing)
								.onChange(of: geocoder, { oldValue, newValue in
									AppPreferences.shared.geocoder = newValue
								})
						}
						.font(.system(size: 15))
					}
					
					Section {
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
							.font(.system(size: 15))
							.contentShape(Rectangle())
							.padding(.vertical, 2)
						}
						.sheet(isPresented: $showDeclaration) {
							DeclarationView()
								.presentationDragIndicator(.visible)
						}
					}
				}
			}
		}
		.background(.purple)
	}
}

#Preview {
	OptionsView(continuousUpdates: .constant(false), backgroundUpdates: .constant(false), mapType: .constant(.standard), mapZoom: .constant(800))
}
