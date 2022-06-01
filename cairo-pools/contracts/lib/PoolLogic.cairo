%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.DataTypes import ReserveData, InitReserveParams

from contracts.src.PoolStorage import _reserves, _reserves_list, _reserves_count

from contracts.lib.ReserveLogic import ReserveLogic

namespace PoolLogic:
    func execute_init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : InitReserveParams
    ):
        # verify if params address correct
        let (reserve) = _reserves.read(params.asset)
        with_attr error_message("Reserve already initialized for {asset}"):
            assert reserve.aTokenAddress = 0
        end
        let (reserve) = ReserveLogic.init(reserve, params.aTokenAddress)  # returns reserve w/ correct aTokenAddress

        # Get next reserve index
        let new_reserve_index = params.reserves_count + 1
        let reserve_data = ReserveData(new_reserve_index, reserve.aTokenAddress)

        # # Updated stored index, reserve list with aTokenAdress, reserves
        _reserves.write(asset=params.asset, value=reserve_data)

        # # For PoC : always append
        _reserves_list.write(reserve_id=new_reserve_index, value=params.asset)
        _reserves_count.write(value=new_reserve_index)
        return ()
    end
end
