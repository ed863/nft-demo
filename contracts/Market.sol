// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TMKNFT is
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable,
    ERC721Enumerable
{
    using Counters for Counters.Counter;
    Counters.Counter private nftId;
    uint256 public blindBoxAmount;
    uint256 public firstSaleTokenId;
    bool userMintPausable = true;
    address public marketContractsAddress;

    constructor() ERC721("TheMonkeyKing", "TMK") {}

    event teamMintNftTo(uint256 a, uint256 b, address _market);
    event _usermint(address a, uint256 b);
    event _withdrawfunds(uint256 a, address b, address c, address d);

    /*erc721 token function*/
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /*pause or unpause usermint function*/
    function userMintPause() external onlyOwner {
        userMintPausable = !userMintPausable;
    }

    /*team mint nft,the number is x,the first minted nft id is firstSaleTokenId*/
    function blindBoxMint(string[] memory nftUriList, address market)
        external
        onlyOwner
    {
        blindBoxAmount = nftUriList.length;
        firstSaleTokenId = nftId._value;
        for (uint256 i = 0; i < nftUriList.length; i++) {
            _safeMint(market, nftId._value);
            _setTokenURI(nftId._value, nftUriList[i]);
            nftId.increment();
        }
        emit teamMintNftTo(blindBoxAmount, firstSaleTokenId, market);
    }

    /*users can mint their own nft,this function can be closed.*/
    function userMint(string memory nftUriData) external {
        require(userMintPausable, "userMint function has been closed");
        _safeMint(msg.sender, nftId._value);
        _setTokenURI(nftId._value, nftUriData);
        nftId.increment();
        emit _usermint(msg.sender, nftId._value - 1);
    }

    function withdraw(
        address payable ironbank,
        address payable marketing,
        address payable team
    ) external onlyOwner {
        emit _withdrawfunds(address(this).balance, ironbank, marketing, team);
        (bool success, ) = ironbank.call{
            value: (address(this).balance / 100) * 85
        }("wagmi");
        require(success, "ironbank wrong");
        (bool success1, ) = marketing.call{
            value: (address(this).balance / 100) * 66
        }("wagmi");
        require(success1, "marketing wrong");
        (bool success2, ) = team.call{value: address(this).balance}("wagmi");
        require(success2, "team wrong");
    }

    receive() external payable {}

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}

contract Trade is Ownable {
    TMKNFT public tmknft;
    uint256 public tax;
    bool public marketPauseStatus = true;
    mapping(uint256 => uint256) public bidPrice;
    mapping(uint256 => address) public sellerAddress;

    modifier tokenPrice(uint256 tokenId) {
        require(bidPrice[tokenId] <= msg.value, "ether amount is not enough");
        _;
    }

    modifier sellerAddressCheck(uint256 tokenId) {
        require(
            sellerAddress[tokenId] != address(0),
            "Your nft is in your wallet or your nft never participates this market.addresscheck"
        );
        _;
    }

    modifier bidPriceCheck(uint256 tokenId) {
        require(
            bidPrice[tokenId] != 0,
            "Your nft is in your wallet or your nft never participates this market.bidpricecheck"
        );
        _;
    }

    event _nftisselling(address a, uint256 b);
    event _nfthasbeensold(address a, uint256 b);
    event _withdrawfunds(uint256 a, address b, address c, address d);
    event _setPrice(address a, uint256 b, uint256 c);
    event _withdrawToken(address a, uint256 b);

    constructor(address payable addrs, uint256 _tax) {
        tmknft = TMKNFT(addrs);
        tax = _tax;
    }

    //adjust the tax rate
    function setTax(uint256 a) external onlyOwner {
        tax = a;
    }

    function marketPausable() external onlyOwner {
        marketPauseStatus = !marketPauseStatus;
    }

    function transferToMarket(uint256 tokenId, uint256 price) external {
        require(marketPauseStatus, "transferToMarket funtion has been closed");
        //require(tmknft.ownerOf(tokenId)==msg.sender,"you don't have this nft token");
        bidPrice[tokenId] = price;
        require(bidPrice[tokenId] != 0, "price cannot be 0");
        sellerAddress[tokenId] = msg.sender;
        tmknft.safeTransferFrom(msg.sender, address(this), tokenId);
        emit _nftisselling(msg.sender, price);
    }

    function makedeal(uint256 tokenId)
        external
        payable
        bidPriceCheck(tokenId)
        tokenPrice(tokenId)
        sellerAddressCheck(tokenId)
    {
        uint256 bid = bidPrice[tokenId];
        address sellAddress = sellerAddress[tokenId];
        bidPrice[tokenId] = 0;
        sellerAddress[tokenId] = address(0);
        /*genzongbianliangfuzhi*/
        tmknft.safeTransferFrom(address(this), msg.sender, tokenId);
        (bool success, ) = payable(sellAddress).call{value: (bid / 100) * tax}(
            ""
        );
        require(success, "seller withdrawal failed,maybe seller is a contract");
        emit _nfthasbeensold(msg.sender, msg.value);
    }

    function withdrawFunds(
        address payable ironbank,
        address payable marketing,
        address payable team
    ) external onlyOwner {
        emit _withdrawfunds(address(this).balance, ironbank, marketing, team);
        (bool success, ) = ironbank.call{
            value: (address(this).balance / 100) * 85
        }("wagmi");
        require(success, "ironbank wrong");
        (bool success1, ) = marketing.call{
            value: (address(this).balance / 100) * 66
        }("wagmi");
        require(success1, "marketing wrong");
        (bool success2, ) = team.call{value: address(this).balance}("wagmi");
        require(success2, "team wrong");
    }

    function setPrice(uint256 tokenId, uint256 _price) external {
        require(
            address(0) != sellerAddress[tokenId],
            "This token is not involved in this sale"
        );
        require(
            msg.sender == sellerAddress[tokenId],
            " This token does not belong to you"
        );
        bidPrice[tokenId] = _price;
        require(bidPrice[tokenId] != 0, "price cannot be 0");
        emit _setPrice(msg.sender, _price, tokenId);
    }

    function withdrawToken(uint256 tokenId) external {
        require(
            address(0) != sellerAddress[tokenId],
            "This token is not involved in this sale"
        );
        require(
            sellerAddress[tokenId] == msg.sender,
            "This token does not belong to you"
        );
        tmknft.safeTransferFrom(address(this), msg.sender, tokenId);
        bidPrice[tokenId] = 0;
        sellerAddress[tokenId] = address(0);
        emit _withdrawToken(msg.sender, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
