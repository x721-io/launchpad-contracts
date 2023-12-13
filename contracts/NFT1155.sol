// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// For Remix IDE usage
// import "@openzeppelin/contracts@3.4/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts@3.4/token/ERC1155/IERC1155MetadataURI.sol";
// import "@openzeppelin/contracts@3.4/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IERC1155Modified.sol";

contract NFT1155 is IERC1155Modified, ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;

    constructor() ERC1155("https://example1155.com") {}

    function balanceOf(address owner, uint id) public view override(ERC1155, IERC1155Modified) returns (uint) {
        return super.balanceOf(owner, id);
    }

    function mintNFT(address to, uint amount) public override returns (uint) {
        bytes memory data;
        _tokenIdCounter.increment();
        _mint(to, _tokenIdCounter.current(), amount, data);

        return _tokenIdCounter.current();
    }

    function mintBatchMultipleIdNFT(address to, uint amountNFT, uint amountOfEach) external {
        for (uint i = 0; i < amountNFT; i++) {
            mintNFT(to, amountOfEach);
        }
    }
    
    function safeTransferNFTFrom(
        address from,
        address to,
        uint tokenId,
        uint amount
    ) external override {
        bytes memory data;
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }
}
