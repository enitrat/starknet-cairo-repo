%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.types.ConfiguratorInputTypes import ConfiguratorInputTypes
from contracts.interfaces.IPoolAddressesProvider import IPoolAddressesProvider
from contracts.interfaces.IPool import IPool

# # MODIFIERS (not properly speaking but cairo equivalent) ##
@storage_var
func _address_provider() -> (address : felt):
end

@storage_var
func _pool_address() -> (address : felt):
end

func only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = _address_provider.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("1"):
        # assert IACLManager.isPoolAdmin(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

# TODO
func only_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = _address_provider.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("1"):
        # assert IACLManager.isPoolAdmin(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

# TODO
func only_emergency_or_pool_admin{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = _address_provider.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("2"):
        # assert IACLManager.isBridge(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

# TODO
func only_asset_listing_or_pool_admins{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = _address_provider.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("2"):
        # assert IACLManager.isBridge(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

# TODO
func only_risk_or_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (addresses_provider) = _address_provider.read()
    # let (ACL_Manager_address) = IPoolAddressesProvider.getACLManager(contract_address=addresses_provider)
    with_attr error_message("2"):
        # assert IACLManager.isBridge(contract_address=ACL_manager_address,caller_address) = TRUE
    end
    return ()
end

const CONFIGURATOR_REVISION = 0x1

func get_revision() -> (revision : felt):
    return (CONFIGURATOR_REVISION)
end

# TODO implement OZ VersionInitializable
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(provider : felt):
    _address_provider.write(provider)
    let (pool_address) = IPoolAddressesProvider.get_pool(contract_address=provider)
    return ()
end

func init_reserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    input : ConfiguratorInputTypes.InitReserveInput*, input_len : felt
):
    only_asset_listing_or_pool_admins()
    let (pool_address) = _pool_address.read()
    _init_reserves(input, input_len, pool_address)
    return ()
end

# TODO end this function
func _init_reserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    input : ConfiguratorInputTypes.InitReserveInput*, input_len : felt, pool_address : felt
):
    # TODO loop
    if input_len == 0:
        return ()
    end
    # ConfiguratorLogic.executeInitReserve(cachedPool, input[i]);
    _init_reserves(
        input + ConfiguratorInputTypes.InitReserveInput.SIZE, input_len - 1, pool_address
    )
    return ()
end

# TODO verify this function
func drop_reserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(asset : felt):
    only_pool_admin()
    let (pool_address) = _pool_address.read()
    IPool.drop_reserve(contract_address=pool_address, asset=asset)
    # TODO emit reserve dropped event
    return ()
end
