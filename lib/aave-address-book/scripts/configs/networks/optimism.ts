import {Hex} from 'viem';
import {ChainId} from '@bgd-labs/rpc-env';
import {NetworkAddresses} from '../types';

export const optimismAddresses: NetworkAddresses<{
  wstETH_stETH_AGGREGATOR: Hex;
  rETH_ETH_AGGREGATOR: Hex;
  LEGACY_BRIDGE_EXECUTOR: Hex;
  AAVE_OPT_ETH_BRIDGE: Hex;
}> = {
  name: 'Optimism',
  chainId: ChainId.optimism,
  addresses: {
    PARASWAP_FEE_CLAIMER: '0x9abf798f5314BFd793A9E57A654BEd35af4A1D60',
    TRANSPARENT_PROXY_FACTORY: '0x984b710d22730f799312513a10c1382e9d1fa689',
    PROXY_ADMIN: '0xD3cF979e676265e4f6379749DECe4708B9A22476',
    CREATE_3_FACTORY: '0x3b56998Ec06477704622ca8e2eA1b4db134cec32',
    AAVE_CL_ROBOT_OPERATOR: '0x55Cf9583D7D30DC4936bAee1f747591dBECe5df7',
    PROTOCOL_GUARDIAN: '0x56C1a4b54921DEA9A344967a8693C7E661D72968',
    AAVE_MERKLE_DISTRIBUTOR: '0x1685D81212580DD4cDA287616C2f6F4794927e18',
    wstETH_stETH_AGGREGATOR: '0xe59EBa0D492cA53C6f46015EEa00517F2707dc77',
    rETH_ETH_AGGREGATOR: '0x22F3727be377781d1579B7C9222382b21c9d1a8f',
    LEGACY_BRIDGE_EXECUTOR: '0x7d9103572bE58FfE99dc390E8246f02dcAe6f611',
    AAVE_OPT_ETH_BRIDGE: '0xc3250A20F8a7BbDd23adE87737EE46A45Fe5543E',
  },
};

export const optimismSepoliaAddresses: NetworkAddresses = {
  name: 'OptimismSepolia',
  chainId: ChainId.optimism_sepolia,
  addresses: {
    GHO_TOKEN: '0xb13Cfa6f8B2Eed2C37fB00fF0c1A59807C585810',
    TRANSPARENT_PROXY_FACTORY: '0x5f4d15d761528c57a5C30c43c1DAb26Fc5452731',
    PROXY_ADMIN: '0xe892E40C92c2E4D281Be59b2E6300F271d824E75',
  },
};