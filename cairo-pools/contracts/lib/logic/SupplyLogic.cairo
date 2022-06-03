%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_eq, uint256_le
from contracts.lib.types.DataTypes import DataTypes
from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.lib.IAToken import IAToken
from contracts.lib.IMintable import IMintable
from contracts.lib.logic.ValidationLogic import ValidationLogic

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.src.PoolStorage import _reserves

namespace SupplyLogic:
    func execute_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteSupplyParams
    ):
        alloc_locals
        # amount must be valid
        let (reserve) = _reserves.read(params.asset)  # parenthesis required to unpack function result

        ValidationLogic.validate_supply(reserve, params.amount)

        # TODO update reserve interest rates

        let (caller) = get_caller_address()

        # Transfer underlying from caller to aToken_address
        IERC20.transferFrom(
            contract_address=params.asset,
            sender=caller,
            recipient=reserve.aToken_address,
            amount=params.amount,
        )

        # TODO boolean to check if it is first supply
        # Mint aToken to on_behalf_of address
        IAToken.mint(
            contract_address=reserve.aToken_address, to=params.on_behalf_of, amount=params.amount
        )

        return ()
    end

    func execute_withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_config : DataTypes.UserConfigurationMap, params : DataTypes.ExecuteWithdrawParams
    ) -> (amount_to_withdraw : Uint256):
        alloc_locals
        # amount must be valid
        uint256_check(params.amount)
        let (caller) = get_caller_address()
        let (reserve) = _reserves.read(params.asset)
        # TODO is there a way to have caching in cairo as-well?
        local amount_to_withdraw : Uint256 = params.amount

        # If amount to withdraw is max(Uint256), set it to userbalance

        # aToken balance of caller
        let (local user_balance) = IAToken.balanceOf(reserve.aToken_address, caller)

        ValidationLogic.validate_withdraw(reserve, params.amount, user_balance)

        # for now, simple implementation, burns coins and returns underlying
        IAToken.burn(
            contract_address=reserve.aToken_address,
            account=caller,
            recipient=params.to,
            amount=params.amount,
        )

        return (amount_to_withdraw)
    end
end
