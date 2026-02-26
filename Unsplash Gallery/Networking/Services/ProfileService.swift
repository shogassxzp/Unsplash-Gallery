//
//  ProfileService.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 26.02.26.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private(set) var username: String?
    private var task: URLSessionTask?

    func fetchProfile(completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil { return }

        guard let request = makeRequest() else { return }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case let .success(profile):
                    self?.username = profile.username
                    completion(.success(profile.username))
                case let .failure(error):
                    completion(.failure(error))
                }
                self?.task = nil
            }
        }
        self.task = task
        task.resume()
    }

    private func makeRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct ProfileResult: Codable {
    let username: String
}
