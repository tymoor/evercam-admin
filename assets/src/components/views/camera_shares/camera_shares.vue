<template>
  <div>
    <div class="overflow-forms">
      <camera-share-filters />
    </div>
    <div>
      <camera-share-show-hide :vuetable-fields="vuetableFields" />
    </div>
    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/camera_shares"
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
          <div slot="delete-share-slot" slot-scope="props">
            <span class="pointer-set" @click="onShareDelete(props.rowData)">
              <i class="trash alternate outline icon"></i>
            </span>
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
  margin-top: -5px;
}
</style>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import CameraShareFilters from "./camera_share_filters";
import CameraShareShowHide from "./camera_shares_show_hide";
import axios from "axios";

export default {
  components: {
    CameraShareFilters, CameraShareShowHide
  },
  data: () => {
    return {
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

  mounted() {
    this.$events.$on('camera-shares-filter-set', eventData => this.onFilterSet(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "camera_exid": filters.camera_exid,
        "sharer_fullname": filters.sharer_fullname,
        "sharee_fullname": filters.sharee_fullname,
        "sharee_email": filters.sharee_email
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

    onShareDelete(data) {
      if (window.confirm("Are you sure you want to delete this share?")) {
        if (data.exid === "Deleted") {

          axios({
            method: 'delete',
            url: `/v1/camera_shares/${data.share_id}`,
            data: {
            }
          }).then(response => {
            if (response.status == 200) {
              this.showSuccessMsg({
                title: "Success",
                message: "Camera Share has been deleted!"
              })
              this.$nextTick( () => this.$refs.vuetable.refresh())
            } else {
              this.showErrorMsg({
                title: "Error",
                message: "Something went wrong."
              })
            }
          })

        } else {

          axios({
            method: 'delete',
            url: `https://media.evercam.io/v2/cameras/${data.exid}?api_id=${data.sharer_api_id}&api_key=${data.sharer_api_key}&email=${data.sharee_email}`,
            data: {
            }
          }).then(response => {
            if (response.status == 200) {
              this.showSuccessMsg({
                title: "Success",
                message: "Camera Share has been deleted!"
              })
              this.$nextTick( () => this.$refs.vuetable.refresh())
            } else {
              this.showErrorMsg({
                title: "Error",
                message: "Something went wrong."
              })
            }
          })
        }
      }
    }
  }
}
</script>