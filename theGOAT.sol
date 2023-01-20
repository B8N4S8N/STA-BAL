import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/datastructures/PriorityQueue.sol";
import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";



contract StableCoin {
    address public owner;
    mapping(address => AToken) public aTokens;
    BalancerPool public pool;
    uint256 public targetPrice;
    mapping(address => uint256) public balances;
    PriorityQueue oracles;
    mapping(address => bool) public isAToken;
    mapping(address => address) public aTokenMapping;
    mapping(address => uint256) public oraclePrices;

    constructor(address[] _aTokens, address _pool, uint256 _targetPrice) public {
        owner = msg.sender;
        for (uint256 i = 0; i < _aTokens.length; i++) {
            if (!isAToken[_aTokens[i]]) {
                aTokens[_aTokens[i]] = AToken(_aTokens[i]);
                isAToken[_aTokens[i]] = true;
            }
        }
        pool = BalancerPool(_pool);
        targetPrice = _targetPrice;
        oracles = PriorityQueue(contract address);
    }

    function addOracle(address _oracle) public {
        require(msg.sender == owner, "Only the owner can add oracles.");
        oracles.push(_oracle);
    }

    function removeOracle(address _oracle) public {
        require(msg.sender == owner, "Only the owner can remove oracles.");
        oracles.remove(_oracle);
    }


function getPrice() public view returns (uint256) {
    // Retrieve the current prices from all oracles
    Oracle oracle;
    uint256[] prices;
    for (address _oracle in oraclePrices) {
        oracle = Oracle(_oracle);
        prices.push(oracle.getPrice("STABLECOIN"));
    }
    // Sort the prices in ascending order
    assembly {
        let len := mload(prices)
        let data := add(prices, 0x20)
        for { let i := 0 } lt(i, len) { i := add(i, 0x20) }
            {
                for { let j := i } lt(j, len) { j := add(j, 0x20) }
                    {
                        let left := mload(add(data, i))
                        let right := mload(add(data, j))
                        if gt(left, right) {
                            mstore(add(data, i), right)
                            mstore(add(data, j), left)
                        }
                    }
            }
    }
    // Retrieve the median or average price
    uint256 price;
    if (prices.length % 2 == 0) {
        price = (prices[prices.length / 2 - 1] + prices[prices.length / 2]) / 2;
    } else {
        price = prices[prices.length / 2];
    }
    return price();

    function getInterestRate() public view returns (uint256) {
    return pool.getCurrentInterestRate();
}

function getAToken(address token) public view returns (address) {
    return aTokenMapping[token];
}

function mint(address to, address token, uint256 amount) public {
    require(msg.sender == owner, "Only the owner can mint tokens.");
    require(SafeMath.add(balances[to], amount) >= balances[to], "Overflow.");
    require(getPrice() < targetPrice, "Coin price is already above target price.");
    require(amount <= aTokens[token].remainingSupplyCap(), "Amount to mint is greater than remaining supply cap.");
    require(amount <= pool.remainingLiquidityCap(), "Amount to mint is greater than remaining liquidity cap of the pool.");
    uint256 interestRate = pool.getCurrentInterestRate();
    require(interestRate != 0, "Interest rate is not available.");
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
}

function burn(address from, address token, uint256 amount) public {
    require(isAToken[token], "Token is not registered as aToken.");

    require(msg.sender == owner, "Only the owner can burn tokens.");
    require(balances[from] >= amount, "Not enough tokens.");
    require(getPrice() > targetPrice, "Coin price is already below target price.");
    uint256 interestRate = pool.getCurrentInterestRate();
    require(interestRate != 0, "Interest rate is not available.");
    require(amount <= pool.remainingLiquidity() / interestRate, "Amount to burn is greater than remaining liquidity of the pool.");
    //require(pool.remainingLiquidity() >= amount * interestRate, "Amount to burn is greater than remaining liquidity of the pool.");

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

}