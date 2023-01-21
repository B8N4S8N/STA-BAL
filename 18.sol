Copy code
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
//Observation: This function allows the owner to add new aTokens to the factory's whitelist. This is useful for adding new aTokens to the pool as they are created. It also ensures that the same aToken is not added multiple times.
function addBalancerPool(address _pool) public {
    require(msg.sender == owner, "Only the owner can add balancer pools.");
    require(!balancerPools[_pool], "Pool is already registered.");
    balancerPools[_pool] = _pool;
}
//Observation: This function allows the owner to add new Balancer pools to the factory's whitelist. This is useful for creating new stablecoins for different pools. It also ensures that the same pool is not added multiple times.

function removeBalancerPool(address _pool) public {
    require(msg.sender == owner, "Only the owner can remove balancer pools.");
    require(balancerPools[_pool], "Pool is not registered.");
    delete balancerPools[_pool];
}
//Observation: This function allows the owner to remove existing Balancer pools from the factory's whitelist. This is useful for removing pools that are no longer needed. It also ensures that only the owner can remove pools.

function removeAToken(address _aToken) public {
    require(msg.sender == owner, "Only the owner can remove aTokens.");
    require(isAToken[_aToken], "Token is not registered.");
    isAToken[_aToken] = false;
}