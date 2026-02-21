//
//  FeedCollectionExtension.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 21.02.26.
//

import UIKit

extension FeedCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20 // make computed property
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}
