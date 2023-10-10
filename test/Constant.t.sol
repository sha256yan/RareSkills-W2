// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Ecosystem-1/NFT.sol";

contract ConstantTest is Test {
    uint256 constant MAX_SUPPLY = 20;

    function testConstant() public view {
        uint256 num;
        assembly {
            num := sload(0)
        }
        console.log(num);
    }
}
