//
//  MapView.swift
//  Mapanalysis-SwiftUI
//
//  Created by Pericles Maravelakis on 18/6/25.
//

import SwiftUI
import MapKit

struct MapView: View {
	@State var annotation: Annotation?
	@State var coordinate: CLLocationCoordinate2D? = nil
	@State var centerMap = AppPreferences.shared.centerMap
	@State var headingOnMap = AppPreferences.shared.headingOnMap
	@State var mapType = AppPreferences.shared.mapType
	@State var mapZoom = AppPreferences.shared.mapZoom
	
	@State var showOptions = false
	@State var showFavorites = false
	@State var showAnnotation = false
	
	@StateObject var locationManager = LocationManager()
	
	init() {
		let permissionManager = LocationManager()
		permissionManager.requestLocationPermission()
	}
	
    var body: some View {
		ZStack {
			MapRepresentable(annotation: $annotation,
							 showAnnotation: $showAnnotation,
							 centerMap: centerMap,
							 headingOnMap: headingOnMap,
							 mapType: mapType,
							 mapZoom: mapZoom,
							 locationManager: locationManager) { coordinate in
				debugPrint("Coordinate is: \(coordinate.latitude) lat, \(coordinate.longitude) long")
			}
			.edgesIgnoringSafeArea(.all)
			.sheet(item: $annotation) { annotation in
					AnnotationView(annotation: annotation)
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
						/*
						 All is needed is to assign the annotation that returns when a favorite is selected.
						 Then the modal will close and updates will take their course when annotation changes.
						 At the end, close the FavoritesView to bring up the AnnotationView after the map update.
						 */
						FavoritesView(annotation: $annotation) { selectedAnnotation in
							annotation = selectedAnnotation
							showFavorites = false
						}
							.presentationDetents([.medium, .large])
							.presentationDragIndicator(.visible)
					}
					
					Button(action: {
						locationManager.getCurrentLocation()
						
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
						OptionsView(centerMap: $centerMap,
									headingOnMap: $headingOnMap,
									mapType: $mapType,
									mapZoom: $mapZoom)
							.presentationDetents([.medium, .large])
							.presentationDragIndicator(.visible)
					}
				}
				.padding(.bottom, 24)
			}
		}
    }
}

#Preview {
    MapView()
}
