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
    let defaultBaseURL: URL
    let authStringURL: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL!,
            authStringURL: Constants.unsplashAuthorizeURLString
        )
    }
}
