//
//  AbstractViewProvider.swift
//  Koboo
//
//  Created by Drusy on 07/05/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

import RealmSwift

class AbstractRealmResultsViewProvider<Item: Object, Cell: ConfigurableCell>: AbstractCollectionViewProvider<Item, Cell, Results<Item>> where Cell.Item == Item {}

class AbstractRealmListViewProvider<Item: Object, Cell: ConfigurableCell>: AbstractCollectionViewProvider<Item, Cell, List<Item>> where Cell.Item == Item {}
