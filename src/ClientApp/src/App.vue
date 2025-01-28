<script setup>
import Header from "./components/Header.vue";
import DetailInfo from "./components/DetailInfo.vue";
import Footer from "./components/Footer.vue";
</script>

<template>
  <div>
    <Header />
    <DetailInfo />
    <Footer />
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
