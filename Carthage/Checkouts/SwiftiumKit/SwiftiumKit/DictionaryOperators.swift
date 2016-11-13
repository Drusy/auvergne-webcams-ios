//
//  Dictionary.swift
//  SwiftiumKit
//
//  Created by Drusy on 04/11/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

/**
 Function to concat two dictionaries of the same types using assignment by sum operator.
 If the dictionaries contain common keys, the right values will me taken.
 
 Usage example :
 ````
 var left: [Int: String] = [ 1: "String 1" ]
 let right: [Int: String] = [ 2: "String 2" ]
 
 left += right
 ````
 
 - Parameter left: a dictionary<T:V>
 - Parameter right: a dictionary<T:V>
 - Returns: a dictionary containing keys and values from left and right
 */
public func +=<K, V>(left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/**
 Function to concat two dictionaries of the same types using addition operator.
 If the dictionaries contain common keys, the right values will me taken.
 
 Usage example :
 ````
 let left: [Int: String] = [ 1: "String 1" ]
 let right: [Int: String] = [ 2: "String 2" ]
 
 let result = left + right
 ````
 
 - Parameter left: a dictionary<T:V>
 - Parameter right: a dictionary<T:V>
 - Returns: a dictionary containing keys and values from left and right
 */
public func +<K, V>(left: [K: V], right: [K: V]) -> Dictionary<K, V> {
    var map = Dictionary<K, V>()
    
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    
    return map
}
