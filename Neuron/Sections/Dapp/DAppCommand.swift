//
//  DAppCommand.swift
//  Neuron
//
//  Created by XiaoLu on 2018/10/16.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

//struct AppChainDAppModel: Decodable {
//    let name: Method
//    let id: Int
//    let chainType: String
//    let object: AppChainObject
//}

struct AppChainObject: Decodable {
    let chainId: Int
    let data: String
    let nonce: Double
    let quota: Double
    let to: String
    let validUntilBlock: Double
    let value: String
    let version: Int
}

struct DAppCommonModel: Decodable {
    let name: Method
    let id: Int
    let chainType: String
    private let object: Any

    var eth: ETHObject? {
        return object as? ETHObject
    }
    var appChain: AppChainObject? {
        return object as? AppChainObject
    }

    enum CodingKeys: String, CodingKey {
        case name
        case id
        case chainType
        case object
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try! values.decode(Method.self, forKey: .name)
        id = try! values.decode(Int.self, forKey: .id)
        chainType = try! values.decode(String.self, forKey: .chainType)
        if chainType == "AppChain" {
            object = try! values.decode(AppChainObject.self, forKey: .object)
        } else {
            object = try! values.decode(ETHObject.self, forKey: .object)
        }
    }
}

struct ETHObject: Decodable {
    let chainId: Int
    let Data: String?
    let from: String
    let to: String?
    let gasLimit: Double?
    let gasPrice: Double?
}