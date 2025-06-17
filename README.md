# Mapanalysis

This is a MapKit usecase application with basic functionality and can be used as a starting point for building ideas and services based on maps and Core Location. 

It is written in Swift and UIKit and makes use of reverse geolocation (forward geolocation functionality is included but not used) from Apple Maps to display additional information. 

##### **Important note:**

While previous versions of this usecase app supported both **Google** and **Bing Maps**, the latest iteration simply removes these two methods for geolocation.

The reasons are practical: This is a simple app to showcase map functionality and I will not add excessive implementations for each platform.

**Bing Maps** has retired the geolocation API, and the service is now offered in **Azure Maps**. Authentication also changes from API Key in Bing to multiple authentication methods like EntraID, JWT, and others that pretty much defeat the purpose of this usecase.

**Google Maps API**, on the other hand, requires a credit card in the  account in order to use the API. I have no other transactions with Google and I find it needless to set up a credit card <u>just</u> for the Maps API.

Alternatives:
There are many alternatives and I'm just pointing out a couple:

**Nominatim** offers geolocation in **OpenStreetMap**. This is a nice and free replacement with minor requirements (1 request per second, valid referer and user-agent), but there is a notification that their */search* and */reverse* APIs have a deprecation warning and will be removed in future releases. Although I could have integrated Nominatim/OpenStreetMap, I will not revisit this app frequently to review, change or replace the API requests if/when they change.

**Mapbox** is another great service. It offers geolocation as part of a greater bundle that also includes their maps and navigation. Their API is also on a Pay-as-you-Go pricing with a free tier. Still, I will not be using Mapbox in this app because I should have switched Apple Maps with Mapbox entirely, which again defeats the purpose.

Therefore, while previous app versions had Google and Bing Maps integration, I'm only including Apple Maps now, which is part of the iOS SDK.


Should the need to create another showcase app arise (ex. Nominatim publishes a new API), there will be either an update to this app or a new one, fully functional with the API under discussion.

### To Do:

- SwiftUI version (Coming soon)
