%lang starknet

from contracts.lib.DataTypes import ReserveData
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IPool:
    func get_reserve(asset : felt) -> (reserve : ReserveData):
    end

    func init_reserve(asset : felt, aTokenAddress : felt):
    end

    func supply(asset : felt, amount : Uint256, onBehalfOf : felt):
    end

    func withdraw(asset : felt, amount : Uint256, to : felt):
    end

    func borrow(asset : felt, amount : Uint256, onBehalfOf : felt):
    end

    func repay(asset : felt, amount : Uint256, onBehalfOf : felt):
    end
end
