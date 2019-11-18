<template>
  <tr v-if="visible" class="vuetable-row-filter">
    <template v-for="(field, fieldIndex) in tableFields">
      <template v-if="isFilterSelect(field)">
        <th :key="fieldIndex"
          :style="{width: field.width}"
        >
          <select class="form-control is-required" autocomplete="off" v-model="field.filter" @change="setFilter(field)">
            <option v-for="option in field.selectOptions" v-bind:value="option.value" :selected="option.selected === true">
              {{ option.name }}
            </option>
          </select>
        </th>
      </template>
      <template v-else-if="isFilterText(field)">
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
    isFilterText: field => field.visible && field.filterable && field.filterType == "text",
    isFilterSelect: field => field.visible && field.filterable && field.filterType == "select",

    setFilter(field) {

      this.tableFields
        .filter(field => this.isFilterable(field))
        .map(field =>
          this.filters.push({ key: field.filterName, value: field.filter })
        );
      let that = this;
      this.fireFilter(that);
    },

    fireFilter: _.debounce((self) => {
      self.$emit(self.vuetable.eventPrefix + "header-event", "filter", self.filters)
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
