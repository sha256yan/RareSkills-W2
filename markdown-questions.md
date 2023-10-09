
- [ ] How does ERC721A save gas?
    - batchMint and batchTransfer functionality (cheaper than multi-calling mint and transfer)

- [ ] Where does it add cost?
    - Storing ownership (additional storage cost) 
    - Packed slots (additional execution cost)
    - Updating ownership on mint and transfers (additional execution)

- [ ] Why shouldn’t ERC721A enumerable’s implementation be used on-chain?
    - Tracking ownership can be done off-chain through event listening. (Not specific to ERC721A and also applies to OZ ERC721Enumerable)



- [ ] Besides the examples listed in the code and the reading, what might the wrapped NFT pattern be used for?
    - NFT Escrow (conditional lock on withdrawing underlying NFT)
    - NFT IOU (similar to AAVE USDC/aUSDC)
    - Infinite recursive NFT????


- [ ] Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace
    - Ingest blocks from inception of contract, searching for Transfers where the "from" OR to "are" the target address. Add a tokenId to a user's off-chain balance for each "to", and remove tokenId for "from" events.