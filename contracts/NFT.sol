// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// For Remix IDE usage
// import "@openzeppelin/contracts@3.4/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts@3.4/token/ERC721/IERC721Metadata.sol";
// import "@openzeppelin/contracts@3.4/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC721Modified.sol";

contract ERC721U2UxBitget is IERC721Modified, ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;

    string private baseURI_;
    mapping(address => bool) _operators;
    modifier onlyOperator() {
        require(_operators[msg.sender], "caller not operator");
        _;
    }

    constructor() ERC721("U2U Network x Bitget Wallet", "U2UxBGW") {}

    function setOperator(address operator_, bool status_) external onlyOwner {
        _operators[operator_] = status_;
    }

    function balanceOf(address owner) public view override(ERC721, IERC721Modified) returns (uint) {
        return super.balanceOf(owner);
    }

    function mintNFT(address to) external override onlyOperator returns (uint) {
        require(_tokenIdCounter.current() + 1 <= maxSupply);
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());

        return _tokenIdCounter.current();
    }

    function mintBatchNFT(
        address to,
        uint amount
    ) external onlyOperator returns (uint[] memory) {
        require(_tokenIdCounter.current() + amount <= maxSupply);
        uint[] memory tokenIds = new uint[](amount);
        for (uint i = 0; i < amount; i++) {
            _tokenIdCounter.increment();
            _safeMint(to, _tokenIdCounter.current());
            tokenIds[i] = _tokenIdCounter.current();
        }
        return tokenIds;
    }

    function safeTransferNFTFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        super.safeTransferFrom(from, to, tokenId);
    }

    function setBaseURI(string memory baseURI__) external onlyOwner {
        baseURI_ = baseURI__;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        require(_maxSupply >= _tokenIdCounter.current(), "Max supply cannot be less than current supply");
        maxSupply = _maxSupply;
    }

        // Override tokenURI to return the same base URI for all tokens
    function tokenURI(uint tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return baseURI_;
    }
}
