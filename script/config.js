const fetcher = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
globalThis.fetch = fetcher;
const { Actor, HttpAgent } =require("@dfinity/agent");
const fs = require("fs");
const path = require("path");

const { networks } = require("../dfx.json");

const getHost =  (env) => {
  return env === "local" ? `http://${networks.local.bind}` : "https://ic0.app";
};

const getActor = (canisterName, env, host) => {
  const candid = eval(getCandid(canisterName));
  const canisterId = getCanisterId(canisterName, env);
  const agent = new HttpAgent( {host});
  agent.fetchRootKey().catch(err=>{
    console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
    console.error(err);
  });
  return Actor.createActor(idlFactory, {agent,canisterId})
};

const getCanisterPath = (canisterName) => path.join(__dirname, '..', 'src', 'declarations', canisterName);

const getCandid = (canisterName) =>
  fs
    .readFileSync(`${getCanisterPath(canisterName)}/${canisterName}.did.js`)
    .toString()
    .replace("export default ", "")
    .replace("export const ", "")
    .replace("export const ", "");

const getCanisterId = (canisterName, env) => {
  if (process.env.DFX_NETWORK === 'ic' || (env && env !== "local")) {
    const CanisterIds = require("../canister_ids.json");
    return CanisterIds[canisterName][env]
  } else {
    const CanisterIds = require("../.dfx/local/canister_ids.json");
    return CanisterIds[canisterName][env]
  }
};

module.exports = { getActor, getHost }