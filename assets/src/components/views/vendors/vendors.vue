<template>
  <div>
    <div class="overflow-forms">
      <v-vendor-filters />
    </div>
    <div>
      <v-vendor-show-hide :vuetable-fields="vuetableFields" />
      <add-vendor :vendorData="vendorData" />
    </div>

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/vendors"
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
          <div slot="custom-actions" slot-scope="props">
            <span class="pointer-set" @click="onActionClicked('edit-item', props.rowData)" data-toggle="modal" data-target="#addModel">
              <i class="edit icon"></i>
            </span>
            <span class="pointer-set" @click="onActionClicked('delete-item', props.rowData)">
              <i class="trash alternate outline icon"></i>
            </span>
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
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import AddVendor from "./add_vendor";

export default {
  components: {
    AddVendor
  },
  data: () => {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'name',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      vendorData: {}
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
    this.$events.$on('vendor-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('vendor-added', e => this.onVendorAdded())
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onVendorAdded () {
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

    onActionClicked(action, data) {
      if (action == "delete-item") {
        if (window.confirm("Are you sure you want to delete this vendor?")) {
          this.$http.delete(`/v1/vendors/${data.exid}`).then(response => {
            this.$notify({
              group: "admins",
              title: "Info",
              type: "success",
              text: "Vendor has been deleted.",
            });
          }, error => {
            this.$notify({
              group: "admins",
              title: "Error",
              type: "error",
              text: "Something went wrong.",
            });
          });
          this.$nextTick( () => this.$refs.vuetable.refresh())
        } 
      }

      if (action == "edit-item") {
        this.vendorData = data
      }
    },
  }
}
</script>