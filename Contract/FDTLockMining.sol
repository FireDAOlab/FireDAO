// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IFDSBT001 {
    function mintExternal(address User, uint256 mintAmount) external;
    function burnExternal(address User, uint256 mintAmount) external;
}


contract FDTLockMining is Ownable {
    uint256 public Id;
    address public FDTAddress;
    address public flame;
    address public FDSBT001Address;
    mapping(address => mapping(uint256 => uint256)) userStakeInfo;
    mapping(address => StakeInfo) public StakeInfos;
    mapping(address => mapping(uint256 => uint256)) public UserWithdraw;    
    uint256 public BounsTime;
    uint256 public FlameAmount;
    struct StakeInfo {
        address user;
        uint256 startStakeTime;
        uint256 endStakeTime;
        uint256 stakeAmount;
        bool isFristStake;
    }
    StakeInfo[] public _StakeInfos;
    address[] public StakeUser;
    constructor () {

    }
    function setFDSBT001Address(address _FDSBT001Address) public onlyOwner{
        FDSBT001Address = _FDSBT001Address;
    }
    function setBonusTime(uint256 _BounsTime) public onlyOwner {
        BounsTime = _BounsTime;
        FlameAmount = IERC20(flame).balanceOf(address(this));
    }
    function withdraw(uint256 amount) public onlyOwner {
        IERC20(flame).transfer(msg.sender,amount);
    }

    function setFDTAddress(address _FDTAddress) public onlyOwner {
        FDTAddress = _FDTAddress;
    }

    function stakeMining(uint256 amount, uint256 inputEndTime ) public {
        require(inputEndTime == 0 || inputEndTime == 1 || inputEndTime == 3 || inputEndTime == 6 || inputEndTime == 12 || inputEndTime == 24 || inputEndTime == 36 , "input type error");
        
        IERC20(FDTAddress).transfer(address(this), amount);
        userStakeInfo[msg.sender][block.timestamp] = amount;
        StakeInfo memory info = StakeInfo({
            user:msg.sender,
            startStakeTime:block.timestamp,
            endStakeTime:block.timestamp + inputEndTime*2592000,
            stakeAmount:amount,
            isFristStake:true
        });

        IFDSBT001(FDSBT001Address).mintExternal(msg.sender, amount*inputEndTime);
        StakeInfos[msg.sender] = info;
        
        StakeUser.push(msg.sender);
        _StakeInfos.push(info);
        if(StakeInfos[msg.sender].isFristStake){
        ReceiveAward();
        }
        Id++;
    }

    function ReceiveAward() internal {
        for(uint i = 0 ;i< _StakeInfos.length ; i++){
        IERC20(flame).transfer(_StakeInfos[i].user,_StakeInfos[i].stakeAmount/(IERC20(FDTAddress).balanceOf(address(this)))*(FlameAmount/BounsTime));
        }

    }

    function UserWithdrawAll()public {

        

    }
}
