{{ config(
    schema = 'thena_fusion_bnb',
    alias = alias('trades'),
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_date', 'blockchain', 'project', 'version', 'tx_hash', 'evt_index', 'trace_address'],
    post_hook='{{ expose_spells(\'["bnb"]\',
                                "project",
                                "thena_fusion",
                                \'["hsrvc"]\') }}'
    )
}}

{% set project_start_date = '2023-02-28' %}

WITH dexs AS
(
    SELECT
        t.evt_block_time AS block_time
        ,t.recipient AS taker
        ,'' AS maker
        ,CASE WHEN amount0 < '0' THEN abs(amount0) ELSE abs(amount1) END AS token_bought_amount_raw -- when amount0 is negative it means trader_a is buying token0 from the pool
        ,CASE WHEN amount0 < '0' THEN abs(amount1) ELSE abs(amount0) END AS token_sold_amount_raw
        ,CAST(NULL AS DOUBLE) AS amount_usd
        ,CASE WHEN amount0 < '0' THEN f.token0 ELSE f.token1 END AS token_bought_address
        ,CASE WHEN amount0 < '0' THEN f.token1 ELSE f.token0 END AS token_sold_address
        ,CAST(t.contract_address as string) as project_contract_address
        ,t.evt_tx_hash AS tx_hash
        ,'' AS trace_address
        ,t.evt_index
    FROM
        {{ source('thena_bnb', 'AlgebraPool_evt_Swap') }} t
    INNER JOIN 
        {{ source('thena_fi_bnb', 'PairFactoryUpgradeable_evt_Pool') }} f
        ON f.pool = t.contract_address
    {% if is_incremental() %}
    WHERE t.evt_block_time >= date_trunc("day", now() - interval '1 week')
    {% endif %}
)
SELECT
    'bnb' AS blockchain
    ,'thena' AS project
    ,'fusion' AS version
    ,TRY_CAST(date_trunc('DAY', dexs.block_time) AS date) AS block_date
    ,dexs.block_time
    ,erc20a.symbol AS token_bought_symbol
    ,erc20b.symbol AS token_sold_symbol
    ,case
        when lower(erc20a.symbol) > lower(erc20b.symbol) then concat(erc20b.symbol, '-', erc20a.symbol)
        else concat(erc20a.symbol, '-', erc20b.symbol)
    end as token_pair
    ,dexs.token_bought_amount_raw / power(10, erc20a.decimals) AS token_bought_amount
    ,dexs.token_sold_amount_raw / power(10, erc20b.decimals) AS token_sold_amount
    ,CAST(dexs.token_bought_amount_raw AS DECIMAL(38,0)) AS token_bought_amount_raw
    ,CAST(dexs.token_sold_amount_raw AS DECIMAL(38,0)) AS token_sold_amount_raw
    ,coalesce(
        dexs.amount_usd
        ,(dexs.token_bought_amount_raw / power(10, p_bought.decimals)) * p_bought.price
        ,(dexs.token_sold_amount_raw / power(10, p_sold.decimals)) * p_sold.price
    ) AS amount_usd
    ,dexs.token_bought_address
    ,dexs.token_sold_address
    ,coalesce(dexs.taker, tx.from) AS taker -- subqueries rely on this COALESCE to avoid redundant joins with the transactions table
    ,dexs.maker
    ,dexs.project_contract_address
    ,dexs.tx_hash
    ,tx.from AS tx_from
    ,tx.to AS tx_to
    ,dexs.trace_address
    ,dexs.evt_index
FROM dexs
INNER JOIN 
    {{ source('bnb', 'transactions') }} tx
    ON tx.hash = dexs.tx_hash
    {% if not is_incremental() %}
    AND tx.block_time >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND tx.block_time >= date_trunc("day", now() - interval '1 week')
    {% endif %}
LEFT JOIN {{ ref('tokens_erc20') }} erc20a
    ON erc20a.contract_address = dexs.token_bought_address 
    AND erc20a.blockchain = 'bnb'
LEFT JOIN {{ ref('tokens_erc20') }} erc20b
    ON erc20b.contract_address = dexs.token_sold_address
    AND erc20b.blockchain = 'bnb'
LEFT JOIN {{ source('prices', 'usd') }} p_bought
    ON p_bought.minute = date_trunc('minute', dexs.block_time)
    AND p_bought.contract_address = dexs.token_bought_address
    AND p_bought.blockchain = 'bnb'
    {% if not is_incremental() %}
    AND p_bought.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_bought.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
LEFT JOIN {{ source('prices', 'usd') }} p_sold
    ON p_sold.minute = date_trunc('minute', dexs.block_time)
    AND p_sold.contract_address = dexs.token_sold_address
    AND p_sold.blockchain = 'bnb'
    {% if not is_incremental() %}
    AND p_sold.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_sold.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
;