//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Alex Littlejohn.
//  Copyright (c) 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Toaster
import SwiftyJSON
import SDWebImage
import AssetsLibrary

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

public extension CameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: @escaping CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        imagePicker.title = "相册"
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        imagePicker.onSelectionComplete = { asset in
            if let asset = asset {
                _ = SingleImageFetcher()
                    .setAsset(asset)
                    .setTargetSize(largestPhotoSize())
                    .onSuccess { image in
                        completion(image, asset)
                    }
                    .onFailure { error in
                        completion(nil, nil)
                    }
                    .fetch()
            } else {
                completion(nil, nil)
            }
        }
        
        return navigationController
    }
}

public class CameraViewController: UIViewController {
    
    var waterMarks : [JSON] = []
    var didUpdateViews = false
    var allowCropping = false
    var animationRunning = false
    var nTag = 0 // 定位当前位置
    //var cameraType = 0
    var sectionTiltes : [String] = []
    var titles : [[String]] = []
    var lcWidth : NSLayoutConstraint!
    var lcHeight : NSLayoutConstraint!
    var imageInfo : (UIImage? , PHAsset?)
    var companyNeed : [Int] = []
    
    var lastInterfaceOrientation : UIInterfaceOrientation?
    var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?
    
    var animationDuration: TimeInterval = 0.5
    var animationSpring: CGFloat = 0.5
    var rotateAnimation: UIViewAnimationOptions = .curveLinear
    
    var cameraButtonEdgeConstraint: NSLayoutConstraint?
    var cameraButtonGravityConstraint: NSLayoutConstraint?
    
    var closeButtonEdgeConstraint: NSLayoutConstraint?
    var closeButtonGravityConstraint: NSLayoutConstraint?
    
    var containerButtonsEdgeOneConstraint: NSLayoutConstraint?
    var containerButtonsEdgeTwoConstraint: NSLayoutConstraint?
    var containerButtonsGravityConstraint: NSLayoutConstraint?
    
    var swapButtonEdgeOneConstraint: NSLayoutConstraint?
    var swapButtonEdgeTwoConstraint: NSLayoutConstraint?
    var swapButtonGravityConstraint: NSLayoutConstraint?
    
    var libraryButtonEdgeOneConstraint: NSLayoutConstraint?
    var libraryButtonEdgeTwoConstraint: NSLayoutConstraint?
    var libraryButtonGravityConstraint: NSLayoutConstraint?
    
    var cancelButtonEdgeConstraint: NSLayoutConstraint?
    var cancelButtonGravityConstraint: NSLayoutConstraint?
    
    var flashButtonEdgeConstraint: NSLayoutConstraint?
    var flashButtonGravityConstraint: NSLayoutConstraint?
    
    var cameraOverlayEdgeOneConstraint: NSLayoutConstraint?
    var cameraOverlayEdgeTwoConstraint: NSLayoutConstraint?
    var cameraOverlayWidthConstraint: NSLayoutConstraint?
    var cameraOverlayCenterConstraint: NSLayoutConstraint?
    
    let cameraView : CameraView = {
        let cameraView = CameraView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        return cameraView
    }()
    
    let leftView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbColorFromHex(rgb: 0x363b3f)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rightView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbColorFromHex(rgb: 0x363b3f)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cameraOverlay : CropOverlay = {
        let cameraOverlay = CropOverlay()
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        return cameraOverlay
    }()
    
    let cameraButton : UIButton = {
        let button = UIButton() // 56 49
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setImage(UIImage(named: "img_homepage_camera5"),
                        for: .normal)
        button.setImage(UIImage(named: "img_homepage_camera5"),
                        for: .highlighted)
        return button
    }()
    
