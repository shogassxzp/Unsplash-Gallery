//
//  ProfileService.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 26.02.26.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    // MARK: - Dependencies
    var urlSession = URLSession.shared
    var tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Private Properties
    private(set) var username: String?
    private var task: URLSessionTask?
    
    private init() {}

    // MARK: - Public Methods
    func fetchProfile(completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil { return }

        guard let request = makeRequest() else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = self.urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(profile):
                    self.username = profile.username
                    completion(.success(profile.username))
                case let .failure(error):
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }

    // MARK: - Private Methods
    private func makeRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        
        guard let token = tokenStorage.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct ProfileResult: Codable {
    let username: String
}
