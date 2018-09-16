//
//  NervosQuoteViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/9/13.
//  Copyright © 2018年 Cryptape. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import BigInt
import Nervos

protocol NervosQuoteViewControllerDelegate: class {
    func getNervosTransactionQuota(nervosQuoteViewController: NervosQuoteViewController, quota: BigUInt, data: Data)
}

class NervosQuoteViewController: UIViewController {
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var quotaTextField: UITextField!
    @IBOutlet weak var hexTextView: RSKPlaceholderTextView!
    var tokenModel = TokenModel()
    var quota = BigUInt(1000000)
    var data = Data()
    weak var delegate: NervosQuoteViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        quotaTextField.delegate = self
        quotaTextField.text = quota.description
        getNervosTransactionCosted(with: quota)
        delegate?.getNervosTransactionQuota(nervosQuoteViewController: self, quota: quota, data: data)
    }

    func getNervosTransactionCosted(with quotaInput: BigUInt) {
        gasLabel.text = Utils.formatToEthereumUnits(quotaInput, toUnits: .Gwei, decimals: 4, fallbackToScientific: false)! + " \(tokenModel.symbol)"
    }
}

extension NervosQuoteViewController: UITextFieldDelegate, UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let quotaInput = textField.text else {
            return
        }
        if quotaInput.count == 0 {
            NeuLoad.showToast(text: "quota不能为空")
            textField.text = quota.description
            return
        }
        let textFieldValue = BigUInt(quotaInput)!
        if textFieldValue < BigUInt(1000000) {
            NeuLoad.showToast(text: "quota值不能少于1000000")
            textField.text = quota.description
            return
        }
        quota = BigUInt(quotaInput)!
        getNervosTransactionCosted(with: quota)
        delegate?.getNervosTransactionQuota(nervosQuoteViewController: self, quota: quota, data: data)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let dataString = textView.text else {
            return
        }
        guard let tempData = Data.fromHex(dataString) else {
            return
        }
        data = tempData
        delegate?.getNervosTransactionQuota(nervosQuoteViewController: self, quota: quota, data: tempData)
    }
}