    let closeButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_camera_close"),
                        for: .normal)
        return button
    }()
    
    let libraryButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("相册", for: .normal)
        button.setTitleColor(UIColor.rgbColorFromHex(rgb: 0xfafafa), for: .normal)
        return button
    }()
    
    let nextButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.rgbColorFromHex(rgb: 0xfafafa), for: .normal)
        button.addTarget(self, action: #selector(CameraViewController.doNextOrCancel), for: .touchUpInside)
        return button
    }()
    
    let flashButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_camera_flash_on"),
                        for: .normal)
        return button
    }()
    
    let middleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "transport")
        return imageView
    }()
    
    let lblName : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblCurrentPage : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hintButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "simple"), for: .normal)
        return button
    }()
    
    let ivDetailDesc : UIImageView = { //描述图片
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let ivSnap : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
  
    public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, completion: @escaping CameraViewCompletion) {
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
        allowCropping = croppingEnabled
        cameraOverlay.isHidden = !allowCropping
        libraryButton.isEnabled = allowsLibraryAccess
        libraryButton.isHidden = !allowsLibraryAccess
    }
  
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    /**
     * Setup the constraints when the app is starting or rotating
     * the screen.
     * To avoid the override/conflict of stable constraint, these
     * stable constraint are one time configurable.
     * Any other dynamic constraint are configurable when the
     * device is rotating, based on the device orientation.
     */
    override public func updateViewConstraints() {

        if !didUpdateViews {
            didUpdateViews = true
        }
        
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        let portrait = statusBarOrientation.isPortrait
        
        configCameraButtonEdgeConstraint(statusBarOrientation)
        configCameraButtonGravityConstraint(portrait)
        
        removeCloseButtonConstraints()
        configCloseButtonEdgeConstraint(statusBarOrientation)
        configCloseButtonGravityConstraint(statusBarOrientation)
        
        removeCancelButtonConstraints()
        configCancelButtonEdgeConstraint(statusBarOrientation)
        configCancelButtonGravityConstraint(statusBarOrientation)
        
        removeContainerConstraints()
        configContainerEdgeConstraint(statusBarOrientation)
        configContainerGravityConstraint(statusBarOrientation)

        removeLibraryButtonConstraints()
        configLibraryEdgeButtonConstraint(statusBarOrientation)
        configLibraryGravityButtonConstraint(portrait)
        
        configFlashEdgeButtonConstraint(statusBarOrientation)
        configFlashGravityButtonConstraint(statusBarOrientation)
        
        let padding : CGFloat = portrait ? 16.0 : -16.0
        removeCameraOverlayEdgesConstraints()
        configCameraOverlayEdgeOneContraint(portrait, padding: padding)
        configCameraOverlayEdgeTwoConstraint(portrait, padding: padding)
        configCameraOverlayWidthConstraint(portrait)
        configCameraOverlayCenterConstraint(portrait)
        
        //rotate(actualInterfaceOrientation: statusBarOrientation)
        
        super.updateViewConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        [cameraView,
         leftView,
         rightView,
         middleView,
         cameraOverlay,
         cameraButton,
         closeButton,
         flashButton,
         libraryButton,
         nextButton].forEach({ self.view.addSubview($0) })
        view.setNeedsUpdateConstraints()
        
        [imageView,
         lblName,
         lblCurrentPage,
         hintButton,
         ivDetailDesc,
         ivSnap].forEach({ middleView.addSubview($0) })
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(50)-[cameraView]-(114)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cameraView" : cameraView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cameraView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cameraView" : cameraView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftView(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["leftView" : leftView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["leftView" : leftView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightView(114)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["rightView" : rightView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["rightView" : rightView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(50)-[middleView]-(114)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["middleView" : middleView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[middleView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["middleView" : middleView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cameraButton(90)]", options: .directionLeadingToTrailing, metrics: nil, views: ["cameraButton" : cameraButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cameraButton(79)]", options: .directionLeadingToTrailing, metrics: nil, views: ["cameraButton" : cameraButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[nextButton(114)]", options: .directionLeadingToTrailing, metrics: nil, views: ["nextButton" : nextButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[nextButton(60)]", options: .directionLeadingToTrailing, metrics: nil, views: ["nextButton" : nextButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[libraryButton(114)]", options: .directionLeadingToTrailing, metrics: nil, views: ["libraryButton" : libraryButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[libraryButton(60)]", options: .directionLeadingToTrailing, metrics: nil, views: ["libraryButton" : libraryButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["closeButton" : closeButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[closeButton(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["closeButton" : closeButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[flashButton(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["flashButton" : flashButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[flashButton(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["flashButton" : flashButton]))
        
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ivSnap]|", options: .directionLeadingToTrailing, metrics: nil, views: ["ivSnap" : ivSnap]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[ivSnap]|", options: .directionLeadingToTrailing, metrics: nil, views: ["ivSnap" : ivSnap]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView(width)]", options: .directionLeadingToTrailing, metrics: ["width" : min(467, 467 / 667.0 * MAX)], views: ["imageView" : imageView]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(height)]", options: .directionLeadingToTrailing, metrics: ["height" : min(350, 350 / 375.0 * MIN)], views: ["imageView" : imageView]))
        middleView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: middleView, attribute: .centerX, multiplier: 1, constant: 0))
        middleView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: middleView, attribute: .centerY, multiplier: 1, constant: 0))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lblName]|", options: .directionLeadingToTrailing, metrics: nil, views: ["lblName" : lblName]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblName]-(40)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["lblName" : lblName]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lblCurrentPage]|", options: .directionLeadingToTrailing, metrics: nil, views: ["lblCurrentPage" : lblCurrentPage]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblCurrentPage]-(10)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["lblCurrentPage" : lblCurrentPage]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hintButton(80)]-(10)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["hintButton" : hintButton]))
        middleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[hintButton(80)]-(10)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["hintButton" : hintButton]))
        
        middleView.addConstraint(NSLayoutConstraint(item: ivDetailDesc, attribute: .bottom, relatedBy: .equal, toItem: hintButton, attribute: .top, multiplier: 1, constant: 20))
        middleView.addConstraint(NSLayoutConstraint(item: ivDetailDesc, attribute: .right, relatedBy: .equal, toItem: hintButton, attribute: .right, multiplier: 1, constant: -15))
        lcWidth = NSLayoutConstraint(item: ivDetailDesc, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        lcHeight = NSLayoutConstraint(item: ivDetailDesc, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        middleView.addConstraint(lcWidth)
        middleView.addConstraint(lcHeight)
        
        ivSnap.isHidden = true
        
        addCameraObserver()
        addRotateObserver()
        setupVolumeControl()
        setupActions()
        checkPermissions()
        cameraView.configureFocus()
        
        
        let section = nTag / 1000
        let row = nTag % 1000 % 100
        let bright = nTag % 1000 >= 100 ? 1 : 0
        let index = row * 2 + bright
        if titles.count > section && titles[section].count > index {
            lblName.text = titles[section][row * 2 + bright]
            lblCurrentPage.text = "\(index + 1)/\(titles[section].count)"
            for json in waterMarks {
                if json["imageClass"].stringValue == sectionTiltes[section] && index == json["imageSeqNum"].intValue {
                    var imageUrl = "\(NetworkManager.sharedInstall.domain)\(json["imageDesc"].stringValue)"
                    var url = URL(string: imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    ivDetailDesc.sd_setImage(with: url)
                    imageUrl = "\(NetworkManager.sharedInstall.domain)\(json["waterMark"].stringValue)"
                    print("水印：\(imageUrl)")
                    url = URL(string: imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "transport"))
                }
            }
        }else{
            lblName.text = "添加照片"
            lblCurrentPage.text = "\(row * 2 + bright + 1)/\(row * 2 + bright + 1)"
        }
        
    }

    /**
     * Start the session of the camera.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraView.startSession()
    }
    
    /**
     * Enable the button to take the picture when the
     * camera is ready.
     */
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if self.cameraView.session?.isRunning == true {
            self.notifyCameraReady()
        }
        
        guard let device = cameraView.device else {
            return
        }
        
        let image = UIImage(named: flashImage(device.flashMode))
        
        flashButton.setImage(image, for: .normal)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /**
     * This method will disable the rotation of the
     */
//    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//         lastInterfaceOrientation = UIApplication.shared.statusBarOrientation
//        if animationRunning {
//            return
//        }
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        coordinator.animate(alongsideTransition: { animation in
//            self.view.setNeedsUpdateConstraints()
//            }, completion: { _ in
//                CATransaction.commit()
//        })
//    }
    
    /**
     * Observer the camera status, when it is ready,
     * it calls the method cameraReady to enable the
     * button to take the picture.
     */
    private func addCameraObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyCameraReady),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
    }
    
    /**
     * Observer the device orientation to update the
     * orientation of CameraView.
     */
    private func addRotateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotateCameraView),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
    }
    
    internal func notifyCameraReady() {
        cameraButton.isEnabled = true
    }
    
    /**
     * Attach the take of picture for any volume button.
     */
    private func setupVolumeControl() {
        volumeControl = VolumeControl(view: view) { [weak self] _ in
            if self?.cameraButton.isEnabled == true {
              self?.capturePhoto()
            }
        }
    }
    
    /**
     * Configure the action for every button on this
     * layout.
     */
    private func setupActions() {
        cameraButton.action = { [weak self] in self?.capturePhoto() }
        libraryButton.action = { [weak self] in self?.showLibrary() }
        closeButton.action = { [weak self] in self?.close() }
        flashButton.action = { [weak self] in self?.toggleFlash() }
        hintButton.action = {
            [weak self] in
            if self!.lcWidth.constant == 0 {
                self?.lcWidth.constant = MAX - 164 - 20 - 22 - 10
                self?.lcHeight.constant = MIN - 20 - 60
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
                    [weak self] in
                    self?.view.layoutIfNeeded()
                    }, completion: { (finish) in
                        
                })
            }else{
                self?.hideDesc()
            }
        }
    }
    
    func hideDesc() {
        self.lcWidth.constant = 0
        self.lcHeight.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
            [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: { (finish) in
                
        })
    }

    
    /**
     * Toggle the buttons status, based on the actual
     * state of the camera.
     */
    private func toggleButtons(enabled: Bool) {
        [cameraButton,
            closeButton,
            //swapButton,
            libraryButton].forEach({ $0.isEnabled = enabled })
    }
    
    func rotateCameraView() {
        cameraView.rotatePreview()
    }
    
    /**
     * This method will rotate the buttons based on
     * the last and actual orientation of the device.
     */
