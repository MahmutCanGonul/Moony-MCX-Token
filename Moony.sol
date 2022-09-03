// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract MoonyChat{
    struct ChatCoin{
        uint256 id;
        uint256 coin;
        string uid;
        address wallet;
    }
    mapping (uint256 => ChatCoin)public cc;
    uint256 public id=0;
    event CreateChatCoin(uint256 _id,uint256 _coin,string uid,address wallet);

     function ControlUid(string memory _uid)private view returns (bool){
        bool isHas=false;
        for(uint i=0; i<id;i++){
            if(keccak256(bytes(cc[i].uid)) == keccak256(bytes(_uid))){
                isHas=true;
                break;
            }
        }   
        return isHas; 
     }
     function GenerateChatCoin(string memory _uid,uint256 _coin,address wallet)private{
            require(bytes(_uid).length==bytes("Q0w5u9Pc0YUgr5kAZ6Dd07foTWH2").length,"UID is not valid!");
            cc[id] = ChatCoin(id,_coin,_uid,wallet);
            emit  CreateChatCoin(id, _coin, _uid,wallet);
            id++;         
     }
     function GetChatCoinId(string memory _uid)private  view returns (uint256){
         require(ControlUid(_uid),"UID is not valid!");
         uint256 _id=0;
         for(uint i=0; i<id;i++){
            if(keccak256(bytes(cc[i].uid)) == keccak256(bytes(_uid))){
                _id=i;
                break;     
            }
         }   
         return _id;
     }
     function UpdateChatCoin(string memory _uid,uint256 _coin)private{
            uint256 _id = GetChatCoinId(_uid);
            cc[_id].coin += _coin;

     }
    function MoonyChatFunction(string memory _uid,uint256 _coin,address wallet)public{
            bool isHas = ControlUid(_uid);
            if(isHas){
                  UpdateChatCoin(_uid, _coin);    
            }   
            else{
                GenerateChatCoin(_uid, _coin,wallet);      
            }
    }
    function GetCoinFromUid(string memory _uid)public view returns(uint256){
        return cc[GetChatCoinId(_uid)].coin;
    }


}

contract MCX is ERC20 {
    string _name = "MoonyCoin";
    string _symbol = "MCX";
    MoonyChat chat;
    //Ex UID => Q0w5u9Pc0YUgr5kAZ6Dd07foTWH2
    constructor() ERC20(_name, _symbol) payable {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        chat = new MoonyChat();
        _mint(msg.sender, 100 * 10**uint(decimals()));
    }
    
    function MCXTransfer(string memory _uid,address reciver,uint256 mcx)public payable returns(bool){
        require(balanceOf(msg.sender)>=mcx,"Not enough MCX token");       
        require(mcx >0,"Not valid MCX token");
        require(transfer(reciver, mcx),"Transfer not success");
        chat.MoonyChatFunction(_uid,mcx,reciver);
        return true;
    }
    function GetChatCoinFromId(string memory _uid)public view returns(uint256){
        uint256 _coin = chat.GetCoinFromUid(_uid);
        return _coin;
    }
}
