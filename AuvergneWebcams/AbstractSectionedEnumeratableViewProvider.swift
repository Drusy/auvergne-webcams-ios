//
//  AbstractSectionedEnumeratableViewProvider.swift
//  AuvergneWebcams
//
//  Created by Richard Bergoin on 24/11/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

protocol ConfigurableSectionView {
    associatedtype Section
    
    static func identifier() -> String
    static func nibName() -> String
    
    func configure(with section: Section)
}

extension ConfigurableSectionView {
    static func nibName() -> String { return identifier() }
}

let kTableViewHeaderKind = "TableViewHeaderKind"
let kTableViewFooterKind = "TableViewFooterKind"

class AbstractConfigurableSectionViewProvider<Section: Any>  {
    func configuredSupplementaryViewOfKind(_ kind: String, inView tableOrCollectionView: UIView, ofSection: Section, at indexPath: IndexPath) -> UIView? {
        fatalError("")
    }
    
    func registerTableHeaderFooterView(tableView: UITableView) {
        fatalError("")
    }
    
    func registerSupplementaryViewOfKind(_ kind: String, inCollectionView collectionView: UICollectionView) {
        fatalError("")
    }
}

class ConfigurableSectionViewProvider<Section: Any, SectionView: ConfigurableSectionView>: AbstractConfigurableSectionViewProvider<Section>
where SectionView.Section == Section {
    
    override func configuredSupplementaryViewOfKind(_ kind: String, inView tableOrCollectionView: UIView, ofSection: Section, at indexPath: IndexPath) -> UIView? {
        var configuredSupplementaryView: UIView?
        let identifier = SectionView.identifier()
        
        if let tableView = tableOrCollectionView as? UITableView {
            configuredSupplementaryView = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        } else if let collectionView = tableOrCollectionView as? UICollectionView {
            configuredSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                          withReuseIdentifier: identifier,
                                                                                          for: indexPath)
        } else {
            fatalError("called with a \(String(describing: tableOrCollectionView)), while expecting UITableView or UICollectionView")
        }
        
        if let configuredSupplementaryView = configuredSupplementaryView as! SectionView? {
            configuredSupplementaryView.configure(with: ofSection)
        }
        
        return configuredSupplementaryView
    }
    
    override func registerTableHeaderFooterView(tableView: UITableView) {
        let nib = UINib(nibName: SectionView.nibName(), bundle: Bundle.main)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: SectionView.identifier())
    }

    override func registerSupplementaryViewOfKind(_ kind: String, inCollectionView collectionView: UICollectionView) {
        let nib = UINib(nibName: SectionView.nibName(), bundle: Bundle.main)
        collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: SectionView.identifier())
    }
}

class AbstractSectionedEnumeratableViewProvider<Section: Hashable, Item: Any, Cell: ConfigurableCell, Enumerator: Collection>: AbstractViewProvider<Item, Cell>
where Cell.Item == Item, Enumerator.Iterator.Element == Item, Enumerator.Index == Int {
    
    typealias SupplementaryViewKind = String
    
    fileprivate var sections: [Section]?
    fileprivate var displaybleSections = [Section]()
    fileprivate var objectsBySections: [Section: Enumerator]?
    
    private var supplementaryViewProviders = [SupplementaryViewKind: AbstractConfigurableSectionViewProvider<Section>]()
    
    
    var headerViewProvider: AbstractConfigurableSectionViewProvider<Section>? {
        didSet {
            headerViewProvider?.registerTableHeaderFooterView(tableView: tableView!)
        }
    }
    var footerViewProvider: AbstractConfigurableSectionViewProvider<Section>? {
        didSet {
            footerViewProvider?.registerTableHeaderFooterView(tableView: tableView!)
        }
    }
    var hideEmptySections: Bool = true
    
    
    // MARK: -
    
    func addSupplementaryViewProvider(_ supplementaryViewProvider: AbstractConfigurableSectionViewProvider<Section>, for kind: SupplementaryViewKind) {
        supplementaryViewProviders[kind] = supplementaryViewProvider
        supplementaryViewProvider.registerSupplementaryViewOfKind(kind, inCollectionView: collectionView!)
    }
    
    func set(objectsBySections: [Section: Enumerator], forSections sections: [Section]) {
        if objectsBySections.count != sections.count {
            preconditionFailure("Number of enumerators should be equal to numbers of sections")
        }
        
        self.sections = sections
        self.objectsBySections = objectsBySections
        
        displaybleSections.removeAll()
        if hideEmptySections {
            for section in sections {
                if let objects = objectsBySections[section] {
                    if objects.count > 0 {
                        displaybleSections.append(section)
                    }
                }
            }
        } else {
            displaybleSections = sections
        }
        
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    func section(at index: Int) -> Section {
        return displaybleSections[index]
    }
    
    // MARK: - Override
    
    override func manageEmptyView(_ visibleElements: Int) {
        super.manageEmptyView(displaybleSections.count)
    }
    
    override func numberOfObjects(in section: Int)  -> Int {
        var numberOfObjects = 0
        let sectionObj = displaybleSections[section]
        if let objects = objectsBySections?[sectionObj] {
            numberOfObjects = objects.count
        }
        return numberOfObjects
    }
    
    override func numberOfSections() -> Int {
        manageEmptyView(displaybleSections.count)
        return displaybleSections.count
    }
    
    override func object(at indexPath: IndexPath) -> Item {
        let section = displaybleSections[indexPath.section]
        guard let objects: Enumerator = objectsBySections?[section] else { fatalError("can't get object at indexPath \(indexPath)") }
        return objects[indexPath.row]
    }
    
    // MARK: - TableView header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: 0, section: section)
        let section = self.section(at: section)
        return headerViewProvider?.configuredSupplementaryViewOfKind(kTableViewHeaderKind, inView: tableView, ofSection: section, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    // MARK: - TableView footer
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: 0, section: section)
        let section = self.section(at: section)
        return footerViewProvider?.configuredSupplementaryViewOfKind(kTableViewFooterKind, inView: tableView, ofSection: section, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.sectionFooterHeight
    }
}
