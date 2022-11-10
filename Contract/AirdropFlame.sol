// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFireSeedAndFSoul{
    function checkFID(address user) external view returns(bool);
    }
    
interface IFireSeed {
    function upclass(address usr) external view returns(address);
    }

contract airdropFlame is Ownable{
    address public flame;
    address public controlStatus;
    bool public Status;
    address public FireSeedAndFSoulAddress;
    address public FireSeedAddress;
    mapping(address => bool) public blackList;
constructor () {
}   
    function setFireSeedAndFSoulAddress(address _FireSeedAndFSoulAddress) public onlyOwner{
        FireSeedAndFSoulAddress = _FireSeedAndFSoulAddress;
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
    function setBlackList(address user) public onlyOwner{
        blackList[user] = true;
    }
    function checkBalanceOfThis() public view returns(uint256) {
        return IERC20(flame).balanceOf(address(this));
    }

    function receiveAirdrop() public {
        require(!Status, "the status is false");
        require(!blackList[msg.sender] ,"you are blackList User");
        require(IERC20(flame).balanceOf(address(this)) > 40000*10**18, "amount is not enough");
        if(IFireSeedAndFSoul(FireSeedAndFSoulAddress).checkFID(msg.sender)){
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(msg.sender),4000*10**18);
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)),2400*10**18);
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender))),1600*10**18);
        IERC20(flame).transfer(msg.sender,40000*10**18);
        }else{
        IERC20(flame).transfer(msg.sender,4000*10**18);
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(msg.sender),400*10**18);
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender)),240*10**18);
        IERC20(flame).transfer(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(IFireSeed(FireSeedAddress).upclass(msg.sender))),160*10**18);

        }
    }


}
