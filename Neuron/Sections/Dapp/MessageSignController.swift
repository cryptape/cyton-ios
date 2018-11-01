//
//  MessageSignController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/30.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

protocol MessageSignControllerDelegate: class {
    func messageSignCallBackWebView(id: Int, value: String, error: DAppError?)
}

class MessageSignController: UIViewController {
    var requestUrlString = ""
    var dappCommonModel: DAppCommonModel!
    weak var delegate: MessageSignControllerDelegate?
    private var chainType: ChainType = .appChain
    private var tokenModel = TokenModel()
    private var messageSignShowViewController: MessageSignShowViewController!
    private var confirmSendViewController: ConfirmSendViewController!
    private var messageSignPageVC: UIPageViewController!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(x: 0, y: ScreenSize.height, width: ScreenSize.width, height: ScreenSize.height)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
        }, completion: { (_) in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        messageSignShowViewController = storyboard!.instantiateViewController(withIdentifier: "messageSignShowViewController") as? MessageSignShowViewController
        messageSignShowViewController.delegate = self
        confirmSendViewController = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "confirmSendViewController") as? ConfirmSendViewController
        confirmSendViewController.delegate = self
        messageSignPageVC.setViewControllers([messageSignShowViewController], direction: .forward, animated: false)
        setUIData()
    }

    func setUIData() {
        if dappCommonModel.chainType == "AppChain" {
            chainType = .appChain
            messageSignShowViewController.dataText = dappCommonModel.appChain?.data ?? ""
        } else {
            chainType = .eth
            messageSignShowViewController.dataText = dappCommonModel.eth?.data ?? ""
        }
        getTokenModel()
    }

    func getTokenModel() {
        let appModel = WalletRealmTool.getCurrentAppModel()
        switch chainType {
        case .appChain:
            let result = appModel.nativeTokenList.filter { return Int($0.chainId) == self.dappCommonModel.appChain!.chainId}
            guard let model = result.first else {
                return
            }
            self.tokenModel = model
        case .eth:
            let result = appModel.nativeTokenList.filter { return Int($0.chainId) == self.dappCommonModel.eth!.chainId}
            guard let model = result.first else {
                return
            }
            self.tokenModel = model
        }
    }

    func ethSign(password: String) {
        switch dappCommonModel.name {
        case .signMessage:
            ethSignMessage(password: password)
        case .signPersonalMessage:
            ethSignPersonalMessage(password: password)
        default:
            break
        }
    }

    func appChainSign(password: String) {
        switch dappCommonModel.name {
        case .signMessage:
            appChainSignMessage(password: password)
        case .signPersonalMessage:
            appChainSignPersonalMessage(password: password)
        default:
            break
        }
    }

    func ethSignPersonalMessage(password: String) {
        Toast.showHUD()
        ETHSignMessageService.signPersonal(message: dappCommonModel.eth?.data ?? "", password: password) { (result) in
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
            case .error:
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func ethSignMessage(password: String) {
        Toast.showHUD()
        ETHSignMessageService.sign(message: dappCommonModel.eth?.data ?? "", password: password) { (result) in
            switch result {
            case .success(let signed):
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: signed, error: nil)
            case .error:
                self.delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.signTransactionFailed)
            }
            Toast.hideHUD()
            self.view.removeFromSuperview()
        }
    }

    func appChainSignMessage(password: String) {

    }

    func appChainSignPersonalMessage(password: String) {

    }

    func removeView() {
        delegate?.messageSignCallBackWebView(id: self.dappCommonModel!.id, value: "", error: DAppError.userCanceled)
        view.removeFromSuperview()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dappPageViewController" {
            messageSignPageVC = segue.destination as? UIPageViewController
        }
    }
}

extension MessageSignController: MessageSignShowViewControllerDelegate {
    func clickAgreeButton() {
        messageSignPageVC.setViewControllers([confirmSendViewController], direction: .forward, animated: true)
    }

    func clickRejectButton() {
        removeView()
    }
}

extension  MessageSignController: ConfirmSendViewControllerDelegate {
    func closePayCoverView() {
        removeView()
    }

    func confirmPassword(confirmSendViewController: ConfirmSendViewController, password: String) {
        switch chainType {
        case .appChain:
            appChainSign(password: password)
        case .eth:
            ethSign(password: password)
        }
    }
}
