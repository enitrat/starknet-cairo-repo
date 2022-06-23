%lang starknet

@contract_interface
namespace IBalance:
    func set_counter(value : felt):
    end

    func get_counter() -> (res : felt):
    end
end
