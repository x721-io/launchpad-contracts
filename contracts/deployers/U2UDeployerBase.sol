// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

// For Remix IDE use
// import "@openzeppelin/contracts@3.4/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IRound.sol";

abstract contract U2UDeployerBase is Ownable {
  address public projectManager = 0x658382AEBd7e20E7069B9EE470D2041dE792B1B0;                      // This is just a placeholder address
  address[] public deployedContracts;

  // modifier onlyProjectManager() {
  //   require(msg.sender == projectManager, "U2U: this function can only be called by project manager");
  //   _;
  // }
}