// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/math/SafeMath.sol";
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./U2UBuyBase.sol";

abstract contract U2UPremintBase is U2UBuyBase {
  using SafeMath for uint256;
  using LibStructs for LibStructs.Token;
  
  LibStructs.Token[] internal _tokens;

  uint internal _totalAmountTokens;   // Sum of all _tokens.amount

  modifier onlyTokenIdsAvailable() {
    require(_tokens.length > 0, "U2U: token IDs = 0");
    _;
  }

  modifier onlyOwnerOrRoundContract() {
    address sender = msg.sender;

    if (sender == owner()) {
      _;
    } else {
      address[] memory roundAddresses = IProjectManager(projectManager).getProject(_projectId).roundAddresses;
      bool isSenderARound = false;

      for (uint i = 0; i < roundAddresses.length; i = i.add(1)) {
        if (roundAddresses[i] == sender) {
          isSenderARound = true;
        }
      }

      require(isSenderARound, "U2U: only owner or contract round");
      _;
    }
  }

  function transferNFTsToNextRound(
    address nextRound,
    uint newMaxNFTPerWallet
  ) external override onlyOwner onlyAfterEnd {
    LibStructs.Token[] memory tokens = _tokens;
    IRound(nextRound).receiveTokensAndIncreaseMaxAmountNFT(
      _round.maxAmountNFT.sub(_round.soldAmountNFT),
      newMaxNFTPerWallet,
      tokens
    );
    delete _tokens;
  }

  function receiveTokensAndIncreaseMaxAmountNFT(
    uint amount,
    uint newMaxNFTPerWallet,
    LibStructs.Token[] memory tokens
  ) external onlyRoundContract {
    _round.maxAmountNFT = _round.maxAmountNFT.add(amount);
    _round.maxAmountNFTPerWallet = newMaxNFTPerWallet;
    addTokens(tokens);
  }

  function addTokens(LibStructs.Token[] memory tokens)
    public
    onlyOwnerOrRoundContract
    onlyBeforeStart
  {
    uint totalNewTokens;

    for (uint i = 0; i < tokens.length; i = i.add(1)) {
      for (uint j = 0; j < tokens.length; j = j.add(1)) {
        if (i != j) {
          require(tokens[j].id != tokens[i].id, "U2U: input duplicated token ID");
        }
      }
      totalNewTokens = totalNewTokens.add(tokens[i].amount);
    }
    require(
      _totalAmountTokens.add(totalNewTokens) <= _round.maxAmountNFT,
      "U2U: total NFTs can't exceed maxAmountNFT"
    );

    if (_collection.isERC721) {
      if (_tokens.length > 0) {
        bool isDuplicated = false;
        for (uint i = 0; i < tokens.length; i = i.add(1)) {
          for (uint j = 0; j < _tokens.length; j = j.add(1)) {
            if (tokens[i].id == _tokens[j].id) {
              isDuplicated = true;
              require(!isDuplicated, "U2U: duplicated token ID");
            }
          }
        }
      }
      for (uint i = 0; i < tokens.length; i = i.add(1)) {
        _tokens.push(tokens[i]);
      }
    } else {
      for (uint i = 0; i < tokens.length; i = i.add(1)) {
        bool found = false;
        for (uint j = 0; j < _tokens.length; j++) {
          if (tokens[i].id == _tokens[j].id) {
            _tokens[j].amount = _tokens[j].amount.add(tokens[i].amount);
            found = true;
            break;
          }
        }
      
        if (!found) {
          _tokens.push(tokens[i]);
        }
      }
    }
  }

  function setTokens(LibStructs.Token[] memory tokens) external onlyOwner onlyBeforeStart {
    delete _tokens;
    addTokens(tokens);
  }

  function _pickTokenByIndex() internal view returns (uint) {
    return uint(
      keccak256(
        abi.encodePacked(msg.sender, blockhash(block.number - 1), block.timestamp)
      )
    ) % _tokens.length;
  }

  function _removeTokenAtIndex(uint index, uint amount) internal {
    require(index < _tokens.length, "U2U: array out of bound");
    if (_tokens[index].amount.sub(amount) == 0) {
      _tokens[index] = _tokens[_tokens.length.sub(1)];
      _tokens.pop();
    } else {
      _tokens[index].amount = _tokens[index].amount.sub(amount);
    }
  }

  function getAvailableTokenIds() external view onlyUnlocked returns (LibStructs.Token[] memory) {
    return _tokens;
  }
}