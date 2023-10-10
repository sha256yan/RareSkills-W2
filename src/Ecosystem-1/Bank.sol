// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "openzeppelin/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {ERC2981} from "openzeppelin/token/common/ERC2981.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {PackedSlotHandler} from "src/Ecosystem-1/PackedSlotHandler.sol";


contract Bank is IERC721Receiver {

    event Deposit(address indexed depositor, uint256 indexed tokenId);
    event Claim(address indexed depositor, uint256 indexed tokenId, uint256 amount);
    event Withdraw(address indexed depositor, uint256 indexed tokenId);

    address constant NFT_ADDRESS = 0x0000000000000000000000000000000000000000;
    address constant ERC20_ADDRESS = 0x0000000000000000000000000000000000000000;
    uint256 constant DAILY_REWARDS = 20_000_000_000_000_000_000; // 20e18

    mapping(address user => mapping(uint256 tokenId => uint256 depositStartTime)) public deposits;

    constructor() {

    }

    function withdrawNFT(uint256 tokenId) external {
        require(deposits[msg.sender][tokenId] > 1, "No deposit found");
        deposits[msg.sender][tokenId] = 1;
        emit Withdraw(msg.sender, tokenId);

        // TODO transfer NFT
    }

    function claimRewards(uint256 tokenId) external {
        uint256 depositStartTime = deposits[msg.sender][tokenId];
        require(depositStartTime > 1, "No deposit found");
        uint256 amount;
        unchecked {
            amount = ((block.timestamp - depositStartTime) / 24 hours) * DAILY_REWARDS;
        }
        deposits[msg.sender][tokenId] = block.timestamp;
        emit Claim(msg.sender, tokenId, amount);

        // TODO mint amount of ERC20
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
        deposits[from][tokenId] = block.timestamp;
        emit Deposit(from, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

}