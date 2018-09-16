//
//  EthTransactionService.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/7.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol EthTransactionServiceProtocol {

    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt,
                                      walletPassword: String,
                                      gasPrice: BigUInt,
                                      erc20TokenAddress: String,
                                      completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void)
    func send(password: String, transaction: TransactionIntermediate, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void)
}

class EthTransactionServiceImp: EthTransactionServiceProtocol {

    func prepareTransactionForSending(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: UInt = 21000,
                                      walletPassword: String,
                                      gasPrice: BigUInt = BigUInt(1000000000),
                                      erc20TokenAddress: String = "",
                                      completion:  @escaping (SendEthResult<TransactionIntermediate>) -> Void) {

        let keyStoreStr = WalletCryptService.didCheckoutKeyStoreWithCurrentWallet(password: walletPassword)
        let currentWalletAddress = WalletRealmTool.getCurrentAppmodel().currentWallet?.address

        DispatchQueue.global().async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.invalidAmountFormat))
                }
                return
            }

            let web3 = Web3NetWork.getWeb3()
            guard let selectedKey = currentWalletAddress else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.noAvailableKeys))
                }
                return
            }
            let ethAddressFrom = EthereumAddress(selectedKey)

            web3.addKeystoreManager(KeystoreManager([EthereumKeystoreV3(keyStoreStr)!]))
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(gasLimit)
            options.from = ethAddressFrom
            options.value = BigUInt(amount)
            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.contractLoadingError))
                }
                return
            }

            guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.retrievingEstimatedGasError))
                }
                return
            }
            options.gasLimit = estimatedGas
            //            guard let gasPrice = web3.eth.getGasPrice().value else {
            //                DispatchQueue.main.async {
            //                    completion(SendEthResult.Error(SendEthErrors.retrievingGasPriceError))
            //                }
            //                return
            //            }
            options.gasPrice = gasPrice
            guard let transaction = contract.method(options: options) else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.createTransactionIssue))
                }
                return
            }

            DispatchQueue.main.async {
                completion(SendEthResult.Success(transaction))
            }
        }
    }

    func send(password: String, transaction: TransactionIntermediate, completion: @escaping (SendEthResult<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password, options: nil)
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(SendEthResult.Error(SendEthErrors.emptyResult))
                }
                return
            }
            DispatchQueue.main.async {
                completion(SendEthResult.Success(value))
            }
        }

    }

}
