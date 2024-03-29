<template>
  <div>
    <div class="overflow-forms">
      <snapmail-filters />
    </div>
    <div>
      <snapmail-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/snapmails"
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
        <div slot="checkbox-slot" slot-scope="props">
          <input type="checkbox" @click="onCheckBoxClick($event, props.rowData)" />
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
import SnapmailFilters from "./snapmail_filters"
import SnapmailShowHide from "./snapmail_show_hide"

export default {
  components: {
    SnapmailFilters, SnapmailShowHide
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
          field: 'inserted_at',
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
    this.$events.$on('snapmail-filter-set', eventData => this.onFilterSet(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "fullname": filters.fullname,
        "cameras": filters.cameras,
        "recipients": filters.recipients,
        "notify_time": filters.notify_time,
        "timezone": filters.timezone,
        "is_paused": filters.is_paused,
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