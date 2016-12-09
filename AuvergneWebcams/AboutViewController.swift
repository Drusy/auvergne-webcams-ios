//
//  AboutViewController.swift
//  filesdnd
//
//  Created by Drusy on 06/11/2016.
//  Copyright © 2016 Files Drag & Drop. All rights reserved.
//

import UIKit
import ActiveLabel
import SafariServices

class AboutViewController: AbstractViewController {

    @IBOutlet var activeDescriptionLabel: ActiveLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activeDescriptionLabel.customize { label in
            label.enabledTypes = [.url, .mention]

            // Mention
            label.mentionColor = UIColor(rgb: 0x7a1f1f)
            label.handleMentionTap{ [weak self] mention in
                var url: URL?
                
                if mention.contains("Openium") {
                    url = URL(string : "https://openium.fr")
                } else if mention.contains("Drusy") {
                    url = URL(string : "https://github.com/Drusy")
                } else if mention.contains("LesPirates") {
                    url = URL(string : "http://agencelespirates.com/")
                } else if mention.contains("FlatIcons") {
                    url = URL(string : "http://www.flaticon.com")
                } else if mention.contains("Freepik") {
                    url = URL(string : "http://www.freepik.com")
                }
                
                if let url = url {
                    let svc = SFSafariViewController(url: url)
                    self?.present(svc, animated: true, completion: nil)
                }
            }
            
            // Urls
            label.URLColor = UIColor(rgb: 0x1f517a)
            label.handleURLTap { [weak self] url in
                let svc = SFSafariViewController(url: url)
                self?.present(svc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: -
    
    override func translate() {
        title = "À Propos"
    }
}
