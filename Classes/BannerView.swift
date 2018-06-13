//
//  Copyright © 2016年 xiAo_Ju. All rights reserved.
//

//! !!: automaticallyAdjustsScrollViewInsets = false 在一个只有这个视图的Controller中加上这句

class BannerView: UIView {
    typealias selectedData = (Int) -> Void
    var pageStepTime = 5 /// 自动滚动时间间隔
    var bgColor: UIColor?
    var imageContentMode = UIViewContentMode.scaleAspectFill
    var isAllowLooping = false {
        willSet {
            if !newValue {
                deinitTimer()
            }
        }
    }

    var handleBack: selectedData? {
        didSet {
            backClosure = handleBack
        }
    }

    var showPageControl = true {
        willSet {
            if !newValue {
                pageControl.removeFromSuperview()
            }
        }
    }

    fileprivate let cellIdentifier = "scrollUpCell"

    private var timer: DispatchSourceTimer?
    fileprivate var count = 0
    fileprivate var isUsingImage = true
    fileprivate var backClosure: selectedData?
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: (self.frame.width - 60) / 2, y: self.frame.height - 30, width: 60, height: 20))
        pageControl.pageIndicatorTintColor = UIColor(white: 0.7, alpha: 0.8)
        return pageControl
    }()

    fileprivate var collectionView: UICollectionView?

    fileprivate var images: [UIImage] = [] {
        didSet {
            if oldValue != images {
                isFirstUse(datas: images)
            }
        }
    }

    fileprivate var urlStrs: [String] = [] {
        didSet {
            if oldValue != urlStrs {
                isFirstUse(datas: urlStrs)
            }
        }
    } /// 图片链接

    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        backgroundColor = UIColor.white
        layout.itemSize = CGSize(width: layout.fixSlit(rect: &bounds, colCount: 1), height: bounds.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView?.collectionViewLayout = layout
        backgroundColor = UIColor.white
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(BannerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
        addSubview(pageControl)
    }

    fileprivate func setTheTimer() {
        if isAllowLooping {
            timer = DispatchSource.makeTimerSource(queue: .main)
            timer?.schedule(deadline: .now() + .seconds(pageStepTime), repeating: .seconds(pageStepTime))
            timer?.setEventHandler {
                self.nextItem()
            }
            timer?.resume()
        }
    }

    fileprivate func deinitTimer() {
        if let time = self.timer {
            time.cancel()
            timer = nil
        }
    }

    func nextItem() {
        if !images.isEmpty {
            let indexPath = collectionView?.indexPathsForVisibleItems.first ?? IndexPath()
            if indexPath.row + 1 < images.count {
                collectionView?.scrollToItem(at: IndexPath(item: indexPath.row + 1, section: 0), at: .centeredHorizontally, animated: true)
            } else {
                collectionView?.scrollToItem(at: IndexPath(item: indexPath.row, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }

    func set(urls: [String]) {
        assert(images.isEmpty, "不要同时设置图片链接和图片")
        if urls.isEmpty { return }

        urlStrs = isAllowLooping ? ([urls[urls.count - 1]] + urls + [urls[0]]) : urls
        isUsingImage = false
        count = urlStrs.count
        pageControl.numberOfPages = urls.count
    }

    func set(images: [UIImage]) {
        assert(urlStrs.isEmpty, "不要同时设置图片链接和图片")
        if images.isEmpty { return }

        self.images = isAllowLooping ? ([images[images.count - 1]] + images + [images[0]]) : images
        count = self.images.count
        pageControl.numberOfPages = images.count
    }

    deinit {
        deinitTimer()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return isUsingImage ? images.count : urlStrs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        if let color = bgColor {
            cell.backgroundColor = color
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
}

extension BannerView: UICollectionViewDelegate {
    // MARK: - UICollectionViewDelegate
    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let bannerCell = (cell as? BannerCell)
        bannerCell?.imageContentMode = imageContentMode
        if isUsingImage {
            bannerCell?.image = images[indexPath.row]
        } else {
            bannerCell?.urlStr = urlStrs[indexPath.row]
        }
    }

    func isFirstUse<T>(datas _: [T]) {
        collectionView?.reloadData()

        if isAllowLooping {
            collectionView?.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let backClosure = self.backClosure {
            backClosure(isAllowLooping ? max(indexPath.row - 1, 0) : indexPath.row)
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_: UIScrollView) {
        deinitTimer()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.width

        let currentPage = {
            let value = page.truncatingRemainder(dividingBy: 1) < 0.3
            if value { // cell过半才改变pageControl
                self.pageControl.currentPage = Int(page) - (self.isAllowLooping ? 1 : 0)
            }
        }

        currentPage()
        guard isAllowLooping else { return }

        if page <= 0.0 {
            // 向右拉
            collectionView?.scrollToItem(at: IndexPath(item: count - 2, section: 0), at: .centeredHorizontally, animated: false)
            pageControl.currentPage = count - 3
        } else if page >= CGFloat(images.count - 1) {
            // 向左
            pageControl.currentPage = 0
            collectionView?.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        } else {
            currentPage()
        }
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        setTheTimer()
    }
}

class BannerCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    var imageContentMode: UIViewContentMode? {
        didSet {
            if let imageContentMode = imageContentMode {
                imageView.contentMode = imageContentMode
                imageView.clipsToBounds = imageContentMode == .scaleAspectFill
            }
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var urlStr: String! {
        didSet {
            if let url = URL(string: urlStr) {
                print(url)
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UICollectionViewFlowLayout {
    /// 修正collection布局有缝隙
    func fixSlit(rect: inout CGRect, colCount: CGFloat, space: CGFloat = 0) -> CGFloat {
        let totalSpace = (colCount - 1) * space
        let itemWidth = (rect.width - totalSpace) / colCount
        let fixValue = 1 / UIScreen.main.scale
        var realItemWidth = floor(itemWidth) + fixValue
        if realItemWidth < itemWidth {
            realItemWidth += fixValue
        }
        let realWidth = colCount * realItemWidth + totalSpace
        let pointX = (realWidth - rect.width) / 2
        rect.origin.x = -pointX
        rect.size.width = realWidth
        return (rect.width - totalSpace) / colCount
    }
}
