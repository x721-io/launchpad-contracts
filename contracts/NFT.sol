// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// For Remix IDE usage
// import "@openzeppelin/contracts@3.4/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts@3.4/token/ERC721/IERC721Metadata.sol";
// import "@openzeppelin/contracts@3.4/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IERC721Modified.sol";

contract NFT is IERC721Modified, ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public maxSupply;
    
    mapping(address => bool) _operators;

    modifier onlyOperator() {
        require(_operators[msg.sender], "caller not operator");
        _;
    }

    constructor() ERC721("Hamster Heroes", "HSH") {
        maxSupply = 35;
    }

    function setOperator(address operator_, bool status_) external onlyOwner {
        _operators[operator_] = status_;
    }

    function balanceOf(address owner_) public view override(ERC721, IERC721Modified) returns (uint) {
        return super.balanceOf(owner_);
    }

    function mintNFT(address to) external override onlyOperator returns (uint) {
        require(_tokenIdCounter.current() < maxSupply);
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());

        return _tokenIdCounter.current();
    }

    function mintBatchNFT(address to, uint amount) external onlyOperator returns (uint[] memory) {
        uint[] memory tokenIds = new uint[](amount);
        for (uint i = 0; i < amount; i++) {
            _tokenIdCounter.increment();
            _safeMint(to, _tokenIdCounter.current());
            tokenIds[i] = _tokenIdCounter.current();
        }

        return tokenIds;
    }
    
    function safeTransferNFTFrom(address from, address to, uint tokenId) external override {
        super.safeTransferFrom(from, to, tokenId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        super._setBaseURI(baseURI_);
    }
}
