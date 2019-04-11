<template>
  <div>
    <div class="overflow-forms">
      <v-cr-filters />
    </div>
    <div>
      <v-cr-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <cr-edit-modal :showCRModal="showCRModal" :crSettings="crSettings"/>
  
    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/cloud_recordings"
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
          <div slot="cr-edit-slot" slot-scope="props">
            <span @click="onEditClick($event, props.rowData)" class="fa fa-edit email-template"></span>
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
  margin-top: 1px;
}

.email-template {
  cursor: pointer;
}

</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import CRModal from "./cr_edit";

export default {
  components: {
    "cr-edit-modal": CRModal
  },
  data: () => {
    return {
      selectedCameras: [],
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 100,
      sortOrder: [
        {
          field: 'firstname',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      crSettings: {},
      showCRModal: false
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
    this.$events.$on('cr-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('close-cr-modal', eventData => this.onCloseCRModal(eventData))
    this.$events.$on('refresh-cr-table', eventData => this.onRefreshCRTable(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "camera_name": filters.camera_name,
        "owner": filters.owner,
        "status": filters.status,
        "storage_duration": filters.storage_duration,
        "interval": filters.interval
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onRefreshCRTable() {
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

    onEditClick(e, data) {
      this.crSettings = data;
      this.showCRModal = true;
    },

    onCloseCRModal(modal) {
      this.crSettings = {};
      this.showCRModal = modal;
    }
  }
}
</script>