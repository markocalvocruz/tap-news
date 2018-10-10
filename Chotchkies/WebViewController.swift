//
//  WebViewController.swift
//  Chotchkies
//
//  Created by Mark Calvo-Cruz on 3/15/18.
//  Copyright © 2018 hello U. All rights reserved.
//


import UIKit
import WebKit


class WebViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    
    var webView: WKWebView!
    var request: URLRequest!
    var delegate: WKUIDelegate?
    var url_string: String?
    var hasFinishedLoading = false
    override var prefersStatusBarHidden: Bool {
        return true
    }


    @IBAction func closeButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: .zero)
        super.init(coder: aDecoder)
        webView.uiDelegate = self
        
    }
    
    
    deinit {
        webView.stopLoading()
        webView.uiDelegate = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(url_string)
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isHidden = false
        view.addSubview(webView)
        view.sendSubview(toBack: webView)
        self.delegate = self
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        if let url  = URL(string: (self.url_string)!) {
            print("VALID URL: \(url.absoluteURL)")
            request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.updateProgress()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    
    
    func updateProgress() {
        if progressView.progress >= 1 {
            progressView.isHidden = true
        } else {
            
            if hasFinishedLoading {
                progressView.progress += 0.002
            } else {
                if progressView.progress <= 0.3 {
                    progressView.progress += 0.004
                } else if progressView.progress <= 0.6 {
                    progressView.progress += 0.002
                } else if progressView.progress <= 0.9 {
                    progressView.progress += 0.001
                } else if progressView.progress <= 0.94 {
                    progressView.progress += 0.0001
                } else {
                    progressView.progress = 0.9401
                }
            }
            
            /**delay(delay: 0.008) { [weak self] in
                if let _self = self {
                    _self.updateProgress()
                }
            }**/
        }
    }
}

extension WebViewController: WKUIDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        hasFinishedLoading = false
        updateProgress()
        print("Article started loading")

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        /**delay(delay: 1) { [weak self] in
            if let _self = self {
                _self.hasFinishedLoading = true
            }
        }**/        print("Article finished loading")
    }
    
    
}



