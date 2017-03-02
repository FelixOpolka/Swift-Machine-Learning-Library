//
//  EnterDigitsViewController.swift
//  DigitRecognition
//
//  Created by Felix Opolka on 28.02.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import UIKit

class EnterDigitsViewController: UIViewController {
    @IBOutlet weak var digitDrawingView: DrawingView!
    enum EdgePosition {
        case Top
        case Bottom
        case Left
        case Right
    }
    enum Orientation {
        case Horizontal
        case Vertical
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearDrawingView))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearDrawingView() {
        digitDrawingView.clearImage()
    }
    
    @IBAction func digitButtonPressed(_ sender: UIButton) {
        let image = digitDrawingView.getImage()!
        let croppedImage = image.cropToMinimumBoundingBox()!
        let resizedImage = croppedImage.resizeToSquare(withLength: 28.0)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
