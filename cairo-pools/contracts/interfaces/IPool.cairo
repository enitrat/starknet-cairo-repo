%lang starknet

from contracts.lib.types.DataTypes import DataTypes
from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IPool:
    func get_reserve(asset : felt) -> (reserve : DataTypes.ReserveData):
    end

    func init_reserve(asset : felt, aToken_address : felt):
    end

    func supply(asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt):
    end

    func withdraw(asset : felt, amount : Uint256, to : felt):
    end

    func borrow(
        asset : felt,
        amount : Uint256,
        interest_rate_mode : felt,
        referral_code : felt,
        on_behalf_of : felt,
    ):
    end

    func repay(asset : felt, amount : Uint256, interest_rate_mode : felt, on_behalf_of : felt):
    end

    # TODO
    func drop_reserve():
    end
end
