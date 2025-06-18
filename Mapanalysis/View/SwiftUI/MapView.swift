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
			span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		)
	)
	
    var body: some View {
		ZStack {
			Map(position: $position) {
				UserAnnotation()
			}
			.onAppear() {
				locationManager.getCurrentLocation()
			}
			.ignoresSafeArea(.all)
			
			VStack {
				Spacer()
				HStack {
					Button(action: {
						debugPrint("favorites")
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
						debugPrint("options")
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
