pragma solidity >=0.6.0 <0.7.0;

contract PayableDemo{
    address payable public _owner;
    
    constructor() public{
        _owner = msg.sender;
    }

    function transfer() public payable{
        _owner.transfer(msg.value);
    }
    
    function showBanlance() public view returns(uint256,uint256){
        address _account = msg.sender;
        return (_account.balance,_owner.balance);
    }
}