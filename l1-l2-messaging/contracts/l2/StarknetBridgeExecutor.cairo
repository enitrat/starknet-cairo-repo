%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.invoke import invoke
from starkware.starknet.common.syscalls import call_contract
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.math import assert_not_zero

@l1_handler
@raw_input
func __l1_default__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr : felt}(
    selector : felt, calldata_size : felt, calldata : felt*
):
    %{
        print("message received")
        print(ids.selector)
        print(ids.calldata_size)
    %}
    assert_not_zero(calldata_size - 1)  # ensure we always have at least a contract address + a calldata_size
    let function_arguments : felt* = calldata + 2  # calldata[0] is the contract address, calldata[1] is the number of arguments

    call_contract(
        contract_address=calldata[0],
        function_selector=selector,
        calldata_size=calldata[1],
        calldata=function_arguments,
    )
    return ()
end
