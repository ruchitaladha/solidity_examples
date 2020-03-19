pragma solidity ^0.4.17;

contract SimpleAuction{
    
    address public beneficiary;
    uint public auctionEnd;
    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint) pendingReturns;
    
    bool ended;
    
    event HighestBidIncrease(address bidder, uint amount);
    
    event AuctionEnd(address winner, uint amount);
    
    function SimpleAuction(uint _biddingTime, address _beneficiary){
        
        beneficiary = _beneficiary;
        auctionEnd =  now + _biddingTime;
    }
    
    function bid() payable{
        require(now < auctionEnd);
        require(msg.value > highestBid);
        
        if(highestBidder != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidIncrease(msg.sender, msg.value);
    }
    
    
    function withdraw() returns (bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!msg.sender.send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    
    function auctionEnd(){
        require(now > auctionEnd);
        require(!ended);
        ended = true;
        AuctionEnd(highestBidder,highestBid);
        beneficiary.transfer(highestBid);
    }
}