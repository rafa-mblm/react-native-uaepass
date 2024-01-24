//
//  UAEPassViewController.swift
//
//  Created by Vyshakh on 18/10/2023.
//  parakkatvyshakh@gmail.com

import UAEPassClient


class UAEPassViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UAEPASSRouter.shared.spConfig = SPConfig(redirectUriLogin: UAEPass.redirectURL!,
                                             scope: "urn:uae:digitalid:profile:general",
                                             state: "HnlHOJTkTb66Y5H",  //Randomly Generated Code 24 alpha numeric.
                                             successSchemeURL: UAEPass.scheme + "://" + UAEPass.successHost!, //client success url scheme.
                                             failSchemeURL: UAEPass.scheme + "://" + UAEPass.failureHost!, //client failure url scheme.
                                             signingScope: UAEPass.scope!) // client signing scope.
    UAEPASSRouter.shared.environmentConfig = UAEPassConfig(clientID: UAEPass.clientId!, clientSecret: "", env: .staging)

    login()

  }

  func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return  String((0..<length).map{ _ in letters.randomElement()! })
  }


  func login() {

    if let webVC = UAEPassWebViewController.instantiate() as? UAEPassWebViewController {

      webVC.urlString = UAEPassConfiguration.getServiceUrlForType(serviceType: .loginURL)

      print(webVC.urlString)

      //print(webVC.urlString)
      let topViewController = UIApplication.shared.windows.last { $0.isKeyWindow }?.rootViewController
//      if let topViewController = UserInterfaceInfo.topViewController() {
        webVC.onUAEPassSuccessBlock = {(code: String?) -> Void in
          topViewController?.dismiss(animated: true)
          if let code = code {
            var returnData = [String: String]()
            returnData["accessCode"] = code
            returnData["isSuccess"] = "true"
            returnData["url"] = webVC.urlString
            UAEPass.resolveResponse(returnData)
          }else{
            let error = NSError(domain: "", code: 400)
            UAEPass.rejectResponse("ERROR", "Failed to get access code", error)
          }
        }
        webVC.onUAEPassFailureBlock = {(response: String?) -> Void in
          topViewController?.dismiss(animated: true)
          let error = NSError(domain: "", code: 400)
          UAEPass.rejectResponse("ERROR", response, error)
        }
        webVC.reloadwithURL(url: webVC.urlString)



        let configuration = WKWebViewConfiguration()
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webVC.webView?.configuration.userContentController.addUserScript(script)

        webVC.webView?.isMultipleTouchEnabled = false;
        webVC.webView?.contentMode = .scaleAspectFit
        webVC.webView?.scrollView.minimumZoomScale = 1.0
        webVC.webView?.scrollView.maximumZoomScale = 1.0
        webVC.webView?.scrollView.bounces = false

        self.present(webVC, animated: true)
//      }
    }
  }






}
