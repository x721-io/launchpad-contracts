// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IRound.sol";

abstract contract U2UDeployerBase is Ownable {
  address public projectManager = 0xcCb0c2790F30AE2E806a49813A2a66037458d315;                      // This is just a placeholder address
  address[] public deployedContracts;

  function deployedContractsLength() external view returns (uint) {
    return deployedContracts.length;
  }
}