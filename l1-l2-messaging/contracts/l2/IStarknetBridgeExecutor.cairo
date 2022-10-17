%lang starknet

@contract_interface
namespace IStarknetBridgeExecutor {
    func call_method(remote_contract: felt, selector: felt, calldata_len: felt, calldata: felt*) {
    }
}
