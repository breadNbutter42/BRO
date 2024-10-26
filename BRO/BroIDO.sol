// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

/*
⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣼⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⣿⣿⣷⡀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⢀⣾⣿⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣷⠀⣠⣾⣿⣿⣷⣄⠀⣾⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⠁⣼⣿⣿⣿⣿⣿⣿⣧⠈⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠘⠛⠛⠛⠛⠛⠛⠛⠛⠃⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣼⠏⠀⠿⣿⣶⣶⣶⣶⣿⠿⠀⠹⣷⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⡟⠀⣴⡄⠀⣈⣹⣏⣁⡀⢠⣦⠀⢻⣇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠀⠐⢿⣿⠿⠿⠿⠿⠿⠿⣿⡿⠂⠀⠙⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣴⣿⣷⣄⠉⢠⣶⠒⠒⣶⡄⠉⣠⣾⣿⣦⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠚⠛⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠛⠓⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀


    /$$    /$$$$$$$  /$$$$$$$   /$$$$$$ 
  /$$$$$$ | $$__  $$| $$__  $$ /$$__  $$
 /$$__  $$| $$  \ $$| $$  \ $$| $$  \ $$  
| $$  \__/| $$$$$$$ | $$$$$$$/| $$  | $$  
|  $$$$$$ | $$__  $$| $$__  $$| $$  | $$   
 \____  $$| $$  \ $$| $$  \ $$| $$  | $$     
 /$$  \ $$| $$$$$$$/| $$  | $$|  $$$$$$/
|  $$$$$$/|_______/ |__/  |__/ \______/  
 \_  $$_/                                                                                                           
   \__/                                                                                                             

*/

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract BRO is ERC20, ERC20Permit { // ERC20Permit added as per https://wizard.openzeppelin.com/#erc20

    address public presaleContract = 0x0000000000000000000000000000000000000000; //Deploy presale contract first and add address here
    uint public idoLaunchTime = 1811775312; // Time to automatically enable general transfers and trading at IDO launch


    constructor() ERC20("BRO", "BRO") ERC20Permit("BRO") {
        _mint(presaleContract, 420690000000 * 10 ** decimals()); // Mint the totalSupply (420.69 B) to the presale contract
    }


    // Override the ERC20 _update function (aka a token transfer) to include presale logic
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if(block.timestamp < idoLaunchTime) { // If not yet IDO launch time, then only the presale contract can transfer tokens
            require(from == presaleContract, "Patience - Trading Not Started Yet!");
        }
        super._update(from, to, amount); // Call the parent _update function if the transfer is allowed
    }

}
// $BRO coin has no association with any other token or project.
// $BRO is a meme coin with no intrinsic value or expectation of financial return.
// There is no formal team or roadmap.
// The coin is completely useless and for entertainment purposes only.
