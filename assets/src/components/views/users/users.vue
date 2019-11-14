<template>
  <div>
    <div class="overflow-forms">
      <user-filters-new :selectedUsers="selectedUsers" />
    </div>
    <div>
      <user-show-hide :vuetable-fields="vuetableFields" />
      <div class="advance-filters">
        <button class="btn btn-secondary mb-1" type="button" @click="toggleAdvanceFilters()">
          <i class="fa fa-filter"></i>
          Advanced
        </button>
      </div>
    </div>

    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/users"
          :fields="fields"
          pagination-path=""
          data-path="data"
          :per-page="perPage"
          :sort-order="sortOrder"
          :append-params="moreParams"
          @vuetable:pagination-data="onPaginationData"
          @vuetable:initialized="onInitialized"
          @vuetable:loading="showLoader"
          @vuetable:loaded="hideLoader"
          :css="css.table"
        >

          <template slot="tableHeader">
            <vuetable-row-header></vuetable-row-header>
            <row-filter
              :visible="filterRowVisible"
              @vuetable:header-event="onRowHeaderEvent"
            ></row-filter>
          </template>

          <div slot="checkbox-slot" slot-scope="props">
            <input type="checkbox" :value="props.rowData" v-model="selectedUsers" />
          </div>
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div class="field perPage-margin">
          <label>Per Page:</label>
          <select class="ui simple dropdown" v-model="perPage">
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
}

#table-wrapper {
  margin-top: 3px;
}

.advance-filters {
  float: right;
  margin-top: -26px;
  margin-right: 7px;
  position: relative;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import UserFiltersNew from "./user_filters_new";
import UserShowHide from "./users_show_hide";

import RowFilter from "./RowFilter.vue";
import RowEventHandler from "./RowEventHandler.js";
import VuetableRowHeader from "vuetable-2/src/components/VuetableRowHeader.vue";

export default {
  components: {
    UserFiltersNew, UserShowHide, RowFilter, VuetableRowHeader
  },
  data: () => {
    return {
      selectedUsers: [],
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 100,
      sortOrder: [
        {
          field: 'created_at',
          direction: 'desc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      showAdvanceFilters: false,
      filterRowVisible: true
    }
  },
  watch: {
    perPage(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.refresh();
      });
    },

    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(
          this.$refs.vuetable.tablePagination
        );
      });
    },

    showAdvanceFilters() {
      this.$events.fire('show-advance-filters', this.showAdvanceFilters)
    }
  },

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.$events.$on('user-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('user-filter-reset', e => this.onFilterReset())
    this.$events.$on('user-modify-refresh', e => this.onUserModifyRefresh())
  },

  methods: {

    toggleAdvanceFilters () {
      this.showAdvanceFilters = !this.showAdvanceFilters
    },

    onFilterSet (filters) {
      this.moreParams = {
        "company_name": filters.company_name,
        "fullname": filters.fullname,
        "email": filters.email,
        "payment_method": filters.payment_method,
        "last_login_at_boolean": filters.last_login_at_boolean,
        "last_login_at_date": filters.last_login_at_date,
        "created_at_date": filters.created_at_date,
        "total_cameras": filters.total_cameras,
        "include_erc": filters.include_erc,
        "cameras_owned": filters.cameras_owned,
        "camera_shares": filters.camera_shares,
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onUserModifyRefresh () {
      this.selectedUsers = []
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onFilterReset () {
      this.moreParams = {}
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onPaginationData(tablePagination) {
      this.$refs.paginationInfo.setPaginationData(tablePagination);
      this.$refs.pagination.setPaginationData(tablePagination);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
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

    onRowHeaderEvent(type, payload) {
      console.log("onRowHeaderEvent:", type, payload);
      let newObj = payload.reduce(function(acc, curr) {

        acc[curr.key] = curr.value;
        return acc;
      }, {})

      this.moreParams = newObj;
      console.log(this.moreParams);

      this.$nextTick( () => this.$refs.vuetable.refresh())
    }
  }
}
</script>