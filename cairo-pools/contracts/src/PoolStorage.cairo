%lang starknet

from starkware.cairo.common.uint256 import Uint256
from contracts.lib.types.DataTypes import DataTypes
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func _reserves(asset : felt) -> (reserve : DataTypes.ReserveData):
end

@storage_var
func _users_config(address : felt) -> (user_config : DataTypes.UserConfigurationMap):
end

@storage_var
func _reserves_list(reserve_id : Uint256) -> (address : felt):
end

@storage_var
func _e_mode_categories(id : felt) -> (category : DataTypes.EModeCategory):
end

@storage_var
func _users_EMode_category(address : felt) -> (category_id : felt):
end

@storage_var
func _bridge_protocol_fee() -> (bps : felt):
end

@storage_var
func _flash_loan_premium_total() -> (bps : felt):
end

@storage_var
func _flash_loan_premium_to_protocol() -> (bps : felt):
end

# Available liquidity that can be borrowed at once at stable rate, expressed in bps
@storage_var
func _max_stable_rate_borrow_size_percent() -> (bps : felt):
end

@storage_var
func _reserves_count() -> (count : Uint256):
end

@view
func get_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt
) -> (reserve : DataTypes.ReserveData):
    return _reserves.read(asset)
end

@view
func get_reserve_address_by_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : Uint256
) -> (address : felt):
    return _reserves_list.read(id)
end

@view
func get_reserves_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    count : Uint256
):
    return _reserves_count.read()
end
