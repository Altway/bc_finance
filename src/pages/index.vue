<template>
	<section class="container">
		<div>
			<app-logo />
			<h1 class="title">crypto-box</h1>
			<!-- <h2 class="subtitle">Truffle box for Nuxt.js development</h2> -->
			<div>
				<nuxt-link to="/truc"> Nuxt Link (Store persistence) </nuxt-link>
			</div>
			<h2 class="paragraph-title">Configuration</h2>

			<div class="row">
				<button @click="test">Test</button>
			</div>
			<h2 class="paragraph-title">Mint TST TOKEN</h2>
			<div class="row">
				<div class="row">
					Mint Address:
					<input v-model="mintRecipientAddress" title="mintRecipientAddress" />
					Mint token Amount:
					<input v-model="mintTokenAmount" title="minTokenAmount" />
				</div>
				<div class="row">
					<button @click="mintToken">Mint Token</button>
				</div>
			</div>
			<h2 class="paragraph-title">Add Admin/Client Address</h2>
			<div class="row">
				<div class="row">
					Admin Address:
					<input v-model="newAdminAddress" title="adminAddress" />
					<button @click="addAdmin">Add New Admin</button>
					Client Address:
					<input v-model="newClientAddress" title="clientAddress" />
					<button @click="addClient">Add New Client</button>
				</div>
			</div>
			<div class="row">
				<div class="row">
					Initial Asset Price:
					<input
						v-model="transientInitialFixing"
						title="transientInitialFixing"
					/>
				</div>
				<div class="row">
					<button @click="setInitialFixing">Set Initial Price</button>
					<span style="margin-left: 10px">{{ initialFixing }}</span>
				</div>
			</div>
			<div>
				Strike Price: {{ strikePrice }}
				<vue-slider v-model="transientStrikePrice"></vue-slider>
				<button @click="setStrikePrice">Set Strike Price</button>
			</div>
			<div>
				Final Fixing: {{ finalFixing }}
				<vue-slider v-model="transientFinalFixing"></vue-slider>
				<button @click="setFinalFixing">Set Final Fixing</button>
			</div>
			<div class="row">
				<div class="row">
					Add Maturity minutes:
					<input v-model="additionalMaturityMinute" title="maturity" />
				</div>
				<div class="row">
					<button @click="addMaturity">Add Maturity</button>
					<span style="margin-left: 10px">{{ maturityDate }}</span>
				</div>
				<div class="row">
					<button @click="switchContractLock">Switch Contract Lock</button>
					<span style="margin-left: 10px">{{ locked }}</span>
				</div>
			</div>

			<h2 class="paragraph-title">Contract Interactions</h2>

			<div class="row">
				<div class="row">
					Authorized Token Symbol:
					<input v-model="addedTokenSymbol" title="symbol" />
					Authorized Token Address:
					<input v-model="addedTokenAddress" title="address" />
				</div>
				<div class="row">
					<button @click="addToken">Add New Token</button>
				</div>
			</div>
			<div class="row">
				to Approved Address:
				<input v-model="toApprovedAddress" title="toApprovedAddress" />
				Amount of tokens Approved
				<input v-model="tokenApprovedAmount" title="tokenApprovedAmount" />
				<button @click="approveAddress">
					Approve {{ tokenApprovedAmount }} tokens
				</button>
			</div>
			<div>
				<h3 class="paragraph-title">Add Liquidity (Admin)</h3>
				<div class="row">
					Token Symbol: <input v-model="tokenSymbol" title="Recipent" />
				</div>
				<div class="row">
					Liquidity Amount:
					<input v-model="liquidityAmount" title="liquidityAmount" />
				</div>
				<div class="row">
					<button @click="addLiquidity">Send Liquidity</button>
				</div>
				<div class="receipt-box">
					Total Liquidity:
					<span style="color: green">{{ totalLiquidity }}</span>
				</div>
			</div>
			<div>
				<h3 class="paragraph-title">Add Notional (Client)</h3>
				<div class="row">
					Token Symbol: <input v-model="tokenSymbol" title="Recipent" />
				</div>
				<div class="row">
					Notional Amount:
					<input v-model="notionalAmount" title="notionalAmount" />
				</div>
				<div class="row">
					<button @click="addNotional">Send Notional</button>
				</div>
				<div class="receipt-box">
					Total Notional:
					<span style="color: green">{{ totalNotional }}</span>
				</div>
			</div>
			<h3 class="paragraph-title">SETTLEMENT</h3>
			<div class="row">
				to Approved Address (farmToken):
				<input v-model="toApprovedAddress" title="toApprovedAddress" />
				Amount of tokens Approved (farmToken)
				<input v-model="tokenApprovedAmount" title="tokenApprovedAmount" />
				<button @click="app">Approve {{ tokenApprovedAmount }} tokens</button>
			</div>
			<div class="row">
				<button @click="settle">Settle</button>
			</div>
			<div class="receipt-box">
				Settle Result:
				<span style="color: green">{{ settleResult }}</span>
			</div>

			<div class="row">
				Liquidity Withdraw Result:
				<input
					v-model="withdrawnLiquidityAmount"
					title="withdrawnLiquidityAmount"
				/>
				<button @click="withdrawLiquidity">
					Liquidity Withdraw {{ withdrawnLiquidityAmount }} tokens
				</button>
			</div>
			<div class="receipt-box">
				<span style="color: green">{{ withdrawnLiquidityResult }}</span>
			</div>

			<div class="row">
				Notional Withdraw Result:
				<input
					v-model="withdrawnNotionalAmount"
					title="withdrawnNotionalAmount"
				/>
				<button @click="withdrawNotional">
					Notional Withdraw {{ withdrawnNotionalAmount }} tokens
				</button>
			</div>
			<div class="receipt-box">
				Notional Withdraw Result:
				<span style="color: green">{{ withdrawnNotionalResult }}</span>
			</div>
		</div>
	</section>
