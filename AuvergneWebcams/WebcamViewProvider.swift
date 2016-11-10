//
//  WebcamViewProvider.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class WebcamsViewProvider: AbstractArrayViewProvider<Webcam, WebcamCollectionViewCell>, UICollectionViewDelegateFlowLayout {

    static let cellHeight: CGFloat = 150
    static let sectionHeight: CGFloat = 50
    
    // MARK: -
    
    override func registerCells() {
        super.registerCells()
        
        let nib = UINib(nibName: WebcamSectionHeaderView.nibName(), bundle: Bundle.main)
        collectionView?.register(nib,
                                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                 withReuseIdentifier: WebcamSectionHeaderView.identifier())
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: collectionView!.frame.size.width,
                                                    height: WebcamsViewProvider.sectionHeight)
        }
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var offset: CGFloat = 0
        var width: CGFloat = 0
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            offset = flowLayout.minimumInteritemSpacing
        }
        width = ((collectionView.frame.size.width - offset) / 2)
        
        return CGSize(width: width, height: WebcamsViewProvider.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width,
                      height: WebcamsViewProvider.sectionHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let complementaryIdentifier = WebcamSectionHeaderView.identifier()
        let complementary = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                            withReuseIdentifier: complementaryIdentifier,
                                                                            for: indexPath)
        
        if let configurableComplementaryView = complementary as? WebcamSectionHeaderView, let section = section(at: indexPath.section) {
            configurableComplementaryView.configure(with: section, atIndexPath: indexPath)
        }
        
        return complementary
    }
}

