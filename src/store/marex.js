// import web3Abi from 'web3-eth-abi'
import web3 from '~/plugins/web3'
import Marex from '../../build/contracts/Marex'
import TestCoin from '../../build/contracts/TestCoin'
import FarmToken from '../../build/contracts/FarmToken'

const testCoinAddress = '0xEb385aD75A2628AfF71125C855EF31415c136511'
const farmTokenAddress = '0xa615E638B2a80C624Cabb1622ac82D122CEc084a'
const MarexAddress = '0xd7DC6BdBD082fa499cA0b973C3b73f0499f18419'

//const MarexContract = Marex.deployed()
//const MarexAddress = MarexContract.address
const marex = new web3.eth.Contract(Marex.abi, MarexAddress)
const testcoin = new web3.eth.Contract(TestCoin.abi, testCoinAddress)
const farmtoken = new web3.eth.Contract(FarmToken.abi, farmTokenAddress)

// console.log(web3.eth.getAccounts())
/*
window.addEventListener('load', async () => {
	// Modern dapp browsers...
	if (window.ethereum) {
		window.web3 = new web3(window.ethereum)
		try {
			// Request account access if needed
			await window.ethereum.enable()
		} catch (error) {
			// User denied account access...
		}
	}
	// Legacy dapp browsers...
	else if (window.web3) {
		window.web3 = new web3(web3.currentProvider)
	}
	// Non-dapp browsers...
	else {
		console.log(
			'Non-Ethereum browser detected. You should consider trying MetaMask!'
		)
	}
})
*/
//const buyerAddress = '0xFC4b2542E010DF9Ccaf28571C86c30E78afFD490'
//const providerAddress = '0xD062dBe6cd2990cb5BBf49E710DB22C6CAd51237'

// Defaut metamask address => var userAccount = web3.eth.accounts[0]
/*
var accountInterval = setInterval(function () {
	// Vérifie si le compte a changé
	if (web3.eth.accounts[0] !== userAccount) {
		userAccount = web3.eth.accounts[0]
		// Appelle une fonction pour mettre à jour l'interface avec le nouveau compte
		updateInterface()
	}
}, 100)
*/
//let account = '0x443A92AEEf6ba86b0ba25DFBE960d8323cB76E8b'
//let acc = web3.eth.accounts[0]
/*
let account = web3.utils.toChecksumAddress(
	'0x443A92AEEf6ba86b0ba25DFBE960d8323cB76E8b'
)*/
/*
let account = web3.eth.getAccounts().then((res) => {
	account = res[0]
	web3.eth.defaultAccount = res[0]
})*/
//account[0] = '0x5dFDd662c5668793a20321Ba163446aC0a69515B'

setInterval(() => {
	marex.methods
		.payoutRatio()
		.call()
		.then((r) => {
			console.log(r)
		})
}, 3000)

marex.events
	.Test()
	.on('data', function (event) {
		let zombie = event.returnValues
		console.log('A new zombie was born!', zombie.event_int, zombie.event_string)
	})
	.on('error', console.error)

marex.events
	.Fric()
	.on('data', function (event) {
		let tmp = event.returnValues
		console.log('Money Money Piggy', tmp.event_int, tmp.event_string)
	})
	.on('error', console.error)

marex.events
	.Log()
	.on('data', function (event) {
		let t = event.returnValues
		console.log('LOG', t.event_string)
	})
	.on('error', console.error)

marex.events
	.LogS()
	.on('data', function (event) {
		let t = event.returnValues
		console.log('LOG', t.event_string)
	})
	.on('error', console.error)

testcoin.events
	.Approval()
	.on('data', function (event) {
		let t = event.returnValues
		console.log('Approval TOKENOWNER', t.tokenOwner)
		console.log('Approval SPENDER', t.spender)
		console.log('Approval TOKENS', t.tokens)
	})
	.on('error', console.error)
export const state = () => ({})

export const mutations = {}

