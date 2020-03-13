//
//  AppstudMapLauncher.swift
//  AppstudMapLauncher
//
//  Copyright (c) 2020 Appstud. All rights reserved.
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import CoreLocation

/**
 Transport mode enum used for deep linking
 */
public enum TransportMode : String {
    case drive,
    ride,
    bike,
    walk
}

/**
  Supported map applications
 */
public enum MapApp : String {
    case apple = "Apple Maps",
    here = "HERE Maps",
    google = "Google Maps",
    yandexNavi = "Yandex Navi",
    yandexMaps = "Yandex Maps",
    citymapper = "Citymapper",
    navigon = "Navigon",
    transit = "The Transit App",
    waze = "Waze",
    moovit = "Moovit"

    static let allValues = [apple, here, google, yandexNavi, yandexMaps, citymapper, navigon, transit, waze, moovit]

    var supportsAddress: Bool {
        switch self {
        case .apple, .google, .transit:
            return true
        default:
            return false
        }
    }

    var supportsLocation: Bool {
        switch self {
        default:
            return true
        }
    }

    /**
      Prepares url scheme prefix used to open app with given app type
      - parameter mapApp: MapApp type
      - returns: Url Prefix
     */
    var urlPrefix: String {
        switch(self) {
        case .here:
            return "here-route://"
        case .google:
            return "comgooglemaps://"
        case .yandexNavi:
            return "yandexnavi://"
        case .yandexMaps:
            return "yandexmaps://"
        case .citymapper:
            return "citymapper://"
        case .navigon:
            return "navigon://"
        case .transit:
            return "transit://"
        case .waze:
            return "waze://"
        case .moovit:
            return "moovit://"
        default:
            return ""
        }
    }

    var transportModes: [TransportMode: String] {
        switch self {
        case .here:
            return [.drive: "d", .walk: "w", .bike: "b", .ride: "pt"]
        case .google:
            return [.drive: "driving", .ride: "transit", .bike: "bicycling", .walk: "walking"]
        case .yandexMaps:
            return [.drive: "auto", .ride: "mt", .walk: "pd"]
        case .apple:
            return [.drive: "d", .walk: "w", .ride: "r"]
        default:
            return [:]
        }
    }
}

/**
  Launcher class
 */
open class AppstudMapLauncher {
    
    /**
      UIApplication used for deep linking
     */
    open var application: UIApplicationProtocol = UIApplication.shared
    
    /**
      Holds available map applications
     */
    private var availableMapApps = [MapApp]()
    
    /**
      Initiliaze Map Launcher
     */
    public init() {
        getAvailableNavigationApps()
    }
    
    // MARK: Get Available Navigation Apps
    
    /**
      Prepares available navigation apps installed on device
     */
    internal func getAvailableNavigationApps() {
        for type in MapApp.allValues {
            if isMapAppInstalled(type) {
                availableMapApps.append(type)
            }
        }
    }

