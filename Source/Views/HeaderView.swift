import UIKit

protocol HeaderViewDelegate: AnyObject {
    func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
    func headerView(_ headerView: HeaderView, didPressShareButton shareButton: UIButton)
}

open class HeaderView: UIView {
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
    
    weak var delegate: HeaderViewDelegate?
    
    // MARK: - Initializers
    
    public init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.clear
        
        [closeButton, deleteButton, shareButton].forEach { addSubview($0) }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {
    
    @objc public func configureLayout() {
        let topPadding: CGFloat

        if #available(iOS 11, *) {
            topPadding = safeAreaInsets.top
        } else {
            topPadding = 0
        }

        // Calculate the center position for the share button
        let centerX = bounds.width / 2 - shareButton.frame.width / 2

        shareButton.frame.origin = CGPoint(
            x: bounds.width - shareButton.frame.width - 17,
            y: topPadding
        )

        closeButton.frame.origin = CGPoint(
            x: 17,
            y: topPadding
        )

        // Position the share button in the center horizontally
        deleteButton.frame.origin = CGPoint(
            x: centerX,
            y: topPadding
        )

    }

}
