//
//  DAppDataHandle.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import WebKit

//enum DAppDataHandle {
//    case sendTransaction(Data)
//    case signTransaction(Data)
//    case signPersonalMessage(Data)
//    case signMessage(Data)
//    case signTypedMessage(Data)
//    case unknown
//}

struct DAppDataHandle {
    static func fromMessage(message: WKScriptMessage) throws -> DAppCommonModel {
        let decoder = JSONDecoder()
        guard let body = message.body as? [String: AnyObject] else {
            throw DAppAction.Error.emptyTX
        }
        let objectData = try! JSONSerialization.data(withJSONObject: body, options: .init(rawValue: 0))
        let objectModel = try! decoder.decode(DAppCommonModel.self, from: objectData)
        return objectModel
    }
}

//enum DAppDataResult<T> {
//    case appChain(AppChainDAppModel)
//    case ethChain(ETHDAppModel)
//    case error(Error)
//}