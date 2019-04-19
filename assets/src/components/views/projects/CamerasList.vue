<template>
  <div>
    <div v-if="showCamerasList">
      <transition name="modal">
       <div class="modal modal-mask" style="display: block;">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h3 class="modal-title">
                {{this.projectData.name}} Cameras
              </h3>
            </div>
            <div class="modal-body">
              <div id="tb_camera_list" :class="['vuetable-wrapper ui basic segment', loading]">
                <div class="handle">
                  <vuetable ref="vuetable"
                    :api-url="apiURL"
                    :fields="fields"
                    pagination-path=""
                    data-path="data"
                    :per-page="perPage"
                    :sort-order="sortOrder"
                    :append-params="moreParams"
                    @vuetable:initialized="onInitialized"
                    @vuetable:loading="showLoader"
                    @vuetable:loaded="hideLoader"
                    :css="css.table"
                  >
                    <div slot="cameras-list-action" slot-scope="props">
                      <i class="trash icon pointer-cursor" @click="deleteCameraFromProject($event, props.rowData)"></i>
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

              <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-primary" @click="hideCamerasListModal()"> Close </button>
            </div>
          </div>
        </div>
      </div>
      </transition>
    </div>
  </div>
</template>

<style scoped>
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
  width: 95%;
  max-width: 100%;
  margin-top: 114.5px;
}

.modal-body .cntry {
  text-align: left;
}
.perPage-margin {
  margin-top: 5px;
}
#tb_camera_list {
  padding: 0;
}
#tb_camera_list .vuetable-pagination {
  display: none;
}
#tb_camera_list .vuetable-body-wrapper {
  overflow-x: hidden;
}
</style>

<script>
import jQuery from 'jquery'
import TableWrapper from "./TableWrapper.js";
import CamerasListFieldDef from "./CamerasListFieldDef.js";

  export default {
    props: ["showCamerasList", "projectData"],
    data: () => {
      return {
        apiURL: "/v1/project_cameras",
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
        fields: CamerasListFieldDef,
        ajaxWait: false,
        errors: []
      }
    },

    watch: {
      projectData() {
        if (this.projectData != null) {
          this.moreParams = {project_id: this.projectData.id};
        }
      }
    },

    methods: {

      showLoader() {
        this.loading = "loading";
      },

      hideLoader() {
        this.loading = "";
      },

      hideCamerasListModal (e) {
        this.moreParams = {};
        this.$events.fire("hide-cameras-list-modal", false);
      },

      deleteCameraFromProject(e, data) {
        if (window.confirm("Are you sure to delete camera from project?")) {
          this.ajaxWait = true
          this.$http.delete(`/v1/camera_from_project`, {params: {camera_id: data.id}}).then(response => {
            this.$nextTick( () => this.$refs.vuetable.refresh())
            this.showSuccessMsg({
              title: "Success",
              message: "Camera deletedfrom project."
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
      }
    }
  }
</script>