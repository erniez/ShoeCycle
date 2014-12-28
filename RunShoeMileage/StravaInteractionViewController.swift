//
//  StravaInteractionViewController.swift
//  ShoeCycle
//
//  Created by El Guapo on 12/24/14.
//
//

import UIKit

class StravaInteractionViewController: UIViewController, UIWebViewDelegate {

    // MARK: -  Properties
    
    private var webview: UIWebView!
    var tempToken: NSString!
    let networkHTTPManager:AFHTTPSessionManager = AFHTTPSessionManager()
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let targetURL: NSURL = NSURL(string: "https://www.strava.com/oauth/authorize?client_id=4002&response_type=code&redirect_uri=http://shoecycleapp.com/callback&scope=write")!
        self.webview = UIWebView(frame: self.view.bounds)
        self.webview.delegate = self
        self.view.addSubview(self.webview!)
        
        let request = NSURLRequest(URL: targetURL)
        self.webview.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UIWebView delegate
    
    func webView(webView: UIWebView,
        shouldStartLoadWithRequest request: NSURLRequest,
        navigationType: UIWebViewNavigationType) -> Bool {
            let requestURL:NSURL = request.URL
            let URLString:NSString = requestURL.absoluteString!
            if (URLString.containsString("shoecycleapp.com/callback") &&
                !URLString.containsString("redirect_uri")) {
                    if  (URLString.containsString("code")) {
                        let tempArray:NSArray = URLString.componentsSeparatedByString("code=")
                        self.tempToken = tempArray.lastObject as NSString
                        println(URLString)
                        self.didReceiveTemporaryToken()
                    }
            }
            
            return true;
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func didReceiveTemporaryToken() {
        let URLString:NSString = "https://www.strava.com/oauth/token"
        let params = ["client_id" : "4002", "client_secret" : "558112ea963c3427a387549a3361bd6677083ff9", "code" : self.tempToken];
        networkHTTPManager.POST(URLString, parameters: params, success: { (data:NSURLSessionDataTask!, results:AnyObject!) -> Void in
                println("SUCCESS!!!")
                println(results)
                self.saveAccessToken(results["access_token"] as NSString)
            }) { (data:NSURLSessionDataTask!, error:NSError!) -> Void in
                println("FAILURE!!!")
                println(error)
        }
    }
    
    private func saveAccessToken(accessToken: NSString) {
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "ShoeCycleStravaAccessToken")
        println(accessToken)
    }
    
}
