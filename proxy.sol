/* This example uses a `StablecoinFactory` contract as the parent contract that manages the instances of the `Stablecoin` contract. The `Stablecoin` contract has been refactored to use a proxy contract pattern to minimize the storage writes in the smart contract and reduce the overall gas usage. The `StablecoinFactory` contract has an `onlyOwner` modifier that only allows the owner to deploy new stablecoin instances and an event that emits when a new stablecoin instance is created. */


pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/proxy/Proxy.sol";
import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";

contract StableCoinFactory {
    address public owner;
    mapping(address => bool) public isAToken;
    mapping(address => address) public stableCoinProxies;
    mapping(address => address) public balancerPools;

    constructor() public {
        owner = msg.sender;
    }

    function createStableCoin(address _balancerPool, address _aToken) public {
        require(msg.sender == owner, "Only the owner can create stablecoins.");
        require(isAToken[_aToken], "AToken must be registered before creating stablecoin.");
        require(balancerPools[_balancerPool], "Balancer pool must be registered before creating stablecoin.");

        address stableCoin = new StableCoin(_balancerPool, _aToken);
        stableCoinProxies[_balancerPool] = stableCoin;

        emit StableCoinCreated(stableCoin);
    }

    function addAToken(address _aToken) public {
        require(msg.sender == owner, "Only the owner can add aTokens.");
        require(!isAToken[_aToken], "Token is already registered.");
        isAToken[_aToken] = true;
    }

    function addBalancerPool(address _pool) public {
        require(msg.sender == owner, "Only the owner can add balancer pools.");
        require(!balancerPools[_pool], "Pool is already registered.");
        balancerPools[_pool] = _pool;
    }

    function removeBalancerPool(address _pool) public {
        require(msg.sender == owner, "Only the owner can remove balancer pools.");
        require(balancerPools[_pool], "Pool is not registered.");
        delete balancerPools[_pool];
    }

    function removeAToken(address _aToken) public {
        require(msg.sender == owner, "Only the owner can remove aTokens.");
        require(isAToken[_aToken], "Token is not registered.");
        isAToken[_aToken] = false;
    }
}

contract StableCoin is Proxy {
    address public oracle;
    BalancerPool public pool;
    AToken public aToken;
    uint256 public targetPrice;

    constructor(address _balancerPool, address _aToken) public {
        pool = BalancerPool(_balancerPool);
        aToken = AToken(_aToken);
    }

    function mint(address _owner, uint256 _amount) public {
        require(pool.remainingLiquidityCap() >= _amount, "Insufficient liquidity cap in pool.");
        require(aToken.remainingSupplyCap() >= _amount, "Insufficient supply cap for AToken.");

        // Retrieve current price from oracle
uint256 currentPrice = chainlink.getLatestAnswer().toUint256();
require(currentPrice <= targetPrice, "Coin price is already above target price.");
// Mint AToken
    aToken.mint(msg.sender, _amount);

    // Add liquidity to pool
    pool.addLiquidity(_aToken, _amount);

    // Update user balance
    balances[msg.sender] += _amount;

    // Emit event
    emit Mint(_aToken, msg.sender, _amount, interest);
}

function burn(address _aToken, uint256 _amount) public {
    require(isAToken[_aToken], "AToken must be registered before burning.");
    require(_amount > 0, "Amount must be greater than 0.");
    require(balances[msg.sender] >= _amount, "Insufficient balance for burn.");

    // Burn AToken
    aToken.burn(msg.sender, _amount);

    // Remove liquidity from pool
    pool.removeLiquidity(_aToken, _amount);

    // Update user balance
    balances[msg.sender] -= _amount;

    // Emit event
    emit Burn(_aToken, msg.sender, _amount);
}

function transferOwnership(address newOwner) public {
    require(msg.sender == owner, "Only the owner can transfer ownership.");
    owner = newOwner;
    emit OwnershipTransferred(owner);
}
}

contract StablecoinFactory is Ownable {
mapping (address => Stablecoin) public stablecoins;

function createStablecoin(address _pool, address _oracle, uint256 _targetPrice) public onlyOwner {
    require(address(stablecoins[_pool]) == address(0), "Stablecoin for pool already exists.");
    stablecoins[_pool] = new Stablecoin(_pool, _oracle, _targetPrice, msg.sender);
    emit StablecoinCreated(_pool, stablecoins[_pool]);
}
}