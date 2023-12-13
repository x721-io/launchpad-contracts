// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// // For Remix IDE usage
// import "@openzeppelin/contracts@3.4/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20("Wrapped ETH", "WETH") {}

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint amount) external payable {
        require(balanceOf(msg.sender) >= amount, "Balance must be greater than or equal to amount");
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}