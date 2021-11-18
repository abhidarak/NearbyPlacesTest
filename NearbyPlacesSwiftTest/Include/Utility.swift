//
//  Utility.swift
//
//  Created by Abhishek Darak
//

import UIKit



// MARK: Global print() and debugPrint() overrides for Release builds

func print(_ items: Any..., separator: String = " ", terminator: String = "\n")
{
    // Make sure <App Target> -> Build Settings -> 'Swift Compiler - Custom Flags' has a `-D DEBUG` entry.
    #if DEBUG
        // Only print to the console when we are in a debug build
        // Ref: https://stackoverflow.com/a/32893825
        var idx = items.startIndex
        let endIdx = items.endIndex

        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
        while idx < endIdx
    #endif
}

func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n")
{
    // Make sure <App Target> -> Build Settings -> 'Swift Compiler - Custom Flags' has a `-D DEBUG` entry.
    #if DEBUG
        // Only print to the console when we are in a debug build
        // Ref: https://stackoverflow.com/a/32893825
        var idx = items.startIndex
        let endIdx = items.endIndex

        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
        while idx < endIdx
    #endif
}


class Utility {

    static var isAppDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    static let okButtonText = NSLocalizedString("OK", comment: "Short text for an 'OK' button on an alert popup")
    static let cancelButtonText = NSLocalizedString("Cancel", comment: "Short text for a 'Cancel' button on an alert popup")
    static let openSettingsButtonText = NSLocalizedString("Open Settings", comment: "Short text on a button on an alert popup that opens the Settings app")

    /// Use as empty string to force UI to update and also keep object rendered
    static let blankDisplayString = " "


    // MARK: UI Colors
    // To set the font that are being used in the App
    // private static let orangeHex = "E85822"
    //static var orange: UIColor
    //{
    //    return UIColor.fromHexString(orangeHex)
    //}
    static var TFUnderlineColor: UIColor {
        return UIColor.fromHexString("#8E8E8E")
    }
    static var TFErrorUnderlineColor: UIColor {
        return UIColor.fromHexString("#C80101")
    }
    

    
    static var systemTextMain: UIColor {
        return UIColor.fromHexString("#1E1E1E")
    }
    
    static var systemTextMainLight: UIColor {
        return UIColor.fromHexString("#8E8E8E")
    }
    
    static var systemButtonBGColor: UIColor {
        return UIColor.fromHexString("#1E1E1E")
    }
    
    static var LinkButtonColor: UIColor {
        return UIColor.fromHexString("#3172D6")
    }

    // MARK: UIAlertController methods

