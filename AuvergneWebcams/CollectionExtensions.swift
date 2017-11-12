//
//  CollectionExtensions.swift
//  AuvergneWebcams
//
//  Created by Drusy on 10/03/2017.
//
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
