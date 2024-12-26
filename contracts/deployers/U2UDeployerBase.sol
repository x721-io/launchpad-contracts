// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../libraries/LibStructs.sol";

import "../interfaces/IRound.sol";

abstract contract U2UDeployerBase is Ownable {
  address public projectManager = 0x7CD840C81A17fAE6C0761F9bbF8666F929ace029;
  address[] public deployedContracts;

  constructor(address initialOwner) Ownable(initialOwner) {}

  function deployedContractsLength() external view returns (uint) {
    return deployedContracts.length;
  }
}
