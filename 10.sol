
pragma solidity ^0.8.0;

import"https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import"https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";



contract StableCoin {
    address public owner;
    mapping(address => AToken) public aTokens;
    BalancerPool public pool;
    uint256 public targetPrice;
    mapping(address => uint256) public balances;

    mapping(address => bool) public isAToken;
    mapping(address => address) public aTokenMapping;
    mapping(address => uint256) public oraclePrices;

constructor(address[] _aTokens, address _pool, uint256 _targetPrice) public {
    owner = msg.sender;
    for (uint256 i = 0; i < _aTokens.length; i++) {
        if (!isAToken[_aTokens[i]]) {
            aTokens[_aTokens[i]] = AToken(_aTokens[i]);
            oraclePrices[_aTokens[i]] = _aTokens[i];
            isAToken[_aTokens[i]] = true;
        }
    }
    pool = BalancerPool(_pool);
    targetPrice = _targetPrice;
    
}

 function addOracle(address _oracle) public {
        require(msg.sender == owner, "Only the owner can add oracles.");
        oracles.push(_oracle);
    }

    function removeOracle(address _oracle) public {
        require(msg.sender == owner, "Only the owner can remove oracles.");
        for (uint256 i = 0; i < oracles.length; i++) {
            if (oracles[i] == _oracle) {
                // remove element at index i
                delete oracles[i];
                break;
            }
        }
    }

function getPrice() public view returns (uint256) {
    // Retrieve the current prices from all oracles
    uint256[] prices;
    for (uint256 i = 0; i < oraclePrices.length; i++) {
        address _oracle = oraclePrices[i];
        Oracle oracle = Oracle(_oracle);
        prices.push(oracle.getPrice("STABLECOIN"));
    }
    // Sort the prices in ascending order
    prices.sort();
    // Retrieve the median price
    uint256 price;
    if (prices.length % 2 == 0) {
        price = (prices[prices.length / 2 - 1] + prices[prices.length / 2]) / 2;
    } else {
        price = prices[prices.length / 2];
   
}
}
 function getInterestRate() public view returns (uint256) {
    return pool.getCurrentInterestRate();
}

function getAToken(address token) public view returns (address) {
    return aTokenMapping[token];
}

function mint(address to, address token, uint256 amount) public {
    require(msg.sender == owner, "Only the owner can mint tokens.");
    require(to != address(0), "Cannot mint to the zero address.");
    require(isAToken[token], "Token is not registered as aToken.");
    ERC20 tokenContract = ERC20(token);
    require(address(tokenContract).isContract(), "Invalid token contract.");
    require(tokenContract.totalSupply() > 0, "Invalid ERC20 token.");
    require(SafeMath.add(balances[to], amount) >= balances[to], "Overflow.");
    require(getPrice() < targetPrice, "Coin price is already above target price.");
    require(amount <= pool.remainingLiquidityCap(), "Amount to mint is greater than remaining liquidity cap of the pool.");
    require(amount <= aTokens[token].remainingSupplyCap(), "Amount to mint is greater than remaining supply cap.");
    uint256 interestRate = pool.getCurrentInterestRate();
    require(interestRate != 0 && interestRate <= 100, "Interest rate is not available or greater than 100%.");
    require(pool.remainingLiquidity() >= amount * interestRate / 100, "Remaining liquidity of the pool is not enough to cover the interest generated from the minted tokens.");

    if(!isAToken[token]) {
        // convert regular token to aToken
        address aToken = getAToken(token);
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
    emit Mint(to, token, amount);
}

function burn(address from, address token, uint256 amount) public {
    require(msg.sender == owner, "Only the owner can burn tokens.");
    require(from != address(0), "Cannot burn from the zero address.");
    require(token != address(0), "Cannot burn from the zero address.");
    require(balances[from] >= amount, "Not enough tokens.");
    require(isAToken[token], "Token is not registered as aToken.");
    require(getPrice() > targetPrice, "Coin price is already below target price.");
    uint256 interestRate = pool.getCurrentInterestRate();
    require(interestRate != 0, "Interest rate is not available.");
    require(amount <= pool.remainingLiquidity() / interestRate, "Amount to burn is greater than remaining liquidity of the pool.");
    address aToken;
    if(!isAToken[token]) {
        // convert regular token to aToken
        aToken = getAToken(token);
        require(aToken != address(0), "Cannot burn from the zero address.");
        require(aTokens[aToken].address != address(0), "Not a valid contract address or not a ERC20 contract.");
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

function transferOwner(address newOwner) public {
    // Only the current owner can transfer ownership
    require(msg.sender == owner, "Only the current owner can transfer ownership.");
    // The new owner address cannot be the zero address
    require(newOwner != address(0), "The new owner address cannot be the zero address.");
    // Transfer ownership
    owner = newOwner;
    emit OwnershipTransferred(msg.sender, newOwner);
}

}

