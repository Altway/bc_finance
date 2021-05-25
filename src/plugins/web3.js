// import Web3 from 'web3'
const Web3 = require('web3')

// const instance = new Web3(Web3.givenProvider || 'http://localhost:9545')
let web3 = new Web3(Web3.givenProvider || 'ws://localhost:9545')

export default web3
