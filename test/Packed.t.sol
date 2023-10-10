// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Ecosystem-1/NFT.sol";
import {PackedSlotHandler} from "src/Ecosystem-1/PackedSlotHandler.sol";

contract PackedTest is Test, PackedSlotHandler {
    uint256 constant MAX_SUPPLY = 20;

    function testPriceChange() public {
        _setPrice(1 ether);
        assert((packedBitmapAndPrice & PRICE_MASK) == 1 ether);
    }

    function testPriceChangeFuzz(uint256 price) public {
        vm.assume(price < (1 << TOKENID_POS));
        _setPrice(price);
        assert((packedBitmapAndPrice & PRICE_MASK) == price);
    }

    function testTicketSpend() public {
        _spendTicket(0);
        console.logBytes32(bytes32(packedBitmapAndPrice & TICKETS_MASK));

        _spendTicket(4);
        console.logBytes32(bytes32(packedBitmapAndPrice & TICKETS_MASK));

        vm.expectRevert("Already spent");
        _spendTicket(4);
    }

    function testIncrementId() public {
        for (uint256 i; i < 20; ++i) {
            _incrementTokenId();
            console.logBytes32(bytes32(packedBitmapAndPrice & TOKENID_MASK));
        }
    }
}
