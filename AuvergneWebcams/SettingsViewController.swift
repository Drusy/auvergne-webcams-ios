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
import MessageUI

enum SettingTag: String {
    case theme
    case autoRefresh
    case autoRefreshDelay
    case about
    case openium
    case rateApp
    case quality
}

class SettingsViewController: FormViewController {
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-icon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))

        setupForm()
        style()
        translate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    // MARK: - Form
    
    func setupForm() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        form =
            Section("Général")
            <<< SwitchRow(SettingTag.autoRefresh.rawValue) {
                $0.title = "Rafraîchissement automatique"
                $0.value = Defaults[\.shouldAutorefresh]
            }.onChange { row in
                Defaults[\.shouldAutorefresh] = row.value ?? false
                NotificationCenter.default.post(name: NSNotification.Name.SettingsDidUpdateAutorefresh,
                                                object: self)
            }
            <<< IntRow(SettingTag.autoRefreshDelay.rawValue) {
                $0.title = "Délai de rafraîchissement (minutes)"
                $0.value = Int(Defaults[\.autorefreshInterval] / 60)
                $0.hidden = Condition.function([SettingTag.autoRefresh.rawValue], { form in
                    return !((form.rowBy(tag: SettingTag.autoRefresh.rawValue) as? SwitchRow)?.value ?? false)
                })
                $0.validationOptions = .validatesOnDemand
                $0.add(rule: RuleGreaterOrEqualThan(min: 1))
                $0.add(rule: RuleSmallerOrEqualThan(max: 120))
                $0.add(rule: RuleRequired())
            }.cellSetup { cell, row in
            }.cellUpdate { cell, row in

            }.onChange { row in
                
            }.onCellHighlightChanged { cell, row in
                row.validate()
                
                if row.isValid {
                    Defaults[\.autorefreshInterval] = Double(row.value ?? 0) * 60
                } else {
                    let message = "Le délai de rafraîchissement doit être suppérieur à 0 et inférieur à 120"
                    let alertController = UIAlertController(title: "Erreur",
                                                            message: message,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .cancel,
                                                 handler: nil)
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    row.value = Int(Defaults[\.autorefreshInterval] / 60)
                    row.updateCell()
                }
            }
            <<< SwitchRow(SettingTag.quality.rawValue) {
                $0.title = "Haute qualité"
                $0.value = Defaults[\.prefersHighQuality]
                }.onChange { row in
                    Defaults[\.prefersHighQuality] = row.value ?? false
                    NotificationCenter.default.post(name: NSNotification.Name.SettingsDidUpdateQuality,
                                                    object: self)
            }

            +++ Section(header: Configuration.applicationName, footer: "Version \(version) (\(build))")
            <<< LabelRow() {
                $0.title = "À propos"
            }.onCellSelection { _, _ in
                self.showAbout()
            }
            <<< LabelRow() {
                $0.title = "Openium"
            }.onCellSelection { _, _ in
                self.showOpeniumWebsite()
            }
            <<< LabelRow() {
                $0.title = "Les Pirates"
            }.onCellSelection { _, _ in
                self.showLesPiratesWebsite()
            }
            <<< LabelRow() {
                $0.title = "Proposer une webcam"
                }.onCellSelection { _, _ in
                    self.proposeYourWebcams()
            }
            <<< LabelRow() {
                $0.title = "Noter l'application"
            }.onCellSelection { _, _ in
                self.rateApp()
            }
    }
    
    // MARK: -
    
    func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id1183930829") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        AnalyticsManager.logEvent(button: "rate_app")
    }
    
    func showLesPiratesWebsite() {
        guard let url = URL(string : "http://agencelespirates.com") else { return }
        let svc = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = UIColor.awDarkGray
            svc.preferredControlTintColor = UIColor.white
        }
        present(svc, animated: true, completion: nil)
        AnalyticsManager.logEvent(button: "website_lespirates")
    }
    
    func showOpeniumWebsite() {
        guard let url = URL(string : "https://openium.fr") else { return }
        let svc = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = UIColor.awDarkGray
            svc.preferredControlTintColor = UIColor.white
        }
        present(svc, animated: true, completion: nil)
        AnalyticsManager.logEvent(button: "website_openium")
    }
    
    func showAbout() {
        let avc = AboutViewController()
        navigationController?.pushViewController(avc, animated: true)
        AnalyticsManager.logEvent(button: "about")
    }
    
    func proposeYourWebcams() {
        let alertTitle = "Nouvelle webcam"
        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: alertTitle,
                                                    message: "Aucun compte email n'est configuré",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil)
            
            alertController.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
            
            return
        }
        
        let mailHandler: () -> Void = {
            let mailComposerVC = MailComposeViewController()
            let attributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.proximaNovaSemiBold(withSize: 17)
            ]
            
            mailComposerVC.navigationBar.titleTextAttributes = attributes
            mailComposerVC.navigationBar.barStyle = .black
            mailComposerVC.navigationBar.isTranslucent = true
            mailComposerVC.navigationBar.tintColor = UIColor.white
            mailComposerVC.navigationBar.barTintColor = UIColor.black
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([Configuration.contactEmail])
            mailComposerVC.setSubject("Proposition de webcam")
            mailComposerVC.setMessageBody("J'ai connaissance d'une webcam non disponible dans l'application.\n\nNom du lieu:\nLien vers la webcam:",
                isHTML: false)
            
            DispatchQueue.main.async {
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }
        
        let alertController = UIAlertController(title: alertTitle,
                                                message: "Afin de proposer une webcam, veuillez vous munir du nom du lieu proposé ainsi que du lien vers la webcam en question.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            mailHandler()
        }
        
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        AnalyticsManager.logEvent(button: "propose_webcam")
    }
    
    func translate() {
        navigationItem.title = "Paramètres"
    }
    
    func style() {
        let tintColor: UIColor = UIColor.white
        
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = UIColor.clear
        tableView?.tintColor = tintColor
        
        IntRow.defaultCellUpdate = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = tintColor
            cell.textField.textColor = tintColor
            cell.accessoryType = .disclosureIndicator
        }
        
        LabelRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
        }
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = tintColor
            cell.accessoryType = .disclosureIndicator
        }
        
        SwitchRow.defaultCellSetup = { cell, row in
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
        }
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.switchControl?.tintColor = tintColor
            cell.switchControl?.onTintColor = UIColor.awBlue
            cell.textLabel?.textColor = tintColor
        }
        
        setupForm()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareDisclosureIndicator()
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            let alertController = UIAlertController(title: "Merci !",
                                                    message: "Nous vous tiendrons au courant rapidement concernant l'ajout de cette nouvelle webcam",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}
