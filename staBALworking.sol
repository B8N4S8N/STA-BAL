// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Stablecoin {
    address owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public peggedValue;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _peggedValue) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        peggedValue = _peggedValue;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function addCoins(uint256 _value) public payable {
        require(msg.value > 0, "Value must be greater than 0.");
        require(_value == (msg.value / peggedValue), "Incorrect amount of coins sent.");
        totalSupply += _value;
        balanceOf[msg.sender] += _value;
        emit Mint(msg.sender, _value);
    }

    function withdrawCoins(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        uint256 withdrawAmount = _value * peggedValue;
        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        payable(msg.sender).transfer(withdrawAmount);
        emit Burn(msg.sender, _value);
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
}
