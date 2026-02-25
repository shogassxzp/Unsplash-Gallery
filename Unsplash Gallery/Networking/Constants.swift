//
//  Constants.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 25.02.26.
//

import Foundation

enum Constants {
    private static var keys: [String: Any]? {
            guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
                return nil
            }
            return dict
        }

        static var accessKey: String {
            guard let key = keys?["AccessKey"] as? String else {
                return ""
            }
            return key
        }

        static var secretKey: String {
            guard let key = keys?["SecretKey"] as? String else {
                return ""
            }
            return key
        }

    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public read_user write_likes read_photos"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

