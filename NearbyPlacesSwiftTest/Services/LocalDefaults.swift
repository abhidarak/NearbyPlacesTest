//
//  LocalDefaults.swift

import Foundation

/// Singleton class for interacting with stored user defaults/prefences in UserDefaults
class LocalDefaults {
    
    /// singleton accessor
    static let shared = LocalDefaults()
    
    private let defaults = UserDefaults.standard


}
