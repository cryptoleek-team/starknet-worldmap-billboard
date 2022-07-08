python -i utils.py
str_to_felt('AnimalRegistry')


nile compile contracts/token/ERC721/ERC721_E1.cairo
nile deploy ERC721_E1 5343714990652405617205487486548 17228 0x01cd5bb99c2c9a21a1659df945d5711d874627a98e849a1a435b879ebae68115 --network goerli


nile compile contracts/token/ERC721/ERC721_E2.cairo
nile deploy ERC721_E2 1327104350272940968382359894520441 16722 --network goerli