<script setup>
import { defineProps } from "vue";

const props = defineProps({
  items: {
    type: Array,
    default: () => [],
  },
});
</script>

<template>
  <section class="detail-info">
    <h2>Purchase Details</h2>
    <table>
      <thead>
        <tr>
          <th>Product</th>
          <th>Quantity</th>
          <th>Unit Price</th>
          <th>Total Price</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in items" :key="index">
          <td data-label="Product">{{ item.productName }}</td>
          <td data-label="Quantity">{{ item.quantity }}</td>
          <td data-label="Unit Price">${{ Number(item.price).toFixed(2) }}</td>
          <td data-label="Total Price">${{ Number(item.total).toFixed(2) }}</td>
        </tr>
      </tbody>
    </table>
  </section>
</template>

<style scoped>
.detail-info {
  width: 100%;
  margin-bottom: 2rem;
}

h2 {
  font-family: var(--font-secondary), sans-serif;
  color: var(--secondary-color);
  margin-bottom: 1rem;
  text-align: center;
}

table {
  width: 100%;
  border-collapse: collapse;
  background-color: var(--background-soft);
  border-radius: 8px;
  overflow: hidden;
}

th,
td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}

th {
  background-color: var(--secondary-color);
  color: var(--background-soft);
  font-family: var(--font-secondary), sans-serif;
}

tr:hover {
  background-color: rgba(107, 91, 149, 0.05);
}

/* Responsive Table for small screens */
@media (max-width: 600px) {
  table,
  thead,
  tbody,
  th,
  td,
  tr {
    display: block;
    background-color: rgba(107, 91, 149, 0.05);
  }

  tr {
    margin-bottom: 1rem;
  }

  td {
    padding-left: 50%;
    position: relative;
    text-align: right;
  }

  td::before {
    content: attr(data-label);
    position: absolute;
    left: 1rem;
    width: 45%;
    padding-right: 1rem;
    font-weight: bold;
    text-align: left;
    color: var(--text-muted);
  }
}
</style>
