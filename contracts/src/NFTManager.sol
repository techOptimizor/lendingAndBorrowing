pragma solidity 0.8.7;

import "./NitroFinaceLiquidityPositions.sol";
import "./Positions.sol";
import "./Libraries/nft2.sol";

contract NFTManager is Position, NitroFinaceLiquidityPositions {
    error TOKENID_COLFACTORE_NOT_A_MATCH();
    uint nextId = 1;

    using Strings for uint256;

    mapping(uint256 => Position.TOKENDATA) public tokenData;
    address Nitro;

    modifier onlyNitro() {
        require(msg.sender == Nitro, "Only Nitro");
        _;
    }

    function createPosition(
        address recepient,
        uint256 _collateralFactor,
        uint256 _interestRate,
        uint256 _liquidity,
        uint256 kValueAtDeltaK,
        uint256 _locusId
    ) external returns (uint tokenId) {
        safeMint(recepient, nextId);
        tokenData[nextId] = (
            TOKENDATA({
                amount: _liquidity,
                collateralFactor: _collateralFactor,
                interestRate: _interestRate,
                locusId: _locusId,
                tokenId: nextId,
                kAtInstance: kValueAtDeltaK,
                name: string(
                    abi.encodePacked(
                        "NitroFinance #",
                        uint256(nextId).toString()
                    )
                ),
                bgHue: randomcolor(360, recepient, nextId).toString(),
                textHue: randomNum(361, block.timestamp, nextId).toString()
            })
        );
        tokenId = nextId;
        nextId++;
    }

    function getPoolandUpdateLiquidity(
        uint256 _tokenId,
        uint256 _amount,
        uint256 colFactor,
        uint256 interestRate,
        uint256 updateOption
    ) external {
        require(_amount > 0, "INVALID_AMOUNT");
        TOKENDATA storage data = tokenData[_tokenId];
        if (
            data.collateralFactor == colFactor &&
            data.interestRate == interestRate
        ) {
            if (updateOption == 1) {
                data.amount += _amount;
            } else if (updateOption == 0) {
                data.amount -= _amount;
            } else {
                revert("Is either 1 to increase or 0 to decrease");
            }
        } else {
            revert TOKENID_COLFACTORE_NOT_A_MATCH();
        }
    }

    function withdraw(uint256 Id) public returns (uint256 _amount) {
        TOKENDATA memory data = tokenData[Id];
        delete tokenData[Id];
        return data.amount;
    }

    function getLocusWithId(uint256 _Id) public view returns (LOCUS memory) {
        TOKENDATA memory data = tokenData[_Id];
        return getLocus[data.collateralFactor][data.interestRate];
    }

    function randomNum(
        uint256 _mod,
        uint256 _seed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 num = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _seed, _salt)
            )
        ) % _mod;
        return num;
    }

    function randomcolor(
        uint256 _mod,
        address _seed,
        uint256 _salt
    ) internal view returns (uint256) {
        uint256 num = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _seed, _salt)
            )
        ) % _mod;
        return num;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        TOKENDATA memory data = tokenData[_tokenId];
        return
            NFTbuilder.getmetadata(
                NFTbuilder.Data({
                    amount: data.amount.toString(),
                    collateralFactor: data.collateralFactor.toString(),
                    interestRate: data.interestRate.toString(),
                    tokenId: data.tokenId.toString(),
                    name: data.name,
                    x: data.bgHue,
                    y: data.textHue
                })
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
