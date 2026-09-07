<script setup>
defineProps({ kind: String });
</script>
<template>
  <div class="art" :class="kind" aria-hidden="true">
    <div v-if="kind === 'bottle' || kind === 'kit'" class="bottle-object"><div class="cap"></div><div class="bottle-body"><span class="bottle-logo">∞</span><span class="bottle-word">INFINITY<br>WELLNESS</span><span class="waterline"></span></div></div>
    <div v-if="kind === 'tote' || kind === 'kit'" class="tote-object"><div class="handles"></div><div class="tote-body"><span>good<br>habits.</span><small>INFINITY WELLNESS</small></div></div>
    <div v-if="kind === 'voucher'" class="voucher-object"><span>your next</span><strong>fresh start.</strong><div class="voucher-line"></div><small>INFINITY CAFÉ</small><span class="voucher-star">✳</span></div>
  </div>
</template>
