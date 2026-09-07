<script setup>
import { computed, nextTick, onMounted, ref } from 'vue';
import { ArrowUpRight, ArrowRight, Check, ChevronLeft, Gift, History, Leaf, RefreshCw, ShoppingBag, Sparkles, X } from 'lucide-vue-next';
import RewardArt from './RewardArt.vue';
import { freshState, parseState, redeem, rewards } from './shop';
import { readState, writeState } from './storage';
const state = ref(freshState());
const tab = ref('shop');
const category = ref('All rewards');
const selected = ref(null);
const receipt = ref(null);
const busy = ref(false);
const loading = ref(true);
const loadFailed = ref(false);
const error = ref('');
const resetOpen = ref(false);
const dialog = ref(null);
let returnFocus;
let requestId;
const categories = ['All rewards', 'Essentials', 'Vouchers', 'Bundles'];
const visibleRewards = computed(() => rewards.filter(r => category.value === 'All rewards' || r.category === category.value));
const number = value => value.toLocaleString();
const dateLabel = value => new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
const rewardFor = id => rewards.find(r => r.id === id);
function openDialog() {
  returnFocus = document.activeElement;
  nextTick(() => dialog.value?.showModal());
}
function choose(reward) {
  selected.value = reward; receipt.value = null; error.value = '';
  requestId = crypto.randomUUID(); openDialog();
}
function close() {
  if (busy.value) return;
  dialog.value?.close(); selected.value = null; receipt.value = null; resetOpen.value = false;
  nextTick(() => returnFocus?.focus());
}
async function confirm() {
  if (busy.value || !selected.value) return;
  busy.value = true; error.value = '';
  try {
    const updated = redeem(state.value, selected.value.id, requestId);
    await writeState(updated);
    state.value = updated; receipt.value = updated.history[0];
  } catch (e) { error.value = e.message || 'Could not save your reward. Try again.'; }
  finally { busy.value = false; }
}
async function reset() {
  if (busy.value) return;
  busy.value = true;
  try { const initial = freshState(); await writeState(initial); state.value = initial; loadFailed.value = false; error.value = ''; }
  catch { error.value = 'Could not reset the demo. Please try again.'; }
  finally { busy.value = false; close(); }
}
onMounted(async () => {
  try { state.value = parseState(await readState()); }
  catch (e) { loadFailed.value = true; error.value = e.message || 'Could not load saved rewards.'; }
  finally { loading.value = false; }
});
</script>