//    internal func rotate(actualInterfaceOrientation: UIInterfaceOrientation) {
//        
//        if lastInterfaceOrientation != nil {
//            let lastTransform = CGAffineTransform(rotationAngle: CGFloat(radians(currentRotation(
//                lastInterfaceOrientation!, newOrientation: actualInterfaceOrientation))))
//            self.setTransform(transform: lastTransform)
//        }
//
//        let transform = CGAffineTransform(rotationAngle: 0)
//        animationRunning = true
//        
//        /**
//         * Dispach delay to avoid any conflict between the CATransaction of rotation of the screen
//         * and CATransaction of animation of buttons.
//         */
//
//        let time: DispatchTime = DispatchTime.now() + Double(1 * UInt64(NSEC_PER_SEC)/10)
//        DispatchQueue.main.asyncAfter(deadline: time) {
//            
//            CATransaction.begin()
//            CATransaction.setDisableActions(false)
//            CATransaction.commit()
//            
//            UIView.animate(
//                withDuration: self.animationDuration,
//                delay: 0.1,
//                usingSpringWithDamping: self.animationSpring,
//                initialSpringVelocity: 0,
//                options: self.rotateAnimation,
//                animations: {
//                self.setTransform(transform: transform)
//                }, completion: { _ in
//                    self.animationRunning = false
//            })
//            
//        }
//    }
    
