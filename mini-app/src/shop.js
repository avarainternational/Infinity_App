export const INITIAL_BALANCE = 1250;
export const rewards = [
  { id: 'bottle', name: 'Everyday water bottle', category: 'Essentials', cost: 500, kind: 'bottle', label: 'FAN FAVORITE', description: 'Your daily hydration companion. A reusable 600 ml bottle with a fresh mint finish.', detail: '600 ml · Reusable · Mint' },
  { id: 'voucher', name: 'A little refreshment', category: 'Vouchers', cost: 250, kind: 'voucher', label: 'LITTLE WIN', description: 'Take a well-earned break with a demo refreshment voucher at an Infinity partner café.', detail: 'One drink · Partner café' },
  { id: 'tote', name: 'Good habits tote', category: 'Essentials', cost: 750, kind: 'tote', label: 'EVERYDAY FAVORITE', description: 'A lightweight cotton tote for your everyday essentials, from study sessions to weekend walks.', detail: 'Natural cotton · Everyday carry' },
  { id: 'kit', name: 'The wellness starter kit', category: 'Bundles', cost: 1500, kind: 'kit', label: 'SOMETHING SPECIAL', description: 'A bottle and a tote, paired for a fresh start. Keep building your habits to unlock this bundle.', detail: 'Bottle + tote · Gift set' },
];
export const freshState = () => ({ version: 1, balance: INITIAL_BALANCE, history: [] });
export function parseState(raw) {
  if (!raw) return freshState();
  const state = JSON.parse(raw);
  if (state.version !== 1 || !Number.isSafeInteger(state.balance) || state.balance < 0 || !Array.isArray(state.history)) throw new Error('Saved demo data is invalid. Reset the demo to start again.');
  const ids = new Set();
  let spent = 0;
  for (const item of state.history) {
    const reward = rewards.find(r => r.id === item.rewardId);
    if (!reward || item.cost !== reward.cost || typeof item.id !== 'string' || ids.has(item.id) || !Number.isFinite(Date.parse(item.date))) throw new Error('Saved demo history is invalid. Reset the demo to start again.');
    ids.add(item.id); spent += item.cost;
  }
  if (state.balance !== INITIAL_BALANCE - spent) throw new Error('Saved demo balance is invalid. Reset the demo to start again.');
  return state;
}
export function redeem(state, rewardId, requestId, date = new Date().toISOString()) {
  if (state.history.some(item => item.id === requestId)) return state;
  const reward = rewards.find(item => item.id === rewardId);
  if (!reward) throw new Error('This reward is unavailable.');
  if (state.balance < reward.cost) throw new Error('You need more points for this reward.');
  return { ...state, balance: state.balance - reward.cost, history: [{ id: requestId, rewardId, cost: reward.cost, date }, ...state.history] };
}
