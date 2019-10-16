<template>
  <div>
    <div class="overflow-forms">
      <SE-filters />
    </div>
    <div>
      <SE-show-hide :vuetable-fields="vuetableFields" />
      <add-extractor :cloneData="cloneData"/>
    </div>

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

    <extraction-status :results="results" :showModal="extractionStatusModal" />

    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/snapshot_extractors"
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
          <div slot="clone-extraction" slot-scope="props">
            <span @click="onCloneExtraction($event, props.rowData)"> <i class="fa fa-clone"></i> </span>
          </div>
          <div slot="delete-extraction" slot-scope="props">
            <span v-if='props.rowData.status != 2 && props.rowData.status != 12' @click="deleteExtraction($event, props.rowData)"> <i class="trash alternate outline icon"></i> </span>
          </div>
          <div slot="extraction-status" slot-scope="props">
            <span v-if='props.rowData.status != 2 && props.rowData.status != 12' @click="onActionClick($event, props.rowData)" class="fa fa-hourglass-start status-pointer"></span>
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
  margin-top: -2px;
}

.status-pointer {
  cursor: pointer;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import AddExtractor from "./add_extractor";
import SEFilters from "./se_filters";
import SEShowHide from "./se_show_hide";
import ExtractionStatus from "./extraction_status";

import axios from "axios";

export default {
  components: {
    AddExtractor, SEFilters, SEShowHide, ExtractionStatus
  },
  data: () => {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 100,
      sortOrder: [
        {
          field: 'id',
          direction: 'desc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      vendorData: {},
      ajaxWait: false,
      results: null,
      extractionStatusModal: false,
      cloneData: null,
      showCloneModal: false
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
    this.$events.$on('se-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('se-added', e => this.onSEAdded(e))
    this.$events.$on('se-cloned', e => this.onSECloned(e))
    this.$events.$on('close-extraction-status-modal', eventData => this.onCloseModal(eventData))
  },

  methods: {

    onSECloned(e) {
      this.cloneData =  null;
    },

    onSEAdded(e) {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
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
    },

    deleteExtraction(event, data) {
      if (window.confirm("Are you sure you want to delete this event?")) {
        axios({
          method: 'delete',
          url: `${this.$root.api_url}/v2/cameras/${data.exid}/apps/cloud-extractions`,
          data: {
            extraction_id: data.id, api_id: data.api_id, api_key: data.api_key
          }
        }).then(response => {
          if (response.status == 200) {
            this.showSuccessMsg({
              title: "Success",
              message: "Snapshot Extractor has been deleted!"
            })

            this.$events.fire('se-added', {})
          } else {
            this.showErrorMsg({
              title: "Error",
              message: "Something went wrong!"
            })
          }
        })
      }
    },

    onActionClick(e, extraction) {
      this.ajaxWait = true
      axios.get(`${this.$root.api_url}/v2/cameras/${extraction.exid}/apps/cloud-extractions`, {
        params: {
          api_key: extraction.api_key,
          api_id: extraction.api_id,
          extraction_id: extraction.id
        }
      }).then(response => {
        this.ajaxWait = false;
        if (Object.keys(response.data).length === 0) {
          this.showErrorMsg({
            title: "Error",
            message: "Something went wrong!"
          });
        } else {
          this.ajaxWait = false
          this.results = {results: response.data, name: extraction.camera}
          this.extractionStatusModal = true
        }
      })
    },

    onCloseModal(modal) {
      this.results = null
      this.extractionStatusModal = false
    },

    onCloneExtraction(e, data) {
      this.cloneData = data
    }
  }
}
</script>