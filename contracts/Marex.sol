/*
Marex SmartContract

SPDX-License-Identifier: MIT
*/
pragma solidity >=0.8.0;

// import "./finance/OptionsExchange.sol";
// import "./deployment/ManagedContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



// contract Marex is ManagedContract {
contract Marex {
    using SafeMath for uint;

    ERC20 public ERC20Interface;

    enum addressType{INVESTOR, LIQUIDITY}
    mapping (address => addressType) public providerType;

    // payoutRatio de 10%
    uint public payoutRatio = 10;
    uint public initialPrice = 30;
    uint public strikePrice = 0;

    // Active le contract aujourd'hui
    uint public activationDate = block.timestamp;
    // Date de maturité à aujourd'hui + 1 minute
    uint public maturityDate = ( activationDate + 3 minutes);
    // Bolean to activate/deactivate the contract
    bool public locked = false;

    // Liquidité maximum du provider
    uint public maximumLiquidity = 10000;
    // Liquidité maximum du sender à payoutRatio * liquidité du provider
    uint public maximumSender = maximumLiquidity * payoutRatio;

    uint public maximumPayout = maximumLiquidity + maximumSender;

    bool public investorLock = false;
    bool public liquidityProviderLock = false;

    // @TODO ajout/Retrait de whitelist
    address[] public whitelistedInvestor;
    address[] public whitelistedLiquidityProvider;

    mapping (address => bool) public senderList;
    // mapping address => fond
    uint _totalHolders; // you should initialize this to 0 in the constructor
    mapping (uint => address payable) public holders;
    mapping (address => uint) public shares;

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

/*
    function initialize(Deployer deployer) override internal {
        // exchange = OptionsExchange(deployer.getContractAddress("OptionsExchange"));
    }
*/

    function setPayoutRatio(uint payout_ratio) public {
        payoutRatio = payout_ratio;
    }
    function setInitialPrice(uint initial_price) public {
        initialPrice = initial_price;
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

    function switchLock() public {
        if (locked) {locked = false;}
        else{locked = true;}
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
    /**
    * @dev add address of token to list of supported tokens using
    * token symbol as identifier in mapping
    */
    function addNewToken(string memory symbol_, address address_) public returns (bool) {
        authorizedTokens[symbol_] = address_;
        return true;
    }

    function transferTokens(string memory symbol_, address to_, uint256 amount_) public {
        //require(tokens[symbol_] != address(0));
        //require(amount_ > 0);

        address contract_ = authorizedTokens[symbol_];
        address from_ = msg.sender;

        ERC20Interface =  ERC20(contract_);

     /*   transactions.push(
            Transfer({
            contract_:  contract_,
            to_: to_,
            amount_: amount_,
            failed_: true
            })
        );
        uint256 transactionId = transactions.length;
        transactionIndexesToSender[from_].push(transactionId - 1);

        if(amount_ > ERC20Interface.allowance(from_, address(this))) {
            emit TransferFailed(from_, to_, amount_);
            revert();
        }
*/
        ERC20Interface.transferFrom(from_, to_, amount_);

        //transactions[transactionId - 1].failed_ = false;

        //emit TransferSuccessful(from_, to_, amount_);
    }

    function addLiquidity(string memory symbol_, uint liquidityAmount) public {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedLiquidityProvider[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumLiquidity


        // WhiteList des liquidityProvider

        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        
        uint previousBalance = ERC20Interface.balanceOf(address(this));

        ERC20Interface.transferFrom(msg.sender, address(this), liquidityAmount);
        
        uint currentBalance = ERC20Interface.balanceOf(address(this));

        if (currentBalance == previousBalance + liquidityAmount) {
            shares[msg.sender] += liquidityAmount;
        }

        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
    }

    function addCollateral(string memory symbol_, uint collateralAmount) public {
        // require(shares[msg.sender] + msg.value <= maximumsender, "You can't send that much money");
        // require(whitelistedLiquidityProvider[msg.sender], "You are not authorized to deposit);
        // require(msg.value > 3, "You can't send that much money");
        // Test if we reach maximumLiquidity


        address contract_ = authorizedTokens[symbol_];
        ERC20Interface =  ERC20(contract_);
        
        uint previousBalance = ERC20Interface.balanceOf(address(this));

        ERC20Interface.transferFrom(msg.sender, address(this), collateralAmount);
        
        uint currentBalance = ERC20Interface.balanceOf(address(this));

        if (currentBalance == previousBalance + collateralAmount) {
            shares[msg.sender] += collateralAmount;
        }

        // Emit that an liquidity provider sent money
        //emit Test(msg.value);
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
    function settle() public {
        // Check maturity requirements
        // require(block.timestamp >= maturityDate, "This is not the right time");
        // require(shares[msg.sender] > 0, "Participant balance is 0");
        // require(!locked, "This Contract is still locked");

        // Check oracle price
        uint oraclePrice = strikePrice;

        // Compute payout function ratio on all shares
        // uint participantShares = shares[msg.sender];
        uint settleAmount = payout(oraclePrice);

        // Check if sum of all balances is okay compared to fund locked in the contract
        // and be sure that debt are cleansed and balance ajusted

        // Send back payout
        address contract_ = authorizedTokens["TST"];
        ERC20Interface =  ERC20(contract_);
        ERC20Interface.transfer(msg.sender, settleAmount);

        shares[msg.sender] = 0;
        
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

    function payout(uint oraclePrice) public view returns(uint) {
        if (oraclePrice >= strikePrice) {
            // return maximumPayout;
            return 20;
        }
        // return (maximumPayout * oraclePrice / initialPrice);
        return 80;

    }
/*
    function maturityEnd() public {
        // Conditions

        require(block.timestamp >= maturityDate, "Maturity not yet ended.");
        require(!locked, "Maturity has already been called.");

        locked = true;
        emit MaturityEnd(strikePrice, block.timestamp);

        uint _shares;
        for(uint i = 0 ; i<_totalHolders; i++) {
            _shares = shares[holders[i]];
            holders[i].transfer(_shares);
        }
    }*/
}
