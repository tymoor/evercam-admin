<template>
  <div>
    <div class="overflow-forms">
      <v-ic-filters />
    </div>
    <div>
      <v-ic-show-hide :vuetable-fields="vuetableFields" />
      <add-ic />
      <v-update-company :showUpdateCompany="showUpdateCompany" :companyData="companyData" />
    </div>

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/intercom_companies"
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
          <div slot="company-actions" slot-scope="props">
            <i class="edit icon pointer-cursor" @click="editCompanyName($event, props.rowData)"></i>&nbsp;&nbsp;<i class="trash icon pointer-cursor" @click="deleteCompany($event, props.rowData)"></i>
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
  margin-top: -2px;
}

.ui.compact.icon.button {
  padding: 5px;
  cursor: pointer;
}

.pointer-cursor {
  cursor: pointer;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import AddIC from "./add_ic";
import ICFilters from "./ic_filters";
import ICShowHide from "./ic_show_hide";
import moment from "moment";
import axios from "axios";
import _ from "lodash";
import UpdateCompany from "./update_company";

export default {
  components: {
    "add-ic": AddIC,
    "v-ic-filters": ICFilters,
    "v-ic-show-hide": ICShowHide,
    "v-update-company": UpdateCompany
  },
  data: () => {
    return {
      loading: "",
      perPage: 100,
      sortOrder: [
        {
          field: 'inserted_at',
          direction: 'desc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      vuetableFields: false,
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      showUpdateCompany: false,
      companyData: {},
      moreParams: {},
      ajaxWait: false,
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
    }
  },

  mounted() {
    this.$events.$on('ic-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('ic-added', e => this.onICAdded())
    this.$events.$on('hide-update-company', e => this.onHideUpdateComapny(e))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onHideUpdateComapny(e) {
      this.$nextTick( () => this.$refs.vuetable.refresh())
      this.showUpdateCompany = false,
      this.companyData = null;
    },

    editCompanyName(e, data) {
      this.showUpdateCompany = true,
      this.companyData = data;
    },

    deleteCompany(e, data) {
      if (window.confirm("Are you sure to delete this company?")) {
        this.ajaxWait = true
        this.$http.delete(`/v1/intercom_companies`, {params: {company_exid: data.exid}}).then(response => {
          this.$nextTick( () => this.$refs.vuetable.refresh())
          this.showSuccessMsg({
            title: "Success",
            message: "Company has been deleted."
          });
          this.ajaxWait = false
        }, error => {
          this.showErrorMsg({
            title: "Error",
            message: "Something went wrong."
          });
          this.ajaxWait = false
        });
      }
    },

    onICAdded () {
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
    }
  }
}
</script>