export const actions = {
	getMaturity() {
		return marex.methods.maturityDate().call()
	},
	async getAddressShares(context, params) {
		return marex.methods.shares(params.transientAddressShares).call()
	},
	async addAdmin(context, params) {
		await marex.methods
			.addAdmin(params.newAdminAddress)
			.send({ from: params.from })
	},
	async addClient(context, params) {
		await marex.methods
			.addClient(params.newClientAddress)
			.send({ from: params.from })
	},
	async setPayoutRatio(context, params) {
		await marex.methods
			.setPayoutRatio(params.transientPayoutRatio)
			.send({ from: params.from })
		return marex.methods.payoutRatio().call()
	},
	async setStrikePrice(context, params) {
		await marex.methods
			.setStrikePrice(params.transientStrikePrice)
			.send({ from: params.from })
		return marex.methods.strikePrice().call()
	},
	async setInitialFixing(context, params) {
		await marex.methods
			.setInitialFixing(params.transientInitialFixing)
			.send({ from: params.from })
		return marex.methods.initialFixing().call()
	},
	async setFinalFixing(context, params) {
		await marex.methods
			.setFinalFixing(params.transientFinalFixing)
			.send({ from: params.from })
		return marex.methods.finalFixing().call()
	},
	async addMaturity(context, params) {
		await marex.methods
			.addMaturity(params.additionalMaturityMinute)
			.send({ from: params.from })
		return marex.methods.maturityDate().call()
	},
	async switchContractLock(context, params) {
		await marex.methods.switchLock().send({ from: params.from })
		return marex.methods.locked().call()
	},
	async addToken(context, params) {
		await marex.methods
			.addNewToken(params.addedTokenSymbol, params.addedTokenAddress)
			.send({ from: params.from })
	},
	async mintToken(context, params) {
		await testcoin.methods
			.mint(params.mintRecipientAddress, params.mintTokenAmount)
			.send({ from: params.from })
	},
	async depositFarmToken(context, params) {
		await farmtoken.methods
			.deposit(params.tokenApprovedAmount)
			.send({ from: params.from })
	},
	async approveFarmToken(context, params) {
		await testcoin.methods
			.approve(farmTokenAddress, params.tokenApprovedAmount)
			.send({ from: params.from })
	},
	async withdraw(context, params) {
		await farmtoken.methods
			.withdraw(params.tokenApprovedAmount)
			.send({ from: params.from })
	},
	async app(context, params) {
		await farmtoken.methods
			.approve(MarexAddress, params.tokenApprovedAmount)
			.send({ from: params.from })
	},
	async approve(context, params) {
		await testcoin.methods
			.approve(MarexAddress, params.tokenApprovedAmount)
			.send({ from: params.from })
	},
	async addNotional(context, params) {
		await marex.methods
			.addNotional(params.tokenSymbol, params.notionalAmount)
			.send({
				from: params.from,
			})
	},
	async addLiquidity(context, params) {
		// Permet de check si une fonction existe sur le SM
		/*
		const setupDate = Marex.abi.find((method) => {
			return method.name === 'associateAddress'
		})*/
		await marex.methods
			.addLiquidity(params.tokenSymbol, params.liquidityAmount)
			.send({
				from: params.from,
				// value: web3.utils.toWei(params.value, 'ether'),
			})
	},
	async withdrawLiquidity(context, params) {
		marex.methods
			.withdrawLiquidity(params.withdrawnLiquidityAmount)
			.send({ from: params.from })
	},
	async withdrawNotional(context, params) {
		marex.methods
			.withdrawNotional(params.withdrawnNotionalAmount)
			.send({ from: params.from })
	},
	async settle(context, params) {
		let a
		marex.methods
			.settle()
			.send({ from: params.from })
			.on('receipt', function (receipt) {
				console.log(receipt)
				a = receipt
			})
			.on('error', function (error) {
				console.log(error)
			})
		console.log(a)
		return a
	},
}
export const getters = {}

// mes enormes couilles
// function getZombieDetails(id) {return eip20.methods.zombies(id).call()}

