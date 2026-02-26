//
//  AuthConfiguration.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 25.02.26.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaltBaseURL: URL
    let authStringURL: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaltBaseURL: URL, authStringURL: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaltBaseURL = defaltBaseURL
        self.authStringURL = authStringURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaltBaseURL: Constants.defaultBaseURL!,
            authStringURL: Constants.unsplashAuthorizeURLString
        )
    }
}
