//
//  ViewController.swift
//  Custom Modal View
//
//  Created by Maximo Hinojosa on 10/26/20.
//

import UIKit

class CardViewController: UIViewController {

    
    @IBOutlet weak var barView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barView?.layer.cornerRadius = barView.frame.height / 2
    }

    
  

}
