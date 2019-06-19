//
//  PresentedController+Setup.swift
//  WeakSelf
//
//  Created by Besher on 2019-06-12.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

// MARK: - Setup and preparation
extension PresentedController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateImages()
    }
    
    func setup(scenario: LeakScenario) {
        let button = CustomButton()
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        self.printingButton = button
        
        switch scenario {
        case .leakyButton: setupLeakyButton()
        case .nonLeakyButton: setupNonLeakyButton()
        case .higherOrderFunctions: higherOrderFunctions()
        case .uiViewAnimate: uiViewAnimate()
        case .leakyViewPropertyAnimator: leakyViewPropertyAnimator()
        case .nonLeakyViewPropertyAnimator1: nonLeakyViewPropertyAnimator1()
        case .nonLeakyViewPropertyAnimator2: nonLeakyViewPropertyAnimator2()
        case .leakyDispatchQueue: leakyDispatchQueue()
        case .nonLeakyDispatchQueue: nonLeakyDispatchQueue()
        case .leakyTimer: leakyTimer()
        case .leakyAsyncCall: leakyAsyncCall()
        case .delayedAllocAsyncCall: delayedAllocAsyncCall()
        case .delayedAllocSemaphore: delayedAllocSemaphore()
        case .savedClosure: savedClosure()
        case .unsavedClosure: unsavedClosure()
        }
    }
    
    // called by parent when we tap Done
    func back(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func generateImages() {
        navigationItem.leftBarButtonItem?.isEnabled = false
        let spinner = SpinnerComponent(text: "Applying filters...", parent: self.view)
        ImageGenerator.generateAsyncImages(count: 2) { images in
            images.forEach {
                let imageView = UIImageView(image: $0)
                let scale = CGFloat.random(in: 1...1.5)
                imageView.center.x += CGFloat.random(in: 1...100)
                imageView.center.y += CGFloat.random(in: 1...100)
                imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.view.insertSubview(imageView, belowSubview: spinner)
            }
            let overlay = UIView(frame: self.view.frame)
            overlay.backgroundColor = .black
            overlay.alpha = 0.3
            self.view.insertSubview(overlay, belowSubview: spinner)
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            spinner.stop()
        }
    }
}

