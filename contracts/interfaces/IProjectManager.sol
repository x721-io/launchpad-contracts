// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../libraries/LibStructs.sol";

interface IProjectManager {
    function getProject(uint projectId) external view returns (LibStructs.Project memory);
}