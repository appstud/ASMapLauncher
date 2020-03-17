//
//  AppstudMapLauncherTests.swift
//  AppstudMapLauncherTests
//
//  Created by Appstud in 2020.
//  Copyright (c) 2020 Appstud. All rights reserved.
//

import UIKit
import MapKit
import Quick
import Nimble

class AppstudMapLauncherTests: QuickSpec {
    
    override func spec() {
        describe("AppstudMapLauncher Tests") {

            describe(".urlPrefixForMapApp(_:)") {
                context("for Apple Maps") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.apple.urlPrefix
                    }

                    it("should return empty prefix") {
                        expect(urlPrefix).to(equal(""))
                    }
                }

                context("for HERE Maps") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.here.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("here-route://"))
                    }
                }

                context("for Google Maps") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.google.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("comgooglemaps://"))
                    }
                }

                context("for Yandex Navigator") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.yandexNavi.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("yandexnavi://"))
                    }
                }

                context("for CityMapper") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.citymapper.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("citymapper://"))
                    }
                }

                context("for Navigon") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.navigon.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("navigon://"))
                    }
                }

                context("for Transit") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.transit.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("transit://"))
                    }
                }

                context("for Waze") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.waze.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("waze://"))
                    }
                }

                context("for Moovit") {
                    var urlPrefix: String!

                    beforeEach {
                        urlPrefix = MapApp.moovit.urlPrefix
                    }

                    it("should return a valid prefix") {
                        expect(urlPrefix).to(equal("moovit://"))
                    }
                }
            }

            describe(".isMapAppInstalled(_:)") {
                context("for Apple Maps") {
                    it("it should return true") {
                        expect(MapApp.apple.isInstalledForLocation()).to(equal(true))
                    }
                }

                context("for HERE Maps") {
                    it("it should return true") {
                        expect(MapApp.here.isInstalledForLocation()).to(equal(false))
                    }
                }
            }

            describe(".googleMapsString(_:)") {
                context("when all params are filled") {
                    var deeplinkingString: String!

                    beforeEach {
                        deeplinkingString = (CLLocation(latitude: 10.0, longitude: 10.0).toGoogleMapsString(with: "TestName")) as String
                    }

                    it("should return a non nil string") {
                        expect(deeplinkingString).to(equal(("10.000000,10.000000+(TestName)")))
                    }
                }

                context("when location is not valid") {
                    var deeplinkingString: String!

                    beforeEach {
                        deeplinkingString = CLLocation(latitude: -9999.99, longitude: -9999.00).toGoogleMapsString(with: "TestName") as String
                    }

                    it("should return a empty string") {
                        expect(deeplinkingString).to(equal(("")))
                    }
                }

                context("when name is empty") {
                    var deeplinkingString: String!

                    beforeEach {
                        deeplinkingString = CLLocation(latitude: 10.0, longitude: 10.0).toGoogleMapsString(with: "") as String
                    }

                    it("should return a string containts lat long") {
                        expect(deeplinkingString).to(equal(("10.000000,10.000000")))
                    }
                }
            }

            context(".urlEncode(_:)") {
                var encodedUrl: String!

                beforeEach {
                    encodedUrl = "http://github.com/appstud".urlEncode() as String
                }

                it("should return a valid url string") {
                    expect(encodedUrl).to(equal("http://github.com/appstud"))
                }
            }

            context(".getMapApps()") {
                var apps = [MapApp]()

                beforeEach {
                    apps = MapApp.getAvailableNavigationApps()
                }

                it("should return an array") {
                    expect(apps).to(haveCount(1))
                }
            }

            describe(".launchMapApp(_:fromDirections:toDirection:)") {
                var fromPoint: MapPoint!
                var toPoint: MapPoint!
                var isOpened = false

                beforeEach {
                    fromPoint = MapPoint(location: CLLocation(latitude: 10.0, longitude: 10.0), name: "FromName", address: "fromAddress")
                    toPoint = MapPoint(location: CLLocation(latitude: 20.0, longitude: 20.0), name: "ToName", address: "ToAddress")
                    isOpened = false
                }

                context("for Apple Maps") {
                    beforeEach {
                        isOpened = MapApp.apple.launch(fromDirections: fromPoint, toDirections: toPoint)
                    }

                    it("should launch given map app") {
                        expect(isOpened).to(equal(true))
                    }
                }
            }
        }
    }

}

class ApplicationFake: UIApplicationProtocol {
    
    var openUrl = true

    init(openUrl: Bool) {
        self.openUrl = openUrl
    }
    
    func openUrl(_ url: URL) -> Bool {
        return openUrl
    }
    
    func canOpenUrl(_ url: URL) -> Bool {
        return openUrl
    }

    /**
     * Open given url for iOS 10+
     */
    internal func openURL(_ url: URL,
                          options: [UIApplication.OpenExternalURLOptionsKey: Any],
                          completionHandler completion: ((Bool) -> Void)?) {

    }

}
