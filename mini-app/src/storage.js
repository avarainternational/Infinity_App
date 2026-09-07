import { Capacitor } from '@capacitor/core';
import { Preferences } from '@capacitor/preferences';
const KEY = 'infinity_reward_shop_demo_v1';
export const isFlutter = () => Boolean(window.RewardShopHost);
let sequence = 0;
const pending = new Map();
window.rewardShopReply = ({ id, value, error }) => {
  const request = pending.get(id);
  if (!request) return;
  clearTimeout(request.timer); pending.delete(id);
  error ? request.reject(new Error(error)) : request.resolve(value);
};
function hostRequest(action, value) {
  return new Promise((resolve, reject) => {
    const id = String(++sequence);
    const timer = setTimeout(() => { pending.delete(id); reject(new Error('The app did not respond. Please reopen the shop.')); }, 8000);
    pending.set(id, { resolve, reject, timer });
    window.RewardShopHost.postMessage(JSON.stringify({ id, action, value }));
  });
}
export async function readState() {
  if (isFlutter()) return hostRequest('read');
  if (Capacitor.isNativePlatform()) return (await Preferences.get({ key: KEY })).value;
  return localStorage.getItem(KEY);
}
export async function writeState(state) {
  const value = JSON.stringify(state);
  if (isFlutter()) return hostRequest('write', value);
  if (Capacitor.isNativePlatform()) return Preferences.set({ key: KEY, value });
  localStorage.setItem(KEY, value);
}
