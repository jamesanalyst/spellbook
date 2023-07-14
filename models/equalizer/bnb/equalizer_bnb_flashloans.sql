{{ config(
      alias = alias('flashloans')
      , materialized = 'incremental'
      , file_format = 'delta'
      , incremental_strategy = 'merge'
      , unique_key = ['tx_hash', 'evt_index']
      , post_hook='{{ expose_spells(\'["bnb"]\',
                                  "project",
                                  "equalizer",
                                  \'["hildobby"]\') }}'
  )
}}

SELECT 'bnb' AS blockchain
, 'Equalizer' AS project
, '1' AS version
, flash.evt_block_time AS block_time
, flash.evt_block_number AS block_number
, flash.amount/POWER(10, tok.decimals) AS amount
, pu.price*(flash.amount/POWER(10, tok.decimals)) AS amount_usd
, flash.evt_tx_hash AS tx_hash
, flash.evt_index
, flash.fee/POWER(10, tok.decimals) AS fee
, flash.token AS currency_contract
, tok.symbol AS currency_symbol
, flash.receiver AS recipient
, flash.contract_address
FROM {{ source('equalizer_bnb','FlashLoanProvider_evt_FlashLoan') }} flash
LEFT JOIN {{ ref('tokens_bnb_bep20') }} tok ON tok.contract_address=flash.token
LEFT JOIN {{ source('prices','usd') }} pu ON pu.blockchain = 'bnb'  
  AND pu.contract_address = flash.token
  AND pu.minute = date_trunc('minute', flash.evt_block_time)
  {% if is_incremental() %}
  AND pu.minute >= date_trunc("day", now() - interval '1 week')
  {% endif %}
{% if is_incremental() %}
WHERE flash.evt_block_time >= date_trunc("day", now() - interval '1 week')
{% endif %}