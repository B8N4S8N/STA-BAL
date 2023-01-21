pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/proxy/Proxy.sol";
import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";
import "https://github.com/smartcontractkit/chainlink/contracts/ChainlinkClient.sol";

contract StableCoinFactory {
    address public owner;
    mapping(address => bool) public isAToken;
    mapping(address => address) public stableCoinProxies;
    mapping(address => address) public balancerPools;

    constructor() public {
        owner = msg.sender;
    }

    function createStableCoin(address _balancerPool, address _aToken, uint256 _targetPrice, address _chainlink) public {
        require(msg.sender == owner, "Only the owner can create stablecoins.");
        require(isAToken[_aToken], "AToken must be registered before creating stablecoin.");
        require(balancerPools[_balancerPool], "Balancer pool must be registered before creating stablecoin.");
        require(_balancerPool.isContract(), "Balancer pool address must be a contract.");
        require(_aToken.isContract(), "AToken address must be a contract.");
        require(_chainlink.isContract(), "Chainlink address must be a contract.");

        // Create new StableCoin contract and proxy it
        address stableCoin = new StableCoin(_balancerPool, _aToken, _targetPrice, _chainlink);
        stableCoinProxies[_balancerPool] = proxy.address;

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
// New function to check the balance of a user
function checkBalance(address _owner) public view returns (uint256) {
    return balances[_owner];
}

 // Remove the stablecoin proxy associated with the AToken
    address stableCoin = stableCoinProxies[_aToken];
    require(stableCoin != address(0), "No stablecoin proxy associated with the AToken.");
    delete stableCoinProxies[_aToken];

    // Kill the stablecoin contract
    stableCoin.kill();
}



