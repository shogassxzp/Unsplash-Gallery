//
//  ImageListService.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 25.02.26.
//

import Combine
import Foundation

final class ImageListService {
    static let shared = ImageListService()
    
    // MARK: - Publishers
    @Published private(set) var photos: [PhotoResult] = []
    @Published private(set) var likedPhotos: [PhotoResult] = []
    
    // MARK: - Dependencies (Injectable)
        var urlSession = URLSession.shared
        var tokenStorage = OAuth2TokenStorage.shared
        var storageManager = StorageManager.shared
        
        // MARK: - Private Properties
        private var likedIds: Set<String> = []
        private var lastLoadedPage: Int?
        private var lastLoadedPageLiked: Int?
        private var task: URLSessionTask?
        
        private let baseURL = "https://api.unsplash.com"

        private init() {
            self.likedIds = Set(storageManager.fetchAllLikes())
        }

    // MARK: - Public Methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        let queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "30")
        ]

        guard let request = makeRequest(path: "/photos", queryItems: queryItems) else { return }

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(photoResults):
                    let synced = self.syncWithLikes(photoResults)
                    self.photos.append(contentsOf: synced)
                    self.lastLoadedPage = nextPage
                case let .failure(error):
                    print("[fetchPhotos]: \(error.localizedDescription)")
                }
                self.task = nil
            }
        }
        task?.resume()
    }

    func fetchLikedPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }

        guard let username = ProfileService.shared.username else {
            ProfileService.shared.fetchProfile { [weak self] _ in self?.fetchLikedPhotosNextPage() }
            return
        }

        let nextPage = (lastLoadedPageLiked ?? 0) + 1
        let queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "30")
        ]

        guard let request = makeRequest(path: "/users/\(username)/likes", queryItems: queryItems) else { return }

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(photoResults):
                    let synced = self.syncWithLikes(photoResults)
                    self.likedPhotos.append(contentsOf: synced)
                    self.lastLoadedPageLiked = nextPage
                case let .failure(error):
                    print("[fetchLikedPhotos]: \(error.localizedDescription)")
                }
                self.task = nil
            }
        }
        task?.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let method = isLike ? "POST" : "DELETE"
        guard let request = makeRequest(path: "/photos/\(photoId)/like", httpMethod: method) else { return }

        let task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    completion(.failure(NSError(domain: "LikeError", code: response.statusCode)))
                    return
                }

                self?.updatePhotoLikeStatus(photoId: photoId, isLike: isLike)
                completion(.success(()))
            }
        }
        task.resume()
    }

    func resetLikedPhotos() {
        likedPhotos = []
        lastLoadedPageLiked = nil
    }

    // MARK: - Private Methods

    private func makeRequest(
        path: String,
        httpMethod: String = "GET",
        queryItems: [URLQueryItem]? = nil
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL + path) else { return nil }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        guard let token = tokenStorage.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }

    private func updatePhotoLikeStatus(photoId: String, isLike: Bool) {
        if isLike {
            likedIds.insert(photoId)
            storageManager.saveLike(id: photoId)
        } else {
            likedIds.remove(photoId)
            storageManager.removeLike(id: photoId)
        }

        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            photos[index] = PhotoResult(
                id: photo.id, createdAt: photo.createdAt, width: photo.width,
                height: photo.height, description: photo.description,
                urls: photo.urls, likedByUser: isLike, user: photo.user
            )
        }

        if !isLike {
            likedPhotos.removeAll(where: { $0.id == photoId })
        }
    }

    private func syncWithLikes(_ results: [PhotoResult]) -> [PhotoResult] {
        results.map { photo in
            let isLikedLocally = likedIds.contains(photo.id)
            return PhotoResult(
                id: photo.id, createdAt: photo.createdAt, width: photo.width,
                height: photo.height, description: photo.description,
                urls: photo.urls, likedByUser: isLikedLocally, user: photo.user
            )
        }
    }
}
