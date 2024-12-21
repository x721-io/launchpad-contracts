// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

interface IERC721U2UMinimal {
    struct Mint721Data {
        uint tokenId;
        string tokenURI;
        Part[] creators;
        Part[] royalties;
        bytes[] signatures;
    }

    struct Part {
        address payable account;
        uint96 value;
    }

    function mintAndTransfer(Mint721Data memory data, address to) external;
    function transferOwnership(address newOwner) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}