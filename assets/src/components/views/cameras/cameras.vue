<template>
  <div>
    <div class="overflow-forms">
      <camera-filters :selectedCameras="selectedCameras" />
    </div>
    <div>
      <button class="btn btn-secondary mb-1 project_finished" type="button" @click="onFinishProject()"><i class="fa fa-check-circle"></i> Status</button>
      <add-to-project :selectedCameras="selectedCameras" />
      <camera-show-hide :vuetable-fields="vuetableFields" />
    </div>

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
    <div v-if="showModal">
      <transition name="modal">
       <div class="modal modal-mask" style="display: block;">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h3 class="modal-title">
                Change Cameras Status
              </h3>
            </div>
            <div class="modal-body">
              <select class="form-control" v-model="cameraStatus">
                <option value="online">Online</option>
                <option value="project_finished">Project Finished</option>
              </select>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-primary" @click="changeCameraStatus()"> Change </button>
              <button type="button" class="btn btn-primary" @click="closeChangeCameraStatus()"> Close </button>
            </div>
          </div>
        </div>
      </div>
      </transition>
    </div>

    <v-horizontal-scroll />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/cameras"
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
            <input type="checkbox" v-model="selectedCameras" :value="props.rowData" />
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

.ui.compact.icon.button {
  padding: 5px;
  cursor: pointer;
}

.pointer-set {
  cursor: pointer;
}

.project_finished {
  margin-top: -35px;
  float: right;
  margin-right: 167px;
}

.modal-mask {
   position: fixed;
   z-index: 9998;
   top: 0;
   left: 0;
   width: 100%;
   height: 100%;
   background-color: rgba(0, 0, 0, .5);
   display: table;
   transition: opacity .3s ease;
}

.modal-dialog {
  width: 15%;
  max-width: 100%;
  margin-top: 114.5px;
}

#api-wait {
  left: 50%;
  position: fixed;
  top: 50%;
  z-index: 99999;
}

</style>

<script>
import FieldsDef from "./FieldsDef.js"
import TableWrapper from "./TableWrapper.js"
import AddToProject from "./add_to_project"
import CameraFilters from "./camera_filters"
import CameraShowHide from "./cameras_show_hide"
import axios from "axios"

export default {
  components: {
    AddToProject, CameraFilters, CameraShowHide
  },
  data: () => {
    return {
      selectedCameras: [],
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      showAddToProject: false,
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
      showModal: false,
      cameraStatus: "project_finished",
      ajaxWait: false
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
    this.$events.$on('camera-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('cameras-deleted', e => this.onCamerasDelete(e))
    this.$events.$on('hide-add-to-project', e => this.onHideAddToProject(e))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "username": filters.username,
        "password": filters.password,
        "camera_exid": filters.camera_exid,
        "camera_name": filters.camera_name,
        "camera_owner": filters.camera_owner,
        "camera_ip": filters.camera_ip,
        "model": filters.model,
        "vendor": filters.vendor
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onHideAddToProject(e) {
      this.$nextTick( () => this.$refs.vuetable.refresh())
      this.selectedCameras = []
    },

    onCamerasDelete (e) {
      this.selectedCameras = []
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

    onFinishProject() {

      if (this.selectedCameras == undefined || Object.keys(this.selectedCameras).length === 0) {
        this.showWarnMsg({
          title: "Warning",
          message: "At least select one Camera!"
        });
      } else {

        this.showModal = true
      }
    },

    changeCameraStatus() {
      this.ajaxWait = true
      axios({
        method: 'post',
        url: "/v1/project_finished",
        data: {
          cameras: this.selectedCameras,
          status: this.cameraStatus
        }
      }).then(response => {
        if (response.status == 200) {
          this.showInfoMsg({
            title: "Info",
            message: `Updated status to project finished for these Cameras. This will take a minute to affect.`
          });
          this.selectedCameras = []
          this.$nextTick( () => this.$refs.vuetable.refresh())
          this.ajaxWait = false
          this.showModal = false
          this.cameraStatus = "project_finished"
        } else {
          this.showErrorMsg({
            title: "Error",
            message: "Something went wrong."
          })
        }
      })
    },

    closeChangeCameraStatus() {
      this.showModal = false;
      this.selectedCameras = []
      this.ajaxWait = false
      this.showModal = false
      this.cameraStatus = "project_finished"
    }
  }
}
</script>