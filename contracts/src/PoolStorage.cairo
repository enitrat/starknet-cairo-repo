%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.lib.DataTypes import ReserveData
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func _reserves(asset : felt) -> (reserve : ReserveData):
end

@storage_var
func _reserves_list(reserve_id : felt) -> (address : felt):
end

@storage_var
func _reserves_count() -> (count : felt):
end

@view
func get_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (reserve : ReserveData):
    return _reserves.read(asset)
end

@view
func get_reserve_address_by_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> (address : felt):
    return _reserves_list.read(id)
end

@view
func get_reserves_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    count : felt
):
    return _reserves_count.read()
end
