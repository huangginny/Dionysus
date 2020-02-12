# How to Contribute to Dionysus

We'd love to include ratings from more different platforms, and I hope you will find this guide helpful!

## Before you Build

1. Run `pod install` to install required dependencies
2. Rename "APIKeys_sample.swift" to "APIKeys.swift"
3. Override the hardcoded settings in "core/AppState.swift"
	- In `AppState.init`, change default plugin to "mock" and active plugin to "\[mock\]" so that no API credentials would be needed
	- Sample data could be found at the bottom of "core/models.swift"
4. The app should now be working with any iOS Simulator or device. Happy hacking :)

## Adding a New Rating Platform

1. Add the required API keys to "APIKeys.swift"
2. Create variables for the required API keys in "APIKeys_sample.swift" and set them to empty string
3. Add the attribution logo to "Assets.xcassets." Make sure the height of the image does not exceed 30px - **the app does not resize the logo accordingly** to comply with [Google Places API display requirements](https://developers.google.com/places/web-service/policies)
4. Create a new class under "core/plugins" folder
5. The class should implement "SitePlugin" protocol. Variables should be initialized in `required init` constructor. Use `logMessage(_: String)` for logging purposes.

variable name | description
--- | ---
`name` | Name of the platform (e.g, "FourSquare")
`attribution` | Name of the logo file in Assets.xcassets (e.g, "powered-by-4sq")
`attributionHasText` | `true` if the logo contains the text "powered by" or "supported by"; `false` otherwise
`colorCode` | 6-digit hex string that represents the theme color of the platform (e.g, "#F94877" for FourSquare's pink theme color)
`totalScore` | The maximum score each place could be rated on the platform (e.g, 5 for Yelp, 10 for FourSquare)

\*Please refer to FourSquarePlugin.swift as a working example on how a plugin should be implemented

Please test your new plugin by overiding the default site in `AppState.init`. You can use "mock" as a non-default active site. If you have personal API keys for other existing site plugins, feel free to test with them as well.

## Get Recognized

Please update your name or Github user name in [README.md,](https://github.com/huangginny/Dionysa/blob/master/README.md) which will be shown in the "About" section in the app.

## Questions?

Create an [issue](https://github.com/huangginny/Dionysa/issues) or reach out to [@ginnyzr7](https://twitter.com/ginnyzr7) on Twitter.
