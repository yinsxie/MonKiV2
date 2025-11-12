//
//  UserDefaults.swift
//  MonKi
//
//  Created by William on 27/10/25.
//

import Foundation

/// List of Identifier for determined userDefault keys
///
/// > Important: Conform to other teammates when adding new keys to avoid duplication. Be sure to double-check existing keys first.
enum UserDefaultsIdentifier {
    case placeHolder
    
    var value: String {
        switch self {
        case .placeHolder:
            return ""
        }
    }
}

enum UserDefaultsError: Error {
    case maxFieldLessThanCurrentFilledField
}

/// Singleton for managing UserDefaults operations
///
/// Usage:
///
/// - Setter: Will set the value for the specified key
/// - Getter: Will retrieve the value for the specified key with an optional value
/// > Important: Getters return optional values, so make sure to unwrap them safely
///
/// >Warning:
/// For setting `maxFieldCount`, it will throw an error if the new value is less than currentFilledField

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init() {}
    
}

private extension UserDefaultsManager {
    func set<T>(value: T, for identifier: UserDefaultsIdentifier) {
        UserDefaults.standard.set(value, forKey: identifier.value)
    }
    
    func get<T>(for identifier: UserDefaultsIdentifier) -> T? {
        return UserDefaults.standard.object(forKey: identifier.value) as? T
    }
}

//MARK: Dev Purposes Only
extension UserDefaultsManager {
    func resetAll() {
        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
    
    func printAll() {
        let all = UserDefaults.standard.dictionaryRepresentation()
        for (key, value) in all {
            print("\(key): \(value)")
        }
    }
    
    //MARK: Change this as needed
    func initDevUserDefaults() {

    }
}
