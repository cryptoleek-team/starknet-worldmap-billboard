%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check, uint256_eq
)
from contracts.token.ERC721.ERC721_base import (
    ERC721_name,
    ERC721_symbol,
    ERC721_balanceOf,
    ERC721_ownerOf,
    ERC721_getApproved,
    ERC721_isApprovedForAll,
    ERC721_mint,
    ERC721_burn,

    ERC721_initializer,
    ERC721_approve,
    ERC721_setApprovalForAll,
    ERC721_transferFrom,
    ERC721_safeTransferFrom
)

from contracts.token.ERC721.ERC721_Metadata_base import (
    ERC721_Metadata_initializer,
    ERC721_Metadata_tokenURI,
    ERC721_Metadata_setBaseTokenURI,
)

from contracts.token.ERC721.ERC165_base import (
    ERC165_supports_interface
)

from contracts.utils.Ownable_base import (
    Ownable_initializer,
    Ownable_only_owner,
    Ownable_get_owner,
    Ownable_transfer_ownership
)


from contracts.token.ERC721.ISTARK_WORLDMAP_BILLBOARD import ISTARK_WORLDMAP_BILLBOARD


#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(name: felt, symbol: felt, owner: felt, bill_board_addr: felt):
    ERC721_initializer(name, symbol)
    ERC721_Metadata_initializer()
    Ownable_initializer(owner)
    let one_as_uint = Uint256(1,0)
    next_token_id_storage.write(one_as_uint)
    bill_board_addr_storage.write(bill_board_addr)
    return ()
end

#
# Storage vars
#
@storage_var
func next_token_id_storage() -> (next_token_id: Uint256):
end

@storage_var
func bill_board_addr_storage() -> (bill_board_addr: felt):
end

#
# Getters
#

@view
func bill_board_addr{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (bill_board_addr: felt):
    let (bill_board_addr) = bill_board_addr_storage.read()
    return (bill_board_addr)
end


@view
func next_token_id{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (next_token_id: Uint256):
    let (next_token_id) = next_token_id_storage.read()
    return (next_token_id=next_token_id)
end


@view
func getOwner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    let (owner) = Ownable_get_owner()
    return (owner=owner)
end

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interface_id: felt) -> (success: felt):
    let (success) = ERC165_supports_interface(interface_id)
    return (success)
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC721_name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC721_symbol()
    return (symbol)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721_balanceOf(owner)
    return (balance)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721_ownerOf(token_id)
    return (owner)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721_getApproved(token_id)
    return (approved)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (is_approved: felt):
    let (is_approved: felt) = ERC721_isApprovedForAll(owner, operator)
    return (is_approved)
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id)
    return (token_uri_len=token_uri_len, token_uri=token_uri)
end

#
# Setters
#

@external
func set_bill_board_addr{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(bill_board_addr: felt):
    Ownable_only_owner()
    bill_board_addr_storage.write(bill_board_addr)
    return ()
end

#
# Externals
#

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, token_id: Uint256):
    ERC721_approve(to, token_id)
    return ()
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    ERC721_setApprovalForAll(operator, approved)
    return ()
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(_from: felt, to: felt, token_id: Uint256):
    ERC721_transferFrom(_from, to, token_id)
    return ()
end

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        _from: felt,
        to: felt,
        token_id: Uint256,
        data_len: felt,
        data: felt*
    ):
    ERC721_safeTransferFrom(_from, to, token_id, data_len, data)
    return ()
end

func _setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(token_id: Uint256, base_token_uri_len: felt, base_token_uri: felt*):
    ERC721_Metadata_setBaseTokenURI(token_id, base_token_uri_len, base_token_uri)
    return ()
end

@external
func mint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(board_id: felt, tokenURIs_len: felt, tokenURIs: felt*):
    alloc_locals

    let (sender_address) = get_caller_address()
    let (bill_board_addr) = bill_board_addr_storage.read()

    let (city, ipfsHash1, ipfsHash2, twitter, bid_level, bid_price, owner) = ISTARK_WORLDMAP_BILLBOARD.get_bill_board_tuple(contract_address=bill_board_addr, id=board_id)

    assert owner = sender_address

    let (token_id) = next_token_id_storage.read()
    let one_as_uint = Uint256(1,0)
    let (next_token_id, _) = uint256_add(one_as_uint, token_id)
    next_token_id_storage.write(next_token_id)

    _setTokenURI(token_id, tokenURIs_len, tokenURIs)

    ERC721_mint(sender_address, token_id)
    return ()
end

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(token_id: Uint256):
    Ownable_only_owner()
    ERC721_burn(token_id)
    return ()
end

@external
func transferOwnership{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(new_owner: felt) -> (new_owner: felt):
    # Ownership check is handled by this function
    Ownable_transfer_ownership(new_owner)
    return (new_owner=new_owner)
end
