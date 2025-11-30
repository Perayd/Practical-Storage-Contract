// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ExampleStorage - demonstrates common EVM storage patterns
contract ExampleStorage {
    // ---------- State (persistent storage) ----------
    address public owner;               // slot 0 (usually)
    uint256 public storedValue;         // slot 1

    // packed values: two uint128 in one 32-byte slot where possible
    uint128 public counterLow;          // part of same slot as counterHigh if ordered correctly
    uint128 public counterHigh;

    // mapping: consumes keccak256(key . slot)
    mapping(address => uint256) public balances;

    // struct + array
    struct Item {
        uint256 id;
        address creator;
        uint256 timestamp;
        string data; // note: dynamic data stored separately; slot holds a hash/pointer
    }
    Item[] public items;

    // events
    event StoredValueChanged(uint256 oldValue, uint256 newValue);
    event ItemAdded(uint256 indexed id, address indexed creator);

    // ---------- Modifiers ----------
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // ---------- Constructor ----------
    constructor() {
        owner = msg.sender;
    }

    // ---------- Functions (write) ----------
    function setStoredValue(uint256 newValue) external onlyOwner {
        uint256 old = storedValue;
        storedValue = newValue; // persistent write
        emit StoredValueChanged(old, newValue);
    }

    function incrementCounters(uint128 lowInc, uint128 highInc) external {
        // demonstrates storage packing: counterLow and counterHigh are each 128 bits
        counterLow += lowInc;
        counterHigh += highInc;
    }

    function setBalance(address who, uint256 amount) external {
        // mapping write
        balances[who] = amount;
    }

    function addItem(string calldata _data) external returns (uint256) {
        uint256 id = items.length;
        items.push(Item({
            id: id,
            creator: msg.sender,
            timestamp: block.timestamp,
            data: _data
        }));
        emit ItemAdded(id, msg.sender);
        return id;
    }

    // ---------- Functions (read helpers) ----------
    function getItem(uint256 index) external view returns (Item memory) {
        require(index < items.length, "index OOB");
        return items[index];
    }

    function getItemsCount() external view returns (uint256) {
        return items.length;
    }
}
