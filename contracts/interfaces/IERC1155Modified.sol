// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC1155Modified {
    function mintNFT(address to, uint amount) external returns (uint);
    function safeTransferNFTFrom(
        address from,
        address to,
        uint tokenId,
        uint amount
    ) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
}