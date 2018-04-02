pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./SafeMath.sol";

contract ForgeVault {
    using SafeMath for uint256;

    uint256 firstFunding = 1534334400;
    uint256 secondFunding = 1565870400;
    address public owner;
    address public pendingOwner;
    ERC20 public ForgeToken;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    function ForgeVault(ERC20 _ForgeToken) public {
        owner = msg.sender;
        ForgeToken = _ForgeToken;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        pendingOwner = newOwner;
    }
    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    /**
     * @dev This method requires that today it is later than August 15, 2018
     */
    function firstWithdraw() public onlyOwner {
        require(now > firstFunding);
        uint256 count = ForgeToken.balanceOf(this).div(2);
        ForgeToken.transfer(owner, count);
    }

    /**
     * @dev This method requires that today it is later than August 15, 2019
     */
    function secondWithdraw() public onlyOwner {
        require(now > secondFunding);
        uint256 count = ForgeToken.balanceOf(this);
        ForgeToken.transfer(owner, count);
    }

}
