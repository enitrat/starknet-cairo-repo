# #This is just a mock oracle that holds assets prices against a common denominator
# UNUSED
%lang starknet

@contract_interface
namespace IPriceOracle:
    func get_price(asset : felt) -> (price : felt):
    end
end
