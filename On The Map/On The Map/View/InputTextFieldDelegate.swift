//
//  InputTextFieldDelegate.swift
//  On The Map
//
//  Created by John McCaffrey on 12/21/18.
//  Copyright © 2018 John McCaffrey. All rights reserved.
//

import Foundation
import UIKit


class InputTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
