// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC1155U2U {
    struct Mint1155Data {
        uint tokenId;
        string tokenURI;
        uint supply;
        Part[] creators;
        Part[] royalties;
        bytes[] signatures;
    }

    struct Part {
        address payable account;
        uint96 value;
    }

    function mintAndTransfer(Mint1155Data memory data, address to, uint256 _amount) external;
    function transferOwnership(address newOwner) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}