</template>

<script>
import AppLogo from '~/components/AppLogo.vue'
//import VueSlider from 'vue-slider-component'
//import 'vue-slider-component/theme/antd.css'

import VueSlider from 'vue-slider-component/dist-css/vue-slider-component.umd.min.js'
import 'vue-slider-component/dist-css/vue-slider-component.css'

// import theme
import 'vue-slider-component/theme/default.css'

import web3 from '~/plugins/web3'

export default {
	components: {
		AppLogo,
		VueSlider,
	},
	data() {
		return {
			userAddress: '',
			payoutRatio: 0,
			transientPayoutRatio: 0,
			initialFixing: 0,
			transientInitialFixing: 0,
			finalFixing: 0,
			transientFinalFixing: 0,
			strikePrice: 0,
			transientStrikePrice: 0,
			additionalMaturityMinute: 0,
			maturityDate: 0,
			locked: false,
			addressShares: 0,
			transientAddressShares: 0,
			addedTokenSymbol: 'TST',
			addedTokenAddress: '',
			toApprovedAddress: '',
			tokenApprovedAmount: 0,
			totalLiquidity: 0,
			liquidityAmount: 0,
			totalNotional: 0,
			notionalAmount: 0,
			tokenSymbol: 'TST',
			amount: 0,
			recipientAddress: '',
			mintRecipientAddress: '',
			mintTokenAmount: '',
			settleResult: '',
			withdrawAmount: 0,
			approvedFarmTokenAmount: 0,
			newAdminAddress: this.newAdminAddress,
			newClientAddress: this.newClientAddress,
			withdrawnLiquidityAmount: 0,
			withdrawnNotionalAmount: 0,
			withdrawnLiquidityResult: 0,
			withdrawnNotionalResult: 0,
		}
	},
	computed: {
		btcPrice: {
			get: function () {
				return this.$store.state.btcPrice
			},
			set(val) {
				this.$store.commit('setBtcPrice', val)
			},
		},
	},
	mounted() {
		web3.eth.getAccounts().then((result) => {
			this.userAddress = result[0]
		})
		/*var account = web3.eth.accounts[0];
		setInterval(function () {
  			if (web3.eth.accounts[0] !== account) {
    			account = web3.eth.accounts[0];
    			updateInterface();
  			}
		}, 100);*/
	},
	methods: {
		async test() {},
		async depositFarmToken() {
			await this.$store.dispatch('marex/depositFarmToken', {
				from: this.userAddress,
				withdrawAmount: this.withdrawAmount,
			})
		},
		async addAdmin() {
			await this.$store.dispatch('marex/addAdmin', {
				from: this.userAddress,
				newAdminAddress: this.newAdminAddress,
			})
		},
		async addClient() {
			await this.$store.dispatch('marex/addClient', {
				from: this.userAddress,
				newClientAddress: this.newClientAddress,
			})
		},
		async approveFarmToken() {
			await this.$store.dispatch('marex/approveFarmToken', {
				from: this.userAddress,
				approvedFarmTokenAmount: this.approvedFarmTokenAmount,
			})
		},
		async withdraw() {
			await this.$store.dispatch('marex/withdraw', {
				from: this.userAddress,
				withdrawAmount: this.withdrawAmount,
			})
		},
		async setPayoutRatio() {
			this.payoutRatio = await this.$store.dispatch('marex/setPayoutRatio', {
				from: this.userAddress,
				transientPayoutRatio: this.transientPayoutRatio,
			})
		},
		async setStrikePrice() {
			this.strikePrice = await this.$store.dispatch('marex/setStrikePrice', {
				from: this.userAddress,
				transientStrikePrice: this.transientStrikePrice,
			})
		},
		async setInitialFixing() {
			this.initialFixing = await this.$store.dispatch(
				'marex/setInitialFixing',
				{
					from: this.userAddress,
					transientInitialFixing: this.transientInitialFixing,
				}
			)
		},
		async setFinalFixing() {
			this.finalFixing = await this.$store.dispatch('marex/setFinalFixing', {
				from: this.userAddress,
				transientFinalFixing: this.transientFinalFixing,
			})
		},
		async addMaturity() {
			this.maturityDate = await this.$store.dispatch('marex/addMaturity', {
				from: this.userAddress,
				additionalMaturityMinute: this.additionalMaturityMinute,
			})
		},
		async switchContractLock() {
			this.locked = await this.$store.dispatch('marex/switchContractLock', {
				from: this.userAddress,
			})
		},
		async getAddressShares() {
			this.addressShares = await this.$store.dispatch('marex/getAdressShares', {
				from: this.userAddress,
				addressShares: this.transientaddressShares,
			})
		},
		async addToken() {
			await this.$store.dispatch('marex/addToken', {
				from: this.userAddress,
				addedTokenSymbol: this.addedTokenSymbol,
				addedTokenAddress: this.addedTokenAddress,
			})
		},
		async mintToken() {
			await this.$store.dispatch('marex/mintToken', {
				from: this.userAddress,
				mintRecipientAddress: this.mintRecipientAddress,
				mintTokenAmount: this.mintTokenAmount,
			})
		},
		async app() {
			await this.$store.dispatch('marex/app', {
				from: this.userAddress,
				toApproveAddress: this.approveAddress,
				tokenApprovedAmount: this.tokenApprovedAmount,
			})
		},
		async approveAddress() {
			await this.$store.dispatch('marex/approve', {
				from: this.userAddress,
				toApproveAddress: this.approveAddress,
				tokenApprovedAmount: this.tokenApprovedAmount,
			})
		},
		async addLiquidity() {
			this.totalLiquidity = await this.$store.dispatch('marex/addLiquidity', {
				from: this.userAddress,
				liquidityAmount: this.liquidityAmount,
				tokenSymbol: this.tokenSymbol,
			})
		},
		async addNotional() {
			this.totalNotional = await this.$store.dispatch('marex/addNotional', {
				from: this.userAddress,
				notionalAmount: this.notionalAmount,
				tokenSymbol: this.tokenSymbol,
			})
		},
		async withdrawLiquidity() {
			this.withdrawLiquidityResult = await this.$store.dispatch(
				'marex/withdrawLiquidity',
				{
					from: this.userAddress,
					withdrawnLiquidityAmount: this.withdrawnLiquidityAmount,
				}
			)
		},
		async withdrawNotional() {
			this.withdrawNotionalResult = await this.$store.dispatch(
				'marex/withdrawNotional',
				{
					from: this.userAddress,
					withdrawnNotionalAmount: this.withdrawnNotionalAmount,
				}
			)
		},
		async settle() {
			this.settleResult = await this.$store.dispatch('marex/settle', {
				from: this.userAddress,
			})
		},
	},
}
</script>

<style>
.container {
	min-height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
	text-align: center;
}

.title {
	font-family: 'Quicksand', 'Source Sans Pro', -apple-system, BlinkMacSystemFont,
		'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; /* 1 */
	display: block;
	font-weight: 300;
	font-size: 100px;
	color: #35495e;
	letter-spacing: 1px;
}

.subtitle {
	font-weight: 300;
	font-size: 42px;
	color: #526488;
	word-spacing: 5px;
	padding-bottom: 15px;
}

.paragraph-title {
	font-weight: 300;
	font-size: 20px;
	color: #35495e;
	word-spacing: 5px;
	padding: 15px 0;
}

.receipt-box {
	padding-top: 15px;
	width: 900px;
	word-break: break-all;
}

.row {
	padding: 10px;
}
</style>
