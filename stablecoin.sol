pragma solidity ^0.8.0;

import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";

contract StableCoin {
    address public owner;
    mapping(address => AToken) public aTokens;
    BalancerPool public pool;
    uint256 public targetPrice; // Target USD price (e.g. $6.66)
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastPrices;
    mapping(address => uint256) public lastPriceUpdate;
    uint256 public priceDropThreshold;  // percentage threshold (e.g. 20)
    uint256 public timePeriod; // time period in seconds (e.g. 3600 for 1 hour)
    mapping(address => bool) public isAToken;
    mapping(address => address) public aTokenMapping;
    mapping(address => uint256) public oraclePrices;


    constructor(address[] _aTokens, address _pool, uint256 _targetPrice,uint256 _priceDropThreshold,uint256 _timePeriod) public {
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
        priceDropThreshold = _priceDropThreshold;
        timePeriod = _timePeriod;
    }

function setOracle(address _oracle) public {
    require(msg.sender == owner, "Only the owner can set the oracle address.");
    oracle = _oracle;
}


//    function getPrice() public view returns (uint256) {
    // Retrieve the current price from the oracle contract
//    Oracle oracle = Oracle(0x1234567890abcdef); // replace with the address of the oracle contract
//    return oracle.getPrice("STABLECOIN"); // replace "STABLECOIN" with the symbol of the stablecoin
//}

function getPrice() public view returns (uint256) {
    // Retrieve the current price from the oracle contract
    Oracle oracle;
    for (address _oracle in oraclePrices) {
        oracle = Oracle(_oracle);
        oraclePrices[_oracle] = oracle.getPrice("STABLECOIN"); // replace "STABLECOIN" with the symbol of the stablecoin
    }
    return oraclePrices[msg.sender];
}

function getInterestRate() public view returns (uint256) {
    return pool.getCurrentInterestRate();
}

    function getAToken(address token) public view returns (address) {
    return aTokenMapping[token];
}



  //  function mint(address to, address token, uint256 amount) public {
    //    require(msg.sender == owner, "Only the owner can mint tokens.");
      //  require(balances[to] + amount >= balances[to], "Overflow.");
  //      require(getPrice() < targetPrice, "Coin price is already above target price.");
//
  //      if(!isAToken[token]) {
    //        aTokens[token].mint(to, amount);
    //        require(pool.contains(token), "Token is not in the pool.");
    //        pool.addLiquidity(token, amount);
    //        balances[to] += amount;
    //    } else {
    //        // convert regular token to aToken
    //        aTokens[getAToken(token)].mint(to, amount);
    //        pool.addLiquidity(getAToken(token), amount);
    //        balances[to] += amount;
  //      }
  //  }



//function mint(address to, address token, uint256 amount) public {
//    require(msg.sender == owner, "Only the owner can mint tokens.");
//    require(balances[to] + amount >= balances[to], "Overflow.");
//    require(getPrice() < targetPrice, "Coin price is already above target price.");
//
//    if(!isAToken[token]) {
        // convert regular token to aToken
//      if(!aTokenMapping[token]) { 
//        aToken = getAToken(token);
//        aTokenMapping[token] = aToken;
//    }
//        aTokens[aTokenMapping[token]].mint(to, amount);
//    require(pool.contains(aTokenMapping[token]), "Token is not in the pool.");
//        pool.addLiquidity(aTokenMapping[token], amount);
//        isAToken[aTokenMapping[token]] = true;
//        aTokenMapping[aToken] = token;
//            } else {
//        aTokens[token].mint(to, amount);
//    require(pool.contains(token), "Token is not in the pool.");
//        pool.addLiquidity(token, amount);
//}
//balances[to] += amount;
//}

//function mint(address to, address token, uint256 amount) public {
//    require(msg.sender == owner, "Only the owner can mint tokens.");
//    require(balances[to] + amount >= balances[to], "Overflow.");
//    require(getPrice() < targetPrice, "Coin price is already above target price.");
//    require(amount <= aTokens[token].remainingSupplyCap(), "Amount exceeds remaining supply cap of token.");
//   require(amount <= pool.remainingLiquidityCap(), "Amount exceeds remaining liquidity cap of pool.");
//
//
//    if(!isAToken[token]) {
//        // convert regular token to aToken
//        
//        if(!aTokenMapping[token]) {
//            aTokenMapping[token] = getAToken(token);
//        }
//        require(pool.contains(aTokenMapping[token]), "Token is not in the pool.");
//        aTokens[aTokenMapping[token]].mint(to, amount);
//        pool.addLiquidity(aTokenMapping[token], amount);
//        isAToken[aTokenMapping[token]] = true;
//    } else {
//        require(pool.contains(token), "Token is not in the pool.");
//        aTokens[token].mint(to, amount);
//        pool.addLiquidity(token, amount);
//    }
//    balances[to] += amount;
//}



//function mint(address to, address token, uint256 amount) public {
//    require(msg.sender == owner, "Only the owner can mint tokens.");
//    require(balances[to] + amount >= balances[to], "Overflow.");
//    require(getPrice() < targetPrice, "Coin price is already above target price.");
//
//    if(!isAToken[token]) {
//        // convert regular token to aToken
//      if(!aTokenMapping[token]) { 
//        aToken = getAToken(token);
//        aTokenMapping[token] = aToken;
//    }
//        require(aTokens[aTokenMapping[token]].remainingSupplyCap() >= amount, "Amount to mint exceeds remaining supply cap.");
//        aTokens[aTokenMapping[token]].mint(to, amount);
//    require(pool.contains(aTokenMapping[token]), "Token is not in the pool.");
//        pool.addLiquidity(aTokenMapping[token], amount);
//        isAToken[aTokenMapping[token]] = true;
//        aTokenMapping[aToken] = token;
//            } else {
//        require(aTokens[token].remainingSupplyCap() >= amount, "Amount to mint exceeds remaining supply cap.");
//        aTokens[token].mint(to, amount);
//    require(pool.contains(token), "Token is not in the pool.");
//        pool.addLiquidity(token, amount);
//}
//balances[to] += amount;
//}


function mint(address to, address token, uint256 amount) public {
    require(msg.sender == owner, "Only the owner can mint tokens.");
    require(SafeMath.add(balances[to], amount) >= balances[to], "Overflow.");
    require(getPrice() < targetPrice, "Coin price is already above target price.");
    require(amount <= aTokens[token].remainingSupplyCap(), "Amount to mint is greater than remaining supply cap.");
    require(amount <= pool.remainingLiquidityCap(), "Amount to mint is greater than remaining liquidity cap of the pool.");
    require(pool.remainingLiquidity() >= amount * getInterestRate(), "Remaining liquidity of the pool is not enough to cover the interest generated from the minted tokens.");

    if(!isAToken[token]) {
        // convert regular token to aToken
        aToken = getAToken(token);
        aTokens[aToken].mint(to, amount);
        require(pool.contains(aToken), "Token is not in the pool.");
        pool.addLiquidity(aToken, amount);
        isAToken[aToken] = true;
        aTokenMapping[aToken] = token;
    } else {
        aTokens[token].mint(to, amount);
        require(pool.contains(token), "Token is not in the pool.");
        pool.addLiquidity(token, amount);
    }
    balances[to] += amount;
}




 //   function burn(address from, address token, uint256 amount) public {
 //       require(msg.sender == owner, "Only the owner can burn tokens.");
 //       require(balances[from] >= amount, "Not enough tokens.");
 //       require(getPrice() > targetPrice, "Coin price is already below target price.");
//
//        address aToken;
//
//        if(!isAToken[token]) {
//             token = getAToken(token);
//            aToken = aTokenMapping[token];
//        }
//            require(pool.contains(token), "Token is not in the pool.");
//            aTokens[token].burn(from, amount);
//            pool.removeLiquidity(token, amount);
//            balances[from] -= amount;
//            }
//            
//                else() {
//            // convert regular token to aToken
//            aTokens[getAToken(token)].burn(from, amount);
//        pool.removeLiquidity(getAToken(token), amount);
//        balances[from] -= amount;
//    }
//}

//function mint(address to, address token, uint256 amount) public {
//    require(msg.sender == owner, "Only the owner can mint tokens.");
//    require(balances[to] + amount >= balances[to], "Overflow.");
//    require(getPrice() < targetPrice, "Coin price is already above target price.");
//
//    if(!isAToken[token]) {
        // convert regular token to aToken
//      if(!aTokenMapping[token]) { 
//        aToken = getAToken(token);
//        aTokenMapping[token] = aToken;
//    }
//        require(aTokens[aTokenMapping[token]].remainingSupplyCap() >= amount, "Amount to mint exceeds remaining supply cap.");
//        aTokens[aTokenMapping[token]].mint(to, amount);
//    require(pool.contains(aTokenMapping[token]), "Token is not in the pool.");
//        pool.addLiquidity(aTokenMapping[token], amount);
//        isAToken[aTokenMapping[token]] = true;
//        aTokenMapping[aToken] = token;
//            } else {
//        require(aTokens[token].remainingSupplyCap() >= amount, "Amount to mint exceeds remaining supply cap.");
//        aTokens[token].mint(to, amount);
//    require(pool.contains(token), "Token is not in the pool.");
//        pool.addLiquidity(token, amount);
//}
//balances[to] += amount;
//}




//function burn(address from, address token, uint256 amount) public {
//    require(msg.sender == owner, "Only the owner can burn tokens.");
//    require(balances[from] >= amount, "Not enough tokens.");
//    require(getPrice() > targetPrice, "Coin price is already below target price.");
//
//    if(!isAToken[token]) {
//        // convert regular token to aToken
//        if(!aTokenMapping[token]) { 
//            aToken = getAToken(token);
//            aTokenMapping[token] = aToken;
//        }
//        require(pool.contains(aTokenMapping[token]), "Token is not in the pool.");
//        aTokens[aTokenMapping[token]].burn(from, amount);
//        pool.removeLiquidity(aTokenMapping[token], amount);
//        isAToken[aTokenMapping[token]] = false;
//    } else {
//        require(pool.contains(token), "Token is not in the pool.");
//        aTokens[token].burn(from, amount);
//        pool.removeLiquidity(token, amount);
//    }
//    balances[from] -= amount;
//}


function burn(address from, address token, uint256 amount) public {
    require(isAToken[token], "Token is not registered as aToken.");

    require(msg.sender == owner, "Only the owner can burn tokens.");
    require(balances[from] >= amount, "Not enough tokens.");
    require(getPrice() > targetPrice, "Coin price is already below target price.");
    require(amount <= pool.remainingLiquidity(), "Amount to burn is greater than remaining liquidity of the pool.");
    require(pool.remainingLiquidity() >= amount, "Amount to burn is greater than remaining liquidity of the pool.");


    address aToken;
    if(!isAToken[token]) {
    // convert regular token to aToken
    aToken = getAToken(token);
    aTokens[aToken].burn(from, amount);
    require(pool.contains(aToken), "Token is not in the pool.");
    pool.removeLiquidity(aToken, amount);
    isAToken[aToken] = false;
    delete aTokenMapping[aToken];
    } else {
    aTokens[token].burn(from, amount);
    require(pool.contains(token), "Token is not in the pool.");
    pool.removeLiquidity(token, amount);
    }
    balances[from] -= amount;
}




/*
function burn(address from, address token, uint256 amount) public {
    require(msg.sender == owner, "Only the owner can burn tokens.");
    require(balances[from] >= amount, "Not enough tokens.");
    require(getPrice() > targetPrice, "Coin price is already below target price.");

    address aToken;
    if(!isAToken[token]) {
    // convert regular token to aToken
        aToken = getAToken(token);
} else {
        aToken = token;
}

    require(aTokens[aToken].remainingSupply() >= amount, "Not enough remaining token supply.");
    require(pool.liquidityOf(aToken) >= amount, "Not enough remaining pool liquidity.");

        aTokens[aToken].burn(from, amount);
        pool.removeLiquidity(aToken, amount);
        balances[from] -= amount;
}



}










/*

mapping(address => bool) public oracles;
address[] public oraclePrices;

constructor(address[] _oraclePrices) public {
    for (uint256 i = 0; i < _oraclePrices.length; i++) {
        oracles[_oraclePrices[i]] = true;
        oraclePrices.push(_oraclePrices[i]);
    }
}

function getPrice() public view returns (uint256) {
    // Retrieve the current price from the oracle contracts
    uint256[] memory prices;
    for (uint256 i = 0; i < oraclePrices.length; i++) {
        Oracle oracle = Oracle(oraclePrices[i]);
        prices.push(oracle.getPrice("STABLECOIN"));
    }
    // select the price you want to use
    return selectPrice(prices);
}

function selectPrice(uint256[] memory prices) internal view returns (uint256) {
    // Example algorithm to select price: return the median of all the prices
    // Sort the prices
    // return the middle element
}



You could also add the oraclePrices mapping and iterate over them to get the average interest rate from all the oracles.

mapping (address => uint256) public oraclePrices;

function getInterestRate() public view returns (uint256) {
    uint256 total = 0;
    for (address _oracle in oraclePrices) {
        total += oraclePrices[_oracle];
    }
    return total / oraclePrices.length;
}