<template>
  <div class="app-shell">
    <header class="brand-bar"><a href="#" class="brand" @click.prevent="tab = 'shop'"><span class="brand-symbol">∞</span><span>INFINITY<small>WELLNESS</small></span></a><span class="prototype"><span></span> Demo experience</span></header>
    <main>
      <div class="eyebrow"><Leaf :size="14" /> GOOD HABITS. LITTLE REWARDS.</div>
      <div class="page-title"><div><h1>Reward Shop<span>.</span></h1><p>A little thank-you for showing up for yourself.</p></div><div class="title-icon"><Gift :size="30" :stroke-width="1.4" /></div></div>
      <section class="balance-card" aria-label="Demo points balance">
        <div><span class="balance-label">YOUR WELLNESS POINTS</span><div class="balance-number">{{ loading ? '…' : number(state.balance) }} <span>pts</span></div><p><span class="tiny-star">✦</span> Small steps. Well-earned perks.</p></div>
        <div class="balance-decoration" aria-hidden="true"><span>✳</span><span>✳</span></div>
        <div class="balance-footer"><span>Prototype balance · No real transactions</span><Sparkles :size="16" /></div>
      </section>
      <nav class="tabs" aria-label="Shop sections"><button :class="{ active: tab === 'shop' }" @click="tab = 'shop'"><ShoppingBag :size="17" /> Explore rewards</button><button :class="{ active: tab === 'history' }" @click="tab = 'history'"><History :size="17" /> My rewards <span v-if="state.history.length" class="count">{{ state.history.length }}</span></button></nav>
      <div v-if="error && !selected" class="error" role="alert">{{ error }}</div>
      <template v-if="tab === 'shop'">
        <section class="section-heading"><div><h2>Find your next little win</h2><p>Made for your everyday wellness routine.</p></div><span class="reward-count">{{ rewards.length }} rewards</span></section>
        <div class="filters" aria-label="Reward categories"><button v-for="item in categories" :key="item" :aria-pressed="category === item" :class="{ active: category === item }" @click="category = item">{{ item }}</button></div>
        <div class="reward-grid">
          <button v-for="reward in visibleRewards" :key="reward.id" class="reward-card" :disabled="loading || loadFailed" @click="choose(reward)">
            <div class="reward-image" :class="reward.kind"><span class="product-label">{{ reward.label }}</span><RewardArt :kind="reward.kind" /><span class="product-arrow"><ArrowUpRight :size="19" /></span></div>
            <div class="reward-info"><span class="category-label">{{ reward.category }}</span><h3>{{ reward.name }}</h3><div class="price-line"><strong><span>✦</span> {{ number(reward.cost) }} <small>pts</small></strong><span v-if="state.balance >= reward.cost" class="available">Within reach</span><span v-else class="shortfall">{{ number(reward.cost - state.balance) }} more pts</span></div></div>
          </button>
        </div>
        <div class="encouragement"><span class="leaf-circle"><Leaf :size="22" /></span><div><h3>Every good habit adds up.</h3><p>This is a demo shop. Rewards and deductions are simulated.</p></div></div>
      </template>
      <template v-else>
        <section class="section-heading"><div><h2>Your little wins</h2><p>All your demo redemptions, in one place.</p></div></section>
        <div v-if="!state.history.length" class="empty"><Gift :size="42" :stroke-width="1.3" /><h3>Your first reward is waiting</h3><p>Choose something you love and it will appear here.</p><button class="primary" @click="tab = 'shop'">Explore rewards <ArrowRight :size="17" /></button></div>
        <article v-for="item in state.history" :key="item.id" class="history-card"><div class="history-art"><RewardArt :kind="rewardFor(item.rewardId).kind" /></div><div><span class="category-label">{{ dateLabel(item.date) }}</span><h3>{{ rewardFor(item.rewardId).name }}</h3><p>Demo redemption · {{ item.id.slice(0, 8).toUpperCase() }}</p></div><strong>−{{ number(item.cost) }}<small>pts</small></strong></article>
      </template>
      <footer><span>Made for a little more well-being.</span><button :disabled="loading || busy" @click="resetOpen = true; openDialog()"><RefreshCw :size="13" /> Reset demo</button></footer>
    </main>
    <dialog ref="dialog" @cancel.prevent="close" @click="event => { if (event.target === dialog) close(); }">
      <div v-if="resetOpen" class="dialog-content"><button class="close" aria-label="Close" :disabled="busy" @click="close"><X /></button><span class="dialog-eyebrow">FRESH START</span><h2>Reset your demo?</h2><p>Your balance returns to 1,250 points and demo redemption history is cleared.</p><button class="primary" :disabled="busy" @click="reset">{{ busy ? 'Resetting…' : 'Reset demo' }}</button><button class="secondary" :disabled="busy" @click="close">Keep my rewards</button></div>
      <div v-else-if="selected" class="dialog-content">
        <button class="close" aria-label="Close reward details" :disabled="busy" @click="close"><X /></button>
        <template v-if="receipt"><span class="success-icon"><Check :size="32" /></span><span class="dialog-eyebrow">A LITTLE WIN, JUST FOR YOU</span><h2>Reward unlocked!</h2><p>{{ selected.name }} is now in My rewards.</p><div class="receipt"><div><span>Points deducted</span><strong>−{{ number(receipt.cost) }} pts</strong></div><div><span>Remaining balance</span><strong>{{ number(state.balance) }} pts</strong></div><div><span>Demo reference</span><strong>{{ receipt.id.slice(0, 8).toUpperCase() }}</strong></div></div><p class="demo-note">Demo only. No real reward or voucher has been issued.</p><button class="primary" @click="close(); tab = 'history'">View my rewards <ArrowRight :size="17" /></button><button class="secondary" @click="close">Keep exploring</button></template>
        <template v-else><div class="detail-art" :class="selected.kind"><RewardArt :kind="selected.kind" /></div><span class="dialog-eyebrow">{{ selected.category }}</span><h2>{{ selected.name }}</h2><p>{{ selected.description }}</p><p class="detail-spec">{{ selected.detail }}</p><div class="receipt"><div><span>Reward cost</span><strong>{{ number(selected.cost) }} pts</strong></div><div><span>Balance after redemption</span><strong>{{ state.balance >= selected.cost ? `${number(state.balance - selected.cost)} pts` : 'Not enough points' }}</strong></div></div><div v-if="error" class="error" role="alert">{{ error }}</div><button class="primary" :disabled="busy || state.balance < selected.cost" @click="confirm">{{ busy ? 'Saving your reward…' : state.balance < selected.cost ? `${number(selected.cost - state.balance)} more points needed` : `Redeem for ${number(selected.cost)} points` }}<ArrowRight v-if="!busy && state.balance >= selected.cost" :size="17" /></button><button class="secondary" :disabled="busy" @click="close"><ChevronLeft :size="15" /> Keep exploring</button><p class="demo-note">Uses demo points. No real wallet deduction.</p></template>
      </div>
    </dialog>
  </div>
</template>
