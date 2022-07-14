# Cosmos

## Query txs events

⠀There are events which you can use in the `DAEMON query txs --events "eventType.eventAttribute=value"` command (events were collected from the Evmos network). 

- coin_received
  - receiver
  - amount
- coin_spent
  - spender
  - amount
- ethereum_tx
  - amount
  - ethereumTxHash
  - txIndex
  - txGasUsed
  - txHash
  - recipient
- message
  - action
  - sender
  - module
  - txType
- transfer
  - recipient
  - sender
  - amount
- tx_log
  - txLog

⠀Examples:
```sh
evmosd query txs --events "coin_spent.spender=evmos17xpfvakm2amg962yls6f84z3kell8c5ljcjw31"
```
