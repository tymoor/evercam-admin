<template>
  <div>

    <div>
      <div class="row cameras-filter_css">
        <form>
          <div class="form-row">
            <div class="col-0.5 search-label">
              <label class="control-label">Year :</label>
            </div>
            <div class="col">
              <select v-model="year" @change="storageYearChange" class="form-control">
                <option value="2015">2015</option>
                <option value="2016">2016</option>
                <option value="2017">2017</option>
                <option value="2018">2018</option>
                <option value="2019">2019</option>
                <option value="all">All</option>
              </select>
            </div>
            <div class="col-6">
              <select v-model="owner" @change="selectedCameras" class="form-control">
                <option value="13959">Construction</option>
                <option value="109148">Non Construction</option>
                <option value="-1">All</option>
              </select>
            </div>
          </div>
        </form>
      </div>
    </div>

    <v-horizontal-scroll />

    <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]" v-show="year == 'all'">
      <div class="handle">
        <vuetable ref="vuetable"
          :api-mode="false"
          :fields="all_year"
          pagination-path="pagination"
          :per-page="perPage"
          :data-manager="dataManagerAll"
          @vuetable:pagination-data="onPaginationData"
          @vuetable:initialized="onInitialized"
          @vuetable:loading="showLoader"
          @vuetable:loaded="hideLoader"
          :css="css.table"
        >
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div>
          <button class="button-margin btn btn-light" @click="refreshJsonData($event)"><i class="fa fa-refresh" aria-hidden="true"></i></span> Refresh Data</button>
        </div>
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

    <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]" v-show="year != 'all'">
      <div class="handle">
        <vuetable ref="vuetables"
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
        </vuetable>
      </div>
      <div class="vuetable-pagination ui bottom segment grid">
        <div>
          <button class="button-margin btn btn-light" @click="refreshJsonData($event)"><i class="fa fa-refresh" aria-hidden="true"></i></span> Refresh Data</button>
        </div>
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
  width: 85%;
}

#table-wrapper {
  margin-top: 1px;
}

#api-wait {
  left: 50%;
  position: fixed;
  top: 50%;
  z-index: 99999;
}

.email-template {
  cursor: pointer;
}

.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}

.button-margin {
  margin-top: 9px
}

</style>

<script>
import FieldsDef from "./FieldsDef.js";
import FieldsDefYear from "./FieldsDefYear.js";
import TableWrapper from "./TableWrapper.js";
import Jquery from "jquery";
import axios from "axios";
import _ from "lodash";

export default {
  data: () => {
    return {
      loading: "",
      perPage: 1000,
      css: TableWrapper,
      moreParams: {},
      paginationComponent: "vuetable-pagination",
      fields: FieldsDef,
      all_year: FieldsDefYear,
      data: [],
      completeData: [],
      completeDataYear: [],
      filtered: [],
      allYearFiltered: [],
      orgData: [],
      yearData: [],
      ajaxWait: true,
      year: "all",
      owner: "13959"
    }
  },
  watch: {
    data(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetables.setData(this.data);
      });
    },
    filtered(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetables.setData(this.filtered);
      });
    },
    allYearFiltered(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.setData(this.allYearFiltered);
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
    axios.get("/v1/storage").then(response => {
      this.orgData = response.data.data;
      this.yearData = this.formatDataWithAllYear(response.data.data);

      let filteredData = this.orgData.filter(d => {
        for (let name in d) {
          if ((d[name] + '').toLowerCase().indexOf(this.owner.toLowerCase()) > -1){
            return d;
          }
        }
      })
      this.allYearFiltered = this.formatDataWithAllYear(filteredData);
      this.ajaxWait = false;
    });
  },

  updated() {
    document.addEventListener("resize", this.setScrollBar());
  },

  methods: {

    selectedCameras() {
      if (this.year == "all") {
        // handle full table only right now
        if (this.owner == "-1") {
          this.allYearFiltered = this.yearData;
        } else {
          let filteredData = this.orgData.filter(d => {
            for (let name in d) {
              if ((d[name] + '').toLowerCase().indexOf(this.owner.toLowerCase()) > -1){
                return d;
              }
            }
          })
          this.allYearFiltered = this.formatDataWithAllYear(filteredData);
        }
      }

      if (this.year != "all") {
        if (this.owner == "-1") {
          this.filtered = this.formatDataWithYear(this.orgData);
        } else {
          let filteredData = this.orgData.filter(d => {
            for (let name in d) {
              if ((d[name] + '').toLowerCase().indexOf(this.owner.toLowerCase()) > -1){
                return d;
              }
            }
          })
          this.filtered = this.formatDataWithYear(filteredData);
        }
      }
    },

    refreshJsonData(event) {
      event.preventDefault();
      if (window.confirm("Are you sure you want to do this? \nThis should be clicked once in 3 or 4 months?")) {
        axios.get(`${this.$root.api_url}/v2/storage/stats`).then(response => {
          this.showSuccessMsg({
            title: "Success",
            message: "This may take a while, Please sit back and relax!"
          });
        });
      }
    },

    formatDataWithAllYear(cameras) {
      let months_chars = {
        "01":"jan",
        "02":"feb",
        "03":"mar",
        "04":"apr",
        "05":"may",
        "06":"jun",
        "07":"jul",
        "08":"aug",
        "09":"sep",
        "10":"oct",
        "11":"nov",
        "12":"dec"
      }
      var obj = cameras.map(({years, ...obj}) => {
          for(var year in years) {
              var months = years[year];
              for(var i in months_chars) {
                  console.log(months)
                  months.includes(i) ? obj[year + "-" + months_chars[i]] = 1 : obj[year + "-" + months_chars[i]] = 0
              }
          }
          return obj;
      });
      return obj;
    },

    formatDataWithYear(cameras) {
      let months_chars = {
        "01":"jan",
        "02":"feb",
        "03":"mar",
        "04":"apr",
        "05":"may",
        "06":"jun",
        "07":"jul",
        "08":"aug",
        "09":"sep",
        "10":"oct",
        "11":"nov",
        "12":"dec"
      }
      let year = this.year;
      var obj = cameras.map(({years, ...obj}) => {
        var months = years[year]
        for(var i in months_chars) {
          months.includes(i) ? obj[months_chars[i]] = 1 : obj[months_chars[i]] = 0
        }
        return obj
      });
      return obj;
    },

    storageYearChange () {
      this.ajaxWait = true;
      if (this.year != 'all') {
        let filteredData;
        if (this.owner == "-1") {
          filteredData = this.orgData;
        } else {
          filteredData = this.orgData.filter(d => {
            for (let name in d) {
              if ((d[name] + '').toLowerCase().indexOf(this.owner.toLowerCase()) > -1){
                return d;
              }
            }
          })
        }
        this.data = this.formatDataWithYear(filteredData);
      } else {
        if (this.owner == "-1") {
          this.allYearFiltered = this.yearData;
        } else {
          let filteredData = this.orgData.filter(d => {
            for (let name in d) {
              if ((d[name] + '').toLowerCase().indexOf(this.owner.toLowerCase()) > -1){
                return d;
              }
            }
          })
          this.allYearFiltered = this.formatDataWithAllYear(filteredData);
        }
      }
      this.ajaxWait = false;
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

    dataManagerAll(sortOrder, pagination) {
      if (this.yearData.length < 1) return;

      let local = this.yearData;

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
    }
  }
}
</script>