// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IWETH.sol";
import "./interfaces/IERC721Modified.sol";
import "./interfaces/IERC1155Modified.sol";
import "./interfaces/IERC721RaribleMinimal.sol";
import "./interfaces/IERC1155Rarible.sol";

import "./U2UBuyBase.sol";

import "./libraries/LibStructs.sol";

contract U2UPremintRoundFCFS is Ownable, U2UBuyBase {
    using SafeMath for uint256;
    
    constructor(
        uint projectId,
        LibStructs.Round memory round,
        LibStructs.Collection memory collection
    ) {
        _projectId = projectId;
        _round = round;
        _collection = collection;
    }

    event BuyERC721Rarible(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721Rarible(uint tokenId)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyBelowMaxAmount721
        onlyBelowMaxAmountUser721
        onlyUnlocked
    {
        require(_collection.isERC721, "U2U: project collection is not ERC721");
        require(
            _collection.isRaribleCollection,
            "U2U: this function only works with NFTs created from Rarible contracts"
        );

        address sender = msg.sender;
        uint value = msg.value;

        require(
            value >= _round.price,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );

        _round.soldAmountNFT = _round.soldAmountNFT.add(1);
        _amountBought[sender] = _amountBought[sender].add(1);
        _checkAndAddNewUser(sender);

        IERC721RaribleMinimal erc721Minimal = IERC721RaribleMinimal(_collection.collectionAddress);
        erc721Minimal.safeTransferFrom(_collection.owner, sender, tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721Rarible(sender, _projectId, _collection.collectionAddress, tokenId);
    }

    event BuyERC721(address buyer, uint projectId, address collection, uint tokenId);
    function buyERC721(uint tokenId)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyBelowMaxAmount721
        onlyBelowMaxAmountUser721
        onlyUnlocked
    {
        require(_collection.isERC721, "U2U: project collection is not ERC721");

        address sender = msg.sender;
        uint value = msg.value;

        require(
            value >= _round.price,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );

        _round.soldAmountNFT = _round.soldAmountNFT.add(1);
        _amountBought[sender] = _amountBought[sender].add(1);
        _checkAndAddNewUser(sender);

        IERC721Modified erc721Modified = IERC721Modified(_collection.collectionAddress);
        erc721Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, _round.price);
        weth.transfer(sender, value.sub(_round.price));

        emit BuyERC721(sender, _projectId, _collection.collectionAddress, tokenId);
    }

    event BuyERC1155Rarible(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155Rarible(uint tokenId, uint amount)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyBelowMaxAmount1155(amount)
        onlyBelowMaxAmountUser1155(amount)
        onlyUnlocked
    {
        require(!_collection.isERC721, "U2U: project collection is not ERC1155");
        require(
            _collection.isRaribleCollection,
            "U2U: this function only works with NFTs created from Rarible contracts"
        );

        address sender = msg.sender;
        uint value = msg.value;
        uint totalPrice = amount.mul(_round.price);

        require(
            value >= totalPrice,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );

        _round.soldAmountNFT = _round.soldAmountNFT.add(amount);
        _amountBought[sender] = _amountBought[sender].add(amount);
        _checkAndAddNewUser(sender);

        IERC1155Rarible erc1155 = IERC1155Rarible(_collection.collectionAddress);

        bytes memory _data;
        erc1155.safeTransferFrom(_collection.owner, sender, tokenId, amount, _data);

        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

        emit BuyERC1155Rarible(
            sender,
            _projectId,
            _collection.collectionAddress,
            tokenId,
            amount
        );
    }

    event BuyERC1155(
        address buyer,
        uint projectId,
        address collection,
        uint tokenId,
        uint amount
    );
    function buyERC1155(uint tokenId, uint amount)
        external
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyBelowMaxAmount1155(amount)
        onlyBelowMaxAmountUser1155(amount)
        onlyUnlocked
    {
        require(!_collection.isERC721, "U2U: project collection is not ERC1155");

        address sender = msg.sender;
        uint value = msg.value;
        uint totalPrice = amount.mul(_round.price);

        require(
            value >= totalPrice,
            "U2U: amount to transfer must be equal or greater than whitelist price"
        );
        
        _round.soldAmountNFT = _round.soldAmountNFT.add(amount);
        _amountBought[sender] = _amountBought[sender].add(amount);
        _checkAndAddNewUser(sender);

        IERC1155Modified erc1155Modified = IERC1155Modified(_collection.collectionAddress);
        erc1155Modified.safeTransferNFTFrom(_collection.owner, sender, tokenId, amount);
        
        weth.deposit{value: value}();
        weth.transfer(_collection.owner, totalPrice);
        weth.transfer(sender, value.sub(totalPrice));

        emit BuyERC1155(sender, _projectId, _collection.collectionAddress, tokenId, amount);
    }
}