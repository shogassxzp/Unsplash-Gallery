//
//  ViewModelProtocol.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 8.03.26.
//

import Foundation

protocol PhotoFeedViewModelProtocol: AnyObject {
    var photosCount: Int { get }
    func photo(at index: Int) -> PhotoResult?
    func fetchNextPage()
    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void)
}
