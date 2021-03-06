pragma solidity ^0.4.17;
contract Vote {
    address public owner;
    uint256 public minimumBet = 100 finney;
    uint256 public totalBet;
    uint256 public numberOfBets;
    address[] public players;
    address[] public lastBetWinners;
    uint256 public lastBetPrize;
    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }
    // The address of the player and => the user info   
    mapping(address => Player) public playerInfo;
    // The max amount of bets that cannot be exceeded to avoid excessive gas consumption
    // when distributing the prizes and restarting the game
    uint public constant LIMIT_AMOUNT_BETS = 100;

    function Vote() public {
        owner = msg.sender;
    }
    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    function checkPlayerExists(address player) public constant returns(bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return true;
            }
        }
        return false;
    }
    function getLastBetWinnerCount() public constant returns(uint256) {
        return lastBetWinners.length;
    }
    // To bet for a number between 1 and 10 both inclusive
    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender));
        require(numberSelected >= 1 && numberSelected <= 10);
        require(msg.value >= minimumBet);
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;
    }
    // Generates a number between 1 and 10 that will be the winner
    function generateNumberWinner() public {
        uint256 numberGenerated = block.number % 10 + 1; // This isn't secure
        distributePrizes(numberGenerated);
    }

   

    // Sends the corresponding ether to each winner depending on the total bets
    function distributePrizes(uint256 numberWinner) public {
        lastBetWinners.length = 0; 
       
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == numberWinner) {
                lastBetWinners.push(playerAddress);
            }
            delete playerInfo[playerAddress]; // Delete all the players
        }
        
        players.length = 0; // Delete all the players array
        lastBetPrize = totalBet / lastBetWinners.length; // How much each winner gets

        for (uint256 j = 0; j < lastBetWinners.length; j++) {
            lastBetWinners[j].transfer(lastBetPrize);
        }

        totalBet = 0;
        numberOfBets = 0;
    }
    // Fallback function in case someone sends ether to the contract so it doesn't get lost and to increase the treasury of this contract that will be distributed in each game
    function() public payable {}

   
}