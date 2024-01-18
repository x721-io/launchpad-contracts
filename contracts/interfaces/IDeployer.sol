// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../libraries/LibStructs.sol";

interface IDeployer {
  function deploy(
    uint projectCount,
    LibStructs.Round calldata round,
    LibStructs.Collection calldata collection,
    LibStructs.Timeframe[] memory timeframes,
    address _projectManager,
    address _feeReceiver,
    address requiredCollection
  ) external returns (address);
}