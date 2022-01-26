// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    IERC20 public stakingToken;

    uint public lastRewardRate; // S = 0;
    uint private totalStakedAmount; // T = 0;
    mapping(address => uint) private stakedBalance; // stake = {};
    mapping(address => uint) private rewardRate; // S0 = {};

    constructor (address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function deposit(address account, uint _amount) external {
        stakedBalance[account] += _amount; // stake[address] = amount;
        rewardRate[account] = lastRewardRate; // S0[address] = S;
        totalStakedAmount += _amount; // T = T + amount;
        stakingToken.transferFrom(account, address(this), _amount);
    }

    function distribute(uint reward) external {
        require(totalStakedAmount != 0, ""); // if T==0 then revert();
        lastRewardRate += reward / totalStakedAmount; // S = S + r / T;
    }

    function withdraw(address account) external {
        uint deposited = stakedBalance[account]; // deposited = stake[address];
        uint reward = deposited * (lastRewardRate - rewardRate[account]); // reward = deposited * (S - S0[address]);
        totalStakedAmount -= deposited; // T = T - deposited;
        stakedBalance[account] = 0; // stake[address] = 0;
        stakingToken.transfer(account, deposited + reward);
        return deposited + reward; // return deposited + reward
    }

    function getReward(address account) public view {

    }
}
