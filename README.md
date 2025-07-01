**ΜapΑnalysis**

This is a MapΚit use case application with basic functionality and can be used as a starting point for building ideas and services based on maps and Core Location.

It is written in Swift and both UIKit and SwiftUI and makes use of reverse geolocation (forward geolocation functionality is included but not used) from Apple Maps to display additional information.

**Note:**

This is not a full-fledged maps app. It's a use case to illustrate some (but not all) capabilities and functionality of MapKit and Core Location. DO NOT TAKE IT AS IS AND IMPLEMENT EVERYTHING IN YOUR APP. Each app is different and needs different things so better study the app and then add to it (if not change everything in your code).

**Language:**

The app is written in Swift. There is no use of extended architectures (like ΜVVΜ because simply it's a use case app), does not store data or has the need for Swift features like protocols etc. It is written with a loose imperative programming concept (for UIKit) but has declarative concepts as well (for SwiftUI). In some cases when the two worlds collide, there are some bridges that gap or smooth the differences (needless to say that if the app were UIKit or SwiftUI only, it would be different but that is not the purpose of this use case).

**UI:**

Written in both UIKit and SwiftUI. Defaults (loosely) to SwiftUI. Has 2 targets and you can select the active scheme to build each UI. it also has different bundle identifiers so that you can have both executables installed on one device at the same time. Just select the scheme you want and proceed with that.

**Important note on geolocation services:**

While previous versions of this use case app supported both **Google** and **Βing Μaps**, the latest iteration simply removes these two methods for geolocation.

The reasons are practical: This is a simple app to showcase map functionality and I will not add excessive implementations for each platform.

**Bing Maps** has retired the geolocation API and the service is now offered in **Azure Maps**. Authentication also changes from API Key in Bing to multiple authentication methods like EntraID, JWT and others that pretty much defeat the purpose of this use case.

**Google Maps API**, on the other hand, requires a credit card in the account in order to use the API. I have no other transactions with Google and I find it needless to set up a credit card just for the Maps API.

Alternatives: There are many alternatives and I'm just pointing out a couple:

**Νominatim** offers geolocation in **OpenStreetMap**. This is a nice and free replacement with minor requirements (1 request per second, valid referer and user-agent), but there is a notification that their */search* and */reverse* APIs have a deprecation warning and will be removed in future releases. Although I could have integrated Nominatim/OpenStreetMap, I will not revisit this app frequently to review, change, or replace the API requests if/when they change.

**Mapbox** is another great service. It offers geolocation as part of a greater bundle that also includes their maps and navigation. Their API is also on a Pay-as-you-Go pricing with a free tier. Still, I will not be using Mapbox in this app because I should have switched Apple Maps with Mapbox entirely, which again defeats the purpose.

Therefore, while previous app versions had Google and Bing Maps integration, I'm only including Apple Maps now, which is part of the iOS SDK.

Should the need to create another showcase app arise (ex. Nominatim publishes a new API), there will be either an update to this app or a new one, fully functional with the API under discussion.

**Testflight:**

There is a Testflight app to check the app before getting deeper. It is compiled with SwiftUI. If the app is not available, it means that the 90-day window since the last upload has expired, so just wait for a few days (or weeks :D) to upload another or simply poke me to do so.

Link: [MapAnalysis](https://testflight.apple.com/join/SQhZ1OCf)
