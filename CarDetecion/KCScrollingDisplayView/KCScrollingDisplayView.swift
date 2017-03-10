//
//  KCScrollingDisplayView.swift
//  KevinClient
//
//  Created by Kevin on 2017/3/8.
//  Copyright © 2017年 KevinClient.,Ltd. All rights reserved.
//

import UIKit



enum KCScrollingDisplayViewPageControlAliment {
    case center
    case right
}
fileprivate var kTotalItemsCount: Int = 0
fileprivate let kReuseIdentifier = "KCScrollingDisplayCollectionViewCell"


protocol KCScrollingDisplayViewDelegate {
    func scrollingDisplayView(_ scrollingDisplayView: KCScrollingDisplayView, clickItemWithCurrentIndex: Int)
    func scrollingDisplayView(_ scrollingDisplayView: KCScrollingDisplayView, scrollItemWithCurrentIndex: Int)
}





// MARK: - 接口方法
extension KCScrollingDisplayView {
    
    /// 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法
    func adjustWhenControllerViewWillAppera() {
        if currentIndex() < kTotalItemsCount {
            let indexPath = NSIndexPath(item: currentIndex(), section: 0)
            if scrollDirection == UICollectionViewScrollDirection.horizontal {
                collectionView .scrollToItem(at: indexPath as IndexPath, at:.left, animated: false)
            }
            else {
                collectionView .scrollToItem(at: indexPath as IndexPath, at:.top, animated: false)
            }
        }
    }
}



// MARK: - 数据源接口
class KCScrollingDisplayView: UIView {
    
    /// 图片Url字符串数组
    var imageUrlArr: [String]? {
        didSet {
            if let imageUrlArr = imageUrlArr {
                dataSourceArr = imageUrlArr
            }
        }
    }
    /// 本地图片数组(图片名、绝对路径都可以)
    var imageLocalPathArr: [String]? {
        didSet {
            if let imageLocalPathArr = imageLocalPathArr {
                dataSourceArr = imageLocalPathArr
            }
        }
    }
    /// 文字数据源
    var titleArr: [String]?
    
    
    
    
    // MARK: - 回调接口
    var scrollingDisplayViewDelegate: KCScrollingDisplayViewDelegate?
    /// 闭包监听点击
    var clickCurrentIndexItemCallback: ((_ currentIndex: Int) -> Void)?
    /// 闭包监听滚动
    var scrollCurrentIndexItemCallback: ((_ currentIndex: Int) -> Void)?
    
    
    
    
    // MARK: - 滚动控制接口
    /// 滚动时间，默认2秒，可设置
    var autoScrollTimeInterval: TimeInterval = 2.0 {
        didSet {
            let temp = isAutoScroll
            isAutoScroll = temp
        }
    }
    /// 滚动方向，默认水平滚动，可设置
    var scrollDirection = UICollectionViewScrollDirection.horizontal {
        didSet {
            flowLayout.scrollDirection = scrollDirection
        }
    }
    /// 默认无限循环，可设置
    var isInfiniteLoop = true {
        didSet {
            if dataSourceArr.count > 0 {
                let temp = dataSourceArr
                dataSourceArr = temp
            }
        }
    }
    /// 默认自动滚动，可设置
    var isAutoScroll = true {
        didSet {
            invalidateTimer()
            if isAutoScroll == true {
                setupTimer()
            }
        }
    }
    
    
    
    
    
