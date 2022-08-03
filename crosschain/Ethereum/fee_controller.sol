// SPDX-License-Identifier: MIT
// compiler 8.1

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract FeeController is Ownable {
    /*
    수수료 컨트롤러
    */
    struct feeStruct{
        uint mint_fee;
        uint switch_fee;
    }
    feeStruct private fee;

    constructor() {
        fee.mint_fee = 0.001 ether;
        fee.switch_fee = 0.001 ether;
    }

    function _stringCompare(string memory a, string memory b) private pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function updateFee(string memory target, uint new_fee) public onlyOwner {
        // 수수료 변경 (단위 Wei)

        if (_stringCompare(target, "mint")) {
            fee.mint_fee = new_fee;
        }
        else if (_stringCompare(target, "switch")) {
            fee.switch_fee = new_fee;
        }
        else {
            revert("Target fee is invalid.");
        }
    }

    function getFee(string memory target) public view returns(uint) {
        // 수수료 반환 (단위 Wei)

        if (_stringCompare(target, "mint")) {
            return fee.mint_fee;
        }
        else if (_stringCompare(target, "switch")) {
            return fee.switch_fee;
        }
        else {
            revert("Target fee is invalid.");
        }
    }
}