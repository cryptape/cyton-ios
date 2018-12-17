//
//  AppChainBalanceLoader.swift
//  Neuron
//
//  Created by XiaoLu on 2018/12/13.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

class AppChainBalanceLoader {
    private let appChain: AppChain
    private let walletAddress: String

    init(appChain: AppChain, address: String) {
        self.appChain = appChain
        self.walletAddress = address
    }

    func getBalance() throws -> BigUInt {
        return try appChain.rpc.getBalance(address: walletAddress)
    }

    func getERC20Balance(contractAddress: String) throws -> BigUInt {
        return try AppChainERC20(appChain: appChain, contractAddress: contractAddress).balance() ?? 0
    }
}