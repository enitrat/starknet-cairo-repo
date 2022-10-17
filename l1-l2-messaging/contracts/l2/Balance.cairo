%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func counter() -> (res: felt) {
}

@external
func set_counter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}(
    value: felt
) {
    counter.write(value);
    return ();
}

@view
func get_counter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}() -> (
    res: felt
) {
    let (res) = counter.read();
    return (res=res);
}
