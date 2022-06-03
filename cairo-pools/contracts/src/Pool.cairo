%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

from openzeppelin.token.erc20.interfaces.IERC20 import IERC20

from contracts.lib.types.DataTypes import DataTypes
from contracts.lib.logic.SupplyLogic import SupplyLogic
from contracts.lib.logic.ReserveLogic import ReserveLogic
from contracts.lib.logic.PoolLogic import PoolLogic
from contracts.lib.logic.BorrowLogic import BorrowLogic

from contracts.src.PoolStorage import (
    _reserves_count,
    _users_config,
    _max_stable_rate_borrow_size_percent,
    _flash_loan_premium_to_protocol,
    _flash_loan_premium_total,
    _users_EMode_category,
)

@storage_var
func POOL_REVISION() -> (revision : Uint256):
end

@storage_var
func ADDRESSES_PROVIDER() -> (address : felt):
end

# # MODIFIERS (not properly speaking but cairo equivalent) ##

func onlyPoolConfigurator{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = ADDRESSES_PROVIDER.read()
    with_attr error_message("10"):
        # assert IPoolAddressesProvider.getPoolConfigurator(contract_address=addresses_provider) = caller_address
    end
    return ()
end

func onlyPoolAdmin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = ADDRESSES_PROVIDER.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("1"):
        # assert IACLManager.isPoolAdmin(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

func onlyBridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = ADDRESSES_PROVIDER.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("2"):
        # assert IACLManager.isBridge(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    provider : felt
):
    ADDRESSES_PROVIDER.write(provider)
    return ()
end

@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(provider : felt):
    let (current_provider) = ADDRESSES_PROVIDER.read()
    with_attr error_message("12"):
        assert provider = current_provider
    end
    _max_stable_rate_borrow_size_percent.write(2500)  # 0.25e4
    _flash_loan_premium_total.write(9)  # 0.0009e4
    _flash_loan_premium_to_protocol.write(0)
    return ()
end

@external
func mint_unbacked{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt
):
    # BridgeLogic.mintUnbacked(asset, amount, on_behalf_of, referral_code)
    return ()
end

@external
func back_unbacked{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt
):
    # BridgeLogic.backUnbacked(asset, amount, on_behalf_of, referral_code)
    return ()
end

@external
func supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, on_behalf_of : felt, referral_code : felt
):
    let (user_config) = _users_config.read(on_behalf_of)
    SupplyLogic.execute_supply(
        user_config, DataTypes.ExecuteSupplyParams(asset, amount, on_behalf_of, referral_code)
    )
    return ()
end

@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, to : felt
) -> (amount_to_withdraw : Uint256):
    let (caller_address) = get_caller_address()
    let (reserves_count) = _reserves_count.read()
    let (user_config) = _users_config.read(caller_address)
    # let (oracle) = IAddressProvider.getPriceOracle(contract_address=ADDRESSES_PROVIDER.read())
    let oracle = 0
    let (user_EMode_category) = _users_EMode_category.read(caller_address)
    let (amount_to_withdraw) = SupplyLogic.execute_withdraw(
        user_config,
        DataTypes.ExecuteWithdrawParams(
        asset=asset,
        amount=amount,
        to=to,
        reserves_count=reserves_count,
        oracle=oracle,
        user_EMode_category=user_EMode_category
        ),
    )
    return (amount_to_withdraw)
end

# Missing interests and everything
@external
func borrow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt,
    amount : Uint256,
    interest_rate_mode : felt,
    referral_code : felt,
    on_behalf_of : felt,
):
    let (caller_address) = get_caller_address()
    let (user_config) = _users_config.read(on_behalf_of)
    let (max_stable_rate_borrow_size_percent) = _max_stable_rate_borrow_size_percent.read()
    let (reserves_count) = _reserves_count.read()
    # let (oracle) = IAddressProvider.getPriceOracle(contract_address=ADDRESSES_PROVIDER.read())
    let oracle = 0
    # let (price_oracle_sentinel) = IAddressProvider.getPriceOracleSentinel(contract_address=ADDRESSES_PROVIDER.read())
    let price_oracle_sentinel = 0

    let (user_EMode_category) = _users_EMode_category.read(caller_address)
    BorrowLogic.execute_borrow(
        user_config,
        DataTypes.ExecuteBorrowParams(
        asset=asset,
        user=caller_address,
        on_behalf_of=on_behalf_of,
        amount=amount,
        interest_rate_mode=interest_rate_mode,
        referral_code=referral_code,
        release_underlying=TRUE,
        max_stable_rate_borrow_size_percent=max_stable_rate_borrow_size_percent,
        reserves_count=reserves_count,
        oracle=oracle,
        user_EMode_category=user_EMode_category,
        price_oracle_sentinel=price_oracle_sentinel
        ),
    )
    return ()
end

# TODO Verify if i can use a felt for the interest rate mode here
@external
func repay{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, interest_rate_mode : felt, on_behalf_of : felt
):
    let (user_config) = _users_config.read(on_behalf_of)

    BorrowLogic.execute_repay(
        user_config,
        DataTypes.ExecuteRepayParams(
        asset=asset,
        amount=amount,
        interest_rate_mode=interest_rate_mode,  # not the struct here but the felt falue
        on_behalf_of=on_behalf_of,
        use_aTokens=FALSE
        ),
    )
    return ()
end

# TODO Verify if i can use a felt for the interest rate mode here
@external
func repay_with_aTokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, interest_rate_mode : felt
):
    let (caller_address) = get_caller_address()
    let (user_config) = _users_config.read(caller_address)

    BorrowLogic.execute_repay(
        user_config,
        DataTypes.ExecuteRepayParams(
        asset=asset,
        amount=amount,
        interest_rate_mode=interest_rate_mode,  # not the struct here but the felt falue
        on_behalf_of=caller_address,
        use_aTokens=TRUE
        ),
    )
    return ()
end

# TODO plenty of missing things here :)

@external
func init_reserve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, aToken_address : felt
):
    let (reserves_count) = _reserves_count.read()
    PoolLogic.execute_init_reserve(
        DataTypes.InitReserveParams(asset, aToken_address, reserves_count)
    )
    return ()
end
