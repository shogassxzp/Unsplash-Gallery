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
    private var likedIds: Set<String> = []

    @Published private(set) var photos: [PhotoResult] = []
    @Published private(set) var likedPhotos: [PhotoResult] = []

    private var lastLoadedPage: Int?
    private var lastLoadedPageLiked: Int?
    private var task: URLSessionTask?

    private init() {
        likedIds = Set(StorageManager.shared.fetchAllLikes())
    }

    // MARK: - Public Methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeRequest(page: nextPage) else { return }

        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            switch result {
            case let .success(photoResults):
                let syncedPhotos = self.syncWithLikes(photoResults)
                self.photos.append(contentsOf: syncedPhotos)
                self.lastLoadedPage = nextPage

            case let .failure(error):
                print("Ошибка загрузки ленты: \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    func makeRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fethcLikedPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }

        guard let username = ProfileService.shared.username else {
            ProfileService.shared.fetchProfile { [weak self] result in
                if case .success = result {
                    self?.fethcLikedPhotosNextPage()
                }
            }
            return
        }

        let nextPage = (lastLoadedPageLiked ?? 0) + 1
        guard let request = makeLikedRequest(username: username, page: nextPage) else { return }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case let .success(photoResults):
                    let syncedPhotos = self.syncWithLikes(photoResults)
                    self.likedPhotos.append(contentsOf: syncedPhotos)
                    self.lastLoadedPageLiked = nextPage
                case let .failure(error):
                    print("Ошибка загрузки лайков: \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }

    func resetLikedPhotos() {
        likedPhotos = []
        lastLoadedPageLiked = nil
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else { return }

        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let response = response as? HTTPURLResponse, !(200 ... 299).contains(response.statusCode) {
                    completion(.failure(NSError(domain: "LikeError", code: response.statusCode)))
                    return
                }
                self?.updatePhotoLikeStatus(photoId: photoId, isLike: isLike)
                completion(.success(()))
            }
        }
        task.resume()
    }

    private func makeLikedRequest(username: String, page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/users/\(username)/likes")
        else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"

        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    private func updatePhotoLikeStatus(photoId: String, isLike: Bool) {
        if isLike {
            likedIds.insert(photoId)
            StorageManager.shared.saveLike(id: photoId)
        } else {
            likedIds.remove(photoId)
            StorageManager.shared.removeLike(id: photoId)
        }

        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            let newPhoto = PhotoResult(
                id: photo.id,
                createdAt: photo.createdAt,
                width: photo.width,
                height: photo.height,
                description: photo.description,
                urls: photo.urls,
                likedByUser: isLike,
                user: photo.user
            )
            photos[index] = newPhoto
        }

        if !isLike {
            likedPhotos.removeAll(where: { $0.id == photoId })
        }
    }

    private func syncWithLikes(_ results: [PhotoResult]) -> [PhotoResult] {
        results.map { photo in
            let isLikedLocally = likedIds.contains(photo.id)
            return PhotoResult(
                id: photo.id,
                createdAt: photo.createdAt,
                width: photo.width,
                height: photo.height,
                description: photo.description,
                urls: photo.urls,
                likedByUser: isLikedLocally,
                user: photo.user
            )
        }
    }
}
