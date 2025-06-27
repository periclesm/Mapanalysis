//
//  DeclarationView.swift
//  Mapanalysis SwiftUI
//
//  Created by Pericles Maravelakis on 19/6/25.
//

import SwiftUI

struct DeclarationView: View {
    var body: some View {
        Text("Why Google and Bing geocoding are disabled?")
			.font(.system(size: 20, weight: .medium))
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, 20)
			.padding(.top, 30)
		ScrollView {
			//Yes, I know, I can add multiple Text to break this wall and have headers/sections/whatever, but it's just an informative text to be bothered. :D
			Text("While previous versions of this use case app supported Google Maps and Bing Maps, the latest iteration simply removes these two methods for geolocation.\n\nThe reasons are simple and practical. This is a use case app and I will not add excessive implementations for each platform.\n\nBing Maps has retired the geolocation API, and the service is now offered in Azure Maps. Authentication also changes from an API Key in Bing to multiple authentication methods like EntraID, JWT, and others that pretty much defeat the purpose of this use case app (I am focusing on maps rather than authentication methods).\n\nGoogle Maps API, on the other hand, requires a credit card to be present in the (developer) account in order to use the API. I have no transactions with Google to set up a credit card just for the Maps API.\n\nAlternatives:\nThere are many alternatives and I'm just pointing out a couple:\n\nNominatim offers geolocation in OpenStreetMap. This is a nice and free replacement with minor requirements (1 request per second, valid referer and user-agent), but there is a notification that their /search and /reverse APIs have a deprecation warning and will be removed in future releases. Although I could have integrated Nominatim/OpenStreetMap, I will not revisit this use case app frequently to review,change or replace the API requests.\n\nMapbox is another great service. It offers geolocation as part of a greater bundle that also includes their maps and navigation. Their API is also on a Pay-as-you-Go pricing with a free tier. Still I will not be using Mapbox in this use case app because I should have switched Apple Maps with Mapbox entirely, which again defeats the purpose of this use case app.\n\nTherefore, while previous app versions had Google and Bing Maps integration, I'm only showcasing Apple Maps, which is included in the iOS SDK.\nShould the need to create another showcase app arise (ex. Nominatim publishes a new API), there will be either an update to this app or a new one fully functional with the API under discussion.")
				.padding(.horizontal, 20)
				.font(.system(size: 14))
		}
    }
}

#Preview {
	DeclarationView()
}
