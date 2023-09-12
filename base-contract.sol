// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract BaseContract {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
