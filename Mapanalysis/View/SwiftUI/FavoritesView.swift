//
//  FavoritesView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 19/6/25.
//

import SwiftUI

struct FavoritesView: View {
	@State private var favorites: [Annotation] = AppPreferences.shared.favorites
	
	var body: some View {
		ZStack {
			VStack {
				Spacer()
				Text("Favorites")
					.foregroundColor(.white)
					.font(.system(size: 28, weight: .bold))
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.leading, 20)
					.padding(.top, 20)
				
				if favorites.isNotEmpty {
					List {
						ForEach(favorites, id: \.title) { annotation in
							AnnotationRow(annotation: annotation)
						}
					}
				} else {
					Spacer()
					VStack(spacing: 30) {
						Image(systemName: "star.slash")
							.resizable()
							.scaledToFit()
							.frame(width: 80, height: 80)
							.foregroundColor(.white.opacity(0.5))
							//.padding(.bottom, 20)
						Text("No favorites added. Go on! Add one...")
							.foregroundColor(.white.opacity(0.8))
							.font(.system(size: 17))
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
		}
		.background(.purple)
	}
}

struct AnnotationRow: View {
	let annotation: Annotation
	
	var body: some View {
		Button(action: {
			debugPrint("PewPew")
		}) {
			HStack {
				VStack(alignment: .leading) {
					Text(annotation.title ?? "")
						.font(.system(size: 17, weight: .medium))
						.foregroundColor(.primary)
						.padding(.bottom, 2)
					
					HStack {
						Text("latitude:")
							.font(.system(size: 13, weight: .light))
							.foregroundColor(.gray)
						Text(annotation.latitudeText)
							.font(.system(size: 13))
							.foregroundColor(.primary)
					}
					
					HStack {
						Text("longitude:")
							.font(.system(size: 13, weight: .light))
							.foregroundColor(.gray)
						Text(annotation.longtitudeText)
							.font(.system(size: 13))
							.foregroundColor(.primary)
					}
				}
				
				Spacer()
				Image(systemName: "chevron.right")
					.foregroundColor(.gray)
			}
		}
		.padding(.vertical, 5)
	}
}

#Preview {
    FavoritesView()
}
