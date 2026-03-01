//
//  OAuth2TokenStorage.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 25.02.26.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let tokenKey = "UnsplashAccessToken"

    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            return token
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func deleteToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
