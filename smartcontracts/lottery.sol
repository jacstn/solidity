// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address public loteryOwner;

    constructor() {
        loteryOwner = msg.sender;
    }

    function buyTicket() external payable {
        require(msg.value == 1 ether, "lottery ticket costs 1 ETH");
        require(msg.sender!=loteryOwner, "owner cannot participate");
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns (uint) {
        require(msg.sender == loteryOwner, "only owner can pick a winner and transfer money");
        return address(this).balance;
    }

    function numOfParticipants() public view returns (uint) {
        return players.length;
    }

    function pickWinner() public returns (address){
        require (players.length >= 2, "minimum 2 participents required");
        uint random = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length))) % players.length;

        address payable winner = payable(players[random]);
        winner.transfer(getBalance());
        players = new address payable[](0);
        return winner;
    }
}
