pragma solidity >=0.6.0 <0.7.0;

contract VoteDemo{
    
    address internal _owner;
    
    struct Voter{
        //投票人唯一地址 
        address addr;
        bool vote;
        uint amount;
    }
    
    struct Candidate{
        address addr;
        uint get;
        bool win;
    }
    
    mapping(address => Voter) public voters;
    mapping(address => Candidate) public candidates;
    
    constructor() public{
        _owner = msg.sender;
    }
    
    event showData(string);
    
    function initCandidate(address addr) public {
        candidates[addr] = Candidate(addr,0,false);
    }
    
    function initVote(address addr) public {
        if(voters[addr].addr != address(0)){
            emit showData("此人已经初始化");
            return;
        }
        voters[addr] = Voter({addr:addr,vote:false,amount:1});
    }
    
    
    function vote(address candidate) public{
        Voter storage v = voters[msg.sender];
        if(v.vote || v.addr == candidate){
            emit showData('此人不具备投票资格！');
            return;
        }
        candidates[candidate].get += v.amount;
        v.vote = true;
        
    }
    
    modifier checkOwner{
        if(msg.sender != _owner){
            revert();
        }
        _;
    }
    
    function success(address addr1,address addr2) public checkOwner returns(address){
        if(candidates[addr1].get > candidates[addr2].get){
            candidates[addr1].win = true;
            return addr1;
        }else{
            candidates[addr2].win = true;
            return addr2;
        }
    }
}