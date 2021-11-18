//
//  MyExtentions.swift
//
//  Created by Abhishek Darak
//

import UIKit

// MARK: UIColor extensions

// https://gist.github.com/arshad/de147c42d7b3063ef7bc
/// Accepts `FFF` and `F0F0F0` formats, with or without a leading `#`, with optional alpha value parameter. Returns clear on invalid string length.
extension UIColor {
    static func fromHexString(_ hexString: String, alpha: Double = 1.0) -> UIColor {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clear
        }
        return UIColor.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(255 * alpha) / 255)
    }
}



// MARK: UIApplication extensions

extension UIApplication {
    // Ref: http://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

/// Localizable descriptions for the API errors suitable for showing to the end user
extension ApiError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("Request Error: Invalid URL", comment: "The HTTP request was to an invalid URL")
        case .authorizationError:
            return NSLocalizedString("Request Error: Authorization Creation Error", comment: "The HTTP request failed to create its authorization information")
        }
    }
}

// MARK: String extensions

extension String {
    /// Shorthand function to trim whitespace and newline
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// Whether all the characters in the string are desirable characters, such as an alphanumerics and symbols.
    /// See `CharacterSet.badCharacters` for the list of undesirable characters.
    var isAllGoodCharacters: Bool {
        get {
            return self.allSatisfy({ (char) -> Bool in char.isGoodCharacter })
        }
    }
    var isValidEmail: Bool {
       let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
       return testEmail.evaluate(with: self)
    }
}


// MARK: CharacterSet extensions

extension CharacterSet {
    /// A combination of sets of characters we have no interest in.
    /// Contains `illegalCharacters`, `controlCharacters`, `nonBaseCharacters`, and `decomposables`.
    static var badCharacters: CharacterSet {
        var bad = CharacterSet.illegalCharacters
        bad.formUnion(CharacterSet.controlCharacters)
        bad.formUnion(CharacterSet.nonBaseCharacters)
        bad.formUnion(CharacterSet.decomposables)
        
        return bad
    }
}

// MARK: UIViewController extensions

extension UIViewController {
    /// Dismisses the keyboard when anywhere in the rest of the view is tapped on
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
  
}

extension Date {
    // iOS date format string references:
    // http://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
    // https://i.stack.imgur.com/lkYVY.png
    
    /// Returns the current datetime at the beginning of the quarter hour interval it was in, or nil on failure.
    ///
    /// Example: 2017-01-01 13:21 -> return 2017-01-01 13:15.
    func getBeginningOfCurrentQuarterHour() -> Date? {
        let cal = Calendar.current
        var comps = cal.dateComponents([.timeZone, .calendar, .year, .month, .day, .hour, .minute], from: self)
        
        if let compsMinute = comps.minute {
            switch compsMinute {
            case 0...14:
                comps.minute = 0
            case 15...29:
                comps.minute = 15
            case 30...44:
                comps.minute = 30
            case 45...59:
                comps.minute = 45
            default:
                comps.minute = 0
            }
            return cal.date(from: comps)
        }
        else
        {
            print("-- WARNING --\nUtility.swift Date.getBeginningOfCurrentQuarterHour")
            print("\tFailed to get the minute component from the Date object, so returning nil")
            return nil
        }
    }
    
    /// Example: 2017-01-01 13:21 -> return 2017-01-01 13:20.
    func getBeginningOfCurrentTenMinutes() -> Date? {
        let cal = Calendar.current
        var comps = cal.dateComponents([.timeZone, .calendar, .year, .month, .day, .hour, .minute], from: self)
        
        if let compsMinute = comps.minute {
            switch compsMinute {
            case 0...9:
                comps.minute = 0
            case 10...19:
                comps.minute = 10
            case 20...29:
                comps.minute = 20
            case 30...39:
                comps.minute = 30
            case 40...49:
                comps.minute = 40
            case 50...59:
                comps.minute = 50
            default:
                comps.minute = 0
            }
            
            return cal.date(from: comps)
        }
        else
        {
            print("-- WARNING --\nUtility.swift Date.getBeginningOfCurrentTenMinutes")
            print("\tFailed to get the minute component from the Date object, so returning nil")
            return nil
        }
    }
    
    
    /// Returns the current datetime at the end of the quarter hour interval it was in, or nil on failure.
    ///
    /// Example: 2017-01-01 13:21 -> 2017-01-01 13:30, or 2017-01-01 13:57 -> 2017-01-01 14:00
    func getEndOfCurrentQuarterHour() -> Date? {
        let cal = Calendar.current
        var comps = cal.dateComponents([.timeZone, .calendar, .year, .month, .day, .hour, .minute], from: self)
        
        if let compsMinute = comps.minute {
            switch compsMinute {
            case 0:
                comps.minute = 0
            case 1...15:
                comps.minute = 15
            case 16...30:
                comps.minute = 30
            case 31...45:
                comps.minute = 45
            default:
                // Since we need to increment the hour for minutes 46 through 59, we just do that on the date object itself
                // to avoid any wrapping around of the date to the next day or anything. Then just get the beginning of the new hour.
                let oneHourAdded = self.addingTimeInterval(TimeInterval(60 * 60 /* one hour */))
                return oneHourAdded.getBeginningOfCurrentHour()
            }
            
            return cal.date(from: comps)
        }
        else
        {
            print("-- WARNING --\nUtility.swift Date.getEndOfCurrentQuarterHour")
            print("\tFailed to get the minute or hour component from the Date object, so returning nil")
            return nil
        }
    }
    
