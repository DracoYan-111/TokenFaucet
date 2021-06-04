// SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TokenFaucet is Ownable {
    using SafeMath for uint;
    using SafeERC20 for ERC20;

    //必发代币Arche
    ERC20 private  Arche = ERC20(address(0));
    //token数组1
    ERC20[11] private Tokens;
    //发送数量
    uint8 private Quantity = 100;
    //发送间隔
    uint32 private Interval = 864000000;
    //用户当前是否可以领取
    mapping(address => uint256) private UserLock;

    modifier lock(){
        require(block.timestamp.sub(UserLock[msg.sender]) > Interval, "Received on the day (T_T)");
        _;
    }
    

    constructor(
        uint8 _quantity,
        ERC20 _arche,
        ERC20[11] memory _tokenOnes){
        //发送数量
        Quantity = _quantity;
        //必发代币Arche
        Arche = _arche;
        //token数组1
        Tokens = _tokenOnes;

    }

    /*
    用户领取
    */
    function Receive() public lock() {
        (uint8 a) = PseudoRandomNumber();
        Arche.safeTransfer(msg.sender, Quantity * (10 ** Arche.decimals()));
        Tokens[a].safeTransfer(msg.sender, Quantity * (10 ** Tokens[a].decimals()));
        UserLock[msg.sender] = block.timestamp;
    }

    /*
    生成随机数
    返回 0-11之间的随机数
    */
    function PseudoRandomNumber() private view returns (uint8 a) {
        uint8 count = 35;
            uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, count--))) % 100);
            if (randomNumber > 11) {
                randomNumber = randomNumber / 4;
            }
            if (randomNumber / 2 < 12) {
               a = randomNumber / 2;
            }
        return a;
    }

    /*
    修改发送数量和发送间隔
    传入 新的发送数量,新的领取间隔
    */
    function SetQuantityAndInterval(
        uint8 _quantity,
        uint32 _interval)
    public onlyOwner {
        //发送数量
        Quantity = _quantity;
        //发送间隔
        Interval = _interval;
    }

    /*
    修改token列表
    传入 新的arche地址，新的11位代币数组
    */
    function SetToken(
        ERC20 _arche,
        ERC20[11] memory _tokenOnes
    ) public onlyOwner {
        Arche = _arche;
        //token数组1
        Tokens = _tokenOnes;
    }
    
    /*
    查看用户是否可以领取
    返回 true / false
    */
    function GetUserData() public view returns(bool userData){
        userData = false;
      if (UserLock[msg.sender] < Interval){
          userData =true;
      }
      return userData;
    }
}
