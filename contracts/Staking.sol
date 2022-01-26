// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Staking {
    IERC20 public stakingToken;

    uint public constant DIVISION = 10000;

    uint public lastRewardRate; // S = 0;
    uint public totalStakedAmount; // T = 0;
    mapping(address => uint) public stakedBalance; // stake = {};
    mapping(address => uint) public rewardRate; // S0 = {};

    constructor (address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function stake(uint _amount) external {
        require(_amount > 0);
        uint allowance = stakingToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        stakedBalance[msg.sender] += _amount; // stake[address] = amount;
        rewardRate[msg.sender] = lastRewardRate; // S0[address] = S;
        totalStakedAmount += _amount; // T = T + amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function distribute(uint reward) external {
        require(totalStakedAmount != 0, ""); // if T==0 then revert();
        uint allowance = stakingToken.allowance(msg.sender, address(this));
        require(allowance >= reward, "Check the token allowance");
        stakingToken.transferFrom(msg.sender, address(this), reward);
        /// r / t can be under 0
        lastRewardRate += (reward * DIVISION / totalStakedAmount); // S = S + r / T;
    }

    function unstake(uint _amount) external {
        uint deposited = stakedBalance[msg.sender]; // deposited = stake[address];
        require(_amount <= deposited, "Withdraw amount is invalid");
        uint reward = deposited * (lastRewardRate - rewardRate[msg.sender]) / DIVISION; // reward = deposited * (S - S0[address]);
        rewardRate[msg.sender] = lastRewardRate;
        totalStakedAmount -= _amount; // T = T - deposited;
        stakedBalance[msg.sender] -= _amount; // stake[address] = 0;
        stakingToken.transfer(msg.sender, _amount + reward);
    }

    function unstakeAll() external {
        uint deposited = stakedBalance[msg.sender]; // deposited = stake[address];
        uint reward = deposited * (lastRewardRate - rewardRate[msg.sender]) / DIVISION; // reward = deposited * (S - S0[address]);
        totalStakedAmount -= deposited; // T = T - deposited;
        stakedBalance[msg.sender] = 0; // stake[address] = 0;
        stakingToken.transfer(msg.sender, deposited + reward);
    }

    function getReward(address account) public view returns (uint){
        uint deposited = stakedBalance[account]; // deposited = stake[address];
        return deposited * (lastRewardRate - rewardRate[account]) / DIVISION; // reward = deposited * (S - S0[address]);
    }
}
