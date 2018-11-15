//
//  TransactionHistoryPresenter.swift
//  Neuron
//
//  Created by 晨风 on 2018/11/14.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import UIKit

class TransactionHistoryPresenter {
    private(set) var transactions = [TransactionDetails]()
    let token: TokenModel

    init(token: TokenModel) {
        self.token = token
        walletAddress = WalletRealmTool.getCurrentAppModel().currentWallet!.address
        tokenAddress = token.address
        tokenType = token.type
//        NotificationCenter.default.addObserver(
//            forName: TransactionStatusManager.transactionStatusChangedNotification,
//            object: nil,
//            queue: OperationQueue.main) { (notification) in
//            print(notification.userInfo ?? [:])
//        }
    }

    deinit {
    }

    func reloadData(completion: @escaping ([Int], Error?) -> Void) {
        guard loading == false else { return }
        transactions = []
        page = 1
        loadMoreData(completion: completion)
    }

    func loadMoreData(completion: @escaping ([Int], Error?) -> Void) {
        guard loading == false else { return }
        loading = true
        DispatchQueue.global().async {
            do {
                let list = try self.loadData()
                if list.count > 0 {
                    self.loading = false
                    self.page += 1
                }
                var insertions = [Int]()
                for idx in list.indices {
                    insertions.append(self.transactions.count + idx)
                }
                self.transactions.append(contentsOf: list)
                DispatchQueue.main.async {
                    completion(insertions, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }

    // MARK: -
    private var loading = false
    private var page: UInt = 1
    private var pageSize: UInt = 10
    private let walletAddress: String
    private let tokenAddress: String
    private let tokenType: TokenModel.TokenType

    private func loadData() throws -> [TransactionDetails] {
        switch tokenType {
        case .nervos:
            return try AppChainTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .ethereum:
            return try EthereumTransactionHistory().getTransactionHistory(walletAddress: walletAddress, page: page, pageSize: pageSize)
        case .erc20:
            return try EthereumTransactionHistory().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        case .nervosErc20:
            return try AppChainTransactionHistory().getErc20TransactionHistory(walletAddress: walletAddress, tokenAddress: tokenAddress, page: page, pageSize: pageSize)
        }
    }
}
