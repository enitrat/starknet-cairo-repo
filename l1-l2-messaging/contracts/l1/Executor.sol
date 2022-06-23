pragma solidity 0.8.10;

import {IStarknetMessaging} from "./IStarknetMessaging.sol";

contract Executor {
    IStarknetMessaging public _messagingContract;
    uint256 public _targetContractAddress;
    uint256 public _l2Bridge;
    
    //set counter function selector
    uint256 constant COUNTER_SELECTOR =
        466113220353904227079477646267669139184889728383601285774983482773350532882;

    /**
        @notice bridge constructor
        @param messagingContract address of the messaging contract
     */
    constructor(
        address messagingContract,
        uint256 l2Bridge,
        uint256 targetContractAddress
    ) {
        _l2Bridge = l2Bridge;
        _targetContractAddress = targetContractAddress;
        _messagingContract = IStarknetMessaging(messagingContract);
    }

    function setCounter(uint128 counter) public {
        uint256[] memory payload = new uint256[](3);
        payload[0] = _targetContractAddress; //target contract address
        payload[1] = 1; // calldata_size -> number of arguments
        payload[2] = counter; // counter value to set

        // Here our l2 contract should receive ;
        // selector : COUNTER_SELECTOR
        // calldata_size : 4
        // calldata : address(this), _targeContractAddres, 1, counter

        _messagingContract.sendMessageToL2(
            _l2Bridge,
            COUNTER_SELECTOR,
            payload
        );
    }
}
