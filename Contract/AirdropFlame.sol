// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract airdropFlame is Ownable{
    address public flame;
    address public controlStatus;
    bool public Status;
constructor () {    
}   
    function setflameAddress(address _flame) public onlyOwner{
        flame = _flame;
    }
    function setControlStatusAddress(address controlAddress) public onlyOwner {
        controlStatus =controlAddress;
    }
    function setStatus() external {
        require(msg.sender == controlStatus, "is not control contract");
        Status =!Status;
    }

    function receiveAirdrop(uint _amount) public {
        require(IERC20(flame).balanceOf(address(this)) > _amount, "amount is not enough");
        IERC20(flame).transfer(msg.sender,_amount);
    }


}
