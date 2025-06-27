//
//  FavoritesView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 19/6/25.
//

import SwiftUI

struct FavoritesView: View {
	@State var favorites: [Annotation] = AppPreferences.shared.favorites
	@Binding var annotation: Annotation?
	var onSelect: ((Annotation) -> Void)? = nil //this closure is executed in MapView
	
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
							FavoriteItem(annotation: annotation) {
								/*
								 When selecting an item in the list, the View's onSelect is executed
								 and passes the selected annotation.
								 Callback = return the annotation back to mapview.
								 */
								onSelect?(annotation)
							}
						}
						.onDelete(perform: delete)
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
	
	private func delete(at offsets: IndexSet) {
		favorites.remove(atOffsets: offsets)
		AppPreferences.shared.favorites = favorites
	}
}

struct FavoriteItem: View {
	let annotation: Annotation
	
	/*
	 No need to define annotation since the closure knows what to contain.
	 This onSelect is used in the button below.
	 */
	let onSelect: (() -> Void)?
	
	var body: some View {
		Button(action: {
			onSelect?() //Button action returns the annotation
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
	FavoritesView(annotation: .constant(nil))
}
