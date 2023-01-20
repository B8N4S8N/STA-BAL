
pragma solidity ^0.8.0;

import "https://github.com/aave/aave-protocol/contracts/aTokens/AToken.sol";
import "https://github.com/balancer-labs/balancer-contracts/contracts/BalancerPool.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract StableCoin {
    address public owner;
    mapping(address => bool) public isAToken;
    BalancerPool public pool;
    uint256 public targetPrice;
    address public oracle;

    constructor(address _pool, address _oracle, uint256 _targetPrice) public {
        owner = msg.sender;
        pool = BalancerPool(_pool);
        oracle = _oracle;
        targetPrice = _targetPrice;
    }

    function addAToken(address _aToken) public {
        require(msg.sender == owner, "Only the owner can add aTokens.");
        require(!isAToken[_aToken], "Token is already registered.");
        isAToken[_aToken] = true;
    }

    function removeAToken(address _aToken) public {
        require(msg.sender == owner, "Only the owner can remove aTokens.");
        require(isAToken[_aToken], "Token is not registered.");
        isAToken[_aToken] = false;
    }

    function mint(address _aToken, uint256 _amount) public {
        require(isAToken[_aToken], "AToken must be registered before minting.");
        require(_amount > 0, "Amount must be greater than 0.");
        require(balances[msg.sender] + _amount > balances[msg.sender], "Overflow.");
        require(pool.remainingLiquidityCap() >= _amount, "Insufficient liquidity cap in pool.");
        require(aTokens[_aToken].remainingSupplyCap() >= _amount, "Insufficient supply cap for AToken.");


    uint256 interest = pool.getCurrentInterestRate();
    require(interest > 0 && interest <= 100, "Invalid interest rate.");

    // Mint AToken
    aTokens[_aToken].mint(msg.sender, _amount);

    // Add liquidity to pool
    pool.addLiquidity(_aToken, _amount);

    // Update user balance
    balances[msg.sender] += _amount;

    // Emit event
    emit Mint(_aToken, msg.sender, _amount, interest);
}
}