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
	@State var continuousUpdates = AppPreferences.shared.continuousUpdates
	@State var backgroundUpdates = AppPreferences.shared.backgroundUpdates
	@State var mapType = AppPreferences.shared.mapType
	@State var mapZoom = AppPreferences.shared.mapZoom
	
	@State var showOptions = false
	@State var showFavorites = false
	@State var showAnnotation = false
	
	@StateObject var locationManager = LocationManager()
	@State private var longPressActionPerformed = false
	@State private var locationIsUpdating = false //that's a SUI-UIK hack
	
	init() {
		let permissionManager = LocationManager()
		permissionManager.requestLocationPermission()
	}
	
    var body: some View {
		ZStack {
			MapRepresentable(annotation: $annotation,
							 showAnnotation: $showAnnotation,
							 continuousUpdates: continuousUpdates,
							 backgroundUpdates: backgroundUpdates,
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
						if longPressActionPerformed {
							longPressActionPerformed = false
						} else {
							if continuousUpdates {
								if locationIsUpdating {
									locationManager.stopLocationUpdates()
								} else {
									locationManager.startLocationUpdates()
								}
							} else {
								locationManager.getCurrentLocation()
							}
						}
					}) {
						Image(systemName: "location")
							.resizable()
							.scaledToFill()
							.frame(width: 26, height: 26)
							.foregroundColor(.yellow)
					}
					.frame(width: 64, height: 64)
					.background(locationIsUpdating ? Color.teal : Color.purple)
					.clipShape(Circle())
					.shadow(radius: 4)
					.onAppear {
						locationManager.onIsUpdatingChanged = { newValue in
							DispatchQueue.main.async {
								self.locationIsUpdating = newValue
							}
						}
					}
					.simultaneousGesture(
						LongPressGesture(minimumDuration: 0.5)
							.onEnded { _ in
								longPressActionPerformed = true
								if continuousUpdates {
									continuousUpdates = false
									locationManager.stopLocationUpdates()
								} else {
									continuousUpdates = true
									locationManager.startLocationUpdates()
								}
							}
					)
					.overlay(
						RoundedRectangle(cornerRadius: 64)
							.stroke(continuousUpdates ? .teal : .orange, lineWidth: 2)
							.padding(-2) //padding is the outset of UIButton! WHOOT???
					)
					
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
						OptionsView(continuousUpdates: $continuousUpdates,
									backgroundUpdates: $backgroundUpdates,
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
