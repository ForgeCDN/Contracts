pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./ERC20.sol";

/**
* @title ForgePreICO
* @dev Contract to preSale ForgeCDN tokens.
*/
contract ForgePreICO {
    using SafeMath for uint256;

    // The token being sold
    ERC20 public token;
    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;
    // address where funds are collected
    address public wallet;
    // how many token units a buyer gets per wei
    uint256 public rate;
    // amount of raised money in wei
    uint256 public weiRaised;
    // Hardcap
    uint256 public cap;
    // Operation wallet
    address public operationWallet;
    // Vault wallet
    address public vault;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function ForgePreICO(ERC20 _token, address _operationWallet, address _vault) public
    {
        require(_vault != address(0));
        require(_operationWallet != address(0));
        require(_token != address(0));
        operationWallet = _operationWallet;
        wallet = msg.sender;
        cap = 2400 * 1 ether;
        startTime = 1522670400;
        endTime = 1525003200;
        rate = 1500;
        vault = _vault;
        token = _token;
    }

    /**
     * fallback function to buy tokens
     */
    function() external payable {
        address beneficiary = msg.sender;
        require(beneficiary != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;

        // calculate token amount to be send
        uint256 tokens = weiAmount.mul(rate);
        uint256 operationTokens = tokens.div(69).mul(11);
        uint256 commandTokens = tokens.div(69).mul(20);
        
        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.transferFrom(wallet, beneficiary, tokens);
        token.transferFrom(wallet, operationWallet, operationTokens);
        token.transferFrom(wallet, vault, commandTokens);
        
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    /**
     * @return true if crowdsale event has ended
     */
    function hasEnded() public view returns (bool) {
        bool capReached = weiRaised >= cap;
        bool timeReached = now > endTime;
        return capReached || timeReached;
    }

    /**
     * send ether to the fund collection wallet
     */
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }


    /**
     * @return true if the transaction can buy tokens
     */
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool standardValidation = withinPeriod && nonZeroPurchase;
        bool withinCap = weiRaised.add(msg.value) <= cap;
        return withinCap && standardValidation;
    }

}
