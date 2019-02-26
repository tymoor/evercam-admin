<template>
  <div>
    <div class="overflow-forms">
      <v-snapmail-history-filters />
    </div>
    <div>
      <v-snapmail-history-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          :api-mode="false"
          :fields="fields"
          pagination-path="pagination"
          :per-page="perPage"
          :data-manager="dataManager"
          @vuetable:pagination-data="onPaginationData"
          @vuetable:initialized="onInitialized"
          @vuetable:loading="showLoader"
          @vuetable:loaded="hideLoader"
          :css="css.table"
        >
        <div slot="template-slot" slot-scope="props">
          <a @click="onTemplateClick($event, props.rowData)" href="#"> Template </a>
        </div>
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div class="field perPage-margin">
          <label>Per Page:</label>
          <select class="ui simple dropdown" v-model="perPage">
            <option :value="60">60</option>
            <option :value="100">100</option>
            <option :value="500">500</option>
            <option :value="1000">1000</option>
          </select>
        </div>
        <vuetable-pagination-info ref="paginationInfo"
        ></vuetable-pagination-info>
        <component :is="paginationComponent" ref="pagination"
          @vuetable-pagination:change-page="onChangePage"
        ></component>
      </div>
    </div>
</div>
</template>

<style scoped>
.perPage-margin {
  margin-top: 5px;
}

.overflow-forms {
  overflow: hidden;
  width: 85%;
}

#table-wrapper {
  margin-top: 1px;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";

import moment from "moment";
import axios from "axios";
import _ from "lodash";

export default {
  data: () => {
    return {
      loading: "",
      perPage: 60,
      css: TableWrapper,
      moreParams: {},
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      data: [],
      filtered: [],
      fromDate: moment().subtract(7, "days").format("YYYY/MM/DD"),
      toDate: moment().format("YYYY/MM/DD")
    }
  },
  watch: {
    data(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.data);
      });
    },
    filtered(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.filtered);
      });
    },
    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(paginationData);
      });
    }
  },

  mounted() {
    axios.get("/v1/snapmail_history", {
      params: {
        fromDate: this.fromDate,
        toDate: this.toDate
      }
    }).then(response => {
      this.data = response.data.data;
      this.filtered = response.data.data;
    });
    this.$events.$on('snapmail-history-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('snapmail-history-date-filter-set', eventData => this.onDateFilter(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.filtered = this.data.filter(d => {
        for (let name in d) {
          if (d[name].toLowerCase().indexOf(filters.search.toLowerCase()) > -1) {
            return d;
          }
        }
      })
    },

    onDateFilter(filters) {
      axios.get("/v1/snapmail_history", {
        params: {
          fromDate: filters.fromDate,
          toDate: filters.toDate
        }
      }).then(response => {
        this.data = response.data.data;
        console.log(this.data)
      });
    },

    onPaginationData(paginationData) {
      this.$refs.pagination.setPaginationData(paginationData);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
    },

    dataManager(sortOrder, pagination) {
      if (this.data.length < 1) return;

      let local = this.data;

      // sortOrder can be empty, so we have to check for that as well
      if (sortOrder.length > 0) {
        console.log("orderBy:", sortOrder[0].sortField, sortOrder[0].direction);
        local = _.orderBy(
          local,
          sortOrder[0].sortField,
          sortOrder[0].direction
        );
      }

      pagination = this.$refs.vuetable.makePagination(
        local.length,
        this.perPage
      );
      console.log('pagination:', pagination)
      let from = pagination.from - 1;
      let to = from + this.perPage;

      return {
        pagination: pagination,
        data: _.slice(local, from, to)
      };
    },

    onInitialized(fields) {
      this.vuetableFields = fields.filter(field => field.togglable);
    },

    showLoader() {
      this.loading = "loading";
    },

    hideLoader() {
      this.loading = "";
    },

    onTemplateClick(e, data) {
      console.log(data)
    }
  }
}
</script>