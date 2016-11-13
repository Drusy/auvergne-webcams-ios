//
//  SettingsViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 13/11/2016.
//
//

import UIKit
import Eureka
import SafariServices
import SwiftyUserDefaults

enum SettingTag: String {
    case theme
    case autoRefresh
    case autoRefreshDelay
    case about
    case openium
    case rateApp
}

class SettingsViewController: FormViewController {
    
    private var foregroundNotification: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        
        setupForm()
        style()
        translate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let navigationController = navigationController {
            let inset = UIApplication.shared.statusBarFrame.height + navigationController.navigationBar.frame.height
            
            tableView?.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        }
    }
    
    // MARK: - Form
    
    func setupForm() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        form
            +++ Section("General")
            <<< SwitchRow(SettingTag.theme.rawValue) {
                $0.title = "Thème sombre"
                $0.value = true
            }.cellSetup { cell, row in
                cell.backgroundColor = UIColor.clear
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.lightGray
            }.onChange { _ in
            }
            <<< SwitchRow(SettingTag.autoRefresh.rawValue) {
                    $0.title = "Rafraîchissement automatique"
            }.cellSetup { cell, row in
                cell.backgroundColor = UIColor.clear
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.lightGray
            }.onChange { _ in
            }
            <<< IntRow(SettingTag.autoRefreshDelay.rawValue) {
                $0.title = "Délai de rafraîchissement (minutes)"
                $0.value = 10
                $0.hidden = Condition.function([SettingTag.autoRefresh.rawValue], { form in
                    return !((form.rowBy(tag: SettingTag.autoRefresh.rawValue) as? SwitchRow)?.value ?? false)
                })
            }.cellSetup { cell, row in
                cell.backgroundColor = UIColor.clear
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.numberOfLines = 2
                cell.textField.textColor = UIColor.white
            }.onChange { _ in
            }
            
            +++ Section(header: "Auvergne Webcams", footer: "Version \(version) (\(build))")
            <<< LabelRow() {
                $0.title = "À propos"
            }.cellSetup { cell, row in
                cell.backgroundColor = UIColor.clear
                cell.accessoryType = .disclosureIndicator
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.lightGray
            }.onCellSelection { _, _ in
                self.showAbout()
            }
            <<< LabelRow() {
                $0.title = "Openium"
                }.cellSetup { cell, row in
                    cell.backgroundColor = UIColor.clear
                    cell.accessoryType = .disclosureIndicator
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.lightGray
                }.onCellSelection { _, _ in
                    self.showOpeniumWebsite()
            }
            <<< LabelRow() {
                $0.title = "Noter l'application"
            }.cellSetup { cell, row in
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = UIColor.clear
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.lightGray
            }.onCellSelection { _, _ in
                self.rateApp()
            }
    }
    
    // MARK: -
    
    func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/xxxxxxx") else { return }
        UIApplication.shared.openURL(url)
    }
    
    func showOpeniumWebsite() {
        guard let url = URL(string : "http://openium.fr") else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    func showAbout() {
        let avc = AboutViewController()
        navigationController?.pushViewController(avc, animated: true)
    }
    
    func translate() {
        navigationItem.title = "Paramètres"
    }
    
    func style() {
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor.clear
        tableView?.tintColor = UIColor.white
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
}

