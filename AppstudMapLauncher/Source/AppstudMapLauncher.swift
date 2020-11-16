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
    case apple,
    here,
    google,
    yandexNavi,
    yandexMaps,
    citymapper,
    navigon,
    transit,
    waze,
    moovit

    static let allValues = [apple, here, google, yandexNavi, yandexMaps, citymapper, navigon, transit, waze, moovit]

    public var title: String {
        return NSLocalizedString("\(self.rawValue).title", tableName: "AppstudMapLauncher", bundle: Bundle(for: MapPoint.self), value: "\(self.rawValue)", comment: "")
    }

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

    /**
      Get the transport mode paramete for the current mapApp
     - parameter transportMode: TransportMode
     - return the transport mode parameter to add to the url
    */
    func getParameter(for transportMode: TransportMode) -> String {
        var parameterString = ""
        if self.transportModes.keys.contains(transportMode), let parameter = self.transportModes[transportMode] {
            switch self {
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

    // MARK: - Check map app availability
    /**
      Checks if app installed with given app type
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    func isInstalled() -> Bool {
        if self == .apple {
            return true
        }
        guard let url = URL(string: self.urlPrefix) else {
            return false
        }
        return UIApplication.shared.canOpenUrl(url)
    }

    /**
      Checks if app installed with given app type and takes CLLocation as parameter
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    public func isInstalledForLocation() -> Bool {
        return self.supportsLocation ? self.isInstalled() : false
    }

    /**
      Checks if app installed with given app type and takes address as parameter
      - parameter mapApp: MapApp
      - returns: Bool installed or not
     */
    public func isInstalledForAddress() -> Bool {
        return self.supportsAddress ? self.isInstalled() : false
    }

    /**
      Returns whether the given navigation application can be launched with given directions and mode
      - parameter fromDirections: MapPoint
      - parameter toDirections: MapPoint
     */
    public func canBeLaunched(fromDirections: MapPoint, toDirections: MapPoint) -> Bool {
        var canLaunch = false
        if fromDirections.location != nil, toDirections.location != nil {
            canLaunch = canLaunch || self.isInstalledForLocation()
        } else if fromDirections.address != nil, toDirections.address != nil {
            canLaunch = canLaunch || self.isInstalledForAddress()
        }
        return canLaunch
    }

    // MARK: - Launch the app

    /**
      Launch navigation application with given app and directions
      - parameter mapApp: MapApp
      - parameter fromDirections: MapPoint
      - parameter toDirections: MapPoint
     */
    public func launch(fromDirections: MapPoint, toDirections: MapPoint, transportMode: TransportMode = .drive) -> Bool {
        if let fromLocation = fromDirections.location, let toLocation = toDirections.location {
            return self.launch(fromDirections: fromLocation, toDirections: toLocation, fromDirectionsName: fromDirections.name, toDirectionsName: toDirections.name, transportMode: transportMode)
        } else if let fromAddress = fromDirections.address, let toAddress = toDirections.address {
            return self.launch(fromDirections: fromAddress, toDirections: toAddress, fromDirectionsName: fromDirections.name, toDirectionsName: toDirections.name, transportMode: transportMode)
        } else {
            return false
        }
    }

    /**
      Launch navigation application with given app and directions
      - parameter fromDirections: String
      - parameter toDirections: String
      - parameter fromDirectionsName: String?
      - parameter toDirectionsName: String?
     */
    public func launch(fromDirections: String, toDirections: String, fromDirectionsName: String?, toDirectionsName: String?, transportMode: TransportMode) -> Bool {
        guard self.isInstalledForAddress() else {
            return false
        }
        var urlString = ""
        switch(self) {
        case .apple:
            urlString = String(format: "http://maps.apple.com/?saddr=%@&daddr=%@",
                               fromDirections.formatAddress(),
                               toDirections.formatAddress())
        case .google:
            urlString = String(format: "\(MapApp.google.urlPrefix)?saddr=%@&daddr=%@",
                fromDirections.formatAddress(),
                toDirections.formatAddress())

            urlString.append(self.getParameter(for: transportMode))
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
            UIApplication.shared.openURL(url, options: [:], completionHandler: nil)
            return true
        } else {
            let isOpened = UIApplication.shared.openUrl(url)
            return isOpened
        }
    }

    /**
      Launch navigation application with given app and directions
      - parameter fromDirections: CLLocation
      - parameter toDirections: CLLocation
      - parameter fromDirectionsName: String?
      - parameter toDirectionsName: String?
     */
    public func launch(fromDirections: CLLocation, toDirections: CLLocation, fromDirectionsName: String?, toDirectionsName: String?, transportMode: TransportMode) -> Bool {
        let fromLatitude = fromDirections.coordinate.latitude
        let fromLongitude = fromDirections.coordinate.longitude
        let toLatitude = toDirections.coordinate.latitude
        let toLongitude = toDirections.coordinate.longitude
        guard self.isInstalledForLocation() else {
            return false
        }
        var urlString = ""
        switch(self) {
        case .apple:
            urlString = String(format: "http://maps.apple.com/?saddr=%@&daddr=%@&z=14",
                               fromDirections.toGoogleMapsString(with: fromDirectionsName),
                               toDirections.toGoogleMapsString(with: toDirectionsName))
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
                fromDirections.toGoogleMapsString(with: fromDirectionsName),
                toDirections.toGoogleMapsString(with: toDirectionsName))
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
                    params.add(String(format: "startname=%@", fromName.urlEncode()))
                }
            }
            if CLLocationCoordinate2DIsValid(toDirections.coordinate) {
                params.add(String(format: "endcoord=%f,%f",
                                    toLatitude,
                                    toLongitude))
                if let toName = toDirectionsName, !toName.isEmpty {
                    params.add(String(format: "endname=%@", toName.urlEncode()))
                }
            }

            urlString = String(format: "\(MapApp.citymapper.urlPrefix)directions?%@", params.componentsJoined(by: "&"))
        case .navigon:
            var name: String = "Destination"
            if let toName = toDirectionsName, !toName.isEmpty {
                name = toName
            }

            urlString = String(format: "\(MapApp.navigon.urlPrefix)coordinate/%@/%f/%f",
                name.urlEncode(),
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
            urlString = String(format: "\(MapApp.moovit.urlPrefix)directions?dest_lat=%f&dest_lon=%f&dest_name=%@&orig_lat=%f&orig_lon=%f&orig_name=%@&auto_run=true&partner_id=%@",
                           toLatitude,
                           toLongitude,
                           toDirectionsName?.urlEncode() ?? "",
                           fromLatitude,
                           fromLongitude,
                           fromDirectionsName?.urlEncode() ?? "",
                           Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "")
        }

        urlString.append(self.getParameter(for: transportMode))
        guard let url = URL(string: urlString) else {
            return false
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.openURL(url, options: [:], completionHandler: nil)
            return true
        } else {
            let isOpened = UIApplication.shared.openUrl(url)
            return isOpened
        }
    }

    // MARK: Get Available Navigation Apps
    /**
      Prepares available navigation apps installed on device
     */
    public static func getAvailableNavigationApps() -> [MapApp] {
        var availableMapApps = [MapApp]()
        MapApp.allValues.forEach { (app) in
            if app.isInstalled() {
                availableMapApps.append(app)
            }
        }
        return availableMapApps
    }
}

extension String {
    /**
      Encodes given string
      - returns: Encoded name
     */
    internal func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    /**
      Prepares deep linking url with given address
      - returns: Deeplink url
     */
    internal func formatAddress() -> String {
        var formattedAddress = self.replacingOccurrences(of: " ", with: "+")
        formattedAddress = formattedAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return formattedAddress
    }
}

extension CLLocation {
    /**
      Prepares deep linking url with given location and name
      - parameter locationName: String?
      - returns: Deeplink url
     */
    internal func toGoogleMapsString(with locationName: String?) -> String {
        guard CLLocationCoordinate2DIsValid(self.coordinate) else {
            return ""
        }

        if let name = locationName, !name.isEmpty {
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            return String(format: "%f,%f+(%@)",
                            self.coordinate.latitude,
                            self.coordinate.longitude,
                            encodedName!)
        }

        return String(format: "%f,%f",
                        self.coordinate.latitude,
                        self.coordinate.longitude)
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
