// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// library TransferHelper {
//     /// @notice Transfers tokens from the targeted address to the given destination
//     /// @notice Errors with 'STF' if transfer fails
//     /// @param token The contract address of the token to be transferred
//     /// @param from The originating address from which the tokens will be transferred
//     /// @param to The destination address of the transfer
//     /// @param value The amount to be transferred
//     function safeTransferFrom(
//         address token,
//         address from,
//         address to,
//         uint256 value
//     ) internal {
//         (bool success, bytes memory data) =
//             token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
//         require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
//     }

//     /// @notice Transfers tokens from msg.sender to a recipient
//     /// @dev Errors with ST if transfer fails
//     /// @param token The contract address of the token which will be transferred
//     /// @param to The recipient of the transfer
//     /// @param value The value of the transfer
//     function safeTransfer(
//         address token,
//         address to,
//         uint256 value
//     ) internal {
//         (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
//         require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
//     }

//     /// @notice Approves the stipulated contract to spend the given allowance in the given token
//     /// @dev Errors with 'SA' if transfer fails
//     /// @param token The contract address of the token to be approved
//     /// @param to The target of the approval
//     /// @param value The amount of the given token the target will be allowed to spend
//     function safeApprove(
//         address token,
//         address to,
//         uint256 value
//     ) internal {
//         (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
//         require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
//     }

//     /// @notice Transfers ETH to the recipient address
//     /// @dev Fails with `STE`
//     /// @param to The destination of the transfer
//     /// @param value The value to be transferred
//     function safeTransferETH(address to, uint256 value) internal {
//         (bool success, ) = to.call{value: value}(new bytes(0));
//         require(success, 'STE');
//     }
// }

