import { createConfig, http } from "wagmi";
import { sepolia } from "wagmi/chains";

export const config = createConfig({
  chains: [sepolia],
  transports: {
    [sepolia.id]: http(
      "https://eth-sepolia.g.alchemy.com/v2/WH4VCblvDcg5UVZD1e1hm3iSLuzKLey0"
    ),
  },
});