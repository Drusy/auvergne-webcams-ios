//
//  CollectionExtensions.swift
//  AuvergneWebcams
//
//  Created by Drusy on 10/03/2017.
//
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
