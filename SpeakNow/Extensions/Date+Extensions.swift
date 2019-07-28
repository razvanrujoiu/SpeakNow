//
//  Date+Extensions.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 28/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import UIKit

extension Date
{
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

