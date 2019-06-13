//
//  ViewController2.swift
//  WeakSelf
//
//  Created by Besher on 2019-06-02.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class PresentedController: UIViewController {
    
    var printingButton: CustomButton?
    
    var leakyStorage: Any? // stores escaping closures to demonstrate leaks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Try the enums with different scenarios when calling this method
        // The comments below will explain why some scenarios might cause a leak
        setup(scenario: .leakyButton)
        
    }
    
    deinit {
        // Not passing here after dismissal means we have a leak problem
        print("Dismissing Presented Controller")
    }
    
    // MARK: - Leak Scenario
    
    // It can be tempting to pass a function directly to the closure property, but it will leak the entire controller!
    // Reason: self is implicitly captured by the closure, and self owns the button which owns the closure
    // thus creating a reference cycle
    func setupLeakyButton() {
        printingButton?.closure = printer
    }
    
    // [weak self] is needed to break the cycle, even if it makes for uglier syntax
    func setupNonLeakyButton() {
        printingButton?.closure = { [weak self] in self?.printer() }
    }
    
    // This is a non-escaping closure (executes immediately), therefore we don't need [weak self]
    func uiViewAnimate() {
        UIView.animate(withDuration: 3.0) { self.view.backgroundColor = .red }
    }
    
    // Same for higher order functions, they are non-escaping, therefore we don't need [weak self]
    func higherOrderFunctions() {
        let numbers = [1,2,3,4,5,6,7,8,9,10]
        numbers.forEach { self.view.tag = $0 }
        _ = numbers.filter { $0 == self.view.tag }
    }
    
    // This leaks the controller because we aren't executing the animation immediately. Instead we store it in a property
    // as an escaping closure without using [weak self]. As a result, the closure maintains a strong reference
    // to self, while self also has a strong reference to the closure, thereby causing a leak
    func leakyViewPropertyAnimator() {
        let anim = UIViewPropertyAnimator(duration: 3.0, curve: .linear) { self.view.backgroundColor = .red }
        anim.addCompletion { _ in self.view.backgroundColor = .white }
        self.leakyStorage = anim
    }
    
    // If we pass references to the properties we want to manipulate directly to the closure, instead of using self,
    // we will no longer leak the controller, even without using [weak self]
    func nonLeakyViewPropertyAnimator1() {
        let view = self.view
        let anim = UIViewPropertyAnimator(duration: 2.0, curve: .linear) { view?.backgroundColor = .red }
        anim.addCompletion { _ in view?.backgroundColor = .white }
        self.leakyStorage = anim
    }
    
    // If we start the animation immediately, it won't leak the controller, even without [weak self]
    func nonLeakyViewPropertyAnimator2() {
        let anim = UIViewPropertyAnimator(duration: 3.0, curve: .linear) { self.view.backgroundColor = .red }
        anim.addCompletion { _ in self.view.backgroundColor = .white }
        anim.startAnimation()
    }
    
    // If we store a Dispatch closure, it escapes, and will leak the controller if we don't use [weak self]
    func leakyDispatchQueue() {
        let workItem = DispatchWorkItem { self.view.backgroundColor = .red }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        self.leakyStorage = workItem
    }
    
    // If we execute a Dispatch closure immediately without storing it, there is no need for [weak self]
    func nonLeakyDispatchQueue() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.view.backgroundColor = .red
        }
        
        DispatchQueue.main.async {
            self.view.backgroundColor = .red
        }
        
        DispatchQueue.global(qos: .background).async {
            print(self.navigationItem.description)
        }
    }
    
    // This timer will leak the controller because
    // 1. it repeats
    // 2. [weak self] is not used
    // If either of those conditions is false, it won't leak
    func leakyTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            let currentColor = self.view.backgroundColor
            self.view.backgroundColor = currentColor == .red ? .blue : .red
        })
        timer.tolerance = 0.5
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    func printer() {
        print("Executing the closure attached to the button")
    }
}
