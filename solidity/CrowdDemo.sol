pragma solidity >=0.6.0 <0.7.0;

contract CrowdDemo{
    struct Funder{
        address addr;
        uint amount;
    }
    
    struct Product{
        address payable addr;
        uint goal;
        uint amount;
        uint funderNum;
        mapping(uint => Funder) funders;
    }
    
    Product[] public products;
    
    function candidate(address payable addr,uint goal) public returns (uint){
        products.push(Product(addr,goal * 10 **18,0,0));
        return products.length;
    }
    
    function vote(uint index) public payable{
        Product storage p =  products[index];
        p.funders[p.funderNum++] = Funder({addr:msg.sender,amount:msg.value});
        p.amount += msg.value;
    }
    
    function check(uint index)public payable returns(bool){
        Product storage p =  products[index];
        if(p.amount < p.goal){
            return false;
        }
        uint amount = p.amount;
        p.addr.transfer(amount);
        p.amount = 0;
    }
}