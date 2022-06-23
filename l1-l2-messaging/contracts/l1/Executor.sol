pragma solidity 0.8.10;

import {IStarknetMessaging} from "./IStarknetMessaging.sol";

contract Executor {
    IStarknetMessaging public _messagingContract;
    uint256 public _targetContractAddress;
    uint256 public _l2Bridge;

    // uint256 constant L2_BRIDGE_SELECTOR =
    //     36732404255973873310547848522947094654948434535978358759594687535784598537;

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

    function setCounter(uint256 counter) public {
        uint256[] memory payload = new uint256[](3);
        payload[1] = _targetContractAddress; //target contract address
        payload[0] = 1; // calldata_size -> number of arguments
        payload[2] = counter; // counter value to set

        // Here our l2 contract should receive ;
        // selector : COUNTER_SELECTOR
        // calldata_size : 3
        // calldata : _targeContractAddres, 1, counter 

        _messagingContract.sendMessageToL2(
            _l2Bridge,
            COUNTER_SELECTOR,
            payload
        );
    }
}
