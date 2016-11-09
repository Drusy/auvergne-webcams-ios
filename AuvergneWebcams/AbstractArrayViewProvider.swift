//
//  AbstractViewProvider.swift
//  UPA
//
//  Created by Drusy on 07/05/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

class AbstractArrayViewProvider<Item: Any, Cell: ConfigurableCell>: AbstractEnumeratableViewProvider<Item, Cell, Array<Item>> where Cell.Item == Item {}
