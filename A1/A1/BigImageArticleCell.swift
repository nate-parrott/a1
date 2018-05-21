import UIKit
import Haneke

private func _textFromArticle(article: API.Article, showURL: Bool, lightText: Bool) -> NSAttributedString {
    let baseTextColor = lightText ? UIColor.white : UIColor.black
    let title = NSMutableAttributedString(string: article.title ?? "", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: baseTextColor])
    if showURL, let urlStr = article.canonical_url, let url = URL(string: urlStr), let host = url.host {
        var hostToDisplay = host.lowercased()
        if hostToDisplay.starts(with: "www.") {
            hostToDisplay = String(hostToDisplay[hostToDisplay.range(of: "www.")!.upperBound...])
        }
        title.append(NSAttributedString(string: "\n" + host.lowercased(), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: baseTextColor.withAlphaComponent(0.5)]))
    }
    let para = NSMutableParagraphStyle()
    para.paragraphSpacingBefore = 2
    title.addAttribute(NSAttributedStringKey.paragraphStyle, value: para, range: NSMakeRange(0, title.length))
    return title
}

class BigImageArticleCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(outerContainer)
        outerContainer.addSubview(innerContainer)
        
        innerContainer.addSubview(imageView)
        imageView.backgroundColor = Styling.emptyArticleCellColor
        imageView.contentMode = .scaleAspectFill
        
        innerContainer.addSubview(gradient)
        
        innerContainer.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        
        innerContainer.layer.cornerRadius = cornerRadius
        innerContainer.clipsToBounds = true
        
        outerContainer.layer.cornerRadius = cornerRadius
        outerContainer.layer.shadowColor = UIColor.black.cgColor
        outerContainer.layer.shadowOpacity = 0.3
        outerContainer.layer.shadowRadius = 12
        outerContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    let cornerRadius: CGFloat = 10
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let outerContainer = UIView()
    let innerContainer = UIView()
    let imageView = UIImageView()
    let gradient = GradientView()
    let label = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        outerContainer.bounds = self.bounds
        outerContainer.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        innerContainer.frame = outerContainer.bounds
        
        outerContainer.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        imageView.frame = innerContainer.bounds
        
        let padding = Styling.collectionPadding
        let labelSize = label.sizeThatFits(CGSize(width: bounds.width - padding * 2, height: bounds.height - padding * 2))
        label.frame = CGRect(x: padding, y: bounds.height - padding - labelSize.height, width: bounds.width - padding * 2, height: labelSize.height)
        let gradientHeight = padding * 2 + label.frame.height + 40
        gradient.frame = CGRect(x: 0, y: bounds.height - gradientHeight, width: bounds.width, height: gradientHeight)
    }
    
    struct Model {
        let article: API.Article
        let showURL: Bool
    }
    var model: Model? {
        didSet {
            setNeedsLayout()
            guard let model = model else { return }
            imageView.image = nil
            label.attributedText = _textFromArticle(article: model.article, showURL: model.showURL, lightText: false)
            gradient.isHidden = true
            guard let imageUrlString = model.article.lead_image_url, let imageUrl = URL(string: imageUrlString) else {
                label.isHidden = false
                return
            }
            URLSession.shared.dataTask(with: imageUrl) { [weak self] (dataOpt, _, _) in
                DispatchQueue.global(qos: .default).async {
                    let imageOpt: UIImage?
                    if let data = dataOpt, let image = UIImage(data: data), image.size.width >= 200 && image.size.height >= 200 {
                        imageOpt = image
                    } else {
                        imageOpt = nil
                    }
                    
                    let lightText = (imageOpt?.areaAverage().hsva.v ?? 1) < 0.66
                    DispatchQueue.main.async {
                        guard let `self` = self, self.model?.article.canonical_url == model.article.canonical_url else { return }
                        self.gradient.set(topColor: UIColor(white: lightText ? 0 : 1, alpha: 0), bottomColor: UIColor(white: lightText ? 0 : 1, alpha: 0.7))
                        UIView.transition(with: self.contentView, duration: 0.15, options: [.allowUserInteraction, .transitionCrossDissolve], animations: {
                            self.label.attributedText = _textFromArticle(article: model.article, showURL: model.showURL, lightText: lightText)
                            self.imageView.image = imageOpt
                            self.gradient.isHidden = (imageOpt == nil)
                        }, completion: nil)
                    }
                }

            }.resume()
        }
    }
    
    // MARK: Touches
    var onTap: (() ->  ())?
    
    var _initialTouchPos: CGPoint?
    let _pressAnimDuration: TimeInterval = 0.12
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _pressed = true
        _initialTouchPos = touches.first!.location(in: window!)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos = touches.first!.location(in: window!)
        if pos.distanceTo(_initialTouchPos!) > 4 {
            _pressed = false
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard _pressed else { return }
        onTap?()
        DispatchQueue.main.asyncAfter(deadline: .now() + _pressAnimDuration) {
            self._pressed = false
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _pressed = false
    }
    var _pressed = false {
        didSet(old) {
            guard old != _pressed else { return }
            UIView.animate(withDuration: _pressAnimDuration, delay: 0, options: .allowUserInteraction, animations: {
                let scale: CGFloat = self._pressed ? 0.95 : 1
                self.outerContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: nil)
        }
    }
}
