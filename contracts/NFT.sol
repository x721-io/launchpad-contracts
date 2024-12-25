// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC721Modified.sol";

contract ERC721U2UxBitget is IERC721Modified, ERC721, Ownable {
    uint256 private _currentTokenId;
    uint256 public maxSupply;

    string private baseURI_;
    mapping(address => bool) private _operators;

    modifier onlyOperator() {
        require(_operators[msg.sender], "caller not operator");
        _;
    }

    constructor() ERC721("U2U Network x Bitget Wallet", "U2UxBGW") Ownable(msg.sender) {}

    function setOperator(address operator_, bool status_) external onlyOwner {
        _operators[operator_] = status_;
    }

    function balanceOf(address owner) public view override(ERC721, IERC721Modified) returns (uint256) {
        return super.balanceOf(owner);
    }

    function mintNFT(address to) external override onlyOperator returns (uint256) {
        require(_currentTokenId + 1 <= maxSupply, "Exceeds max supply");
        _currentTokenId++;
        uint256 tokenId = _currentTokenId;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function mintBatchNFT(address to, uint256 amount) external onlyOperator returns (uint256[] memory) {
        require(_currentTokenId + amount <= maxSupply, "Exceeds max supply");
        uint256[] memory tokenIds = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            _currentTokenId++;
            uint256 tokenId = _currentTokenId;
            _safeMint(to, tokenId);
            tokenIds[i] = tokenId;
        }
        return tokenIds;
    }

    function safeTransferNFTFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId);
    }

    function setBaseURI(string memory baseURI__) external onlyOwner {
        baseURI_ = baseURI__;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        require(_maxSupply >= _currentTokenId, "Max supply cannot be less than current supply");
        maxSupply = _maxSupply;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return baseURI_;
    }
}
