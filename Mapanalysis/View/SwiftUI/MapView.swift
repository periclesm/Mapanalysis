//
//  MapView.swift
//  Mapanalysis-SwiftUI
//
//  Created by Pericles Maravelakis on 18/6/25.
//

import SwiftUI
import MapKit

struct MapView: View {
	@StateObject private var locationManager = LocationManager()
	
	@State private var position = MapCameraPosition.region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 37.9710, longitude: 23.7285),
			span: MKCoordinateSpan(latitudeDelta: AppPreferences.shared.mapZoom / 100000,
								   longitudeDelta: AppPreferences.shared.mapZoom / 100000)
			/*
			 Division by 100000 is the factor between the UIKit value and SwiftUI value for maps.
			 Normally it should not be like this but I have this app on both UIKit and SwiftUI so something must look wierd somewhere... :S
			 */
		)
	)
	
	@State private var showOptions = false
	@State private var showFavorites = false
	@State private var showAnnotation = false
	
    var body: some View {
		ZStack {
			Map(position: $position) {
				UserAnnotation()
			}
			.ignoresSafeArea(.all)
			.onAppear() {
				locationManager.getCurrentLocation()
			}
			.onTapGesture {
				debugPrint("boink")
				showAnnotation = true
			}
			.sheet(isPresented: $showAnnotation) {
				AnnotationView()
					.presentationDetents([.medium])
					.presentationDragIndicator(.visible)
					.presentationBackgroundInteraction(.disabled)
			}
			
			VStack {
				Spacer()
				HStack {
					Button(action: {
						showFavorites = true
					}) {
						Image(systemName: "map.fill")
							.resizable()
							.scaledToFill()
							.frame(width: 18, height: 18)
							.foregroundColor(.yellow)
					}
					.frame(width: 48, height: 48)
					.background(.purple)
					.clipShape(Circle())
					.shadow(radius: 4)
					.sheet(isPresented: $showFavorites) {
						FavoritesView()
							.presentationDetents([.medium, .large])
							.presentationDragIndicator(.visible)
					}
//					.overlay(
//						RoundedRectangle(cornerRadius: 48)
//							.stroke(Color.yellow, lineWidth: 2)
//					)
					
					Button(action: {
						debugPrint("location")
					}) {
						Image(systemName: "location")
							.resizable()
							.scaledToFill()
							.frame(width: 26, height: 26)
							.foregroundColor(.yellow)
					}
					.frame(width: 64, height: 64)
					.background(.purple)
					.clipShape(Circle())
					.shadow(radius: 4)
//					.overlay(
//						RoundedRectangle(cornerRadius: 64)
//							.stroke(Color.yellow, lineWidth: 2)
//						//hey! where's the outset from the UIButton? Huh???
//					)
					
					Button(action: {
						showOptions = true
					}) {
						Image(systemName: "gearshape.fill")
							.resizable()
							.scaledToFill()
							.frame(width: 18, height: 18)
							.foregroundColor(.yellow)
					}
					.frame(width: 48, height: 48)
					.background(.purple)
					.clipShape(Circle())
					.shadow(radius: 4)
					.sheet(isPresented: $showOptions) {
						OptionsView()
							.presentationDetents([.large])
							.presentationDragIndicator(.visible)
					}
//					.overlay(
//						RoundedRectangle(cornerRadius: 48)
//							.stroke(Color.yellow, lineWidth: 2)
//					)
				}
				.padding(.bottom, 24)
			}
		}
    }
}

#Preview {
    MapView()
}
