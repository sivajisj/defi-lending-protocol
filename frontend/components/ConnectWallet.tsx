"use client";

import { useAccount, useConnect, useDisconnect } from "wagmi";

export default function ConnectWallet() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();

  if (isConnected)
    return (
      <button
        onClick={() => disconnect()}
        className="bg-red-500 px-4 py-2 rounded"
      >
        {address?.slice(0, 6)}... Disconnect
      </button>
    );

  return (
    <button
      onClick={() => connect({ connector: connectors[0] })}
      className="bg-blue-500 px-4 py-2 rounded cursor-pointer"
    >
      Connect Wallet
    </button>
  );
}