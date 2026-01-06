import UIKit

protocol HeaderViewDelegate: AnyObject {
    func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressShareButton shareButton: UIButton)
}

open class HeaderView: UIView {
    
    private let contentView = UIView()
    
    open fileprivate(set) lazy var closeButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.CloseButton.text,
            attributes: LightboxConfig.CloseButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControl.State())
        
        if let size = LightboxConfig.CloseButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        
        button.addTarget(self, action: #selector(closeButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.CloseButton.image {
            button.setBackgroundImage(image, for: UIControl.State())
        }
        
        button.isHidden = !LightboxConfig.CloseButton.enabled
        
        return button
    }()
    
    open fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.DeleteButton.text,
            attributes: LightboxConfig.DeleteButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControl.State())
        
        if let size = LightboxConfig.DeleteButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.DeleteButton.image {
            button.setBackgroundImage(image, for: UIControl.State())
        }
        
        button.isHidden = !LightboxConfig.DeleteButton.enabled
        
        return button
    }()
    
    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.addTarget(self, action: #selector(shareButtonDidPress(_:)), for: .touchUpInside)
        
        let title = NSAttributedString(
            string: LightboxConfig.ShareButton.text,
            attributes: LightboxConfig.ShareButton.textAttributes)
        
        if #available(iOS 13.0, *) {
            if let image = LightboxConfig.ShareButton.image {
                let shareImage = image.withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
                button.setImage(shareImage, for: .normal)
            } else {
                button.setAttributedTitle(title, for: UIControl.State())
            }
        } else {
            button.setAttributedTitle(title, for: UIControl.State())
        }
        
        if let size = LightboxConfig.ShareButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = !LightboxConfig.ShareButton.enabled
        
        return button
    }()
    
    open fileprivate(set) lazy var pageLabel: UILabel = { [unowned self] in
      let label = UILabel(frame: CGRect.zero)
      label.isHidden = !LightboxConfig.PageIndicator.enabled
      label.numberOfLines = 1
      return label
    }()
    
    weak var delegate: HeaderViewDelegate?
    
    // MARK: - Initializers
    
    public init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(contentView)
        [closeButton, deleteButton, shareButton, pageLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.configureLayout()
    }
    
    // MARK: - Actions
    
    @objc func deleteButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressDeleteButton: button)
    }
    
    @objc func closeButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressCloseButton: button)
    }
    @objc func shareButtonDidPress(_ button: UIButton) {
        delegate?.headerView(self, didPressShareButton: button)
    }
    
    func updatePage(_ page: Int, _ numberOfPages: Int) {
      let text = "\(page)/\(numberOfPages)"
      pageLabel.attributedText = NSAttributedString(string: text,
        attributes: LightboxConfig.PageIndicator.textAttributes)
      pageLabel.sizeToFit()
    }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

    @objc public func configureLayout() {

        let safeTop: CGFloat
        if #available(iOS 11, *) {
            safeTop = safeAreaInsets.top
        } else {
            safeTop = 0
        }

        let hasNotch = safeTop > 20
        let topInset = hasNotch ? safeTop : 0
        frame.size.height = topInset + 60
        contentView.frame = CGRect(
            x: 0,
            y: topInset,
            width: bounds.width,
            height: 60
        )

        let centerY = contentView.bounds.midY

        let isLandscape: Bool
        if let scene = window?.windowScene {
            isLandscape = scene.interfaceOrientation.isLandscape
        } else {
            isLandscape = false
        }

        let sidePadding: CGFloat = isLandscape ? 32 : 17

        closeButton.center = CGPoint(
            x: sidePadding + closeButton.bounds.width / 2,
            y: centerY
        )

        shareButton.center = CGPoint(
            x: contentView.bounds.width - sidePadding - shareButton.bounds.width / 2,
            y: centerY
        )

        deleteButton.center = CGPoint(
            x: contentView.bounds.midX,
            y: centerY
        )

        pageLabel.center = CGPoint(
            x: contentView.bounds.midX,
            y: centerY
        )
    }

}
