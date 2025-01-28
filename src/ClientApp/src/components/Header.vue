<script setup>
import { ref } from "vue";

const purchaseDate = ref(new Date().toLocaleDateString());
const totalAmount = ref("$123.45");
const shopName = ref("Global eCommerce Store");
</script>

<template>
  <header class="header">
    <h1>{{ shopName }}</h1>
    <div class="header-info">
      <span>Date of Purchase: {{ purchaseDate }}</span>
      <span>Total Amount: {{ totalAmount }}</span>
    </div>
  </header>
</template>

<style scoped>
.header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
  animation: fadeIn 1s ease-in-out;
}

h1 {
  font-family: var(--font-secondary), sans-serif;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
}

.header-info {
  display: flex;
  gap: 1.5rem;
  font-size: 1rem;
  color: var(--text-muted);
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
