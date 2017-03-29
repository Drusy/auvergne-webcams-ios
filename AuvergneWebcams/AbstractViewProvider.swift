//
//  AbstractViewProviders.swift
//  AuvergneWebcams
//
//  Created by Richard Bergoin on 26/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

protocol ConfigurableCell {
    associatedtype Item
    
    static func identifier() -> String
    static func nibName() -> String
    
    func configure(with item: Item)
}

extension ConfigurableCell {
    static func nibName() -> String { return identifier() }
}

/*
 
 
 Subclass to use with Realm Results objects :
 ````
    class AbstractRealmViewProvider<Item: Object, Cell: ConfigurableCell>: AbstractCollectionViewProvider<Item, Cell, Results<Item>> where Cell.Item == Item {}
 ````

 */
class AbstractViewProvider<Item: Any, Cell: ConfigurableCell>: NSObject, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate where Cell.Item == Item {
 
    typealias ItemSelectionHandler = (_ item: Item, _ indexPath: IndexPath) -> Void
    
    var emptyView: UIView? {
        didSet {
            emptyView?.removeFromSuperview()
        }
    }
    var tableView: UITableView?
    var collectionView: UICollectionView?
    var itemSelectionHandler: ItemSelectionHandler?
    var additionalCellConfigurationCustomizer: ((_ cell: Cell, _ item: Item) -> Void)?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        registerCells()
    }
    
    convenience init(tableView: UITableView, emptyView: UIView) {
        self.init(tableView: tableView)
        self.emptyView = emptyView
    }
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        super.init()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        registerCells()
    }
    
    convenience init(collectionView: UICollectionView, emptyView: UIView) {
        self.init(collectionView: collectionView)
        self.emptyView = emptyView
    }
    
    // MARK: to be overrided
    
    func numberOfSections() -> Int {
        return 1
    }

    func numberOfObjects(in section: Int)  -> Int {
        fatalError("numberOfObjectsInSection must be overrided")
    }
    
    func object(at indexPath: IndexPath) -> Item {
        fatalError("objectAtIndexPath must be overrided")
    }
    
    // MARK: - Overridable
    
    func registerCells() {
        let nib = UINib(nibName: Cell.nibName(), bundle: Bundle.main)
        
        self.collectionView?.register(nib, forCellWithReuseIdentifier: Cell.identifier())
        self.tableView?.register(nib, forCellReuseIdentifier: Cell.identifier())
    }
    
    func identifier(_ indexPath: IndexPath) -> String? {
        return nil
    }
    
    // MARK: Empty view management
    
    func showEmptyView() {
        guard let emptyView = emptyView else { return }
        guard let scrollView = collectionView ?? tableView else { return }
        
        if emptyView.superview == nil {
            if let parentView = scrollView.superview {
                
                parentView.addSubview(emptyView)
                parentView.bringSubview(toFront: emptyView)
                
                emptyView.translatesAutoresizingMaskIntoConstraints = false
                
                let topConstraint = NSLayoutConstraint(
                    item: emptyView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: scrollView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0)
                let leadingContraint = NSLayoutConstraint(
                    item: emptyView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: scrollView,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0)
                let bottomConstraint = NSLayoutConstraint(
                    item: emptyView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: scrollView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0)
                let trailingConstraint = NSLayoutConstraint(
                    item: emptyView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: scrollView,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0)
                
                NSLayoutConstraint.activate([topConstraint,
                                             leadingContraint,
                                             bottomConstraint,
                                             trailingConstraint])
            }
        }
        
        emptyView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        emptyView.isHidden = false
    }
    
    func hideEmptyView() {
        if let emptyView = emptyView {
            if emptyView.superview == tableView || emptyView.superview == collectionView {
                emptyView.removeFromSuperview()
            }
            emptyView.isHidden = true
        }
    }
    
    func manageEmptyView(_ visibleElements: Int) {
        if visibleElements == 0 {
            showEmptyView()
        } else {
            hideEmptyView()
        }
    }
    
    // MARK: -
    
    func configure(cell: Cell, item: Item) {
        cell.configure(with: item)
        if let additionalCellConfigurationCustomizer = additionalCellConfigurationCustomizer {
            additionalCellConfigurationCustomizer(cell, item)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = numberOfObjects(in: section)
        manageEmptyView(count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = identifier(indexPath) ?? Cell.identifier()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let item = object(at: indexPath)
        configure(cell: cell as! Cell, item: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = object(at: indexPath)
        itemSelectionHandler?(item, indexPath)
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfObjects(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = identifier(indexPath) ?? Cell.identifier()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        let item = object(at: indexPath)
        configure(cell: cell as! Cell, item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = object(at: indexPath)
        itemSelectionHandler?(item, indexPath)
    }
}
