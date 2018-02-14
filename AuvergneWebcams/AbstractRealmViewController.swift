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
    lazy var realm: Realm = {
        return try! Realm()
    }()
}
