# Ethereum Multi-Signature Wallet Smart Contract

## About

This is one of the first smart contracts I wrote while learning Solidity. It creates an ETH multisig wallet on an Ethereum blockchain.

A multisig wallet is a wallet that requires signatures (approvals) from multiple addresses that own the wallet for outgoing transfers to take place. For example, a 2-of-3 multisig wallet needs 2 signatures from a total of 3 owner addresses to authorize a withdrawal.

## Setup

### Set Initialization Parameters

1. `_requiredApprovals`: Number of signatures required for a withdrawal
2. `_ownerAddresses`: List of Ethereum addresses owning the multisig wallet

### Example Deployment

The [Remix IDE](https://remix.ethereum.org) can be used to quickly deploy a smart contract and run transactions in a sandbox Ethereum blockchain in the browser.

For a 3-of-4 multisig wallet instance of the smart contract, the initialization parameter list looks like this:

```
3, ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
```

How to use the Remix IDE:

1. Create a new file and paste the contents of the smart contract. Save the file by pressing Ctrl + S.
2. Open the `Deploy & run transactions` tab and insert the initialization parameter list next to the `Deploy` button. Deploy the `MultisigWallet` contract.
3. Expand the deployed contract listed under `Deployed Contracts` to see all its functions that you can execute.
