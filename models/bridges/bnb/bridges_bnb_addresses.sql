{{ config(alias = 'addresses',
        schema = 'bridges_bnb',
        tags=['static'],
          ) }}

SELECT blockchain, address, bridge_name, description
FROM (VALUES 
      ('bnb', 0xBBbD1BbB4f9b936C3604906D7592A644071dE884, 'Allbridge', 'Bridge')
    ,('bnb', 0x6F817a0cE8F7640Add3bC0c1C2298635043c2423, 'Anyswap', 'anyETH Token')
    ,('bnb', 0xb1CB88B1a1992deB4189Ea4f566b594c13392Ada, 'AnySwap', 'Bridge Avalanche')
    ,('bnb', 0x4b3B4120d4D7975455d8C2894228789c91a247F8, 'Anyswap', 'Bridge Fantom')
    ,('bnb', 0xd6faf697504075a358524996b132b532cc5D0F14, 'Anyswap', 'Moonriver Bridge')
    ,('bnb', 0x9DF69F656A9CFdf5cD1c2140B71e2Aa130cE7eB8, 'BlazeX', 'Crosschain Bridge')
    ,('bnb', 0x5d96d4287D1ff115eE50faC0526cf43eCf79bFc6, 'Celer Network', 'cBridge 2.0')
    ,('bnb', 0x43dE2d77BF8027e25dBD179B491e8d64f38398aA, 'deBridgeGate', '')
    ,('bnb', 0xE7351Fd770A37282b91D153Ee690B63579D6dd7f, 'Dln', 'Destination')
    ,('bnb', 0xF0b456250DC9990662a6F25808cC74A6d1131Ea9, 'Gnosis Chain', 'BSC - Gnosis Omni Bridge')
    ,('bnb', 0x05185872898b6f94AA600177EF41B9334B1FA48B, 'Gnosis Chain', 'BSC-xDAI Omni Bridge')
    ,('bnb', 0xfD53b1B4AF84D59B20bF2C20CA89a6BeeAa2c628, 'Harmony', 'Bridge')
    ,('bnb', 0xa90a8e34cea28bF9a234d4eac240fB32358b51AB, 'iSwap', 'Binance Bridge')
    ,('bnb', 0x3c2269811836af69497E5F486A85D7316753cf62, 'LayerZero', 'Binance Smart Chain Endpoint')
    ,('bnb', 0x4948ff01cF150e7867D9eEef6272DB13fD37C537, 'Less Network', 'Bridge')
    ,('bnb', 0x05B70Fb5477A93bE33822bfB31fDAF2c171970dF, 'Mayan', 'Swap Bridge')
    ,('bnb', 0xC10Ef9F491C9B59f936957026020C321651ac078, 'Multichain', 'anyCall V6')
    ,('bnb', 0x92C079d3155C2722dBf7E65017a5baf9CD15561c, 'Multichain', 'Bridge')
    ,('bnb', 0xd1C5966f9F5Ee6881Ff6b261BBeDa45972B1B5f3, 'Multichain', 'Router V4')
    ,('bnb', 0xABd380327Fe66724FFDa91A87c772FB8D00bE488, 'Multichain', 'Router V4 2')
    ,('bnb', 0xe1d592c3322f1F714Ca11f05B6bC0eFEf1907859, 'Multichain', 'Router V6')
    ,('bnb', 0x638E8FE7AD4D9C05735Ecb6b9c66013679276651, 'Spore Finance', 'Bridge')
    ,('bnb', 0xd123f70AE324d34A9E76b67a27bf77593bA8749f, 'Synapse', 'Bridge')
    ,('bnb', 0x749F37Df06A99D6A8E065dd065f8cF947ca23697, 'Synapse', 'Bridge Zap 1')
    ,('bnb', 0x158B536C2ae3afDeA1be69fD91f942A2f96e0a6d, 'Undead Blocks', 'Bridge')
    ,('bnb', 0x98f3c9e6E3fAce36bAAd05FE09d375Ef1464288B, 'Wormhole', 'Binance Smart Chain Core Bridge')
    ,('bnb', 0x5a58505a96D1dbf8dF91cB21B54419FC36e93fdE, 'Wormhole', 'NFT Bridge')
    ,('bnb', 0xB6F6D86a8f9879A9c87f643768d9efc38c1Da6E7, 'Wormhole: Token Bridge', 'Token Bridge')
    ,('bnb', 0x31eFc4AeAA7c39e54A33FDc3C46ee2Bd70ae0A09, 'xPollinate', 'Transaction Manager')
    ,('bnb', 0xcb9Cc9d0f8f4Ac451a523D3C064553dD33Ea39E3, 'Zeroswap', 'BSC Bridge')
    ,('bnb', 0x6694340fc020c5e6b96567843da2df01b2ce1eb6, 'Stargate Finance: Bridge', 'Bridge')

      ) AS x (blockchain, address, bridge_name, description)