#UNUSED
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func _price(asset : felt) -> (price : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset_1 : felt, price_1 : felt, asset_2 : felt, price_2 : felt
):
    _price.write(asset_1, price_1)
    _price.write(asset_2, price_2)
    return ()
end

@view
func get_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(asset : felt) -> (
    price : felt
):
    return _price.read(asset)
end
