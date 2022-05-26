%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.uint256 import Uint256
from contracts.lib.DataTypes import InitReserveParams
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.src.PoolStorage import _reserves_count

from contracts.lib.SupplyLogic import SupplyLogic
from contracts.lib.ReserveLogic import ReserveLogic
from contracts.lib.PoolLogic import PoolLogic
from contracts.lib.BorrowLogic import BorrowLogic

@external
func supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, onBehalfOf : felt
):
    SupplyLogic._executeSupply(asset, amount, onBehalfOf)
    return ()
end

@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, to : felt
):
    SupplyLogic._executeWithdraw(asset, amount, to)
    return ()
end

@external
func init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, aTokenAddress : felt
):
    let (reserves_count) = _reserves_count.read()
    PoolLogic.execute_init_reserve(InitReserveParams(asset, aTokenAddress, reserves_count))
    return ()
end

# Missing interests and everything
@external
func borrow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, onBehalfOf : felt
):
    return ()
end
