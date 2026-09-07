import test from 'node:test';
import assert from 'node:assert/strict';
import { freshState, parseState, redeem } from '../src/shop.js';
test('redemption deducts the catalog cost and survives storage round-trip', () => {
  const state = redeem(freshState(), 'bottle', 'one');
  assert.equal(state.balance, 750);
  assert.equal(state.history[0].cost, 500);
  assert.deepEqual(parseState(JSON.stringify(state)), state);
});
test('repeated request is idempotent', () => {
  const state = redeem(freshState(), 'bottle', 'one');
  assert.equal(redeem(state, 'bottle', 'one'), state);
});
test('rejects insufficient funds and unknown rewards without mutating state', () => {
  const state = freshState();
  assert.throws(() => redeem(state, 'kit', 'one'), /more points/);
  assert.throws(() => redeem(state, 'missing', 'two'), /unavailable/);
  assert.equal(state.balance, 1250);
  assert.equal(state.history.length, 0);
});
test('can spend exact balance, then refuses further redemptions', () => {
  const state = redeem(redeem(freshState(), 'bottle', 'one'), 'tote', 'two');
  assert.equal(state.balance, 0);
  assert.throws(() => redeem(state, 'voucher', 'three'), /more points/);
});
test('rejects corrupt or inconsistent persisted state', () => {
  assert.throws(() => parseState('{'));
  assert.throws(() => parseState(JSON.stringify({version: 1, balance: -1, history: []})));
  assert.throws(() => parseState(JSON.stringify({version: 1, balance: 900, history: []})));
  assert.deepEqual(parseState(null), freshState());
});