    /// Returns the current datetime at the beginning of the hour, or nil on failure.
    func getBeginningOfCurrentHour() -> Date? {
        let cal = Calendar.current
        let comps = cal.dateComponents([.timeZone, .calendar, .year, .month, .day, .hour], from: self)
        return cal.date(from: comps)
    }
    
    /// Returns the current date at 00:00:00 or nil on failure.
    func getBeginningOfCurrentDay(useUtcTimezone: Bool = false) -> Date? {
        let cal = Calendar.current
        var comps = cal.dateComponents([.timeZone, .calendar, .year, .month, .day], from: self)
        
        if useUtcTimezone
        {
            comps.timeZone = TimeZone(secondsFromGMT: 0)
        }
        
        return cal.date(from: comps)
    }
    
    /// Returns a string formatted for debugging (yyyy-MM-dd HH:mm:ss.SSS)
    func toDebugDateTimeString() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS xxx"
        return formatter.string(from: self)
    }
    
    /// Returns a string formatted for debugging (yyyy-MM-dd)
    func toDebugDateString() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// Returns a string formatted for debugging (HH:mm:ss.SSS)
    func toDebugTimeString() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "HH:mm:ss.SSS xxx"
        return formatter.string(from: self)
    }
    
    /**
     Creates a Date from a datetime formatted string in a RFC3339 format, specifically when using '+00:00' for UTC and not 'Z'.
     
     - Parameter dateString: A datetime string such as 2015-08-11T10:19:32+00:00
     - Returns: The created Date object on success, or nil on failure to create.
     */
    init?(fromRfc3339String: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // locale to POSIX ensures that the user's locale won't be used
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        
        if let date = formatter.date(from: fromRfc3339String) {
            self.init(timeInterval: 0, since: date)
            return
        }
        
        return nil
    }
}


// MARK: Character extensions

extension Character {
    /// Whether the character is not in the `badCharacters` set.
    var isGoodCharacter: Bool {
        get {
            return self.unicodeScalars.allSatisfy({ (unicodeScalar) -> Bool in !CharacterSet.badCharacters.contains(unicodeScalar) })
        }
    }
}

// MARK: Data extensions

// Some helper string conversion methods
extension Data {
    /// Returns the object converted to a string if it contains all valid UTF-8 characters, and they're also all desirable characters
    func toString() -> String {
        if let str = String(data: self, encoding: .utf8) {
            if str.isAllGoodCharacters
            {
                return str
            }
            else
            {
                print("-- NOTICE -- Utility.swift: Data.toString(): contains undesirable characters")
                return ""
            }
        }
        else
        {
            print("-- NOTICE -- Utility.swift: Data.toString(): Not a valid UTF-8 sequence")
            return "" // blank string on failure to parse into string
        }
    }
    
    /// Whether the `toString()` call will return a string of good characters or not
    var wouldBeGoodString: Bool {
        get {
            if let str = String(data: self, encoding: .utf8) {
                return str.isAllGoodCharacters
            }
            else
            {
                return false
            }
        }
    }
    
    // Data conforms to the Collection protocol, therefore one can use map() to map each byte to the corresponding hex string.
    // The %02x format prints the argument in base 16, filled up to two digits with a leading zero if necessary.
    // The hh modifier causes the argument (which is passed as an integer on the stack) to be treated as a one byte quantity.
    // One could omit the modifier here because $0 is an unsigned number (UInt8) and no sign-extension will occur, but it does no harm leaving it in.
    // The result is then joined to a single string.
    // Ref: http://stackoverflow.com/a/40089462/3712461
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /*
     Allows use of closed range operator for selecting specific bytes from a Data object, which reads much easier.
     
     Example:
     
     let x = Data(bytes: [0x0, 0x1])
     
     // Now we can do:
     let z = x.subdata(in: 0...1)
     
     // Instead of:
     let z = x.subdata(in: 0..<2)
     */
    // Ref: https://stackoverflow.com/a/40431710/3712461
    func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
    
    /// Create Data from string converted to byte array (via UTF8 code units of string converted to array)
    init(fromUtf8String: String) {
        self.init(bytes: Array(fromUtf8String.utf8) as [UInt8])
    }
}

extension Int {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter
    }()

    var delimiter: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension UILabel {
    
   
    // adding space between each characters
    func addCharacterSpacing(kernValue: Double = 3) {
        if let labelText = text, labelText.isEmpty == false {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern,
                                          value: kernValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}



extension UIButton {

    
    // adding space between each characters
    func addCharacterSpacing(kernValue: Double = 3) {
        if let labelText = currentTitle, labelText.isEmpty == false {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern,
                                          value: kernValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
}

extension UIView {

  // OUTPUT 2
  func dropCellShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    
    
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius
    
    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    
    
  }
}
