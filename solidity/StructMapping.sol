pragma solidity >=0.6.0 <0.7.0;

contract StructMapping{
    struct Person{
        string _name;
        uint _age;
    }
    mapping(address => Person) public perMap;
    
    function serPerson(string memory name,uint age) public{
        perMap[msg.sender] = Person({_name:name,_age:age});
    }
    
    function getPerson() public view returns(string memory name,uint age){
        Person memory person = perMap[msg.sender];
        return (person._name,person._age);
    }
}