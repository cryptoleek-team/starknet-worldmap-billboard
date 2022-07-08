%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_check,
    uint256_eq,
    uint256_mul,
    uint256_signed_div_rem
)

from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
    assert_nn,
    assert_le,
    assert_lt,
    assert_in_range,
    signed_div_rem
)

from contracts.utils.String import String_get, String_set

from contracts.utils.Ownable_base import (
    Ownable_initializer,
    Ownable_only_owner,
    Ownable_get_owner,
    Ownable_transfer_ownership
)

from contracts.token.ERC20.IERC20 import IERC20


@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, world_token_addr: felt, base_price: felt, split_ratio: felt):

    Ownable_initializer(owner)

    next_board_id_storage.write(1)
    world_token_addr_storage.write(world_token_addr)
    base_price_storage.write(base_price)
    split_ratio_storage.write(split_ratio)

    return ()
end

struct BillBoard:
    member city : felt
    member ipfsHash1 : felt
    member ipfsHash2 : felt
    member twitter : felt
    member bidLevel : felt
    member owner : felt
end

#
# Storage Variables
#

@storage_var
func next_board_id_storage() -> (next_board_id: felt):
end

@storage_var
func world_token_addr_storage() -> (world_token_addr: felt):
end

@storage_var
func base_price_storage() -> (base_price: felt):
end

@storage_var
func split_ratio_storage() -> (split_ratio: felt):
end

@storage_var
func bill_boards_storage(board_id : felt) -> (bill_board : (felt, felt, felt, felt, felt, felt)):
end

#
# Views
#

@view
func get_next_board_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (next_board_id: felt):
    let (next_board_id) = next_board_id_storage.read()
    return (next_board_id)
end

@view
func get_world_token_addr{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (token_addr: felt):
    let (token_addr) = world_token_addr_storage.read()
    return (token_addr)
end

@view
func get_base_price{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (base_price: felt):
    let (base_price) = base_price_storage.read()
    return (base_price)
end

@view
func get_split_ratio{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (split_ratio: felt):
    let (split_ratio) = split_ratio_storage.read()
    return (split_ratio)
end

@view
func get_bill_board{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(id: felt) -> (bill_board: BillBoard):

    let (bill_board_data) = bill_boards_storage.read(id)
    let _city = bill_board_data[0]
    let _ipfsHash1 = bill_board_data[1]
    let _ipfsHash2 = bill_board_data[2]
    let _twitter = bill_board_data[3]
    let _bid_level = bill_board_data[4]
    let _prev_owner = bill_board_data[5]

    let billboard = BillBoard(
        city = _city,
        ipfsHash1 = _ipfsHash1,
        ipfsHash2 = _ipfsHash2,
        twitter = _twitter,
        bidLevel = _bid_level,
        owner = _prev_owner
    )
    return (billboard)
end

@view
func get_bill_board_tuple{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(id: felt) -> (_city: felt, _ipfsHash1: felt, _ipfsHash2: felt, _twitter: felt, _bid_level: felt, _owner: felt):

    let (bill_board_data) = bill_boards_storage.read(id)
    let _city = bill_board_data[0]
    let _ipfsHash1 = bill_board_data[1]
    let _ipfsHash2 = bill_board_data[2]
    let _twitter = bill_board_data[3]
    let _bid_level = bill_board_data[4]
    let _prev_owner = bill_board_data[5]

    return (_city, _ipfsHash1, _ipfsHash2, _twitter, _bid_level, _prev_owner)
end

#
# Setter
#

@external
func set_world_token_addr{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(world_token_addr: felt):

    Ownable_only_owner()
    world_token_addr_storage.write(world_token_addr)
    return ()
end

@external
func set_base_price{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(base_price: felt):

    Ownable_only_owner()
    base_price_storage.write(base_price)
    return ()
end

@external
func set_split_ratio{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(split_ratio: felt):

    Ownable_only_owner()
    split_ratio_storage.write(split_ratio)
    return ()
end

#
# Main Functions
#

@external
func setup{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(_city: felt):
    alloc_locals

    Ownable_only_owner()

    let (id) = next_board_id_storage.read()
    let (contract_address) = get_contract_address()

    let _ipfsHash1 = 0
    let _ipfsHash2 = 0
    let _twitter = 0
    let _bid_level = 1
    let _owner = contract_address

    bill_boards_storage.write(id, (_city, _ipfsHash1, _ipfsHash2, _twitter, _bid_level, _owner))

    let next_id = id + 1
    next_board_id_storage.write(next_id)

    return ()
end

@external
func bid{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(id: felt, _city: felt, _ipfsHash1: felt, _ipfsHash2: felt, _twitter: felt) -> ( billboard: BillBoard ):

    alloc_locals

    let (current_board_id) = next_board_id_storage.read()

    assert_lt(0, id)
    assert_le(id, current_board_id)

    let (city, ipfsHash1, ipfsHash2, twitter, bid_level, owner) = get_bill_board_tuple(id)

    assert city = _city

    let (sender_address) = get_caller_address()
    let (contract_address) = get_contract_address()
    let (base_price) = base_price_storage.read()
    let (split_ratio) = split_ratio_storage.read()


    let (world_token_addr) = world_token_addr_storage.read()
    let (world_token_balance) = IERC20.balanceOf(
        contract_address=world_token_addr, account=sender_address
    )

    let next_bid_level = bid_level + 1

    let (required_fund_uint256, no_no) = uint256_mul(Uint256(base_price, 0), Uint256(bid_level, 0))

    let (is_required_fund_valid) = uint256_le(required_fund_uint256, world_token_balance)
    assert is_required_fund_valid = 1

    let (amount_to_prev_owner_uint256, remainder) = uint256_signed_div_rem(required_fund_uint256, Uint256(split_ratio, 0))
    IERC20.transferFrom(contract_address=world_token_addr, sender=sender_address, recipient=owner, amount=amount_to_prev_owner_uint256)

    let (remaining_amount_uint256) = uint256_sub(required_fund_uint256, amount_to_prev_owner_uint256)
    IERC20.transferFrom(contract_address=world_token_addr, sender=sender_address, recipient=contract_address, amount=remaining_amount_uint256)

    bill_boards_storage.write(id, (_city, _ipfsHash1, _ipfsHash2, _twitter, next_bid_level, sender_address))

    let billboard = BillBoard(
        city = _city,
        ipfsHash1 = _ipfsHash1,
        ipfsHash2 = _ipfsHash2,
        twitter = _twitter,
        bidLevel = next_bid_level,
        owner = sender_address
    )
    return (billboard)

end

