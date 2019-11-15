<template>
  <tr v-if="visible" class="vuetable-row-filter">
    <template v-for="(field, fieldIndex) in tableFields">
      <template v-if="isFilterable(field)">
        <th :key="fieldIndex"
          :style="{width: field.width}"
        >
          <div class="ui fluid input">
            <input type="text" v-model="field.filter" placeholder="search..."
              @keyup="setFilter(field)"
            >
          </div>
        </th>
      </template>
      <template v-else-if="!field.visible"></template>
      <template v-else>
        <th :key="fieldIndex"></th>
      </template>
    </template>
    <vuetable-col-gutter v-if="vuetable.scrollVisible"/>
  </tr>
</template>

<script>
import VuetableColGutter from "vuetable-2/src/components/VuetableColGutter";
import _ from "lodash";

export default {
  components: {
    VuetableColGutter
  },

  data: () => {
    return {
      filters: []
    }
  },

  props: {
    visible: {
      type: Boolean,
      default: true
    }
  },

  computed: {
    vuetable() {
      return this.$parent;
    },
    tableFields() {
      return this.vuetable.tableFields;
    }
  },

  mounted() {
    this.tableFields
      .filter(field => this.isFilterable(field))
      .map(field => (field.filter = ""));
  },

  methods: {
    isFilterable: field => field.visible && field.filterable,

    setFilter(field) {

      this.tableFields
        .filter(field => this.isFilterable(field) && field.filter !== "")
        .map(field =>
          this.filters.push({ key: field.sortField, value: field.filter })
        );
      let that = this;
      this.fireFilter(that);
    },

    fireFilter: _.debounce((self) => {
      self.$emit(self.vuetable.eventPrefix + "header-event", "filter", self.filters);
    }, 500),
  }
};
</script>

<style>
table.vuetable tr.vuetable-row-filter th {
  padding: 0px;
}
table.vuetable tr.vuetable-row-filter input {
  border: 0px;
  border-radius: 0px;
}
</style>
