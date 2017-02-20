//
//  AbstractEnumeratableViewProvider.swift
//  Koboo
//
//  Created by Richard Bergoin on 27/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

class AbstractCollectionViewProvider<Item: Any, Cell: ConfigurableCell, Enumerator: Collection>: AbstractViewProvider<Item, Cell>
where Cell.Item == Item, Enumerator.Iterator.Element == Item, Enumerator.Index == Int, Enumerator.IndexDistance == Int {
    
    var objects: Enumerator? {
        didSet {
            tableView?.reloadData()
            collectionView?.reloadData()
        }
    }
    
    override func numberOfObjects(in section: Int)  -> Int {
        if let objects = self.objects {
            return objects.count
        } else {
            return 0
        }
    }
    
    override func object(at indexPath: IndexPath) -> Item {
        let item = objects![(indexPath as NSIndexPath).row]
        return item
    }
    
}
