//
//  DownloadImagePopoverPresentationController.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 3.12.21.
//

import UIKit

class CustomModalViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter image URL"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Input the correct URL address of the image to edit and then share with your friends."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var inputField: UITextField = {
        let field = UITextField()
        field.placeholder = "URL"
        field.font = .boldSystemFont(ofSize: 20)
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.keyboardType = .default
        field.returnKeyType = .done
        field.clearButtonMode = .always
        field.contentVerticalAlignment = .center
        field.delegate = self
        return field
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle("Download", for: .normal)
        button.addTarget(self, action: #selector(downloadFromURL), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [titleLabel, notesLabel, inputField, downloadButton, spacer])
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .blue
        return activityIndicator
    }()
    
    // Constants
    private let maxDimmedAlpha: CGFloat = 0.6
    private let defaultHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.dimmedView)
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(self.contentStackView)
        self.containerView.addSubview(activityIndicator)
        
        self.setupConstraints()
        self.setupCloseActionGesture()
        self.setupHideKeyboardGesture()
        self.setupKeyboardNotifications()
        self.setupInputField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateShowDimmedView()
        self.animatePresentContainer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromAllNotifications()
        self.animateDismissView()
    }
    
    @objc private func downloadFromURL(){
        self.hideKeyboard()
        guard let urlString = self.inputField.text else {return}
        if(!urlString.isEmpty){
            self.activityIndicator.startAnimating()
            let downloadImageOperation = DownloadImageOperation()
            downloadImageOperation.qualityOfService = .userInitiated
            downloadImageOperation.urlString = urlString
            downloadImageOperation.start()
            downloadImageOperation.completionBlock = { [weak self] in
                guard
                    let self = self,
                    let downloadedImage = downloadImageOperation.downloadedImage
                else {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.inputField.isError(baseColor: UIColor.black.cgColor, numberOfShakes: 3, revert: true)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let vc: FiltersViewController = FiltersViewController(image: downloadedImage)
                    guard let presentingVC = self.presentingViewController as? UINavigationController else {return}
                    self.animateDismissView()
                    presentingVC.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc private func handleCloseAction() {
        self.hideKeyboard()
        self.animateDismissView()
    }
    
    @objc private func hideKeyboard() {
        self.inputField.endEditing(true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            self.dimmedView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.dimmedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.dimmedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.dimmedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            // set container static constraint (trailing & leading)
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            // content stackView
            self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),
            self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            // set activityIndicator constraints
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
        ])
        
        self.containerViewBottomConstraint = self.containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: self.defaultHeight)
        self.containerViewBottomConstraint?.isActive = true
    }
    
    private func setupCloseActionGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        self.dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func setupHideKeyboardGesture() {
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.containerView.addGestureRecognizer(hideKeyboardGesture)
    }
    
    private func setupKeyboardNotifications(){
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
    }
    
    private func setupInputField(){
        self.inputField.setBottomBorderOnlyWith(color: UIColor.black.cgColor)
    }
    
    // MARK: Present and dismiss animation
    private func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateShowDimmedView() {
        self.dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    private func animateDismissView() {
        // hide blur view
        self.dimmedView.alpha = self.maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}

extension CustomModalViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // return NO to disallow editing.
        print("TextField should begin editing method called")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // became first responder
        print("TextField did begin editing method called")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
        print("TextField should end editing method called")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
        print("TextField did end editing method called")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // if implemented, called in place of textFieldDidEndEditing:
        print("TextField did end editing with reason method called")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        print("While entering the characters this method gets called")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // called when clear button pressed. return NO to ignore (no notifications)
        print("TextField should clear method called")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should Return method called")
        return textField.resignFirstResponder()
    }
}

extension CustomModalViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Get required info out of the notification
        if let userInfo = notification.userInfo,
           let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
           let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
           let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = self.containerView.frame.maxY - endRect.origin.y
            
            // Raise the modal view to the height of the keyboard
            if(keyboardOverlap != 0){
                // FIXME: keyboardWillShowNotification is called after we enter first symbol...Why???
                self.containerViewBottomConstraint?.constant = -keyboardOverlap
            }
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Get required info out of the notification
        if let userInfo = notification.userInfo,
           let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
           let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Lower the modal view to its original position
            self.containerViewBottomConstraint?.constant = 0
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension UITextField {
    func setBottomBorderOnlyWith(color: CGColor) {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func isError(baseColor: CGColor, numberOfShakes shakes: Float, revert: Bool) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}
