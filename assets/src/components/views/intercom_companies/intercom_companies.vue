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
      perPage: 60,
      css: TableWrapper,
      moreParams: {},
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      data: [],
      filtered: [],
      showUpdateCompany: false,
      companyData: {},
      ajaxWait: true,
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
    this.ajaxWait = true,
    axios.get("/v1/intercom_companies").then(response => {
      this.data = response.data.data;
      this.ajaxWait = false
      this.filtered = response.data.data;
    });
    this.$events.$on('ic-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('ic-added', e => this.onICAdded())
    this.$events.$on('hide-update-company', e => this.onHideUpdateComapny(e))
  },

  methods: {
    onFilterSet (filter) {
      this.filtered = this.data.filter(d => {
        for (let name in d) {
          if ((d[name] + '').toLowerCase().indexOf(filter.search.toLowerCase()) > -1){
            return d;
          }
        }
      })
    },

    updateCompanyName (company_id, newCompanyName) {
      let newData = this.data;
      let filteredData = this.filtered;
      for (var i = 0; i < newData.length; i++) {
        if (newData[i].company_id === company_id) {
          newData[i].name = newCompanyName;
        }
      }

      for (var i = 0; i < filteredData.length; i++) {
        if (filteredData[i].company_id === company_id) {
          filteredData[i].name = newCompanyName;
        }
      }
      this.data = newData
      this.filtered = filteredData
    },

    onHideUpdateComapny(e) {
      if (e != null) {
        this.updateCompanyName(e.company_id, e.company_name)
      }
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
        this.$http.delete(`/v1/intercom_companies`, {params: {id: data.id, company_id: data.company_id}}).then(response => {
          this.showSuccessMsg({
            title: "Success",
            message: "Company has been deleted."
          });
          this.removeDeletedCompany(data.id)
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

    removeDeletedCompany(id) {
      let newData = this.data
      let filteredData = this.filtered
      for (var i = 0; i < newData.length; i++) {
        if (newData[i].id === id) {
          newData.splice(i, 1)
        }
      }

      for (var i = 0; i < filteredData.length; i++) {
        if (filteredData[i].id === id) {
          filteredData.splice(i, 1)
        }
      }
      this.data = newData
      this.filtered = filteredData
    },

    onICAdded () {
      this.$nextTick( () => this.$refs.vuetable.refresh())
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
    }
  }
}
</script>