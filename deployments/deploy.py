# scripts/deploy.py
import logging
logging.basicConfig(level = logging.DEBUG)

MAX_LEN_FELT = 31

def run(nre):
    deploy_world_token(nre)
    deploy_stark_worldmap_billboard(nre)
    deploy_stark_worldmap_billboard_collection(nre)


def deploy_world_token(nre):
    print("Deploying world_token")
    nre.compile(["contracts/token/ERC20/world_token.cairo"])

    owner = get_owner_acct(nre)
    name = str(str_to_felt("World Token"))
    symbol = str(str_to_felt("WORLD"))

    params = [name, symbol, "0", "0", owner]
    address, abi = nre.deploy("world_token", params, alias="world_token")

    print(f"ABI: {abi},\nContract address: {address}")

def deploy_stark_worldmap_billboard(nre):
    print("Deploying stark_worldmap_billboard")
    nre.compile(["contracts/stark_worldmap_billboard.cairo"])

    owner = get_owner_acct(nre)
    world_token_addr, abi = nre.get_deployment("world_token")

    params = [owner, world_token_addr, "1000000000000000000", "2"]
    address, abi = nre.deploy("stark_worldmap_billboard", params, alias="stark_worldmap_billboard")

    print(f"ABI: {abi},\nContract address: {address}")

def deploy_stark_worldmap_billboard_collection(nre):
    print("Deploying stark_worldmap_billboard_collection")
    nre.compile(["contracts/token/ERC721/stark_worldmap_billboard_collection.cairo"])

    owner = get_owner_acct(nre)
    name = str(str_to_felt("WorldMapBBC"))
    symbol = str(str_to_felt("SWMBBC"))

    stark_worldmap_billboard_addr, abi = nre.get_deployment("stark_worldmap_billboard")

    params = [name, symbol, owner, stark_worldmap_billboard_addr]
    address, abi = nre.deploy("stark_worldmap_billboard_collection", params, alias="stark_worldmap_billboard_collection")

    print(f"ABI: {abi},\nContract address: {address}")



# Helper functions
def get_owner_acct(nre):
    address, abi = nre.get_deployment("account-0")
    return address

def str_to_felt(text):
    if len(text) > MAX_LEN_FELT:
        raise Exception("Text length too long to convert to felt.")

    return int.from_bytes(text.encode(), "big")


def felt_to_str(felt):
    length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(length, byteorder="big").decode("utf-8")


def str_to_felt_array(text):
    return [str_to_felt(text[i:i+MAX_LEN_FELT]) for i in range(0, len(text), MAX_LEN_FELT)]


def uint256_to_int(uint256):
    return uint256[0] + uint256[1]*2**128


def uint256(val):
    return (val & 2**128-1, (val & (2**256-2**128)) >> 128)


def hex_to_felt(val):
    return int(val, 16)