//
//  WebcamSectionViewProvider.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

protocol WebcamSectionViewProviderDelegate: class {
    func webcamSection(viewProvider: WebcamSectionViewProvider, scrollViewDidScroll scrollView: UIScrollView)
}

class WebcamSectionViewProvider: AbstractArrayViewProvider<Webcam, WebcamCollectionViewCell>, UICollectionViewDelegateFlowLayout {
    
    var section: WebcamSection?
    
    weak var delegate: WebcamSectionViewProviderDelegate?
    
    static var cellHeight: CGFloat {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 250
            } else {
                return 200
            }
        }
    }
    static let sectionHeight: CGFloat = 100
    
    // MARK: -
    
    override func registerCells() {
        super.registerCells()
        
        let identifier = WebcamSectionHeaderView.identifier()
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        collectionView?.register(nib,
                                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                 withReuseIdentifier: identifier)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: collectionView!.frame.size.width,
                                                    height: WebcamSectionViewProvider.sectionHeight)
        }
    }
    
    // MARK: - CollectionViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webcamSection(viewProvider: self, scrollViewDidScroll: scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var offset: CGFloat = 0
        var width: CGFloat = 0
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            offset = flowLayout.minimumInteritemSpacing
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = ((collectionView.frame.size.width - offset) / 2)
        } else {
            width = collectionView.frame.size.width * 0.8
        }
        
        return CGSize(width: width, height: WebcamSectionViewProvider.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.section == nil {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.frame.size.width,
                          height: WebcamSectionViewProvider.sectionHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let complementaryIdentifier = WebcamSectionHeaderView.identifier()
        let complementary = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                            withReuseIdentifier: complementaryIdentifier,
                                                                            for: indexPath)
        
        if let configurableComplementaryView = complementary as? WebcamSectionHeaderView, let section = section {
            configurableComplementaryView.configure(withSection: section)
        }
        
        return complementary
    }
}
