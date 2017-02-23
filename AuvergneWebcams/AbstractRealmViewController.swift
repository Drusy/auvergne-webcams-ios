//
//  AbstractRealmViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 23/02/2017.
//
//

import Foundation
import RealmSwift

class AbstractRealmViewController: AbstractViewController {
    var realm = try! Realm()
}
