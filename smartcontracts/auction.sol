i// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;


contract Auciton {
    enum auctionState {
        STARTED, RUNNING, ENDED, CANCELED
    }

    address public owner;
    mapping(address => uint) public bids;
    uint public startBlock;
    uint public endBlock;
    auctionState state;
    uint8 bidIncrement = 100;
    address highestBidder;
    uint highestBid;
    string ipfsHash="";

    constructor() {
        owner = msg.sender;
        state = auctionState.RUNNING;
        startBlock = block.number;
        endBlock = startBlock + 40320;
    }

    function bid() public payable notOwner{
        require(msg.value >= 100, "minimum bid is 100 wei");

        uint currentBid = bids[msg.sender] + msg.value;
        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]) {
            highestBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    modifier notOwner() {
        require(msg.sender != owner, "bidder must not be an owner of the contract");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "action can be performed only by contract owner");
        _;
    }

    function myBid() public view returns (uint) {
        return bids[msg.sender];
    }

    function min(uint a, uint b) pure internal returns (uint) {
        if (a > b) return b;
        return a;
    }

    function finalizeAuction() public {
        require(state == auctionState.CANCELED || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        address payable receipient;
        uint value;

        if (state == auctionState.CANCELED) {
            receipient == payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if (msg.sender == owner) {
                receipient = payable(owner);
                value = highestBid;
            } else {
                if (msg.sender == highestBidder) {
                    receipient = payable(highestBidder);
                    value = bids[highestBidder] - highestBid;
                } else {
                    receipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        receipient.transfer(value);
    }

    function cancelAuction() public onlyOwner {
        auctionState = auctionState.CANCELED;
    }
}
