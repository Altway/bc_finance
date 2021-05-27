/*
Marex SmartContract

SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.0;

// import "./deployment/ManagedContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./finance/FarmToken.sol";
import "./finance/TestCoin.sol";


// contract Marex is ManagedContract {
contract Marex {
    using SafeMath for uint;

    IERC20 public ERC20Interface;
    FarmToken public _farmtoken;
    TestCoin public _testcoin;

    /*
    enum addressType{INVESTOR, LIQUIDITY}
    mapping (address => addressType) public providerType;
    */

    // payoutRatio de 10%
    uint public payoutRatio = 10;
    uint public initialFixing = 30;
    uint public strikePrice = 0;

    // Active le contract aujourd'hui
    uint public activationDate = block.timestamp;
    // Date de maturité à aujourd'hui + 1 minute
    uint public maturityDate = ( activationDate + 3 minutes);
    // Bolean to activate/deactivate the contract
    bool public locked = false;

    // Liquidité maximum du provider
    uint public maximumLiquidity = 10;
    // Liquidité maximum du sender à payoutRatio * liquidité du provider
    uint public maximumNotional = maximumLiquidity * payoutRatio;
    uint public maximumRedemption = maximumLiquidity + maximumNotional;

    // Number of shares required to withdrawn before the maturity has been reached
    uint public earlyRedemptionSharesNumber = 10;

    // For multiple liquidity providers
    // uint public maximumDenomination = maximumLiquidity + maximumNotional;
    // uint public maximumIssuanceSize = maximumDenomination + maximumNotional;

    // @TODO ajout/Retrait de whitelist
    mapping(address => bool) public clientWhitelist;
    mapping(address => bool) public adminWhitelist;

    // mapping address => fond
    mapping (address => uint) public shares;

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
        _farmtoken = FarmToken(farmTokenAddress);
        _testcoin = TestCoin(testCoinAddress);
        // _farmtoken.approve(farmTokenAddress, 1000000);
        _testcoin.approve(farmTokenAddress, 1000000);
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

    function setPayoutRatio(uint payout_ratio) public {
        payoutRatio = payout_ratio;
    }
    function setInitialPrice(uint initial_price) public {
        initialFixing = initial_price;
    }
    function setStrikePrice(uint strike_price) public {
        strikePrice = strike_price;
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
    function setEarlyRedemptionSharesNumber(uint shares_number) public {
        earlyRedemptionSharesNumber = shares_number;
    }

    function switchLock() public {
        if (locked) {locked = false;}
        else{locked = true;}
    }

    function addNewToken(string memory symbol_, address address_) public returns (bool) {
        authorizedTokens[symbol_] = address_;
        return true;
    }

    function adminPayout(uint finalFixing) public view returns(uint) {
        if (finalFixing < strikePrice) {
            return maximumRedemption - (clientShares * (finalFixing / initialFixing) + maximumLiquidity);
        }
        return 0;

    }
    function payout(uint finalFixing, uint notional) public view returns(uint) {
        if (finalFixing >= strikePrice) {
            return maximumRedemption;
        }
        return notional * (finalFixing / initialFixing) + maximumLiquidity;

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
        _farmtoken.deposit(liquidityAmount);        
        // Conversion Ratio ?
        _farmtoken.transfer(msg.sender, liquidityAmount);
        
        shares[msg.sender] += liquidityAmount;
        adminShares += liquidityAmount;
        /*if (currentBalance == previousBalance + liquidityAmount) {
        }*/

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
        require(clientShares + notionalAmount <= maximumNotional, "Too many Notional");



        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        
        ERC20Interface.transferFrom(msg.sender, address(this), notionalAmount);

        shares[msg.sender] += notionalAmount;
        clientShares += notionalAmount;
            // Conversion Ratio ?
        _farmtoken.deposit(notionalAmount);
        _farmtoken.transfer(msg.sender, notionalAmount);

        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
    }
    function settle(uint sharesAmount) public {
        address contract_ = authorizedTokens["TST"];
        ERC20Interface =  ERC20(contract_);
        // Have we reached maturity ?
        require(block.timestamp >= maturityDate, "Maturity date not reached yet");
        // Do both participant send their maximum amount ?
        /*
        require(
            ERC20Interface.balanceOf(address(this)) == maximumRedemption && 
            shares[msg.sender] == maximumNotional, 
            "Maximum payout not reached"
        );*/

        // Check oracle price
        uint oraclePrice = strikePrice;
        // Without liquidity pegging
        // uint notional = shares[msg.sender];
        // With liquidity pegging (Ratio multiplier ?)
        // must also check if shares are enough compared to what was deposited
        uint notional = sharesAmount;

        // uint settleAmount = 0 ;
        uint settleAmount = notional;
        
        // uint previousBalance = _farmtoken.balanceOf(address(this));
        _farmtoken.transferFrom(msg.sender, address(this), sharesAmount);
        // uint currentBalance = _farmtoken.balanceOf(address(this));
        _farmtoken.withdraw(sharesAmount);

        // Normally multiplier * sharesAmount = initialCollateral
        // initialCollateral has to be fed in the payout function
        
        /*
        if(clientWhitelist[msg.sender].exists) {
            // Address is a client
            settleAmount = payout(oraclePrice, notional);
        } else if (admin.whiteList[msg.sender].exists) {
            // Address is an admin
            settleAmount = what's left in the pool ?
        } else {
            // Address is neither we stop computation
            assert(true);
        }*/

        // Compute payout function ratio on all shares
        // uint participantShares = shares[msg.sender];

        // Check if sum of all balances is okay compared to fund locked in the contract
        // and be sure that debt are cleansed and balance ajusted

        // Send back payout
        ERC20Interface.transfer(msg.sender, settleAmount);

        // Previous
        // shares[msg.sender] = 0;
        // Multiplier also need here if liquidity pegging
        shares[msg.sender] -= sharesAmount;
        clientShares -= sharesAmount;
        
        // Emit the event 
        emit Fric(settleAmount, "Send money back");


        /*
        // Use the PayoutRatio Function
        if (settleAmount > 0) {
            shares[msg.sender] -= settleAmount;
            if(senderList[msg.sender]) {
                holders[_totalHolders] = address(0);
                senderList[msg.sender] = false;
                _totalHolders--;
            }
        }
        msg.sender.transfer(settleAmount);

        */
        // exchange.withdrawTokens(settleAmount);
    }


    function withdrawNotional(uint lpTokenAmount) public {
        // Depending on the number of LP tokens sent
        require(clientWhitelist[msg.sender], "You're not an allowed client");
        require(block.timestamp >= maturityDate, "Maturity date not reached yet");
        //Check if the maxm amount from admin ad client have been deposited otherwise you can't withdraw
        // + report the maturity until the max deposit has been made

        // uint previousBalance = _farmtoken.balanceOf(address(this));
        _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
        // uint currentBalance = _farmtoken.balanceOf(address(this));
        uint256 clientAmount = _farmtoken.withdraw(lpTokenAmount);

        // OraclePrice should be fixed now
        uint oraclePrice = strikePrice;
        // uint withdrawAmount;
        // uint currentShares = shares[msg.sender];

        uint currentPayoutAmount = (1 - (shares[msg.sender] - clientAmount)/100) * payout(oraclePrice, clientAmount);


        shares[msg.sender] -= clientAmount;
        clientShares -= clientAmount;

        ERC20Interface.transfer(msg.sender, currentPayoutAmount);
    }

    function withdrawLiquidity(uint lpTokenAmount) public {
        // Depending on the number of LP tokens sent
        require(adminWhitelist[msg.sender], "You're not an allowed client");
        if (lpTokenAmount == clientShares + adminShares) {
            _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
            _farmtoken.withdraw(lpTokenAmount);
            shares[msg.sender] = 0;
            clientShares = 0;
            adminShares = 0;
            // We Must clean every shares of everyone for this options
            ERC20Interface.transfer(msg.sender, maximumRedemption);

        } else {
            require(block.timestamp >= maturityDate, "Maturity date not reached yet");

            // uint previousBalance = _farmtoken.balanceOf(address(this));
            _farmtoken.transferFrom(msg.sender, address(this), lpTokenAmount);
            // uint currentBalance = _farmtoken.balanceOf(address(this));
            uint256 adminAmount = _farmtoken.withdraw(lpTokenAmount);

            // OraclePrice should be fixed now
            uint oraclePrice = strikePrice;
            // uint withdrawAmount;
            // uint currentShares = shares[msg.sender];

            uint currentPayoutAmount = (1 - (shares[msg.sender] - adminAmount)/100) * adminPayout(oraclePrice);


            shares[msg.sender] -= adminAmount;

            ERC20Interface.transfer(msg.sender, currentPayoutAmount);
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
    function withdraw() public returns (bool) {
        // It is important to set this to zero because the recipient
        // can call this function again as part of the receiving call
        // before `send` returns.
        pendingReturns[msg.sender] = 0;

        if (!msg.sender.send(amount)) {
            // No need to call throw here, just reset the amount owing
            pendingReturns[msg.sender] = amount;
            return false;
        }
        return true;
    }*/

}
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