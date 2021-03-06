// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DecentralizedNote is ERC20 {
    using Address for address;
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public token;

    constructor()
        ERC20("DecentralizedNote", "DEN")
    {
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function balance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function deposit(uint _amount) public returns(uint){
        // Amount must be greater than zero
        require(_amount > 0, "amount cannot be 0");

        // Mint FarmToken to msg sender
        _mint(msg.sender, _amount);

        return _amount;
    }

    function withdraw(uint _amount) public returns(uint){
        // Burn FarmTokens from msg sender
        _burn(msg.sender, _amount);
        
        return _amount;
    }
}