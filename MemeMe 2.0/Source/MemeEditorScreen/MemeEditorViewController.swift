//
//  MemeEditorViewController.swift
//  Meme
//
//  Created by Oladipupo Oluwatobi on 29/03/2020.
//  Copyright © 2020 Oladipupo Oluwatobi. All rights reserved.
//

import UIKit
import MobileCoreServices

final class MemeEditorViewController: UIViewController {
    let toolBar = UIToolbar(
        //This is a workaround for [apparently] UIToolbar bug where it breaks
        //contraints of private subviews (e.g. _UIModernBarButton: centerY)
        //https://forums.developer.apple.com/thread/121474
        frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44))
    )
    let photoView = UIImageView(frame: .zero)
    let instructionLabel = UILabel()
    let cameraButton = UIBarButtonItem()
    let topTextField = UITextField()
    let bottomTextField = UITextField()
    var bottomTextFieldBottomConstraint = NSLayoutConstraint()
    var topTextFieldTopConstraint = NSLayoutConstraint()
    var textFieldLeadingConstraint = NSLayoutConstraint()
    var textFieldTrailingConstraint = NSLayoutConstraint()
    var keyboardHeight: CGFloat = 0.0
    let didSaveMemeCallback: () -> Void
    
    init(callback: @escaping () -> Void) {
        didSaveMemeCallback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.addSubview(photoView)
        view.addSubview(toolBar)
        
        setUpNavigationBar()
        setUpImageView()
        setUpToolBar()
        setUpTextFields(textField: bottomTextField)
        setUpTextFields(textField: topTextField)
        setUpPickImageLabel()
        setDefaultValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let textFieldConstraints = calculateTextFieldsConstants()
        topTextFieldTopConstraint.constant = textFieldConstraints.top
        bottomTextFieldBottomConstraint.constant = textFieldConstraints.bottom
        textFieldLeadingConstraint.constant = calculateHorizontalTextFieldOffset()
        textFieldLeadingConstraint.constant = calculateHorizontalTextFieldOffset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsudcribeFromKeyboardNotifications()
    }
    
    func setDefaultValues() {
        self.instructionLabel.isHidden = false
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        topTextField.text = Labels.EditorScreen.TextField.topText
        bottomTextField.text = Labels.EditorScreen.TextField.bottomText
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    private func setUpNavigationBar() {
        let actionItem = UIBarButtonItem(barButtonSystemItem: .action, target: self,  action: #selector(openActivityView))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        navigationItem.leftBarButtonItem = actionItem
        navigationItem.rightBarButtonItem = cancelItem
    }
    
    private func setUpToolBar() {
        func spacer() -> UIBarButtonItem {
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        cameraButton.image = UIImage(systemName: Labels.EditorScreen.Toolbar.cameraButtonImageName)
        cameraButton.style = .plain
        cameraButton.target = self
        cameraButton.action = #selector(presentCamera)
        let albumButton = UIBarButtonItem(
            title: Labels.EditorScreen.Toolbar.albumButtonTitle,
            style: .plain,
            target: self,
            action: #selector(presentPhotoLibrary)
        )
        let items = [spacer(), cameraButton, spacer(), albumButton, spacer()]
        toolBar.setItems(items, animated: false)
    }
    
    private func setUpImageView() {
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        photoView.backgroundColor = .darkGray
        photoView.contentMode = .scaleAspectFit
    }
    
    func setUpPickImageLabel() {
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(instructionLabel)
        instructionLabel.font = .systemFont(ofSize: 30, weight: .medium)
        instructionLabel.numberOfLines = 0
        instructionLabel.text = Labels.EditorScreen.instructionText
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setUpTextFields(textField: UITextField) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        if textField == topTextField {
            topTextFieldTopConstraint = textField.topAnchor.constraint(
                equalTo: photoView.topAnchor,
                constant: 16
            )
            textFieldLeadingConstraint = textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            )
            textFieldTrailingConstraint = view.trailingAnchor.constraint(
                equalTo: textField.trailingAnchor,
                constant: 16
            )
            topTextFieldTopConstraint.priority = .defaultLow
            
            NSLayoutConstraint.activate([
                topTextFieldTopConstraint,
                textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                textFieldLeadingConstraint,
                textFieldTrailingConstraint,
            ])
        }
        if textField == bottomTextField {
            bottomTextFieldBottomConstraint = photoView.bottomAnchor.constraint(
                equalTo: textField.bottomAnchor,
                constant: 16
            )
            textFieldLeadingConstraint = textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            )
            textFieldTrailingConstraint = view.trailingAnchor.constraint(
                equalTo: textField.trailingAnchor,
                constant: 16
            )
            NSLayoutConstraint.activate([
                textFieldLeadingConstraint,
                textFieldTrailingConstraint,
                textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                bottomTextFieldBottomConstraint
            ])
        }
        
        
        textField.borderStyle = .none
        textField.isUserInteractionEnabled = false
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12
        textField.autocapitalizationType = .allCharacters
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    var memeFont: UIFont {
        UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)
            ?? UIFont.systemFont(ofSize: 40)
    }
    
    var memeTextAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: memeFont,
            NSAttributedString.Key.strokeWidth: -3.0
        ]
    }
    
    func calculateVisibleImageSize(image: UIImage) -> CGSize {
        let imageViewSize = photoView.frame.size
        let aspectRatio = image.aspectRatio(isPortrait: isPortrait)
        let smallerSide = isPortrait ? imageViewSize.width : imageViewSize.height
        return CGSize(
            width: smallerSide * (isPortrait ? 1 : aspectRatio),
            height: smallerSide * (isPortrait ? aspectRatio : 1)
        )
    }
    
    func calculateTextFieldsConstants() -> (top: CGFloat, bottom: CGFloat) {
        var topConstant: CGFloat = 0.0
        var bottomConstant: CGFloat = 0.0
        guard let image = photoView.image else { return (topConstant, bottomConstant)}
        
        let keyboardOffset = max(0, keyboardHeight - view.safeAreaInsets.bottom)
        if isPortrait {
            let imageViewHeight = photoView.frame.height
            let contextSize = calculateVisibleImageSize(image: image)
            topConstant = ((imageViewHeight - contextSize.height) / 2 + 16)
            let baseOffset = max((imageViewHeight - contextSize.height) / 2, keyboardOffset)
            bottomConstant = baseOffset + 16
        } else {
            topConstant = 16
            bottomConstant = 16 + keyboardOffset
        }
        return (topConstant, bottomConstant)
    }
    
    func calculateHorizontalTextFieldOffset() -> CGFloat {
        guard let image = photoView.image else { return 0.0 }
        let contextSize = calculateVisibleImageSize(image: image)
        return isPortrait ? 16 : ((photoView.frame.width - contextSize.width) / 2 + 16)
    }
    
    @objc func presentPhotoLibrary() {
        presentPicker(for: .photoLibrary)
    }
    
    @objc func presentCamera() {
        presentPicker(for: .camera)
    }
    
    func presentPicker(for sourceType: UIImagePickerController.SourceType) {
        guard let imagePicker = UIImagePickerController(sourceType: sourceType) else {
            return
        }
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func openActivityView() {
        guard let image = renderMemeImage() else {
            presentAlert(
                title: Labels.EditorScreen.Alert.createMemeErrorText,
                message: Labels.EditorScreen.Alert.createMemeErrorDescription
            )
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [weak self] _, completed, _, error in
            if completed && error == nil {
                self?.save(image: image)
            }
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard bottomTextField.isEditing else {
            return
        }
        keyboardHeight = getKeyboardHight(notification)
        let duration = getKeyboardAnimationDuration(notification)
        let curve = getKeyboardAnimationCurve(notification)
        
        self.view.layoutIfNeeded()
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.animationOptions(for: curve),
            animations: {
                //We call setNeedsLayout to work around edge case when we rotate
                //device with a keyboard visible. In which case viewDidLayoutSubviews is
                //called before keyboardWillShow and layoutIfNeeded in this animation block
                //does not trigger another layout cycle.
                self.view.setNeedsLayout()
        },
            completion: nil
        )
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0.0
        let duration = getKeyboardAnimationDuration(notification)
        let curve = getKeyboardAnimationCurve(notification)
        
        self.view.layoutIfNeeded()
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.animationOptions(for: curve),
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
    
    func getKeyboardAnimationCurve(_ notification: Notification) -> UIView.AnimationCurve {
        let userInfo = notification.userInfo
        let curve = userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
        return UIView.AnimationCurve(rawValue: curve.intValue)!
    }
    
    func getKeyboardAnimationDuration(_ notification: Notification) -> TimeInterval {
        let userInfo = notification.userInfo
        let duration = userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        return duration.doubleValue
    }
    
    func getKeyboardHight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsudcribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func save(image: UIImage) {
        let id = UUID()
        let meme = Meme(
            id: id,
            topText: topTextField.text ?? "",
            bottomText: bottomTextField.text ?? "",
            date: Date()
        )
        do {
            try ImageStore.saveImage(image: image, id: id)
            let existingMemes = MemeStore.loadMemes()
            try MemeStore.save(memes: existingMemes + [meme])
            didSaveMemeCallback()
        } catch ImageStore.Error.imageNotFound {
            presentAlert(
                title: ImageStore.Error.imageNotFound.title,
                message: ImageStore.Error.imageNotFound.localizedDescription
            )
        } catch MemeStore.Error.encodingFailed {
            presentAlert(
                title: Labels.EditorScreen.Alert.saveErrorText,
                message: Labels.EditorScreen.Alert.unrecoverableSaveErrorDescription
            )
            //attempt to clean-up the mess after save failure
            try? ImageStore.deleteImage(id: id)
        } catch {
            presentAlert(
                title: Labels.EditorScreen.Alert.saveErrorText,
                message: error.localizedDescription
            )
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: Labels.EditorScreen.Alert.okButtonTitle,
                style: .default,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    func renderMemeImage() -> UIImage? {
        guard let image = photoView.image else { return nil }
        
        let renderer = MemeImageRenderer(
            isPortrait: isPortrait,
            image: image,
            imageFrame: photoView.frame,
            topTextFrame: view.convert(topTextField.frame, to: photoView),
            bottomTextFrame: view.convert(bottomTextField.frame, to: photoView),
            topText: topTextField.text ?? "",
            bottomText: bottomTextField.text ?? "",
            topFont: topTextField.font ?? memeFont,
            bottomFont: bottomTextField.font ?? memeFont
        )
        
        return renderer.render()
    }
    
    var isPortrait: Bool { view.frame.height > view.frame.width }
}

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeImage as String),
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
        }
        
        dismiss(animated: true) {
            self.instructionLabel.isHidden = true
            self.photoView.image = image
            self.topTextField.isHidden = false
            self.bottomTextField.isHidden = false
            self.topTextField.isUserInteractionEnabled = true
            self.bottomTextField.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
}

