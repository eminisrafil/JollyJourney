///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///


//import Shuffle_iOS
import PopBounceButton
import UIKit
import Shuffle_iOS

protocol TinderViewControllerDelegate: AnyObject {

    func didUpdatePhotoStoryValidationState(photoStory: SearchResult, validationState: Bool)
    func didUpdateImageValidation(photoStory: SearchResult, imageValidation: Bool)
    func didTapOnPhotoStory(photoStory: SearchResult)
    func tinderViewControllerDidFinish(_ vc: TinderViewController)
}

class TinderViewController: UIViewController {

    init(models: [SearchResult]) {
        self.cardModels = models
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var delegate: TinderViewControllerDelegate?

    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()
    private let cardModels: [SearchResult]

    override func viewDidLoad() {
        super.viewDidLoad()
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self

        configureNavigationBar()
        layoutButtonStackView()
        layoutCardStackView()
        configureBackgroundGradient()
    }

    private func configureNavigationBar() {
        title = "1/\(cardModels.count)"

        let backArrow = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .default)
        let backArrowImage = UIImage(systemName: "chevron.backward", withConfiguration: backArrow)?.withTintColor(.black, renderingMode: .alwaysOriginal)

        let backButton = UIBarButtonItem(image: backArrowImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleShift))
        backButton.tag = 1
        backButton.tintColor = .black

        let waybackArrowImage = UIImage(systemName: "chevron.forward", withConfiguration: backArrow)?.withTintColor(.black, renderingMode: .alwaysOriginal)

        let forwardButton = UIBarButtonItem(image: waybackArrowImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(handleShift))
        forwardButton.tag = 2
        forwardButton.tintColor = .black
        navigationItem.leftBarButtonItems = [backButton, forwardButton]

        let searchArrowImage = UIImage(systemName: "magnifyingglass", withConfiguration: backArrow)?.withTintColor(.black, renderingMode: .alwaysOriginal)

        let skipButton = UIBarButtonItem(image: searchArrowImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(didPressSkipToButton))
        skipButton.tag = 3
        skipButton.tintColor = .black

        let finishButton = UIBarButtonItem(title: "Finish",
                                            style: .plain,
                                            target: self,
                                            action: #selector(handleShift))
        finishButton.tag = 4
        finishButton.tintColor = .black
        navigationItem.rightBarButtonItems = [finishButton, skipButton]
    }

    private func configureBackgroundGradient() {
        let backgroundGray = UIColor(red: 244 / 255, green: 247 / 255, blue: 250 / 255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func layoutButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
                               right: view.safeAreaLayoutGuide.rightAnchor,
                               paddingLeft: 24,
                               paddingBottom: 12,
                               paddingRight: 24)
    }

    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: buttonStackView.topAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
    }

    @objc
    private func handleShift(_ sender: UIButton) {
        if sender.tag == 4 {
            delegate?.tinderViewControllerDidFinish(self)
        } else if sender.tag == 3 {
            // handled by didPressSkipToButton
        } else {
            let shift: Int = sender.tag == 1 ? -1 : 1
            cardStack.shift(withDistance: shift, animated: true)
            title = "\((cardStack.topCardIndex ?? 0) + 1)/\(cardModels.count)"
        }
    }

    @objc func didPressSkipToButton() {
        let alertController = UIAlertController(title: "Skip to", message: "Enter a number.", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Skip to index"
        }

        let createUserName = UIAlertAction(title: "go!", style: .default) { [weak self] alert -> Void in
            if let text = alertController.textFields?[0].text,
               text.count > 0, let skipToNumber = Int(text), let topCardIndex = self?.cardStack.topCardIndex {
                guard let self = self else { return }

                let shift = (skipToNumber - 1) - topCardIndex

                self.cardStack.shift(withDistance: shift, animated: true)
                self.title = "\(skipToNumber)/\(self.cardModels.count)"
            }
        }

        alertController.addAction(createUserName)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        DispatchQueue.main.async {
//            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: Data Source + Delegates

extension TinderViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {

    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.footerHeight = 130
        card.swipeDirections = [.left, .up, .right, .down]
        for direction in card.swipeDirections {
            card.setOverlay(TinderCardOverlay(direction: direction), forDirection: direction)
        }

        let model: SearchResult = cardModels[index]

        card.content = TinderCardContentView(withImage: model.imageURL, rawAIOutput: "model.rawAIOutput")
        var title = "\(model.description)"
//        if model.totalNumberOfItemsTagged > 1 {
//            title = "\(model.totalNumberOfItemsTagged)x " + title
//        }
        card.footer = TinderCardFooterView(withTitle: title, subtitle: "")

        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cardModels.count
    }

    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        delegate?.tinderViewControllerDidFinish(self)
    }

    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        title = "\(index+1)/\(cardModels.count)"
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        let photoModel = cardModels[index]
        title = "\(index+1)/\(cardModels.count)"


            switch direction {
            case .up:
                delegate?.didUpdatePhotoStoryValidationState(photoStory: photoModel, validationState: true)
            case .down:
                cardStack.shift(withDistance: 1, animated: true)
            case .left:
                delegate?.didUpdatePhotoStoryValidationState(photoStory: photoModel, validationState: false)
            case .right:
                delegate?.didUpdatePhotoStoryValidationState(photoStory: photoModel, validationState: true)
            }
    }

    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        delegate?.didTapOnPhotoStory(photoStory: cardModels[index])
    }

    func didTapButton(button: TinderButton) {
        switch button.tag {
        case 1:
            cardStack.undoLastSwipe(animated: true)
        case 2:
            cardStack.swipe(.left, animated: true)
        case 3:
            cardStack.swipe(.up, animated: true)
        case 4:
            cardStack.swipe(.right, animated: true)
        case 5:
            cardStack.reloadData()
        default:
            break
        }
    }
}