    /**
        Simple alert with just an OK button.

        - Parameters:
            - title: The alert's title
            - message: The message to display
            - okCallback: Callback to call when OK button is pressed
            - alertStyle: Whether to show a modal popup alert (.Alert, default), or one that slides up from the bottom (.ActionSheet)

        - Returns: A UIAlertController ready to use with presentViewController() from a UIViewController.
    */
    static func messageAlert(title: String, message: String, okCallback: @escaping ((UIAlertAction) -> Void) = {_ in }, alertStyle: UIAlertController.Style = .alert) -> UIAlertController
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: alertStyle
        )

        alertController.addAction(UIAlertAction(title: okButtonText, style: .default, handler: okCallback))

        return alertController
    }

    /**
        Simple alert with OK and Cancel buttons.

        - Parameters:
            - title: The alert's title
            - message: The message to display
            - okCallback: Callback to call when OK button is pressed
            - cancelCallback: Callback to call when Cancel button is pressed
            - alertStyle: Whether to show a modal popup alert (.Alert, default), or one that slides up from the bottom (.ActionSheet)

        - Returns: A UIAlertController ready to use with presentViewController() from a UIViewController.
    */
    static func confirmAlert(title: String, message: String, okCallback: @escaping ((UIAlertAction) -> Void) = {_ in }, cancelCallback: @escaping ((UIAlertAction) -> Void) = {_ in }, alertStyle: UIAlertController.Style = .alert) -> UIAlertController
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: alertStyle
        )

        alertController.addAction(UIAlertAction(title: okButtonText, style: .default, handler: okCallback))
        alertController.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: cancelCallback))

        return alertController
    }

    /**
        Simple alert with Open Settings and Cancel buttons so the user can easily go to the Settings app and change a setting.

        - Parameters:
            - title: The alert's title
            - message: The message to display
            - alertStyle: Whether to show a modal popup alert (.Alert, default), or one that slides up from the bottom (.ActionSheet)

        - Returns: A UIAlertController ready to use with presentViewController() from a UIViewController.
    */
    static func settingsAppLinkAlert(title: String, message: String, cancelCallback: @escaping ((UIAlertAction) -> Void) = {_ in }, alertStyle: UIAlertController.Style = .alert) -> UIAlertController
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: alertStyle
        )

        alertController.addAction(UIAlertAction(title: openSettingsButtonText, style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alertController.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: cancelCallback))

        return alertController
    }

    private static let decimalNumberFormatter = NumberFormatter()
    private static var defaultDecimalNumberFormatterMinDecimalPlaces: Int?
    private static var defaultDecimalNumberFormatterMaxDecimalPlaces: Int?

    static func formatNumberDecimal(_ number: Any, minDecimalPlaces: Int? = nil, maxDecimalPlaces: Int? = nil) -> String? {
        // Set the decimal format style so we get thousands separators (also takes locale into account)
        decimalNumberFormatter.numberStyle = .decimal

        // Hold onto defaults if we haven't yet
        if defaultDecimalNumberFormatterMinDecimalPlaces == nil
        {
            defaultDecimalNumberFormatterMinDecimalPlaces = decimalNumberFormatter.minimumFractionDigits
        }
        if defaultDecimalNumberFormatterMaxDecimalPlaces == nil
        {
            defaultDecimalNumberFormatterMaxDecimalPlaces = decimalNumberFormatter.maximumFractionDigits
        }

        // Set min and/or max places
        if let min = minDecimalPlaces {
            decimalNumberFormatter.minimumFractionDigits = min
        }
        if let max = maxDecimalPlaces {
            decimalNumberFormatter.maximumFractionDigits = max
        }

        // Do string conversion attempt
        let returnString = decimalNumberFormatter.string(for: number)

        // Reset min and/or max, if we need to
        if let _ = minDecimalPlaces {
            decimalNumberFormatter.minimumFractionDigits = defaultDecimalNumberFormatterMinDecimalPlaces!
        }
        if let _ = maxDecimalPlaces {
            decimalNumberFormatter.maximumFractionDigits = defaultDecimalNumberFormatterMaxDecimalPlaces!
        }

        return returnString
    }
    
    /// to change numeric string to double
    public static func getDoubleValue(value:Any) -> Double {
        if value is String {
            let str_val:String = value as! String
            if str_val.isEmpty == true {
                return 0.0
            } else {
                return Double(value as! String )!
            }
        }
        if value is Double {
            return Double(value as! Double)
        }
        return 0
    }
    
    
    private static func getColorByName(initial:String) -> UIColor {
        
        for (color,initials) in Strings.ColorInitials {
            if initials.contains(initial) {
                return UIColor.fromHexString(color)
            }
        }
        return UIColor.fromHexString("#FF0000")
    }
    
    static func imageWith(name: String?) -> UILabel? {
        let frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        
      //  nameLabel.textColor =
       // nameLabel.font = UIFont(name: LibreFranklin.semibold, size: 19.2)
        
        
        
        //nameLabel.text = initial
        //UIGraphicsBeginImageContext(frame.size)
        
        //if let currentContext = UIGraphicsGetCurrentContext() {
        //    nameLabel.layer.render(in: currentContext)
        //    let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            
            return nameLabel
       // }
       // return nil
    }
    
    
    static func IntialChar(name: String?) -> (NSAttributedString,UIColor) {
        var initial = ""
        if let firstLetter = name?.first {
            initial = String(firstLetter).capitalized
            
           
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.fromHexString("#FFFFFF",alpha: 0.85), .font: UIFont(name: LibreFranklin.semibold, size: 19.2) ]
        
        let attributedText = NSAttributedString(string: initial, attributes: attributes)
        
        let color =  getColorByName(initial:initial)
        return (attributedText,color)
    }
}


