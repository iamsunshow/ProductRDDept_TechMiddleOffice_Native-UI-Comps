/// 通用 H5 容器：加载外部内容平台页面（帮助 / 协议等）。

import UIKit
import WebKit
import SnapKit

/// 全屏 WKWebView，用于打开 `LegalContentConfig` 等外部 URL。
final class WebContentViewController: UIViewController, WKNavigationDelegate {
    private let pageTitle: String
    private let url: URL
    private let webView = WKWebView(frame: .zero)
    private let progress = UIProgressView(progressViewStyle: .default)
    private var progressObservation: NSKeyValueObservation?

    /// - Parameters:
    ///   - title: 导航标题
    ///   - url: 目标地址
    init(title: String, url: URL) {
        self.pageTitle = title
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    deinit {
        progressObservation?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = pageTitle
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        progress.progressTintColor = AppColor.primary
        progress.trackTintColor = AppColor.border

        view.addSubview(progress)
        view.addSubview(webView)
        progress.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(2)
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] web, _ in
            guard let self else { return }
            self.progress.isHidden = web.estimatedProgress >= 1
            self.progress.setProgress(Float(web.estimatedProgress), animated: true)
        }

        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(
            title: "无法打开页面",
            message: "请检查网络，或确认内容平台地址已配置。\n\(url.absoluteString)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}
