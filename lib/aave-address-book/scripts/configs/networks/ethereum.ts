import {Hex} from 'viem';
import {ChainId} from '@bgd-labs/rpc-env';
import {AddressInfo, NetworkAddresses} from '../types';

export const ethereumAddresses: NetworkAddresses<{
  ECOSYSTEM_RESERVE: Hex;
  AAVE_ECOSYSTEM_RESERVE_CONTROLLER: AddressInfo;
  PROXY_ADMIN_LONG: Hex;
  AAVE_SWAPPER: Hex;
  AAVE_POL_ETH_BRIDGE: Hex;
  sDAI_POT: Hex;
  stEUR: Hex;
  agEUR_EUR_AGGREGATOR: Hex;
  EUR_USD_AGGREGATOR: Hex;
  weETH_RATIO_PROVIDER: Hex;
}> = {
  name: 'Ethereum',
  chainId: ChainId.mainnet,
  addresses: {
    AAVE_ECOSYSTEM_RESERVE_CONTROLLER: {
      value: '0x3d569673dAa0575c936c7c67c4E6AedA69CC630C',
      type: 'IAaveEcosystemReserveController',
    },
    ECOSYSTEM_RESERVE: '0x25F2226B597E8F9514B3F68F00f494cF4f286491',
    PROXY_ADMIN_LONG: '0x86C3FfeE349A7cFf7cA88C449717B1b133bfb517',
    AAVE_SWAPPER: '0x3ea64b1C0194524b48F9118462C8E9cd61a243c7',
    AAVE_POL_ETH_BRIDGE: '0x1C2BA5b8ab8e795fF44387ba6d251fa65AD20b36',
    PARASWAP_FEE_CLAIMER: '0x9abf798f5314BFd793A9E57A654BEd35af4A1D60',
    TRANSPARENT_PROXY_FACTORY: '0x9FB3B12248bf010AEA7cE08343C8499FFAB4770f',
    PROXY_ADMIN: '0xD3cF979e676265e4f6379749DECe4708B9A22476',
    CREATE_3_FACTORY: '0xcc3C54B95f3f1867A43009B80ed4DD930E3cE2F7',
    AAVE_CL_ROBOT_OPERATOR: '0x1cDF8879eC8bE012bA959EB515b11008E0cb6323',
    PROTOCOL_GUARDIAN: '0x2CFe3ec4d5a6811f4B8067F0DE7e47DfA938Aa30',
    AAVE_MERKLE_DISTRIBUTOR: '0xa88c6D90eAe942291325f9ae3c66f3563B93FE10',
    sDAI_POT: '0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7',
    stEUR: '0x004626A008B1aCdC4c74ab51644093b155e59A23',
    agEUR_EUR_AGGREGATOR: '0xb4d5289C58CE36080b0748B47F859D8F50dFAACb',
    EUR_USD_AGGREGATOR: '0xb49f677943BC038e9857d61E7d053CaA2C1734C1',
    weETH_RATIO_PROVIDER: '0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee',
  },
};

export const sepoliaAddresses: NetworkAddresses = {
  name: 'Sepolia',
  chainId: ChainId.sepolia,
  addresses: {
    TRANSPARENT_PROXY_FACTORY: '0x84B08568906ee891de1c23175E5B92d7Df7DDCc4',
    PROXY_ADMIN: '0x8dDa7a1E3e96EB13BE50bB59e80485227E3DE2e7',
    GHO_TOKEN: '0xc4bF5CbDaBE595361438F8c6a187bDc330539c60',
    GHO_FLASHMINTER_FACILITATOR: '0xB5d0ef1548D9C70d3E7a96cA67A2d7EbC5b1173E',
  },
};