// MARK: Dev errors

enum DevelopmentError: Error {
    case notImplementedError
    case methodNotOverriddenByInheritor
    case incorrectParameterUsage
}

/// Descriptions for errors - Not meant for display to end user; just for dev purposes
extension DevelopmentError: LocalizedError {
    var description: String {
        switch self {
        case .notImplementedError:
            return "\n\t-- ERROR --\n\tSomething was not implemented that was supposed to be!"
        case .methodNotOverriddenByInheritor:
            return "\n\t-- ERROR --\n\tAn implemention that overrides the parent's implementation is missing!"
        case .incorrectParameterUsage:
            return "\n\t-- ERROR --\n\tA parameter was used incorrectly!"
        }
    }
}

// MARK: API errors

/// Errors specifically for the the API classes
enum ApiError: Error {
    case invalidUrl
    case authorizationError
}


// MARK: External URLs

struct ExternalUrls {

}



// MARK: Fonts

// Easiest way to gather the relevant custom font name strings we need to be able to use them through code it to just
// loop through and print UIFont.familyNames and within each of those, loop through and print UIFont.fontNames(forFamilyName: family).
// These strings don't match the filenames, nor are they easy to look at through attributes.

/// Strings for the different weights of the Proxima Nova font.
struct LibreFranklin {
    static let familyName = "LibreFranklin"

    private static let base = familyName + "-"
    static let black = base + "Black"
    static let blackItalic = base + "BlackItalic"
    static let bold = base + "Bold"
    static let boldItalic = base + "BoldItalic"
    //static let extrabold = base + "ExtraBold"
    //static let extraboldItalic = base + "ExtraBoldItalic"
    static let extraLight = base + "ExtraLight"
    static let extraLightItalic = base + "ExtraLightItalic"
    static let italic = base + "Italic"
    static let light = base + "Light"
    static let lightItalic = base + "LightItalic"
    static let medium = base + "Medium"
    static let mediumItalic = base + "MediumItalic"
    static let regular = base + "Regular"
    static let semibold = base + "SemiBold"
    static let semiboldItalic = base + "SemiBoldItalic"
    static let thin = base + "Thin"
    static let thinItalic = base + "ThinItalic"
}

struct AppFontStyles {
    static let button = UIFont(name: LibreFranklin.medium, size: 18)
}
extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

