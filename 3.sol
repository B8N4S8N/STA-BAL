pragma solidity ^0.8.0;

import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract StableCoin {
address public owner;
mapping(address => AToken) public aTokens;
BalancerPool public pool;
uint256 public targetPrice; // Target USD price (e.g. $6.66)
mapping(address => uint256) public balances;
mapping(address => bool) public isAToken;
mapping(address => address) public aTokenMapping;
mapping(address => uint256) public oraclePrices;


constructor(address[] _aTokens, address _pool, uint256 _targetPrice) public {
    owner = msg.sender;
   for (uint256 i = 0; i < _oracles.length; i++) {
    oraclePrices[_oracles[i]] = 0;
}

    for (uint256 i = 0; i < _aTokens.length; i++) {
      if(!isAToken[_aTokens[i]]) {  
        aTokens[_aTokens[i]] = AToken(_aTokens[i]);
        isAToken[_aTokens[i]] = true;
    }
}
    pool = BalancerPool(_pool);
    targetPrice = _targetPrice;
}
function setOracle(address _oracle) public {
require(msg.sender == owner, "Only the owner can set the oracle address.");
oraclePrices[_oracle] = oracle;
}

/*function getPrice() public view returns (uint256) {
// Retrieve the current price from the oracle contract
Oracle oracle;
uint256 price;
for (address _oracle in oraclePrices) {
oracle = Oracle(_oracle);
price = oracle.getPrice("STABLECOIN"); // replace "STABLECOIN" with the symbol of the stablecoin
oraclePrices[_oracle] = price;
}
return oraclePrices[msg.sender];
}
*/
function getPrice() public view returns (uint256) {
    uint256 price;
    for (address _oracle in oraclePrices) {
        Oracle oracle = Oracle(_oracle);
        price = oracle.getPrice("STABLECOIN"); // replace "STABLECOIN" with the symbol of the stablecoin
        oraclePrices[_oracle] = price;
    }
    return oraclePrices[msg.sender];
}



function getInterestRate()