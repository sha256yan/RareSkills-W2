// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

abstract contract PackedSlotHandler {
    /// @dev [ TICKETS BITMAP (8 BITS), TOKENID COUNTER (8 BITS), PRICE IN ETH (240 BITS) ]
    uint256 internal packedBitmapAndPrice = 0xff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; // 2^256 - 1

    uint256 constant PRICE_MASK = 0x0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff; // 2^240 - 1
    uint256 constant TICKETS_MASK = 0xff00000000000000000000000000000000000000000000000000000000000000; // (2^8 - 1) << 248
    uint256 constant TOKENID_MASK = 0x00ff000000000000000000000000000000000000000000000000000000000000; // (2^8 - 1) << 240
    uint256 constant TOKENID_POS = 240;
    uint256 constant FINAL_TICKET_POS = 248;

    /// @notice Sets the packed price
    /// @param newPrice The new price to set
    function _setPrice(uint256 newPrice) internal {
        require(newPrice < (1 << TOKENID_POS), "Price too high");
        uint256 currentPacked = packedBitmapAndPrice;
        unchecked {
            packedBitmapAndPrice = (currentPacked & ~PRICE_MASK) | newPrice;
        }
    }

    /// @notice returns the price of a ticket
    function _getPrice() internal view returns (uint256 price) {
        return packedBitmapAndPrice & PRICE_MASK;
    }

    /// @notice changes the value of a  ticket bit to 0
    /// @return success true if the ticket bit was 1, false if it was already 0 (spent ticket)
    function _spendTicket(uint256 ticketIndex) internal returns (uint256 success) {
        //external function does this check: require(ticketIndex < 8, "Invalid ticket index");
        uint256 currentPacked = packedBitmapAndPrice;
        uint256 ticketBit = 1 << (255 - ticketIndex);
        require((currentPacked & ticketBit) != 0, "Already spent");
        unchecked {
            packedBitmapAndPrice = currentPacked & ~ticketBit;
        }
        return 1;
    }

    /// @notice gets the current tokenId
    function _getTokenId() internal view returns (uint256) {
        return (packedBitmapAndPrice & TOKENID_MASK) >> TOKENID_POS;
    }


    /// @notice increments the tokenId counter and returns the new tokenId
    function _incrementTokenId() internal returns (uint256 _newId) {
        uint256 currentPacked = packedBitmapAndPrice;
        _newId = ((currentPacked & TOKENID_MASK) >> TOKENID_POS) + 1;
        unchecked {
            packedBitmapAndPrice = (currentPacked & ~TOKENID_MASK) | (_newId << TOKENID_POS);
        }
        return _newId;
    }
}
