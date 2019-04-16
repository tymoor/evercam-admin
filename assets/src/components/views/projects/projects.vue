<template>
  <div class="explain-menu">
    <div>
      <v-project-filters />
    </div>
    <div>
      <v-add-project />
      <v-update-project :showUpdateProject="showUpdateProject" :projectData="projectData" />
    </div>

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
      <div class="handle">
        <vuetable ref="vuetable"
          api-url="/v1/projects"
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
          <div slot="project-actions" slot-scope="props">
            <i class="edit icon pointer-cursor" @click="editProject($event, props.rowData)"></i>&nbsp;&nbsp;<i class="trash icon pointer-cursor" @click="deleteProject($event, props.rowData)"></i>
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
  .pointer-cursor {
    cursor: pointer;
  }
</style>

<script>
  import FieldsDef from "./FieldsDef.js";
  import TableWrapper from "./TableWrapper.js";
  import ProjectFilters from "./project_filters";
  import UpdateProject from "./update_project";
  import AddProject from "./add_project";

  export default {
    components: {
      "v-project-filters": ProjectFilters,
      "v-update-project": UpdateProject,
      "v-add-project": AddProject
    },
    data: () => {
      return {
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
        paginationComponent: "vuetable-pagination",
        fields: FieldsDef,
        showUpdateProject: false,
        projectData: {},
        moreParams: {},
        ajaxWait: false,
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
      this.$events.$on('hide-update-project', e => this.onHideUpdateProject(e))
      this.$events.$on('project-added', e => this.onProjectAdded())
    },
    methods:{

      editProject(e, data) {
        this.showUpdateProject = true,
        this.projectData = data;
      },

      onHideUpdateProject(e) {
        this.$nextTick( () => this.$refs.vuetable.refresh())
        this.showUpdateProject = false,
        this.projectData = null;
      },

      deleteProject(e, data) {
        if (window.confirm("Are you sure to delete this project?\nIt will also remove reference of this project from cameras.")) {
          this.ajaxWait = true
          this.$http.delete(`/v1/projects`, {params: {project_exid: data.exid}}).then(response => {
            this.$nextTick( () => this.$refs.vuetable.refresh())
            this.showSuccessMsg({
              title: "Success",
              message: "Project has been deleted."
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
      },

      onProjectAdded () {
        this.$nextTick( () => this.$refs.vuetable.refresh())
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