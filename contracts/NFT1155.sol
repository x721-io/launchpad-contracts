// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interfaces/IERC1155Modified.sol";

contract NFT1155 is IERC1155Modified, ERC1155 {
    uint256 private _currentTokenId;

    constructor() ERC1155("https://example1155.com") {}

    function balanceOf(address owner, uint256 id) public view override(ERC1155, IERC1155Modified) returns (uint256) {
        return super.balanceOf(owner, id);
    }

    function mintNFT(address to, uint256 amount) public override returns (uint256) {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");

        _currentTokenId++;
        uint256 newTokenId = _currentTokenId;
        _mint(to, newTokenId, amount, "");

        return newTokenId;
    }

    function mintBatchMultipleIdNFT(address to, uint256 amountNFT, uint256 amountOfEach) external {
        require(to != address(0), "Invalid address");
        require(amountNFT > 0, "AmountNFT must be greater than zero");
        require(amountOfEach > 0, "AmountOfEach must be greater than zero");

        for (uint256 i = 0; i < amountNFT; i++) {
            mintNFT(to, amountOfEach);
        }
    }

    function safeTransferNFTFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) external override {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Caller is not owner nor approved");
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than zero");

        safeTransferFrom(from, to, tokenId, amount, "");
    }
}