    // MARK: - 自定义样式接口
    /// 图片内容模式
    var bannerImageViewContentMode = UIViewContentMode.scaleToFill
    /// 占位图，用于网络未加载到图片时,默认未设置
    var placeholderImageName: String? = nil {
        didSet {
            insertSubview(placeholderImageView, belowSubview: collectionView)
            if let placeholderImageName = placeholderImageName {
                placeholderImageView.image = UIImage(named: placeholderImageName)
            }
        }
    }
    /// 默认显示分页控件，可设置
    var isShowPageControl = true {
        didSet {
            pageControl?.isHidden = !isShowPageControl
        }
    }
    /// 默认一张图不显示分页控件，可设置
    var isShowPageControlWithSinglePage = false {
        didSet {
            pageControl?.isHidden = !isShowPageControlWithSinglePage
        }
    }
    /// 分页控件位置默认居中，可设置
    var pageControlAliment: KCScrollingDisplayViewPageControlAliment = .center
    /// 分页控件圆点大小默认(10,10),可设置
    var pageControlDotSize: CGSize = CGSize(width: 10.0, height: 10.0)
    /// 分页控件居右时与右边的间距,默认为10
    var pageControlRightOrigin: CGFloat = 10.0
    /// 分页控件与底部的间距,默认为10
    var pageControlBottomOrigin: CGFloat = 10.0
    /// 分页控件当前点颜色，默认白色
    var currentPageDotColor = UIColor.white {
        didSet {
            pageControl?.currentPageIndicatorTintColor = currentPageDotColor
        }
    }
    /// 其他分页控件颜色,默认亮灰色
    var pageDotColor = UIColor.lightGray {
        didSet {
            pageControl?.pageIndicatorTintColor = pageDotColor
        }
    }
    /// 是否只显示文字轮播,默认为否
    var isOnlyShowText = false {
        didSet {
            if isOnlyShowText == true {
                isShowPageControl = false
            }
        }
    }
    /// 文字背景颜色,默认半透明黑色
    var titleBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    /// 文字颜色，默认白色
    var titleColor = UIColor.white
    /// 字体font,默认14
    var titleFont: CGFloat = 14.0
    /// 文字默认居左
    var titleAlignment = NSTextAlignment.left
    /// 文字控件高度默认30
    var titleLabelHeight: CGFloat = 30.0
    
    
    
    

    
    
    // MARK: - 私有属性
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(KCScrollingDisplayCollectionViewCell.self, forCellWithReuseIdentifier: kReuseIdentifier)
        return collectionView
    }()
    fileprivate lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = self.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = self.scrollDirection
        return flowLayout
    }()
    /// dataSourceArr为空时的占位背景图
    fileprivate lazy var placeholderImageView: UIImageView = {
        let placeholderImageView = UIImageView(frame: self.bounds)
        placeholderImageView.contentMode = UIViewContentMode.scaleAspectFit
        return placeholderImageView
    }()
    /// 可能装着图片URL或者本地图片路径
    fileprivate var dataSourceArr = [String]() {
        didSet {
            invalidateTimer()
            kTotalItemsCount = isInfiniteLoop ? dataSourceArr.count*100 : dataSourceArr.count
            if dataSourceArr.count > 1 {
                collectionView.isScrollEnabled = true
                let temp = isAutoScroll
                isAutoScroll = temp
            }
            else {
                collectionView.isScrollEnabled = false
            }
            setupPageControl()
            collectionView.reloadData()
        }
    }
    fileprivate var pageControl: UIPageControl?
    fileprivate var timer: Timer?
    
    
    
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if collectionView.contentOffset.x == 0 && kTotalItemsCount > 0 {
            var targetIndex = 0
            if isInfiniteLoop == true {
                targetIndex = kTotalItemsCount/2
            }
            else {
                targetIndex = 0
            }
            let indexPath = NSIndexPath(item: targetIndex, section: 0)
            if scrollDirection == UICollectionViewScrollDirection.horizontal {
                collectionView .scrollToItem(at: indexPath as IndexPath, at:.left, animated: false)
            }
            else {
                collectionView .scrollToItem(at: indexPath as IndexPath, at:.top, animated: false)
            }
        }
        
        // pageControl Frame
        let size = CGSize(width: (CGFloat(dataSourceArr.count)*pageControlDotSize.width*1.5), height: pageControlDotSize.height)
        var x = (self.bounds.size.width-size.width)*0.5
        if pageControlAliment == .right {
            x = collectionView.bounds.width - size.width - pageControlRightOrigin
        }
        let y = collectionView.bounds.size.height - size.height - pageControlBottomOrigin
        let frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        pageControl?.frame = frame
        pageControl?.isHidden = !isShowPageControl
    }
    
    deinit {
        //解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    //解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            if isAutoScroll == true {
                invalidateTimer()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}











// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate
extension KCScrollingDisplayView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kTotalItemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseIdentifier, for: indexPath) as! KCScrollingDisplayCollectionViewCell
        let imageInfo = dataSourceArr[currentItemIndex(indexPath.item)]
        
        
        if isOnlyShowText == false {
            
            if imageInfo.hasPrefix("http") {
                // 加载网络图片
                if let placeholderImageName = placeholderImageName {
                    cell.bannerImageView.kf.setImage(with: URL(string: imageInfo), placeholder: UIImage(named: placeholderImageName))
                }
                else {
                    cell.bannerImageView.kf.setImage(with: URL(string: imageInfo))
                }
            }
            else {
                // 加载本地图片
                var image = UIImage(named: imageInfo)
                if image == nil {
                    image = UIImage(contentsOfFile: imageInfo)
                }
                cell.bannerImageView.image = image
            }
        }
        
        
        if let titleArr = titleArr {
            if titleArr.count > 0 && currentItemIndex(indexPath.item) < titleArr.count {
                cell.title = titleArr[currentItemIndex(indexPath.item)]
            }
        }
        
        
        if cell.isHasConfigured == false {
            cell.isOnlyShowText = isOnlyShowText
            cell.bannerImageView.contentMode = bannerImageViewContentMode
            cell.titleLabelHeight = titleLabelHeight
            cell.titleLabel.backgroundColor = titleBackgroundColor
            cell.titleLabel.font = UIFont.systemFont(ofSize: titleFont)
            cell.titleLabel.textColor = titleColor
            cell.titleLabel.textAlignment = titleAlignment
            cell.clipsToBounds = true
            cell.isHasConfigured = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        scrollingDisplayViewDelegate?.scrollingDisplayView(self, clickItemWithCurrentIndex: currentItemIndex(indexPath.item))
        clickCurrentIndexItemCallback?(currentItemIndex(indexPath.item))
    }
    
    // UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dataSourceArr.count > 0 {
            pageControl?.currentPage = currentItemIndex(currentIndex())
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll == true {
            invalidateTimer()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll {
            setupTimer()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if dataSourceArr.count > 0 {
            
            scrollingDisplayViewDelegate?.scrollingDisplayView(self, scrollItemWithCurrentIndex: currentItemIndex(currentIndex()))
            scrollCurrentIndexItemCallback?(currentItemIndex(currentIndex()))
            
        }
    }
}






// MARK: - Event Response
extension KCScrollingDisplayView {
    @objc fileprivate func timerAutoScroll() {
        if kTotalItemsCount > 0 {
            scrollToIndex(currentIndex()+1)
        }
    }
    
    fileprivate func scrollToIndex(_ targetIndex: Int) {
        var targetIndex = targetIndex
        var isAnimated = true
        if targetIndex >= kTotalItemsCount {
            if isInfiniteLoop == true {
                targetIndex = kTotalItemsCount/2
                isAnimated = false
            }
        }
        
        let indexPath = NSIndexPath(item: targetIndex, section: 0)
        if scrollDirection == UICollectionViewScrollDirection.horizontal {
            collectionView .scrollToItem(at: indexPath as IndexPath, at:.left, animated: isAnimated)
        }
        else {
            collectionView .scrollToItem(at: indexPath as IndexPath, at:.top, animated: isAnimated)
        }
        
    }
}






// MARK: - Private Methods
extension KCScrollingDisplayView {
    
    fileprivate func invalidateTimer() {
        
        timer?.invalidate()
        self.timer = nil
        
    }
    
    fileprivate func setupPageControl() {
        
        pageControl?.removeFromSuperview()
        // ==0 只显示文字 ==1 单个隐藏
        if (dataSourceArr.count == 0 ||
            isOnlyShowText == true ||
            (isShowPageControlWithSinglePage == false && dataSourceArr.count == 1)) {
            return
        }
        pageControl = UIPageControl()
        pageControl!.currentPageIndicatorTintColor = currentPageDotColor
        pageControl!.pageIndicatorTintColor = pageDotColor
        pageControl!.numberOfPages = dataSourceArr.count
        pageControl!.currentPage = currentItemIndex(currentIndex())
        pageControl!.isUserInteractionEnabled = false
        addSubview(pageControl!)
    }
    
    fileprivate func setupTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(timerAutoScroll), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    fileprivate func currentIndex() -> Int {
        if collectionView.bounds.size.width == 0 || collectionView.bounds.height == 0 {
            return 0
        }
        else {
            var index = 0
            if flowLayout.scrollDirection == UICollectionViewScrollDirection.horizontal {
                index = Int((collectionView.contentOffset.x + flowLayout.itemSize.width*0.5)/flowLayout.itemSize.width)
            }
            else {
                index = Int((collectionView.contentOffset.y + flowLayout.itemSize.height*0.5)/flowLayout.itemSize.height)
            }
            return (index > 0 ? index : 0)
        }
    }
    
    /// 数据源下标
    fileprivate func currentItemIndex(_ index: Int) -> Int {
        return index % dataSourceArr.count
    }
}