// Override the system font with our custom font in the font class itself.
// Be sure to call overrideInitialize() in AppDelegate.init().
// Note the appearance won't change in Interface Builder / Storyboard, but this is much better than having to change it everywhere.
// We'll need to keep in mind that the sizing will be slightly different due to the font differences, so be sure to test on device / in simulator.
// Ref: http://stackoverflow.com/a/40484460/3712461
// We can add other CTFontXXXXXUsage overrides as needed; print out the fontAttribute you'd like to override and add here.
extension UIFont {
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: LibreFranklin.regular, size: size)!
    }

    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: LibreFranklin.bold, size: size)!
    }

    // System italic only comes in regular weight
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: LibreFranklin.italic, size: size)!
    }

    // All other weights
    @objc class func myWeightedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case UIFont.Weight.light:
            return UIFont(name: LibreFranklin.light, size: size)!
        case UIFont.Weight.thin:
            return UIFont(name: LibreFranklin.thin, size: size)!
        case UIFont.Weight.semibold:
            return UIFont(name: LibreFranklin.semibold, size: size)!
        case UIFont.Weight.black:
            return UIFont(name: LibreFranklin.black, size: size)!
        case UIFont.Weight.heavy:
            return UIFont(name: LibreFranklin.semibold, size: size)!
        default:
            return mySystemFont(ofSize: size)
        }
    }

    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }

        var fontName = ""
        switch fontAttribute {
            // It seems there is only one weight for italics when using System font
            case "CTFontObliqueUsage":
                fontName = LibreFranklin.italic

            case "CTFontUltraLightUsage":
                fontName = LibreFranklin.thin
            case "CTFontThinUsage", "CTFontLightUsage":
                fontName = LibreFranklin.light
            case "CTFontRegularUsage", "CTFontMediumUsage":
                fontName = LibreFranklin.regular
            case "CTFontDemiUsage":
                fontName = LibreFranklin.semibold
            case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                fontName = LibreFranklin.bold
            case "CTFontHeavyUsage":
                fontName = LibreFranklin.semibold
            case "CTFontBlackUsage":
                fontName = LibreFranklin.black
            default:
                print("\nUIFont convenience init\n\t'default' case `fontAttribute` value: \(fontAttribute)")

                fontName = LibreFranklin.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }

    class func overrideInitialize() {
        guard self == UIFont.self else {
            return
        }

        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }

        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
        {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }

        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:)))
        {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }

        if let weightedSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:weight:))),
            let myWeightedSystemFontMethod = class_getClassMethod(self, #selector(myWeightedSystemFont(ofSize:weight:)))
        {
            method_exchangeImplementations(weightedSystemFontMethod, myWeightedSystemFontMethod)
        }

        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
        {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}






// MARK: DataConvertible protocol / extension

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {
    /// Create from a Data object
    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }
    /// Converts the value to a Data object
    var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

// All the types that are safe to convert using DataConvertible
extension Int: DataConvertible { }
extension Int8: DataConvertible { }
extension Int16: DataConvertible { }
extension Int32: DataConvertible { }
extension Int64: DataConvertible { }
extension UInt: DataConvertible { }
extension UInt8: DataConvertible { }
extension UInt16: DataConvertible { }
extension UInt32: DataConvertible { }
extension UInt64: DataConvertible { }
extension CGFloat: DataConvertible { }
extension Float: DataConvertible { }
extension Double: DataConvertible { }


// MARK: IntConvertible protocol / extension

protocol IntConvertible {
    var int: Int { get }
}

extension IntConvertible {
    /// Converts the value to an Int
    var int: Int {
        switch self {
        case is Int8:
            return Int(self as! Int8)
        case is Int16:
            return Int(self as! Int16)
        case is Int32:
            return Int(self as! Int32)
        case is Int64:
            return Int(self as! Int64)
        case is UInt:
            return Int(self as! UInt)
        case is UInt8:
            return Int(self as! UInt8)
        case is UInt16:
            return Int(self as! UInt16)
        case is UInt32:
            return Int(self as! UInt32)
        case is UInt64:
            return Int(self as! UInt64)
        case is CGFloat:
            return Int(self as! CGFloat)
        case is Float:
            return Int(self as! Float)
        case is Double:
            return Int(self as! Double)
        default:
            print("\nUtility.IntConvertible - var int\n\t-- ERROR --\n\tAttempted to convert unsupported type of \(type(of: self))")
            return 0
        }
    }
}

// All the types that are safe to convert using IntConvertible
extension Int8: IntConvertible { }
extension Int16: IntConvertible { }
extension Int32: IntConvertible { }
extension Int64: IntConvertible { }
extension UInt: IntConvertible { }
extension UInt8: IntConvertible { }
extension UInt16: IntConvertible { }
extension UInt32: IntConvertible { }
extension UInt64: IntConvertible { }
extension CGFloat: IntConvertible { }
extension Float: IntConvertible { }
extension Double: IntConvertible { }
