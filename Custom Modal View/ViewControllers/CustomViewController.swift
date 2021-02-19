//
//  ViewController.swift
//  Custom Modal View
//
//  Created by Maximo Hinojosa on 10/26/20.
//

import UIKit

class CustomViewController: UIViewController {
    
    struct UIConstants {
        let cardHeight: CGFloat = 600
        let cardHandleAreaHeight: CGFloat = 65
        let animationDuration: TimeInterval = 0.9
        let dampingRatio: CGFloat = 1
    }
    
    enum CardState {
        case expanded
        case collapsed
    }

    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!
    private let uiConstants = UIConstants()
    
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 65
    
    var cardVisible = false
    var nextState: CardState {
        return cardVisible ? . collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(patternImage: UIImage(named: "miami") ?? UIImage())
        setUpCard()
    }

    private func setUpCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - uiConstants.cardHandleAreaHeight, width: self.view.bounds.width, height: uiConstants.cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        cardViewController.barView.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.barView.addGestureRecognizer(panGestureRecognizer)
        cardViewController.barHandleContainerView.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.barHandleContainerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handleCardTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitonIfNeeded(state: nextState, duration: uiConstants.animationDuration)
        default:
            break
        }
    }
    
    @objc private func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // startTransition
            startInteravtiveTranstion(state: nextState, duration: uiConstants.animationDuration)
        case .changed:
            // updateTransition
            let transition = recognizer.translation(in: self.cardViewController.barView)
            var fractionComplete = transition.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // continueTransition
            continueInteractiveTransion()
        default:
            break
        }
    }
    
    private func startInteravtiveTranstion(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitonIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            /// pausing animations to make modal interactive
            /// set animation progress when interrupted so that we can work witht that value later
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        /// update fraction complete for all animations
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func continueInteractiveTransion() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func animateTransitonIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: uiConstants.dampingRatio) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            /// update card visible flag in the completion block
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            /// add frame animator to the running animations array
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            /// add  cornerRadius animator to our running animations array
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: uiConstants.dampingRatio) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .light)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            
            /// add blur animator to the running animations array
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
}
