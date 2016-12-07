//
//  AbstractEnumeratableViewProvider.swift
//  MyRallyEnginneer
//
//  Created by Richard Bergoin on 27/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

class AbstractEnumeratableViewProvider<Item: Any, Cell: ConfigurableCell, Enumerator: Collection>: AbstractViewProvider<Item, Cell>
where Cell.Item == Item, Enumerator.Iterator.Element == Item, Enumerator.Index == Int, Enumerator.IndexDistance == Int {
    
    fileprivate var sections: [WebcamSection]?
    fileprivate var objectsBySections: [Enumerator]?
    
    // MARK: -
    
    func set(objects: [Enumerator], forSections sections: [WebcamSection]) {
        if objects.count != sections.count {
            preconditionFailure("Number of enumerators should be equal to numbers of sections")
        }
        
        self.sections = sections
        self.objectsBySections = objects
        
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    func section(at index: Int) -> WebcamSection? {
        guard let sections = sections else { return nil}
        return sections[index]
    }
    
    // MARK: - Override
    
    override func numberOfObjects(in section: Int)  -> Int {
        guard let objects = objectsBySections?[section] else { return 0}
        return objects.count
    }
    
    override func numberOfSections() -> Int {
        return sections?.count ?? 0
    }
    
    override func object(at indexPath: IndexPath) -> Item? {
        guard let objects: Enumerator = objectsBySections?[indexPath.section] else { return nil }
        return objects[indexPath.row]
    }
}
