%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.lib.DataTypes import ReserveData
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func _reserves(asset : felt) -> (reserve : ReserveData):
end

@storage_var
func _reservesList(reserveId : Uint256) -> (address : felt):
end

@storage_var
func _reservesCount() -> (count : felt):
end

@storage_var
func user_balance(address : felt, asset : felt) -> (balance : Uint256):
end

@view
func get_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (reserve : ReserveData):
    return _reserves.read(asset)
end

@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt, asset : felt
) -> (balance : Uint256):
    return user_balance.read(address, asset)
end