//    func setTransform(transform: CGAffineTransform) {
//        self.closeButton.transform = transform
//        //self.swapButton.transform = transform
//        self.libraryButton.transform = transform
//        self.flashButton.transform = transform
//    }
    
    /**
     * Validate the permissions of the camera and
     * library, if the user do not accept these
     * permissions, it shows an view that notifies
     * the user that it not allow the permissions.
     */
    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                DispatchQueue.main.async() {
                    if !granted {
                        self.showNoPermissionsView()
                    }
                }
            }
        }
    }
    
    /**
     * Generate the view of no permission.
     */
    private func showNoPermissionsView(library: Bool = false) {
        let permissionsView = PermissionsView(frame: view.bounds)
        let title: String
        let desc: String
        
        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }
        
        permissionsView.configureInView(view, title: title, descriptiom: desc, completion: close)
    }
    
    /**
     * This method will be called when the user
     * try to take the picture.
     * It will lock any button while the shot is
     * taken, then, realease the buttons and save
     * the picture on the device.
     */
    internal func capturePhoto() {
        if self.lcWidth.constant != 0 {
            self.hideDesc()
            return
        }
        guard let output = cameraView.imageOutput,
            let connection = output.connection(withMediaType: AVMediaTypeVideo) else {
            return
        }
        
        if connection.isEnabled {
            toggleButtons(enabled: false)
            cameraView.capturePhoto {[weak self] image in
                guard let image = image else {
                    self?.toggleButtons(enabled: true)
                    return
                }
                self?.saveImage(image: image)
            }
        }
    }
    
    internal func saveImage(image: UIImage) {
        self.layoutCameraResult(image: image)
    }
    
    // 关闭按钮事件
    internal func close() {
        if self.lcWidth.constant != 0 {
            self.hideDesc()
            return
        }
        onCompletion?(imageInfo.0, imageInfo.1)
        self.dismiss(animated: true) { 
            
        }
    }
    
    // 相册按钮事件
    internal func showLibrary() {
        if self.lcWidth.constant != 0 {
            self.hideDesc()
            return
        }
        if libraryButton.title(for: .normal) == "重拍" {
            cameraView.startSession()
            ivSnap.isHidden = true
            flashButton.isHidden = false
            libraryButton.setTitle("相册", for: .normal)
            nextButton.setTitle("取消", for: .normal)
            cameraButton.isHidden = false
            imageInfo = (nil , nil)
            
        }else{
            
            let status = ALAssetsLibrary.authorizationStatus()
            if status == ALAuthorizationStatus.restricted || status == ALAuthorizationStatus.denied {
                let alert = UIAlertController(title: "提示", message: "请至设置里开启相册功能", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: { 
                    
                })
                return
            }
            
            let imagePicker = CameraViewController.imagePickerViewController(croppingEnabled: allowCropping) { image, asset in
                
                defer {
                    self.dismiss(animated: true, completion: nil)
                }
                
                guard let image = image, let asset = asset else {
                    return
                }
                
                self.ivSnap.isHidden = false
                self.ivSnap.image = image
                self.flashButton.isHidden = true
                self.libraryButton.setTitle("重拍", for: .normal)
                self.cameraButton.isHidden = true
                
                let section = self.nTag / 1000
                let row = self.nTag % 1000 % 100
                let bright = self.nTag % 1000 >= 100 ? 1 : 0
                
                if self.titles.count > section && self.titles[section].count > (row * 2 + bright) + 1 {
                    let array = Array(self.companyNeed)
                    if array.contains(self.nTag) && array.last! != self.nTag {
                        self.nextButton.setTitle("拍下一张", for: .normal)
                    }else{
                        self.nextButton.setTitle("完成", for: .normal)
                    }
                }else{
                    self.nextButton.setTitle("完成", for: .normal)
                }
                
                self.imageInfo = (image , asset)
            }
            
            present(imagePicker, animated: true) {
                self.cameraView.stopSession()
            }
        }
    }
    
    // 闪光灯按钮
    internal func toggleFlash() {
        if self.lcWidth.constant != 0 {
            self.hideDesc()
            return
        }
        cameraView.cycleFlash()
        
        guard let device = cameraView.device else {
            return
        }
  
        let image = UIImage(named: flashImage(device.flashMode))
        
        flashButton.setImage(image, for: .normal)
    }
    
    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevicePosition.front
    }
    
    // 按拍照按钮
    internal func layoutCameraResult(image: UIImage) {
        cameraView.stopSession()
        
        toggleButtons(enabled: true)
        
        self.ivSnap.isHidden = false
        self.ivSnap.image = image
        self.flashButton.isHidden = true
        self.libraryButton.setTitle("重拍", for: .normal)
        self.cameraButton.isHidden = true
        
        let section = self.nTag / 1000
        let row = self.nTag % 1000 % 100
        let bright = self.nTag % 1000 >= 100 ? 1 : 0
        
        if self.titles.count > section && self.titles[section].count > (row * 2 + bright) + 1 {
            let array = Array(self.companyNeed)
            if array.contains(self.nTag) && array.last! != self.nTag {
                self.nextButton.setTitle("拍下一张", for: .normal)
            }else{
                self.nextButton.setTitle("完成", for: .normal)
            }
        }else{
            self.nextButton.setTitle("完成", for: .normal)
        }
        self.imageInfo = (image , nil)
    }
    
    // 拍下一张或者取消
    func doNextOrCancel(button : UIButton)  {
        if self.lcWidth.constant != 0 {
            self.hideDesc()
            return
        }
        if button.title(for: .normal) == "取消" {
            onCompletion?(nil , nil)
            self.dismiss(animated: true, completion: { 
                
            })
        }else if button.title(for: .normal) == "完成" {
            onCompletion?(imageInfo.0 , imageInfo.1)
            self.dismiss(animated: true, completion: {
                
            })
        }else{
            if companyNeed.count > 0 {
                if companyNeed.contains(nTag) {
                    let array = Array(companyNeed)
                    let index = array.index(of: nTag)
                    nTag = array[index! + 1]
                    onCompletion?(imageInfo.0 , imageInfo.1)
                    imageInfo = (nil , nil)
                    NotificationCenter.default.post(name: Notification.Name("detectionnew"), object: 3, userInfo: ["tag" : nTag])
                    
                    cameraView.startSession()
                    ivSnap.isHidden = true
                    flashButton.isHidden = false
                    cameraButton.isHidden = false
                    libraryButton.setTitle("相册", for: .normal)
                    
                    self.nextButton.setTitle("取消", for: .normal)
                    
                    let section = nTag / 1000
                    let row = nTag % 1000 % 100
                    let bright = nTag % 1000 >= 100 ? 1 : 0
                    let index2 = row * 2 + bright
                    if titles.count > section && titles[section].count > index2 {
                        lblName.text = titles[section][row * 2 + bright]
                        lblCurrentPage.text = "\(index2 + 1)/\(titles[section].count)"
                        for json in waterMarks {
                            if json["imageClass"].stringValue == sectionTiltes[section] && index2 == json["imageSeqNum"].intValue {
                                var imageUrl = "\(NetworkManager.sharedInstall.domain)\(json["imageDesc"].stringValue)"
                                var url = URL(string: imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                                ivDetailDesc.sd_setImage(with: url)
                                imageUrl = "\(NetworkManager.sharedInstall.domain)\(json["waterMark"].stringValue)"
                                print("水印：\(imageUrl)")
                                url = URL(string: imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "mask_left_45"))
                            }
                        }
                    }else{
                        lblName.text = "添加照片"
                        lblCurrentPage.text = "\(row * 2 + bright + 1)/\(row * 2 + bright + 1)"
                    }
                    
                    
                }else{
                    // 添加只能单拍
                    
                }
            }
        }
    }
    
    // 设置屏幕方向
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}
