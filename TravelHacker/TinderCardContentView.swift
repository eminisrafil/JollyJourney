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

import UIKit
import Kingfisher


class TinderCardContentView: UIView {

  private let backgroundView: UIView = {
    let background = UIView()
    background.clipsToBounds = true
    background.layer.cornerRadius = 10
    return background
  }()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private let gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
                       UIColor.black.withAlphaComponent(0.8).cgColor]
    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    gradient.endPoint = CGPoint(x: 0.5, y: 1)
    return gradient
  }()
    
    private var isButtonExpanded = false
    private var rawAIOutput: String?

    private let aiButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "🛎️"
        config.baseForegroundColor = .systemBlue
        config.background.backgroundColor = .white
        config.background.cornerRadius = 5
        let button = UIButton(configuration: config)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.numberOfLines = 0  // Allow multiple lines
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

    init(withImage imageURL: String?, rawAIOutput: String?) {
    super.init(frame: .zero)

    if let photoURL = URL(string: imageURL ?? "") {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: photoURL, placeholder: nil)
    } else {
        //self.photoImageView.image = //#imageLiteral(resourceName: "user-icon")
    }
    
        self.rawAIOutput = rawAIOutput
        
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  private func initialize() {
    addSubview(backgroundView)
    backgroundView.anchorToSuperview()
    backgroundView.addSubview(imageView)
    imageView.anchorToSuperview()
    applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    backgroundView.layer.insertSublayer(gradientLayer, above: imageView.layer)
      
      addSubview(aiButton)
      aiButton.translatesAutoresizingMaskIntoConstraints = false
      let padding: CGFloat = 20 // Adjust padding as needed

      NSLayoutConstraint.activate([
          aiButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
          aiButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
          aiButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -padding), // Constraint to prevent overstretching
          aiButton.widthAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor, constant: -padding) // Constraint to limit width
      ])
      aiButton.addTarget(self, action: #selector(aiButtonTapped), for: .touchUpInside)

      // Check if rawAIOutput is not nil to show the button
      aiButton.isHidden = rawAIOutput?.count ?? 0 < 1
  }

  @objc private func aiButtonTapped() {
      isButtonExpanded.toggle()
      if isButtonExpanded {
          // Show the raw AI output
          var config = aiButton.configuration
          config?.title = "Raw AI Output\n\(rawAIOutput ?? "")"
          aiButton.configuration = config
      } else {
          // Restore to the original emoji title
          var config = aiButton.configuration
          config?.title = "🤖"
          aiButton.configuration = config
      }
  }

  // Method to set rawAIOutput and update button visibility
  func setRawAIOutput(_ output: String?) {
      rawAIOutput = output
      aiButton.isHidden = rawAIOutput == nil
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let heightFactor: CGFloat = 0.35
    gradientLayer.frame = CGRect(x: 0,
                                 y: (1 - heightFactor) * bounds.height,
                                 width: bounds.width,
                                 height: heightFactor * bounds.height)
  }
}
