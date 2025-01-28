<script setup>
import { ref, onMounted } from "vue";
import Header from "./components/Header.vue";
import DetailInfo from "./components/DetailInfo.vue";
import Footer from "./components/Footer.vue";

const receipt = ref(null);

onMounted(async () => {
  try {
    const segments = window.location.pathname
      .split("/receipt/")
      .filter(Boolean);
    const receiptId = segments.pop();

    if (!receiptId) {
      console.error("Invalid receipt ID:", receiptId);
      return;
    }

    const response = await fetch(
      `http://localhost:7275/api/receipts/${receiptId}`
    );
    if (!response.ok) {
      console.error("Failed to fetch receipt data:", response.statusText);
      return;
    }
    receipt.value = await response.json();
  } catch (error) {
    console.error("Error fetching receipt data:", error);
  }
});
</script>

<template>
  <div v-if="receipt">
    <Header
      :shopName="receipt.shopName"
      :purchaseDate="new Date().toLocaleDateString()"
      :totalAmount="receipt.total"
    />
    <DetailInfo :items="receipt.items" />
    <Footer
      vatNumber="DE123456789"
      address="Teststr. 123, 12345 Berlin"
      contactEmail="info@test.shop"
    />
  </div>
  <div v-else>
    <p>Loading receipt data...</p>
  </div>
</template>

<style scoped>
#app {
  display: flex;
  flex-direction: column;
  align-items: center;
  animation: fadeIn 1s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
</style>
