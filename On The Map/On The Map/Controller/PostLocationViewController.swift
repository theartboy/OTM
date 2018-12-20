//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by John McCaffrey on 12/14/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import UIKit

class PostLocationViewController: UIViewController {
    var locationString: String!
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        tabBarController?.tabBar.isHidden = true
    }

    @IBAction func popVC(_ sender: Any) {
        OTMClient.Auth.sessionId = ""
//        navigationController?.popToRootViewController(animated: true)
//        https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
   }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
