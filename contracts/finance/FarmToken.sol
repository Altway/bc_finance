// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FarmToken is ERC20 {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    constructor(address _token)
        ERC20("FarmToken", "FRM")
    {
        token = IERC20(_token);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function deposit(uint256 _amount) public returns(uint256){
        // Amount must be greater than zero
        require(_amount > 0, "amount cannot be 0");

        // Transfer MyToken to smart contract
        token.safeTransferFrom(msg.sender, address(this), _amount);

        // Mint FarmToken to msg sender
        _mint(msg.sender, _amount);

        return _amount;
    }

    function withdraw(uint256 _amount) public returns(uint256){
        // Burn FarmTokens from msg sender
        _burn(msg.sender, _amount);

        // Transfer MyTokens from this smart contract to msg sender
        token.safeTransfer(msg.sender, _amount);
        
        return _amount;
    }
}