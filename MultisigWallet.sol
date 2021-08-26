pragma solidity ^0.8.0;

/*
Example initialization for a 3-of-4 multisig wallet contract instance:
3, ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
*/

contract MultisigWallet {
    // Number of required approvals (signatures) for a withdrawal
    uint8 public requiredApprovals;

    // List of addresses owning the multisig wallet
    address[] public owners;

    struct WithdrawalRequest {
        address payable to;
        uint amount;
        uint8 approvals;
        bool executed;
    }
    // List of withdrawal requests
    WithdrawalRequest[] public requests;

    // Map of given approvals for withdrawal requests
    // Owner address --> (index of request --> approved?)
    mapping(address => mapping(uint => bool)) private approvals;

    constructor(uint8 _requiredApprovals, address[] memory _ownerAddresses) {
        require(
            _requiredApprovals <= _ownerAddresses.length,
            "m can't be higher than n in m-of-n multisig wallet."
        );
        require(
            _ownerAddresses.length <= 256,
            "Number of owner addresses too high."
        );
        // Check that owner addresses are unique
        for (uint8 i = 0; i < _ownerAddresses.length; i++) {
            uint8 countFound = 0;
            for (uint8 j = 0; j < _ownerAddresses.length; j++) {
                if (_ownerAddresses[i] == _ownerAddresses[j]) {
                    countFound++;
                }
            }
            require(countFound == 1, "Owner addresses aren't unique.");
        }

        requiredApprovals = _requiredApprovals;
        owners = _ownerAddresses;
    }

    event DepositMade(uint amount);

    event WithdrawalRequested(
        uint index,
        address indexed initiator,
        address indexed to,
        uint amount
    );

    event WithdrawalApproved(
        uint indexed index,
        uint8 approvals,
        address approver
    );

    event WithdrawalExecuted(uint indexed index);

    // Checks that caller is one of the owners
    modifier onlyOwners {
        bool isOwner = false;
        for (uint8 i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Caller isn't owner.");
        _;
    }

    // Deposits to multisig wallet
    function deposit() external payable {
        if (msg.value > 0) {
            emit DepositMade(msg.value);
        }
    }

    // Accepts direct deposits to multisig wallet address
    receive() external payable{}

    // Returns balance of multisig wallet
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Returns all withdrawal requests
    function getAllRequests() public view returns (WithdrawalRequest[] memory) {
        return requests;
    }

    // Creates withdrawal request and approves it by caller
    // Returns index of the newly created request in requests
    function request(address payable _to, uint _amount)
        public
        onlyOwners
        returns (uint)
    {
        require(
            _amount <= address(this).balance,
            "Request exceeds balance of multisig wallet."
        );

        uint index = requests.length;
        requests.push(WithdrawalRequest(_to, _amount, 1, false));
        approvals[msg.sender][index] = true;
        emit WithdrawalRequested(index, msg.sender, _to, _amount);
        return index;
    }

    // Approves withdrawal request and executes it if enough approvals have been given
    function approve(uint _requestIndex) public onlyOwners {
        require(_requestIndex < requests.length, "Request doesn't exist.");
        require(
            !requests[_requestIndex].executed,
            "Request has already been executed."
        );
        require(
            !approvals[msg.sender][_requestIndex],
            "Request has already been approved by caller."
        );

        // Approve
        approvals[msg.sender][_requestIndex] = true;
        requests[_requestIndex].approvals++;
        emit WithdrawalApproved(
            _requestIndex,
            requests[_requestIndex].approvals,
            msg.sender
        );

        // Execute
        if (requests[_requestIndex].approvals >= requiredApprovals) {
            _execute(_requestIndex);
        }
    }

    // Executes withdrawal request
    function _execute(uint _requestIndex) private onlyOwners {
        WithdrawalRequest storage r = requests[_requestIndex];
        require(
            r.amount <= address(this).balance,
            "Request exceeds balance of multisig wallet."
        );

        r.executed = true;
        emit WithdrawalExecuted(_requestIndex);
        r.to.transfer(r.amount);
    }
}
