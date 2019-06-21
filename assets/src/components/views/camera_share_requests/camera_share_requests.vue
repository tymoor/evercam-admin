<template>
  <div>
    <div class="overflow-forms">
      <CSR-filters :selectedCSR="selectedCSR"/>
    </div>
    <div>
      <CSR-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/camera_share_requests"
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
        <div slot="slot" slot-scope="props">
          <input :value="props.rowData.id" type="checkbox" v-model="selectedCSR" />
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
  width: 85%;
}

#table-wrapper {
  margin-top: 1px;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import CSRFilters from "./csr_filters";
import CSRShowHide from "./csr_show_hide";

export default {
  components: {
    CSRFilters, CSRShowHide
  },
  data: () => {
    return {
      selectedCSR: [],
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
      fields: FieldsDef
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

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.$events.$on('csr-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('csr-deleted', e => this.onCSRDelete(e))
  },

  methods: {

    onCSRDelete (e) {
      this.selectedCSR = []
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onFilterSet (filters) {
      this.moreParams = {
        "sharer": filters.sharer,
        "camera": filters.camera,
        "sharee_email": filters.sharee_email,
        "rights": filters.rights,
        "status": filters.status
      }
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