//
//  SearchViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 20/02/2017.
//
//

import UIKit

class SearchViewController: AbstractRealmViewController {

    @IBOutlet var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var clearSearchButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchLabel: UILabel!
    @IBOutlet var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }

    lazy var provider: WebcamSectionViewProvider = {
        let provider = WebcamSectionViewProvider(collectionView: self.collectionView)
        provider.delegate = self
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        provider.itemSelectionHandler = { [weak self] webcam, indexPath in
            let webcamDetail = WebcamDetailViewController(webcam: webcam)
            self?.navigationController?.pushViewController(webcamDetail, animated: true)
        }
        
        searchTextField.becomeFirstResponder()
        search(text: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationController = navigationController {
            var height = navigationController.navigationBar.bounds.height
            
            if !UIApplication.shared.isStatusBarHidden {
                height += UIApplication.shared.statusBarFrame.height
            }
            
            searchViewTopConstraint.constant = height
        }
    }
    
    // MARK: - 
    
    override func translate() {
        super.translate()
        
        title = "Rechercher"
        searchTextField.attributedPlaceholder = "Rechercher une webcam"
            .withFont(UIFont.proximaNovaLightItalic(withSize: 16))
            .withTextColor(UIColor.awLightGray)
    }
    
    func search(text: String?) {
        
        if let searchText = text, !searchText.isEmpty {
            clearSearchButton.isHidden = false
            
            let webcams = Array(realm.objects(Webcam.self).filter("%K = false", #keyPath(Webcam.isHidden)).sorted(byKeyPath: #keyPath(Webcam.title), ascending: true))
            let searchResult = webcams.filter { webcam in
                let title = webcam.title ?? ""
                let tags = webcam.tags.filter { (webcamTag: WebcamTag) -> Bool in
                    return webcamTag.tag.localizedCaseInsensitiveContains(searchText)
                }
                
                if !tags.isEmpty {
                    return true
                }
                
                return title.localizedCaseInsensitiveContains(searchText)
            }
            
            provider.objects = searchResult
            
            var label: String
            if searchResult.isEmpty {
                label = "Aucun résultat pour "
            } else if searchResult.count == 1 {
                label = "1 résultat pour "
            } else {
                label = "\(searchResult.count) résultats pour "
            }
            
            let attributedResultText = label
                .withFont(UIFont.proximaNovaRegular(withSize: 16))
                .withTextColor(UIColor.white)
            let attributedSearchText = searchText
                .withFont(UIFont.proximaNovaSemiBoldItalic(withSize: 16))
                .withTextColor(UIColor.awBlue)
            
            searchLabel.attributedText = attributedResultText + attributedSearchText
        } else {
            provider.objects = []
            searchLabel.text = nil
            clearSearchButton.isHidden = true
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onEditingDidBegin(_ sender: Any) {        
        clearSearchButton.isHidden = false
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
        guard let text = searchTextField.text, !text.isEmpty else { return }
        
        AnalyticsManager.logEvent(searchText: text)
    }
    
    @IBAction func onSearchEditingChanged(_ sender: Any) {
        guard let searchText = searchTextField.text else { return }
        
        search(text: searchText)
    }
    
    @IBAction func onClearSearchTouched(_ sender: Any) {
        searchTextField.text = nil
        searchTextField.resignFirstResponder()
        
        clearSearchButton.isHidden = true
        
        search(text: nil)
    }
}

// MARK: - WebcamCarouselViewProviderDelegate

extension SearchViewController: WebcamSectionViewProviderDelegate {
    func webcamSection(viewProvider: WebcamSectionViewProvider, scrollViewDidScroll scrollView: UIScrollView) {
        if searchTextField.isEditing {
            searchTextField.endEditing(true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchText = textField.text else { return true }
        
        textField.resignFirstResponder()
        search(text: searchText)
        
        return true
    }
}
