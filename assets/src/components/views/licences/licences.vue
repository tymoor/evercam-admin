<template>
  <div>
    <div class="overflow-forms">
      <v-li-filters />
    </div>
    <div>
      <v-li-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <v-horizontal-scroll />

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
          <div slot="delete-slot" slot-scope="props">
            <div v-if="props.rowData.id">
              <span @click="onDeleteLicences($event, props.rowData)" class="fa fa-trash delete_licences"></span>
            </div>
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

.delete_licences {
  cursor: pointer;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import LIFilters from "./li_filters";
import LIShowHide from "./li_show_hide";
import moment from "moment";
import axios from "axios";
import _ from "lodash";

export default {
  components: {
    "v-li-filters": LIFilters,
    "v-li-show-hide": LIShowHide
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

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.ajaxWait = true,
    axios.get("/v1/licences").then(response => {
      this.data = response.data.data;
      this.ajaxWait = false
      this.filtered = response.data.data;
    });
    this.$events.$on('li-filter-set', eventData => this.onFilterSet(eventData))
  },

  updated() {
    document.addEventListener("resize", this.setScrollBar());
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
    },

    onDeleteLicences(e, data) {
      console.log(data)
      if (window.confirm("Are you sure you want to delete this licence?")) {
        if (("id" in data)) {
          console.log("ye db wala hai")
          this.$http.delete(`/v1/licences`, {params: {licence_id: data.id}}).then(response => {
            this.$notify({
              group: "admins",
              title: "Info",
              type: "success",
              text: "Licence has been deleted.",
            });
            this.$router.go()
          }, error => {
            this.$notify({
              group: "admins",
              title: "Error",
              type: "error",
              text: "Something went wrong.",
            });
          });
        }
      }
    }
  }
}
</script>