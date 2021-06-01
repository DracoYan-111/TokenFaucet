// SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TokenFaucet is Ownable {
    //----------------------- EVENT -----------------------
    event Receives(address, ERC20[4], uint256);

    using SafeMath for uint;
    using SafeERC20 for ERC20;

    //必发代币Arche
    ERC20 public  Arche = ERC20(address(0));
    //token数组1
    ERC20[4] public TokenOnes;
    //token数组2
    ERC20[4] public TokenTwos;
    //token数组3
    ERC20[4] public TokenThrees;
    //发送数量
    uint8 public Quantity = 1;
    //发送间隔
    uint32 public Interval = 86400;
    //用户当前是否可以领取
    mapping(address => uint256) UserLock;

    modifier lock(){
        require(block.timestamp.sub(UserLock[msg.sender]) > Interval, "Received on the day (T_T)");
        _;
    }

    constructor(
        uint8 _quantity,
        ERC20 _arche,
        ERC20[4] memory _tokenOnes,
        ERC20[4] memory _tokenTwos,
        ERC20[4] memory _tokenThrees){
        Quantity = _quantity;
        Arche = _arche;
        //token数组1
        TokenOnes = _tokenOnes;
        //token数组2
        TokenTwos = _tokenTwos;
        //token数组3
        TokenThrees = _tokenThrees;
    }

    /*
    用户领取
    */
    function Receive() public lock() {
        (uint8 a,uint8 b,uint8 c) = PseudoRandomNumber();
        Arche.safeTransfer(msg.sender, Quantity * (10 ** Arche.decimals()));
        TokenOnes[a].safeTransfer(msg.sender, Quantity * (10 ** TokenOnes[a].decimals()));
        TokenTwos[b].safeTransfer(msg.sender, Quantity * (10 ** TokenTwos[b].decimals()));
        TokenThrees[c].safeTransfer(msg.sender, Quantity * (10 ** TokenThrees[c].decimals()));
        UserLock[msg.sender] = block.timestamp;
    }

    /*
    生成随机数
    返回 0-4之间的随机数
    */
    function PseudoRandomNumber() public view returns (uint8 a, uint8 b, uint8 c) {
        uint8 count = 35;
        uint8[3] memory counts;
        for (uint8 i = 0; i < counts.length; i++) {
            uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, count--))) % 100);
            if (randomNumber > 4) {
                randomNumber = randomNumber / 2;
            }
            counts[i] = randomNumber / 14;
        }
        return (
        counts[0],
        counts[1],
        counts[2]
        );
    }

    /*
    修改发送数量和发送间隔
    */
    function SetQuantityAndInterval(uint8 _quantity, uint32 _interval) public onlyOwner {
        //发送数量
        Quantity = _quantity;
        //发送间隔
        Interval = _interval;
    }

    /*
    修改token列表
    */
    function SetToken(
        ERC20 _arche,
        ERC20[4] memory _tokenOnes,
        ERC20[4] memory _tokenTwos,
        ERC20[4] memory _tokenThrees) public onlyOwner {
        Arche = _arche;
        //token数组1
        TokenOnes = _tokenOnes;
        //token数组2
        TokenTwos = _tokenTwos;
        //token数组3
        TokenThrees = _tokenThrees;
    }
}
