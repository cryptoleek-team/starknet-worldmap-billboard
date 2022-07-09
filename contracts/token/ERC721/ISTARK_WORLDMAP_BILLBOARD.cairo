%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct BillBoard:
    member city : felt
    member ipfsHash : felt
    member twitter : felt
    member desc : felt
    member bidLevel : felt
    member owner : felt
end


@contract_interface
namespace ISTARK_WORLDMAP_BILLBOARD:
    func get_bill_board_tuple(id: felt) -> (_city: felt, _ipfsHash1: felt, _ipfsHash2: felt, _twitter: felt, _bid_level: felt, _bid_price: felt, _owner: felt):
    end
end