// utiliser la fonction: getZombieDetails(15).then(function(result) {console.log("Zombie 15: " + JSON.stringify(result));});
// Cela va convertir 1 ETH en Wei web3js.utils.toWei("1", "ether");
// Pour les fonctions payable : cryptoZombies.methods.levelUp(zombieId).send({ from: userAccount, value: web3js.utils.toWei("0.001", "ether") })

// Subscribe à un event:
/*
cryptoZombies.events.NewZombie()
.on("data", function(event) {
	let zombie = event.returnValues;
	// Nous pouvons accéder aux 3 valeurs de retour de cet évènement avec l'objet `event.returnValues` :
	console.log("A new zombie was born!", zombie.zombieId, zombie.name, zombie.dna);
  }).on("error", console.error);
  */

// Subscribe avec filter sur les champs "indexed" pour fitlerr parmis tous les events

/*
cryptoZombies.events.Transfer({ filter: { _to: userAccount } })
.on("data", function(event) {
  let data = event.returnValues;
  // L’utilisateur actuel a reçu un zombie !
  // Faire quelque chose pour mettre à jour l'interface
}).on("error", console.error);
*/

// Filtrer parmis les events passés entre block*
/*
cryptoZombies.getPastEvents("NewZombie", { fromBlock: 0, toBlock: "latest" })
.then(function(events) {
  // `events` est un tableau d'objets `event` pour lequel nous pouvons itérer, comme nous l'avons fait ci-dessus
  // Ce code donnera une liste de tous les zombies créés
});
*/
/*
		return marex.methods.setupDate(24).send({
			from: web3.utils.toChecksumAddress(account),
			//value: web3.utils.toWei('0.01', 'ether'),
		})
		/*
		const setupDateMethodTransactionData = web3Abi.encodeFunctionCall(
			setupDate,
			[params.to, web3.utils.toBN(params.value)]
		)
		console.log(setupDateMethodTransactionData)

		/*
		const estimateGas = await web3.eth.estimateGas({
			from: account,
			to: tokenAddress,
			data: setupDateMethodTransactionData,
		})
		console.log(estimateGas)

		const receipt = await web3.eth.sendTransaction({
			from: account,
			to: tokenAddress,
			data: setupDateMethodTransactionData,
			value: 0,
			gas: estimateGas,
		})
		console.log(receipt)

		return receipt
	},
*/

/*
	getName() {
		return eip20.methods.name().call({ from: account })
	},
	*/

/*
	async transfer(context, params) {
		console.log(params)
		console.log(context)
		console.log(account)
		const transferMethod = Marex.abi.find((method) => {
			return method.name === 'transfer'
		})

		const transferMethodTransactionData = web3Abi.encodeFunctionCall(
			transferMethod,
			[params.to, web3.utils.toBN(params.value)]
		)

		const estimateGas = await web3.eth.estimateGas({
			from: account,
			to: tokenAddress,
			data: transferMethodTransactionData,
		})

		const receipt = await web3.eth.sendTransaction({
			from: account,
			to: tokenAddress,
			data: transferMethodTransactionData,
			value: 0,
			gas: estimateGas,
		})

		return receipt
	},*/
/*
	async mat(context, params) {
		let a
		marex.methods
			.maturity()
			.send({ from: params.from })
			.on('receipt', function (receipt) {
				console.log(receipt)
				a = receipt
			})
			.on('error', function (error) {
				console.log(error)
			})
		console.log(a)
		return a
	},*/
/*
	async tokenTransfer(context, params) {
		await marex.methods
			.transferTokens(
				web3.utils.asciiToHex(params.symbol),
				params.to,
				params.value
			)
			.send({ from: params.from })
	},*/
/*
	async app(context, params) {
		await marex.methods
			.approve(web3.utils.asciiToHex(params.approveValue), params.value)
			.send({ from: params.from })
	},*/

// export default web3

// web3.utils.asciiToHex(params.addedtokenSymbol),
