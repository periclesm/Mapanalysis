//
//  AnnotationView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 19/6/25.
//

import SwiftUI

struct AnnotationView: View {
	var annotation: Annotation?
	@State private var favoriteButtonTitle = "Add Favorite"
	
    var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Spacer()
				Button(action: {
					favoriteAction()
				}) {
					Text(favoriteButtonTitle)
						.font(.system(size: 14, weight: .semibold))
						.foregroundColor(.yellow)
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.background(Color.purple)
						.clipShape(Capsule())
				}
				.onAppear {
					guard annotation != nil else { return }
					setButtonTitle()
				}
			}
			
			Text("Address:")
				.foregroundColor(.gray)
				.font(.system(size: 13))
			Text(addressFormat())
				.font(.system(size: 22, weight: .bold))
			Text(cityFormat())
			Text("\(annotation?.address?.administrative ?? "Administrative")")
			Text("\(annotation?.address?.country ?? "Country")")
				.padding(.bottom, 8)
			
			Text("Coordinates:")
				.foregroundColor(.gray)
				.font(.system(size: 13))
			HStack {
				Text("Latitude:")
					.foregroundColor(.gray)
					.font(.system(size: 13))
				Text(annotation?.latitudeText ?? "--")
			}
			HStack {
				Text("Longitude:")
					.foregroundColor(.gray)
					.font(.system(size: 13))
				Text(annotation?.longtitudeText ?? "--")
			}
			Spacer()
			
		}
		.padding(.horizontal, 20)
		.padding(.top, 20)
    }
}

//Using the extension to separate the View from functions
extension AnnotationView {
	
	private func addressFormat() -> String {
		if let name = annotation?.address?.name {
			return name
		} else if let address = annotation?.address?.address {
			return address
		}
		
		return "Unknown Address"
	}
	
	private func cityFormat() -> String {
		return "\(annotation?.address?.locality ?? "City")" + " " + "\(annotation?.address?.locality ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	func favoriteAction() {
		guard let annotation else { return }
		
		if AppPreferences.shared.favorites.contains(annotation) {
			removeFavorite()
		} else {
			addFavorite()
		}
		
		setButtonTitle()
	}
	
	func addFavorite() {
		guard let annotation else { return }
		AppPreferences.shared.favorites.append(annotation)
	}
	
	func removeFavorite() {
		guard let annotation else { return }
		if let index = AppPreferences.shared.favorites.firstIndex(of: annotation) {
			AppPreferences.shared.favorites.remove(at: index)
		}
	}
	
	func setButtonTitle() {
		guard let annotation else { return }
		
		if AppPreferences.shared.favorites.contains(annotation) {
			favoriteButtonTitle = "Remove Favorite"
		} else {
			favoriteButtonTitle = "Add Favorite"
		}
	}
}

#Preview {
    AnnotationView()
}
