// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {ERC2981} from "openzeppelin/token/common/ERC2981.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {PackedSlotHandler} from "src/Ecosystem-1/PackedSlotHandler.sol";

/*
QUESTIONS

- How to initialise constructor of BASE of BASE contract? (Ownable2Step inherits Ownable, and the Ownable constructor needs an arg)
- How to override supportsInterface()

- Why use a bitmap when we can check if tokenId is mintable by checking if ownerOf(tokenId) == address(0)?
- Why use OZ bitmaps when it requires us to do a warm access SSTORE for each BIT in a given slot?

- Constants are stored in contract bytecode rather than storage? 

*/

contract NFT is PackedSlotHandler, Ownable2Step, ERC721, ERC2981 {
    bytes32 public merkleRoot;
    uint256 constant MAX_SUPPLY = 20;

    constructor(address owner, bytes32 _merkleRoot) Ownable(owner) ERC721("NFT", "NFT") payable {
        merkleRoot = _merkleRoot;
    }

    /// @notice whitelisted addresses get a 50% discount on the price
    /// @param account whitelisted address included in merkle tree
    /// @param ticketId ticket id included in merkle tree & bitmap
    /// @param merkleProof merkle proof to verify inclusion in merkle tree
    function discountPurchase(address account, uint256 ticketId, bytes32[] calldata merkleProof) external payable {
        require(msg.value == (_getPrice() >> 1), "Invalid price");
        require(_getTokenId() < MAX_SUPPLY, "Sold out");
        require(
            MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(account, ticketId))),
            "Invalid merkle proof"
        );

        _spendTicket(ticketId);
        _mint(account, _incrementTokenId());
    }

    /// @notice full price purchase
    /// @param account address to mint the token to
    function purchase(address account) external payable {
        require(_getTokenId() < MAX_SUPPLY, "Sold out");
        require(msg.value == _getPrice(), "Invalid price");
        _mint(account, _incrementTokenId());
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = owner().call{value: address(this).balance}("");
        require(ok, "failed");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }
}