contract FireLock {
    uint256 index;

    struct LockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        address token;
        uint256 cliffPeriod;
    }

    struct groupLockDetail{
        string LockTitle;
        uint256 ddl;
        uint256 startTime;
        address admin;
        uint256 amount;
        uint256 unlockCycle;
        uint256 unlockRound;
        uint256[] rate;
        address token;
        address[] mumber;
        bool isNotchange;
    }

    mapping(address => address[]) tokenAddress;

    mapping(address => LockDetail[]) public ownerLockDetail;

    mapping(uint256 => address[]) groupMumber;
    mapping(uint256 => address[]) groupTokenAddress;
    mapping(address => groupLockDetail[]) public adminGropLockDetail;
    mapping(address => address) adminAndOwner;
    bool alreadyChange;
    mapping(address => bool) isChangedOwner;

    mapping(address => uint256[]) public UsergroupLockNum;


    function lock(address _token,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile) public {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        address owner = msg.sender;
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400
        });

        // LockDetail memory lockDetail = ownerLockDetail[msg.sender][(ownerLockDetail[msg.sender]).length];
        // lockDetail.ddl =block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400;
        // lockDetail.amount = amount;
        // lockDetail.token = _token; 
        // lockDetail.unlockCycle = _unlockCycle;
        // lockDetail.unlockRound = _unlockRound;
        // lockDetail.cliffPeriod = block.timestamp +_cliffPeriod *86400 ;
        // lockDetail.startTime = block.timestamp;
        tokenAddress[msg.sender].push(_token);
        ownerLockDetail[msg.sender].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }

    // function testTransferFrom(address _token,uint256 amount) public {
    //     TransferHelper.safeTransferFrom(_token,msg.sender,address(this),amount);
    // }
    // function kegongtest(address _tokenAddress, uint256 _amount) public{
    //     IERC20(_tokenAddress).transferFrom(msg.sender , address(0xC92eE4588Ce1a2304E1B252596828abDDB161f2D), _amount);
    // }
    // function kegongtest2(address _tokenAddress, uint256 _amount) public{
    //     IERC20(_tokenAddress).transferFrom(msg.sender , address(this), _amount);
    // }
    // function checkAdress() public view returns(address){
    //     return address(this);
    // }
    function lockOthers(address _token,address _to,uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount,uint256 _cliffPeriod ,string memory _titile) public {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        
        address owner = msg.sender;
        LockDetail memory lockinfo = LockDetail({
            LockTitle:_titile,
            ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
            startTime : block.timestamp,
            amount:_amount,
            unlockCycle: _unlockCycle,
            unlockRound:_unlockRound,
            token:_token,
            cliffPeriod:block.timestamp +_cliffPeriod *86400
        });

        tokenAddress[_to].push(_token);
        ownerLockDetail[_to].push(lockinfo);
        IERC20(_token).transferFrom(owner,address(this),_amount);
    }
      function groupLock(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to, uint256[] memory _rate,string memory _titile,uint256 _cliffPeriod) public {
      require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
        startTime:block.timestamp,
        admin:msg.sender,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        mumber:_to,
        isNotchange:false
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[msg.sender].push(LockId);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;
    }
     function groupLock_true(address _token, uint256 _unlockCycle,uint256 _unlockRound ,uint256 _amount , address[] memory _to,uint256[] memory _rate, string memory _titile,uint256 _cliffPeriod) public {
        require(block.timestamp + _unlockCycle * _unlockRound * 86400 > block.timestamp,"ddl should be bigger than ddl current time");
        require(_amount > 0 ,"token amount should be bigger than zero");
        uint LockId; 
        groupLockDetail memory _groupLockDetail = groupLockDetail({
        LockTitle:_titile,
        ddl:block.timestamp+ _unlockCycle * _unlockRound * 86400 + _cliffPeriod *86400,
        startTime:block.timestamp,
        admin:msg.sender,
        amount:_amount,
        unlockCycle:_unlockCycle,
        unlockRound:_unlockRound,
        rate : _rate,
        token:_token,
        mumber:_to,
        isNotchange:false
        });
        groupTokenAddress[LockId].push(_token);
        UsergroupLockNum[msg.sender].push(LockId);
        adminGropLockDetail[msg.sender].push(_groupLockDetail);
        groupMumber[LockId] = _to;
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        LockId++;

    }

    function unlock(address _token) public{
        uint len = ownerLockDetail[msg.sender].length;
        for(uint i = 0; i < len - 1; i++ ){
            if(ownerLockDetail[msg.sender][i].token == _token){
                index = i;
            }
        }
        require(block.timestamp >= ownerLockDetail[msg.sender][index].cliffPeriod,"current time should be bigger than cliffPeriod");
        uint amountOfUser = ownerLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
        IERC20(_token).transfer(msg.sender, (amountOfUser/(ownerLockDetail[msg.sender][index].unlockCycle*ownerLockDetail[msg.sender][index].unlockRound))*(block.timestamp-ownerLockDetail[msg.sender][index].startTime)/86400);
        }else{revert();}
    }

    function groupUnLock(address _token) public {
       uint len = adminGropLockDetail[msg.sender].length;
        for(uint i = 0; i < len - 1; i++ ){
            if(adminGropLockDetail[msg.sender][i].token == _token){
                index = i;
            }
        }
        require(block.timestamp >= adminGropLockDetail[msg.sender][index].ddl,"current time should be bigger than deadlineTime");
        uint amountOfUser = adminGropLockDetail[msg.sender][index].amount;
        uint amount = IERC20(_token).balanceOf(address(this));
        if(amount > amountOfUser){
            for(uint i = 0 ; i < adminGropLockDetail[msg.sender][index].mumber.length;i++){
            IERC20(_token).transfer(adminGropLockDetail[msg.sender][index].mumber[i], (amountOfUser*adminGropLockDetail[msg.sender][index].rate[i]/100)/(adminGropLockDetail[msg.sender][index].unlockRound*adminGropLockDetail[msg.sender][index].unlockRound)*(block.timestamp - adminGropLockDetail[msg.sender][index].startTime)/86400);
            }
        }else{revert();}
    }
    function changeLockAdmin(address  _to, uint _index) public {
        require(msg.sender == adminGropLockDetail[msg.sender][index].admin,"you are not admin");
        require(!isChangedOwner[_to], "you already change");
        require(adminGropLockDetail[msg.sender][index].isNotchange ,"you can't turn on isNotchange when you create ");
        adminGropLockDetail[msg.sender][_index].admin = _to;
        adminAndOwner[_to] = msg.sender;
        alreadyChange =true;
        isChangedOwner[_to] = alreadyChange;
        
    }
    function changeLockNumber(address[] memory _to) public {
        if(!isChangedOwner[msg.sender]){
        require(msg.sender == adminGropLockDetail[msg.sender][index].admin);
        adminGropLockDetail[msg.sender][index].mumber = _to;
        adminGropLockDetail[adminAndOwner[msg.sender]][index].mumber = _to;
        }else{
        require(msg.sender == adminGropLockDetail[adminAndOwner[msg.sender]][index].admin, "you are not admin");
        adminGropLockDetail[adminAndOwner[msg.sender]][index].mumber = _to;
    }
}
    function getLockTitle() public view returns(string memory){
        return ownerLockDetail[msg.sender][index].LockTitle;
    }
    function getGroupLockTitle() public view returns(string memory) {
        return adminGropLockDetail[msg.sender][index].LockTitle;
    }
    function getAmount() public view returns(uint) {
        return ownerLockDetail[msg.sender][index].amount;
    }
    function getDdl() public view returns(uint) {
        return ownerLockDetail[msg.sender][index].ddl;
    }

    function getTokenName() public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][index].token).name();
    }

    function getTokenSymbol() public view returns(string memory) {
        return IERC20(ownerLockDetail[msg.sender][index].token).symbol();
    }

    function getTokenDecimals() public view returns(uint) {
        return IERC20(ownerLockDetail[msg.sender][index].token).decimals();
    }

    function getToken() public view returns(address[] memory) {
        return tokenAddress[msg.sender];
    }
    // function checkADdress() public view returns(address){
    //     return msg.sender;
    // }
}