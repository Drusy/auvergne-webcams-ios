//
//  CGSizeExtension.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import Foundation

extension CGSize {
    static func aspectFit(aspectRatio : CGSize, boundingSize: CGSize) -> CGSize {
        var boundingSize = boundingSize
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        
        if( mH < mW ) {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW < mH ) {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return boundingSize
    }
    
    static func aspectFill(aspectRatio :CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;
        
        if( mH > mW ) {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return minimumSize
    }
}