    /**
      Checks if app installed with given app type
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    private func isMapAppInstalled(_ mapApp: MapApp) -> Bool {
        if mapApp == .apple {
            return true
        }
        guard let url = URL(string: mapApp.urlPrefix) else {
            return false
        }
        return application.canOpenUrl(url)
    }

    /**
      Checks if app installed with given app type and takes CLLocation as parameter
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    func isMapAppInstalledForLocation(_ mapApp: MapApp) -> Bool {
        return mapApp.supportsLocation ? isMapAppInstalled(mapApp) : false
    }

    /**
      Checks if app installed with given app type and takes address as parameter
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    open func isMapAppInstalledForAddress(_ mapApp: MapApp) -> Bool {
        return mapApp.supportsAddress ? isMapAppInstalled(mapApp) : false
    }

    /**
      Launch navigation application with given app and directions
      - parameter mapApp: MapApp
      - parameter fromDirections: String
      - parameter toDirections: String
      - parameter fromDirectionsName: String?
      - parameter toDirectionsName: String?
     */
    open func launchMapApp(_ mapApp: MapApp, fromDirections: String, toDirections: String, fromDirectionsName: String?, toDirectionsName: String?, transportMode: TransportMode) -> Bool {
        if !isMapAppInstalledForAddress(mapApp) {
            return false
        }
        var urlString = ""
        switch(mapApp) {
        case .apple:
            urlString = String(format: "http://maps.apple.com/?saddr=%@&daddr=%@",
                                 formatString(fromDirections),
                                 formatString(toDirections))
        case .google:
            urlString = String(format: "\(MapApp.google.urlPrefix)?saddr=%@&daddr=%@",
                           formatString(fromDirections),
                           formatString(toDirections))

            urlString.append(getTransportModeParameter(for: mapApp, with: transportMode))
        case .transit:
            urlString = String(format: "\(MapApp.transit.urlPrefix)directions?from=%f&to=%f", fromDirections, toDirections)
        default:
            urlString = ""
            return false
        }
        guard let url = URL(string: urlString) else {
            return false
        }
        if #available(iOS 10.0, *) {
            application.openURL(url, options: [:], completionHandler: nil)
            return true
        } else {
            let isOpened = application.openUrl(url)
            return isOpened
        }
    }

    /**
     Launch navigation application with given app and directions
     - parameter mapApp: MapApp
     - parameter transportMode: TransportMode
     - return the transport mode parameter to add to the url
    */
    func getTransportModeParameter(for mapApp: MapApp, with transportMode: TransportMode) -> String {
        var parameterString = ""
        if mapApp.transportModes.keys.contains(transportMode), let parameter = mapApp.transportModes[transportMode] {
            switch mapApp {
            case .here:
                parameterString.append("?m=\(parameter)")
            case .google:
                parameterString.append("&directionsmode=\(parameter)")
            case .yandexMaps:
                parameterString.append("&rtt=\(parameter)")
            case .apple:
                parameterString.append("&dirflg=\(parameter)")
            default:
                parameterString.append("")
            }
        }
        return parameterString
    }

    /**
      Launch navigation application with given app and directions
      - parameter mapApp: MapApp
      - parameter fromDirections: CLLocation
      - parameter toDirections: CLLocation
      - parameter fromDirectionsName: String?
      - parameter toDirectionsName: String?
     */
    open func launchMapApp(_ mapApp: MapApp, fromDirections: CLLocation, toDirections: CLLocation, fromDirectionsName: String?, toDirectionsName: String?, transportMode: TransportMode) -> Bool {
        let fromLatitude = fromDirections.coordinate.latitude
        let fromLongitude = fromDirections.coordinate.longitude
        let toLatitude = toDirections.coordinate.latitude
        let toLongitude = toDirections.coordinate.longitude
        if !isMapAppInstalledForLocation(mapApp) {
            return false
        }
        var urlString = ""
        switch(mapApp) {
        case .apple:
            urlString = String(format: "http://maps.apple.com/?saddr=%@&daddr=%@&z=14",
                                 googleMapsString(fromDirections, fromDirectionsName),
                                 googleMapsString(toDirections, toDirectionsName))
        case .here:
            if #available(iOS 9.0, *) {
                urlString = String(format: "https://share.here.com/r/%f,%f,%@/%f,%f,%@",
                               fromLatitude,
                               fromLongitude,
                               fromDirectionsName ?? "",
                               toLatitude,
                               toLongitude,
                               toDirectionsName ?? "")
            } else {
                urlString = String(format: "\(MapApp.here.urlPrefix)%f,%f,%@/%f,%f,%@",
                               fromLatitude,
                               fromLongitude,
                               fromDirectionsName ?? "",
                               toLatitude,
                               toLongitude,
                               toDirectionsName ?? "")
            }
        case .google:
            urlString = String(format: "\(MapApp.google.urlPrefix)?saddr=%@&daddr=%@",
                           googleMapsString(fromDirections, fromDirectionsName),
                           googleMapsString(toDirections, toDirectionsName))
        case .yandexMaps:
            urlString = String(format: "\(MapApp.yandexMaps.urlPrefix)maps.yandex.ru/?rtext=%f,%f~%f,%f",
            fromLatitude,
            fromLongitude,
            toLatitude,
            toLongitude)
        case .yandexNavi:
            urlString = String(format: "\(MapApp.yandexNavi.urlPrefix)build_route_on_map?lat_to=%f&lon_to=%f&lat_from=%f&lon_from=%f",
                           toLatitude,
                           toLongitude,
                           fromLatitude,
                           fromLongitude)
        case .citymapper:
            let params: NSMutableArray! = NSMutableArray(capacity: 10)
            if CLLocationCoordinate2DIsValid(fromDirections.coordinate) {
                params.add(String(format: "startcoord=%f,%f",
                                    fromLatitude,
                                    fromLongitude))
                if let fromName = fromDirectionsName, !fromName.isEmpty {
                    params.add(String(format: "startname=%@", urlEncode(fromName)))
                }
            }
            if CLLocationCoordinate2DIsValid(toDirections.coordinate) {
                params.add(String(format: "endcoord=%f,%f",
                                    toLatitude,
                                    toLongitude))
                if let toName = toDirectionsName, !toName.isEmpty {
                    params.add(String(format: "endname=%@", urlEncode(toName)))
                }
            }
            
            urlString = String(format: "\(MapApp.citymapper.urlPrefix)directions?%@", params.componentsJoined(by: "&"))
        case .navigon:
            var name: String = "Destination"
            if let toName = toDirectionsName, !toName.isEmpty {
                name = toName
            }
            
            urlString = String(format: "\(MapApp.navigon.urlPrefix)coordinate/%@/%f/%f",
                           urlEncode(name),
                           toLongitude,
                           toLatitude)
        case .transit:
            let params = NSMutableArray(capacity: 2)
            params.add(String(format: "from=%f,%f", fromLatitude, fromLongitude))
            params.add(String(format: "to=%f,%f", toLatitude, toLongitude))
            urlString = String(format: "\(MapApp.transit.urlPrefix)directions?%@", params.componentsJoined(by: "&"))
        case .waze:
            urlString = String(format: "\(MapApp.waze.urlPrefix)?ll=%f,%f&navigate=yes",
                           toLatitude,
                           toLongitude)
        case .moovit:
            urlString = String(format: "\(MapApp.moovit.urlPrefix)directions?dest_lat=%f&dest_lon=%f&dest_name%@=&orig_lat=%f&orig_lon=%f&orig_name=%@&auto_run=true&partner_id=%@",
                           toLatitude,
                           toLongitude,
                           urlEncode(toDirectionsName ?? ""),
                           fromLatitude,
                           fromLongitude,
                           urlEncode(fromDirectionsName ?? ""),
                           Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "")
        }

        urlString.append(getTransportModeParameter(for: mapApp, with: transportMode))
        guard let url = URL(string: urlString) else {
            return false
        }
        if #available(iOS 10.0, *) {
            application.openURL(url, options: [:], completionHandler: nil)
            return true
        } else {
            let isOpened = application.openUrl(url)
            return isOpened
        }
    }

    /**
      Returns whether the given navigation application can be launched with given directions and mode
      - parameter mapApp: MapApp
      - parameter fromDirections: MapPoint
      - parameter toDirections: MapPoint
     */
    open func canLaunchMapApp(_ mapApp: MapApp, fromDirections: MapPoint, toDirections: MapPoint) -> Bool {
        var canLaunch = false
        if fromDirections.location != nil, toDirections.location != nil {
            canLaunch = canLaunch || isMapAppInstalledForLocation(mapApp)
        } else if fromDirections.address != nil, toDirections.address != nil {
            canLaunch = canLaunch || isMapAppInstalledForAddress(mapApp)
        }
        return canLaunch
    }

    /**
      Launch navigation application with given app and directions
      - parameter mapApp: MapApp
      - parameter fromDirections: MapPoint
      - parameter toDirections: MapPoint
     */
    open func launchMapApp(_ mapApp: MapApp, fromDirections: MapPoint, toDirections: MapPoint, transportMode: TransportMode = .drive) -> Bool {
        if let fromLocation = fromDirections.location, let toLocation = toDirections.location {
            return launchMapApp(mapApp, fromDirections: fromLocation, toDirections: toLocation, fromDirectionsName: fromDirections.name, toDirectionsName: toDirections.name, transportMode: transportMode)
        } else if let fromAddress = fromDirections.address, let toAddress = toDirections.address {
            return launchMapApp(mapApp, fromDirections: fromAddress, toDirections: toAddress, fromDirectionsName: fromDirections.name, toDirectionsName: toDirections.name, transportMode: transportMode)
        } else {
            return false
        }
    }

    /**
      Prepares deep linking url with given address
      - parameter address: String
      - returns: Deeplink url
     */
    internal func formatString(_ address: String) -> String {
        var formattedAddress = address.replacingOccurrences(of: " ", with: "+")
        formattedAddress = formattedAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return formattedAddress
    }

    /**
      Prepares deep linking url with given location and name
      - parameter location: CLLocation
      - parameter locationName: String?
      - returns: Deeplink url
     */
    internal func googleMapsString(_ location: CLLocation, _ locationName: String?) -> String {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            return ""
        }

        if let name = locationName, !name.isEmpty {
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            return String(format: "%f,%f+(%@)",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            encodedName!)
        }

        return String(format: "%f,%f",
                        location.coordinate.latitude,
                        location.coordinate.longitude)
    }
    
    /**
      Encodes given string
      - parameter name: String
      - returns: Encoded name
     */
    internal func urlEncode(_ name: String) -> String {
        return name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    // MARK: Map Apps Getter
    
    /**
      Returns available navigation apps
      - returns: Map Apps
     */
    open func getMapApps() -> [MapApp] {
        return availableMapApps
    }
    
}

/**
  Protocol that used for UIApplication
 */
public protocol UIApplicationProtocol {
    
    /**
      Open given url
     */
    func openUrl(_ url: URL) -> Bool
    
    /**
      Checks if given url can be opened
     */
    func canOpenUrl(_ url: URL) -> Bool
    
    /**
      Open given url for iOS 10+
     */
    @available(iOS 10.0, *)
    func openURL(_ url: URL,
                 options: [UIApplication.OpenExternalURLOptionsKey: Any],
                 completionHandler completion: ((Bool) -> Swift.Void)?)

}

/**
  Extension for UIApplication
 */
extension UIApplication: UIApplicationProtocol {

    public func openUrl(_ url: URL) -> Bool {
        if #available(iOS 10.0, *) {
            return false
        } else {
            return openURL(url)
        }
    }
    
    public func canOpenUrl(_ url: URL) -> Bool {
        return canOpenURL(url)
    }

    public func openURL(_ url: URL,
                        options: [UIApplication.OpenExternalURLOptionsKey: Any],
                        completionHandler completion: ((Bool) -> Void)?) {
        if #available(iOS 10.0, *) {
            open(url, options: options, completionHandler: completion)
        } else {
            _ = openUrl(url)
        }
    }

}
