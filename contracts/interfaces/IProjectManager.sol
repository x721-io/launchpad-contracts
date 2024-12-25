// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma abicoder v2;

import "../libraries/LibStructs.sol";

interface IProjectManager {
    function getProject(uint projectId) external view returns (LibStructs.Project memory);
}