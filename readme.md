# ShoeCycle

<a href="https://apps.apple.com/us/app/shoecycle/id509385499?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1332892800" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Description
ShoeCycle is a manual entry distance tracker for your running shoes. You can take a photo of your shoes, see your weekly mileage on a graph, and view your daily run history in table form. It has simple integrations with HealthKit and Strava. 

This is the very first app I worked on over 10 years ago while trying to learn to code for the iOS platform. I still use it to log my runs. It’s a simple CoreData backed app. Currently, there is no backend for it. The only networking I have is a simple integration with Strava. 

I’ve totally rewritten the code from the ground up in SwiftUI. I have plans to have a more meaningful integration with Strava and a backend API, but first, I had to modernize the app. There was some very, very old Objective-C code I was working with.

## A Note on Code Quality

This code base is a decent example of code quality. However, there are a few caveats that I must mention. I was learning SwiftUI as I was writing this. Some of the code is a little messy, and I will be refactoring it in the near future. The first screen I attacked was the main add distance screen, so it’s a bit disorganized. All database interaction code was a direct port from Objective-C to Swift. I will be refactoring this code as well. Please look at the develop branch to see the latest code work. 

## Future Updates
These are my near-term plans for updates:
- Decoupling from all legacy code.
- Refactoring some of the SwiftUI
- Diving a little deeper into Core Data and refactoring the ShoeStore
- Making a more valuable Strava integration.

## Running the App
### To Install
- Clone repo
- Checkout develop
- Load ShoeCycle.xcodeproj
- Wait for packages to load
- Remove the Secrets.swift file in the Supporting Files directory
- Run 

### To play around with the app:
- Tap the “Add Shoe” button
- Name your shoe
- Tap the “Generate Histories” button
- Repeat as desired

## License

Licensed under [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html)
