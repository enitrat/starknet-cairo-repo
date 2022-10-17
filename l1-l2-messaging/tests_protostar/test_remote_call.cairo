%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from contracts.l2.IStarknetBridgeExecutor import IStarknetBridgeExecutor
from contracts.l2.IBalance import IBalance

const SELECTOR = 466113220353904227079477646267669139184889728383601285774983482773350532882;  // set_counter

// Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr: felt*, range_check_ptr}() {
    %{
        context.balance = deploy_contract("./contracts/l2/Balance.cairo").contract_address

        context.executor = deploy_contract("./contracts/l2/StarknetBridgeExecutor.cairo").contract_address
    %}
    return ();
}

@view
func test_remote_call{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local executor_address;
    local balance_address;
    %{
        ids.executor_address = context.executor
        ids.balance_address = context.balance
    %}
    let calldata: felt* = alloc();
    assert [calldata] = 3;

    IStarknetBridgeExecutor.call_method(
        contract_address=executor_address,
        remote_contract=balance_address,
        selector=SELECTOR,
        calldata_len=1,
        calldata=calldata,
    );

    let (counter) = IBalance.get_counter(contract_address=balance_address);
    assert counter = 3;
    return ();
}
