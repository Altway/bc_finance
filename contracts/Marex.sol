/*
Marex SmartContract

SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.0;

// import "./deployment/ManagedContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./finance/DecentralizedNote.sol";
import "./finance/MarexCoin.sol";


// contract Marex is ManagedContract {
contract Marex {
    using SafeMath for uint;

    IERC20 public ERC20Interface;
    DecentralizedNote public _farmtoken;
    MarexCoin public _testcoin;

    /*
    enum addressType{INVESTOR, LIQUIDITY}
    mapping (address => addressType) public providerType;
    */

    // payoutRatio de 10%
    uint public payoutRatio = 10;
    uint public initialFixing = 40000;
    uint public finalFixing = 26000;
    uint public strikePrice = 30000;

    // Active le contract aujourd'hui
    uint public activationDate = block.timestamp;
    // Date de maturité à aujourd'hui + 1 minute
    uint public maturityDate = ( activationDate + 3 minutes);
    // Bolean to activate/deactivate the contract
    bool public locked = false;

    // Liquidité maximum du provider
    uint public maximumLiquidity = 10;

    uint public totalLiquidity = 0;
    uint public totalNotional = 0;

    // For multiple liquidity providers
    // uint public maximumDenomination = maximumLiquidity + maximumNotional;
    // uint public maximumIssuanceSize = maximumDenomination + maximumNotional;

    // @TODO ajout/Retrait de whitelist
    mapping(address => bool) public clientWhitelist;
    mapping(address => bool) public adminWhitelist;
    uint public adminShares = 0;
    uint public clientShares = 0;

    /**
    * @dev list of all supported tokens for transfer
    *  string token symbol
    *  address contract address of token
    */
    mapping(string => address) public authorizedTokens;


    event Test(uint event_int);
    event Fric(uint event_int, string event_string);
    event Log(address event_string);
    event LogS(string event_string);
    event MaturityEnd(uint event_uint, uint event_block);

    constructor(address farmTokenAddress, address testCoinAddress) {
        _farmtoken = DecentralizedNote(farmTokenAddress);
        _testcoin = MarexCoin(testCoinAddress);
        // _farmtoken.approve(farmTokenAddress, 1000000);
    }
    /*
    function initialize(Deployer deployer) override internal {
        // exchange = OptionsExchange(deployer.getContractAddress("OptionsExchange"));
    }
    */
    function addClient(address _address) public {
        clientWhitelist[_address] = true;
    }
    function addAdmin(address _address) public {
        adminWhitelist[_address] = true;
    }
    function setPayoutRatio(uint _payoutRatio) public {
        payoutRatio = _payoutRatio;
    }
    function setInitialFixing(uint _initialFixing) public {
        initialFixing = _initialFixing;
    }
    function setFinalFixing(uint _finalFixing) public {
        finalFixing = _finalFixing;
    }
    function setStrikePrice(uint _strikePrice) public {
        strikePrice = _strikePrice;
    }
    function addMaturity(uint maturity_minute) public {
        maturityDate = maturityDate + ( maturity_minute * 60);
    }
    function setMaximumLiquidity(uint maximum_liquidity) public {
        maximumLiquidity = maximum_liquidity;
    }
    function setMaximumNotional(uint maximum_notional) public {
        maximumLiquidity = maximum_notional;
    }
    function switchLock() public {
        if (locked) {locked = false;}
        else{locked = true;}
    }
    function addNewToken(string memory symbol_, address address_) public returns (bool) {
        authorizedTokens[symbol_] = address_;
        return true;
    }
    function adminPayout(uint _finalFixing) public view returns(uint) {
        if (_finalFixing >= strikePrice) {
            return 0;
        }
        return getPool() - clientPayout(_finalFixing);
    }
    function clientPayout(uint _finalFixing) public view returns(uint) {
        if (_finalFixing >= strikePrice) {
            return getPool();
        }
        return totalLiquidity + (totalNotional * finalFixing) / initialFixing;
    }
    function getPool() public view returns(uint) {
        return totalLiquidity + totalNotional;
    }

    function getEarlyRedemptionSharesNumber() public view returns(uint) {
        return clientShares + adminShares;
    }

    function getMaximumNotional() public view returns(uint) {
        return maximumLiquidity * payoutRatio;
    }

    function addLiquidity(string memory symbol_, uint liquidityAmount) public {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedLiquidityProvider[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumLiquidity


        // LiquidityProvider Whitelist
        // require(adminWhitelist[msg.sender].exists, "You are not an authorized admin");
        require(adminWhitelist[msg.sender], "You're not an allowed admin");
        require(adminShares + liquidityAmount <= maximumLiquidity, "Too many liquidity");

        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        ERC20Interface.transferFrom(msg.sender, address(this), liquidityAmount);
        totalLiquidity += liquidityAmount;
        

        uint mintedToken = _farmtoken.deposit(liquidityAmount);        
        _farmtoken.transfer(msg.sender, mintedToken);
        adminShares += mintedToken;

        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
    }

    function addNotional(string memory symbol_, uint notionalAmount) public {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedLiquidityProvider[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumLiquidity
        
        // Client Whitelist
        // require(clientWhitelist[msg.sender].exists, "You are not an authorized client");

        require(clientWhitelist[msg.sender], "You're not an allowed client");
        require(clientShares + notionalAmount <= getMaximumNotional(), "Too many Notional");

        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        ERC20Interface.transferFrom(msg.sender, address(this), notionalAmount);
        totalNotional += notionalAmount;

        uint mintedToken = _farmtoken.deposit(notionalAmount);
        _farmtoken.transfer(msg.sender, mintedToken);
        clientShares += mintedToken;

        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
    }
    function withdrawNotional(uint lpTokenAmount) public {
        // Depending on the number of LP tokens sent
        require(clientWhitelist[msg.sender], "You're not an allowed client");
        require(block.timestamp >= maturityDate, "Maturity date not reached yet");
        //Check if the maxm amount from admin ad client have been deposited otherwise you can't withdraw
        // + report the maturity until the max deposit has been made
        _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
        _farmtoken.withdraw(lpTokenAmount);

        // OraclePrice should be fixed now
        uint oraclePrice = finalFixing;

        uint value = clientPayout(oraclePrice);
        // fcking hell we can't use percentage
        // uint currentPayoutAmount = (100*value - shares[msg.sender] * value - clientAmount * value) / 100;
        uint currentPayoutAmount = (lpTokenAmount * value ) / clientShares;

        ERC20Interface.transfer(msg.sender, currentPayoutAmount);
    }

    function withdrawLiquidity(uint lpTokenAmount) public {
        // Depending on the number of LP tokens sent
        require(adminWhitelist[msg.sender], "You're not an allowed client");
        if (lpTokenAmount == getEarlyRedemptionSharesNumber()) {
            _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
            _farmtoken.withdraw(lpTokenAmount);
            settle();

        } else {
            require(block.timestamp >= maturityDate, "Maturity date not reached yet");

            _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
            _farmtoken.withdraw(lpTokenAmount);

            // OraclePrice should be fixed now
            uint oraclePrice = finalFixing;

            // uint value = _testcoin.balanceOf(address(this));
            uint value = adminPayout(oraclePrice);
            uint currentPayoutAmount = (lpTokenAmount * value ) / adminShares;
            // uint currentPayoutAmount = (100*value - shares[msg.sender] * value - adminAmount * value) / 100;
            ERC20Interface.transfer(msg.sender, currentPayoutAmount);
        }
    }

    function settle() public {
        clientShares = 0;
        adminShares = 0;
        totalLiquidity = 0;
        totalNotional = 0;
        if (!(_testcoin.balanceOf(address(this)) == 0)) {
            _testcoin.transfer(msg.sender, _testcoin.balanceOf(address(this)));
        }
    }
}
/*
    function associateLiquidity(string memory symbol_) public payable {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedLiquidityProvider[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumLiquidity
        shares[msg.sender] += msg.value;
        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        ERC20Interface.transfer(address(this), msg.value);
        // exchange.depositTokens(address(this), address(ERC20Interface), msg.value);
       /* 
        require(!liquidityProviderLock, "This contract is locked for funds");
        if (shares[msg.sender] + msg.value > maximumLiquidity) {
            if (msg.value >= (maximumSender - shares[msg.sender])) {
                shares[msg.sender] += (maximumLiquidity = shares[msg.sender]);
                msg.sender.transfer(maximumLiquidity = shares[msg.sender]);
                liquidityProviderLock = true;
            }
        }else{
            shares[msg.sender] += msg.value;
        }
        if(!senderList[msg.sender]) {
            holders[_totalHolders] = msg.sender;
            providerType[msg.sender] = addressType.LIQUIDITY;
            senderList[msg.sender] = true;
            _totalHolders++;
        }*/
        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
    //}
    /*
    function associateAddress() public payable {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedInvestor[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumsender
        require(!investorLock, "This contract is locked for funds");
        if (shares[msg.sender] + msg.value > maximumSender) {
            if (msg.value >= (maximumSender - shares[msg.sender])) {
                shares[msg.sender] += (maximumSender = shares[msg.sender]);
                payable(msg.sender).transfer(maximumSender = shares[msg.sender]);
                investorLock = true;
            }
        }else{
            shares[msg.sender] += msg.value;
        }
        if(!senderList[msg.sender]) {
            holders[_totalHolders] = payable(msg.sender);
            providerType[msg.sender] = addressType.INVESTOR;
            senderList[msg.sender] = true;
            _totalHolders++;
        }
        // Emit that an investors sent money
        emit Test(msg.value);
    }
*/
/*
    function approve(string memory symbol_, address address_, uint value) public {
        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        ERC20Interface.approve(address_, value);
        // ERC20Interface.approve(address(0xCD50Fcc572DB2Cf8056aa76Cb0b26812696E353c), value);
        //ee.approve(address(exchange), msg.value);
        emit Log(address(contract_));
    }
*/