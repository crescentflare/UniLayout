//
//  UniWebView.swift
//  UniLayout Pod
//
//  Library view: a web view
//  Extends UIView containing a UIWebView to support properties for UniLayout containers and padding
//

import UIKit

/// A UniLayout enabled UIWebView, adding padding and layout properties
open class UniWebView: UIView, UniLayoutView, UniLayoutPaddedView {

    // ---
    // MARK: Layout integration
    // ---
    
    public var layoutProperties = UniLayoutProperties()
    public var padding = UIEdgeInsets.zero
    
    public var visibility: UniVisibility {
        set {
            isHidden = newValue != .visible
            layoutProperties.hiddenTakesSpace = newValue == .invisible
        }
        get {
            if isHidden {
                return layoutProperties.hiddenTakesSpace ? .invisible : .hidden
            }
            return .visible
        }
    }

    
    // ---
    // MARK: Members
    // ---
    
    private var webView = UniNotifyingWebView()

    
    // ---
    // MARK: UIWebView properties
    // ---
    
    public var delegate: UIWebViewDelegate? {
        get {
            return webView.delegate
        }
        set {
            webView.delegate = newValue
        }
    }
    
    public var request: URLRequest? {
        get {
            return webView.request
        }
    }

    public var canGoBack: Bool {
        get {
            return webView.canGoBack
        }
    }

    public var canGoForward: Bool {
        get {
            return webView.canGoForward
        }
    }
    
    public var isLoading: Bool {
        get {
            return webView.isLoading
        }
    }
    
    public var internalWebView: UIWebView {
        get {
            return webView
        }
    }

    
    // ---
    // MARK: Initialization
    // ---

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(webView)
    }
    
    
    // ---
    // MARK: UIWebView methods
    // ---

    public func loadRequest(_ request: URLRequest) {
        webView.loadRequest(request)
    }

    public func loadHTMLString(_ string: String, baseURL: URL? = nil) {
        webView.loadHTMLString(string, baseURL: baseURL)
    }

    public func loadData(_ data: Data, mimeType: String, textEncodingName: String, baseURL: URL) {
        webView.load(data, mimeType: mimeType, textEncodingName: textEncodingName, baseURL: baseURL)
    }

    public func reload() {
        webView.reload()
    }

    public func stopLoading() {
        webView.stopLoading()
    }

    public func goBack() {
        webView.goBack()
    }

    public func goForward() {
        webView.goForward()
    }

    
    // ---
    // MARK: Custom layout
    // ---

    open func measuredSize(sizeSpec: CGSize, widthSpec: UniMeasureSpec, heightSpec: UniMeasureSpec) -> CGSize {
        let paddedSize = CGSize(width: max(0, sizeSpec.width - padding.left - padding.right), height: max(0, sizeSpec.height - padding.top - padding.bottom))
        var result = CGSize(width: padding.left + padding.right, height: padding.top + padding.bottom)
        let webviewResult = webView.systemLayoutSizeFitting(paddedSize, withHorizontalFittingPriority: widthSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired, verticalFittingPriority: heightSpec == .unspecified ? UILayoutPriorityFittingSizeLevel : UILayoutPriorityRequired)
        result.width += webviewResult.width
        result.height += webviewResult.height
        if widthSpec == .exactSize {
            result.width = sizeSpec.width
        } else if widthSpec == .limitSize {
            result.width = min(result.width, sizeSpec.width)
        }
        if heightSpec == .exactSize {
            result.height = sizeSpec.height
        } else if heightSpec == .limitSize {
            result.height = min(result.height, sizeSpec.height)
        }
        return result
    }

    open override func layoutSubviews() {
        UniLayout.setFrame(view: webView, frame: CGRect(x: padding.left, y: padding.top, width: max(0, bounds.width - padding.left - padding.right), height: max(0, bounds.height - padding.top - padding.bottom)))
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return measuredSize(sizeSpec: targetSize, widthSpec: horizontalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified, heightSpec: verticalFittingPriority == UILayoutPriorityRequired ? UniMeasureSpec.limitSize : UniMeasureSpec.unspecified)
    }
    
}

class UniNotifyingWebView: UIWebView {
    
    // ---
    // MARK: Hook layout into content changes
    // ---
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        if superview is UniLayoutView {
            UniLayout.setNeedsLayout(view: superview!)
        }
    }
    
}
