%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.types.DataTypes import DataTypes
from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.uint256 import Uint256

from contracts.src.PoolStorage import _reserves, _reserves_list, _reserves_count

from contracts.lib.logic.ReserveLogic import ReserveLogic

namespace PoolLogic:
    func execute_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : DataTypes.InitReserveParams
    ):
        alloc_locals
        # verify if params address correct
        let (reserve) = _reserves.read(params.asset)
        with_attr error_message("Reserve already initialized for {asset}"):
            assert reserve.aToken_address = 0
        end
        let (reserve) = ReserveLogic.init(reserve, params.aToken_address)  # returns reserve w/ correct aToken_address

        # Get next reserve index
        let (new_reserve_index : Uint256) = SafeUint256.add(params.reserves_count, Uint256(1, 0))
        let reserve_data = DataTypes.ReserveData(new_reserve_index, reserve.aToken_address)

        # # Updated stored index, reserve list with aTokenAdress, reserves
        _reserves.write(asset=params.asset, value=reserve_data)

        # # For PoC : always append
        _reserves_list.write(reserve_id=new_reserve_index, value=params.asset)
        _reserves_count.write(value=new_reserve_index)
        return ()
    end
end
